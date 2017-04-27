pkg=c("rvest", "tidyverse", "ggmap", "leaflet", "jpeg")
sapply(pkg, require, character=T)


# Step 1: Locaton and Foodtype info to base url address
url_interest=function(FOODTYPE="", LOCATION="Des Moines, IA"){
  LOCATION=gsub(" ", "\\+", LOCATION)
  initial_url="https://www.yelp.com/search?find_desc=FOODTYPE&find_loc=LOCATION"
  initial_url=sub("FOODTYPE", FOODTYPE, initial_url)
  initial_url=sub("LOCATION", LOCATION, initial_url)
  return(initial_url)
}

ea.url='//div [@class="arrange_unit page-option"]//a [@class="available-number pagination-links_anchor"]'

url_interest() %>% 
  read_html() %>%
  html_nodes(xpath=ea.url)%>% 
  html_attr(name="href") %>% 
  paste0("https://www.yelp.com",.) %>%
  c(url_interest(), .) ->urls # Note multiple pages of url generated



# Step 2: Base url addresses to multiple restaurant info under specific location and foodtype from step 1
ea.paths=c(ea.name='//li [@class="regular-search-result"]//a [@class="biz-name js-analytics-click"]',
           ea.price='//li [@class="regular-search-result"]//span [@class="business-attribute price-range"]',
           ea.cat='//li [@class="regular-search-result"]//span [@class="category-str-list"]',
           ea.address='.//address',
           ea.star='//li [@class="regular-search-result"]//div [@class="biz-rating biz-rating-large clearfix"]')

## Basic info of a single page from Step 1
basic_info=function(url_address){
  ## If No entry,  a problem row number different. Should fix it to "NA" if no entry...
  ## e.g. url_interest=function(FOODTYPE="", LOCATION="Des+Moines,\\+IA") >>> urls[9]
  Base=lapply(ea.paths, function(x) html_nodes(read_html(url_address), xpath=x))
  sapply(1:length(Base), function(x) length(Base[[x]])) %>% min -> Min_m
  ## Fix this part later.
  Base=lapply(1:length(Base), function(x) Base[[x]][1:Min_m])
  names(Base)<-c("ea.name", "ea.price", "ea.cat", "ea.address", "ea.star")
  
  rest_name=Base$ea.name %>% html_text()
  
  rest_star=Base$ea.star %>% sub(".*title=\"([\\.0-9]+) .*", "\\1", .)
  
  rest_url=Base$ea.name%>% 
    html_attr(name="href") %>% 
    paste0("https://www.yelp.com",.)
  
  rest_price=Base$ea.price %>% html_text()
  
  rest_cat=Base$ea.cat %>% html_text() %>% gsub("\n {2,}", "", .)
  
  rest_address=Base$ea.address %>%
    html_text() %>%
    gsub("\n +", "",.)
  
  return(cbind.data.frame(name=rest_name, rating=rest_star, price=rest_price, Address=rest_address, category=rest_cat, webpage=rest_url, stringsAsFactors=F))
}

get_basic_info=function(n, urls){
lapply(urls[1:n], basic_info) %>% do.call("rbind",.) -> b_output  # Loop over multiple page from Step 1.
b_output$Address%>%
  data.frame(address=.,stringsAsFactors=F) %>%
  mutate_geocode(.,address) %>%
  cbind(b_output, .) %>%
  return() 
}


basic_info_combined=function(FOODTYPE, LOCATION, n=1){
  save_this=url_interest(FOODTYPE, LOCATION)
  save_this %>%
    read_html() %>%
    html_nodes(xpath=ea.url)%>% 
    html_attr(name="href") %>% 
    paste0("https://www.yelp.com",.) %>%
    c(save_this, .) ->urls
  if(n<=length(urls)){get_basic_info(n,urls) %>%
      return()
  } else {get_basic_info(length(urls), urls) %>%
      return()
    }
}

# ptm <- proc.time()
# get_basic_info(9, urls) -> Basic_data
# saveRDS(Basic_data, "../Data/example/Basic.rds")
# proc.time()-ptm
