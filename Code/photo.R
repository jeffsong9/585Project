get_images=function(url){
  # Erase all image files if any
  do.call(file.remove, list(list.files("../Data/temp", full.names = TRUE)))
  
  # Get urls were the photos are stored
  photo_url=gsub("/biz/", "/biz_photos/", url)
  path='//li [@data-photo-id]//img'
  photo_url %>% 
    read_html() %>%
    html_nodes(xpath=path) %>%
    html_attr(name="src")-> photo_urls
  n=length(photo_urls)
  
  # download files
  sapply(1:n, function(i) download.file(photo_urls[i], paste0("../Data/temp/", i,".jpg"), mode="wb", quiet = T))
}

