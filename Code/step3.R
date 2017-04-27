pkg=c("rvest", "tidyverse", "ggmap", "leaflet", "jpeg")
sapply(pkg, require, character=T)

# Step 3: From a list of restaurant webpage urls, extract a specific restaurant info.
paths2=c(ea.phone='//span [@class="biz-phone"]',
         ea.hour='//table [@class="table table-simple hours-table"]',
         ea.review='//div [@class="review-content"]',
         ea.price_range='//dd [@class="nowrap price-description"]',
         ea.feature='//div [@class="short-def-list"]')

specific_info=function(a_single_restaurant_url){

  Base2=lapply(paths2, function(x) html_nodes(read_html(a_single_restaurant_url), xpath=x))
  
  # phone number
  Base2$ea.phone %>% html_text() %>% gsub("\n {2,}", "", .)->Phone
  
  # hour
  Base2$ea.hour %>%  html_table() %>% .[[1]] %>% data.frame() -> Hours
  names(Hours)<-c("Day","Time", "Available")
  # html_nodes(., xpath='.//tr')
  
  # Review text
  path_review=c(star='.//div [@title]', date='.//span [@class="rating-qualifier"]', text='.//p')
  get_review_contents=function(Base2ea.review){
    path_review_list=lapply(path_review, function(x) html_nodes(Base2ea.review, xpath=x))
    
    cbind.data.frame(star=path_review_list$star %>% sub(".*title=\"([.0-9]+) star.*", "\\1", .),
                     posted=path_review_list$date %>% html_text() %>% gsub("\n {2,}", "", .),
                     text=path_review_list$text %>% html_text(), stringsAsFactors=F) %>% 
      return()
  }
  Base2$ea.review %>% get_review_contents() -> User_reviews
  
  #price
  Base2$ea.price_range %>% html_text() %>% gsub("\n {2,}", "", .) ->Price
  
  # feature
  path_feature=c(feature='.//dt', availability=".//dd")
  get_more_info=function(Base2ea.feature){
    get_feature=lapply(path_feature, function(x) html_nodes(Base2ea.feature, xpath=x))
    
    cbind.data.frame(`More Information`=get_feature$feature %>% html_text %>% gsub("\n {2,}", "", .), 
                     Answer=get_feature$availability %>% html_text %>% gsub("\n {2,}", "", .),
                     stringsAsFactors=F) %>% 
      return()
  }
  Base2$ea.feature %>% get_more_info() ->More_info
  
  list(Phone=Phone, Hours=Hours, Recommended_Reviews=User_reviews, Price_range=Price, More_info=More_info) %>% 
    return()
}

# lapply(Basic_data$webpage, function(x) specific_info(x)) ->Specific
# saveRDS(Specific, "../Data/example/Specific.rds")
# Example
# Basic_data=readRDS("../Data/example/Basic.rds")
# Basic_data$webpage[1] %>%specific_info() -> EXample
# EXample$Recommended_Reviews[1,3]
