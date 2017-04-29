# Setup

pkg=c("tidyverse", "ggmap", "shiny", "leaflet", "DT")
sapply(pkg, require, character=T)
source("../Code/step1n2.r")
source("../Code/step3.r")
source("../Code/photo.r")
'%!in%' <- function(x,y)!('%in%'(x,y))

# Server
shinyServer(function(input, output, session) {
  
#####################################################################################################################  
##################################################   Main page Starts here   ########################################
#####################################################################################################################

  Data_filter=eventReactive(list(input$search,input$refresh),{
    # do.call(file.remove, list(list.files("../Data/temp/image", full.names = TRUE)))
    if(input$refresh==F){
      if(input$Near==""){
        basic_info_combined(input$Find,"Ames, IA",n=1) %>%
          data.frame(stringsAsFactors=F)
      } else {basic_info_combined(input$Find,input$Near,n=1)%>%
          data.frame(stringsAsFactors=F)
      }
    } else{ #if(is.na(input$refresh)!=T){
      if(input$location==""){
        basic_info_combined(input$interest,"Ames, IA",n=1) %>%
          data.frame(stringsAsFactors=F) %>%
          filter(price %in% (input$price))
      } else {basic_info_combined(input$interest,input$location,n=1)%>%
          data.frame(stringsAsFactors=F) %>%
          filter(price %in% (input$price))
      }
    }
  })
# Read-in data ends here

#####################################################################################################################  
#################################################   Table output Starts here   ######################################
#####################################################################################################################

  output$table1 = DT::renderDataTable(
    Data_filter()%>% 
      select(name, rating, price), server = TRUE)
  
  x1=reactiveValues()
  x1$data=integer()
  observe({
    if(!is.null(input$table1_rows_selected)){
      input$table1_rows_selected
      isolate({
        x1$data <- input$table1_rows_selected
        x1$data <- as.vector(x1$data)
      })
    }
  })
  output$otext2=renderPrint(x1$data)

  
#####################################################################################################################  
#################################################   Map output Starts here   ########################################
#####################################################################################################################

  output$map <-renderLeaflet({
    Data_filter() %>%
      leaflet() %>%
      addTiles()%>%
      fitBounds(~min(lon), ~min(lat), ~max(lon), ~max(lat)) %>%
      addAwesomeMarkers(popup=Data_filter() %>% .[,1], icon=awesomeIcons(icon = 'cutlery', library = 'glyphicon', markerColor = 'blue'), options = popupOptions(closeButton = T))
  }) #addAwesomeMarkers
  
  observeEvent(input$table1_rows_selected,{
    Data_filter()%>%
      .[x1$data,] %>%
      leafletProxy("map",data=.) %>%
      addAwesomeMarkers(popup=Data_filter() %>% .[x1$data,1], icon=awesomeIcons(icon = 'cutlery', library = 'glyphicon', markerColor = 'red'))
    # popup=Data_filter()%>%filter(id)%>%select(id==x1$data),
  })
  
##########################################################################
  data <- reactiveValues(clickedMarker=NULL, check=NULL)
  observeEvent(input$map_marker_click,{
    data$clickedMarker <- input$map_marker_click
    print(data$clickedMarker)}
  )
  observeEvent(input$map_click,{
    data$clickedMarker <- NULL
    print(data$clickedMarker)})

  
#####################################################################################################################  
#################################################   Review Block Starts here   ######################################
#####################################################################################################################  

  Specific_data=eventReactive(input$table1_rows_selected,{
    Data_filter() %>% 
      .[x1$data,6] %>%
      specific_info()
  })

  output$rest_name=renderText({paste0("<font size=\"6\">", Data_filter() %>% .[x1$data,1],"</font>")})
  
  output$reviews=renderTable(Specific_data() %>% .$Recommended_Reviews, align='ccc')
  
  output$phone=renderText({paste0("<font size=\"3\"><span class=\"glyphicon glyphicon-earphone\" aria-hidden=\"true\"></span> Phone ", Specific_data() %>% .$Phone, "</font>")})
  
  output$price=renderText({paste0("<font size=\"3\"> Price Range  <b>", Specific_data() %>% .$Price_range, "</b></font>")})
  
  output$hours_title=renderText({"<font color=\"#FF0000\", size=\"5\"><b>Hours</b></font>"})
  output$hours=renderTable(Specific_data() %>% .$Hours)
  
  output$m_info_title=renderText({"<font color=\"#FF0000\", size=\"5\"><b>More Business Info</b></font>"})
  output$m_info=renderTable(Specific_data() %>% .$More_info)
# End Review Block

#####################################################################################################################  
#################################################   Image Block Starts here   #######################################
#####################################################################################################################

  observeEvent(input$table1_rows_selected,{
    Data_filter() %>% 
      .[x1$data,6] %>%
      get_images()
  })
  
  vars=reactiveValues(counter = 1)
  observe({
    if(!is.null(input$Next)){
      input$Next
      isolate({
        vars$counter <- vars$counter + 1
      })
    }
  })
  observe({
    if(!is.null(input$Prev)){
      input$Prev
      isolate({
        vars$counter <- vars$counter - 1
      })
    }
  })
  output$myImage <- renderImage({
      filename <- normalizePath(file.path(paste0('../Data/temp/', abs(vars$counter), '.jpg'))) #'../Data/temp/1.jpg'
      list(src = filename, 
           contentType = 'image/jpg',
           alt = paste("Image number"),
           style="display: block; margin-left: auto; margin-right: auto;"
      )
  }, deleteFile = FALSE)
# Image Block Ends


  
  
# Close for Server  
})
