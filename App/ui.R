
# Setup
pkg=c("tidyverse", "ggmap", "shiny", "leaflet", "DT")
sapply(pkg, require, character=T)


# UI
shinyUI(
  
  fluidPage( #style="padding-top: 80px;",
    
    conditionalPanel(condition = "input.search<1",
      absolutePanel(
        div(img(src=paste0(sample(1:3,1),'.jpg'), width = "1392px", height = "783px"))
        # imageOutput("preImage")
      ),
      absolutePanel(top="200px", left="650px",
                    div(img(src="Relp3.png", height = 100, width = 200))
      ),
      absolutePanel(top="300px", left="500px",
        fluidRow(
          column(width=5,
                 HTML("<div style='background-color: transparent; font-size: 20px; width: 350px; height=10px; color: white;'>"), #text-align: center;  check css
                 selectizeInput(inputId = "Find", label="Find", choices = c("Restaurant", "Bars", "Delivery"), selected="Restaurant", options = list(placeholder = 'Please select an option below')), #onInitialize = I('function() {this.setValue(""); }'))),
                 HTML("</div>")
          ),
          column(width=5,
                 HTML("<div style='background-color: transparent; font-size: 20px; width: 300px; color: white;'>"),
                 textInput(inputId = "Near", label = "Near", placeholder = "Ames, IA"),
                 HTML("</div>")
          ),
          column(width=2,
                 HTML("<div style='padding-top: 33px;'>"),
                 actionButton(inputId = "search",label="", icon = icon("search", lib = "glyphicon"), style="color: white; background-color: red; border-color: red;", width="50px", height="200px"),# padding:25px;font-size:100%;")
                 HTML("</div>")
          )
        ),# close the first fluidRow

        fluidRow(
          column(width=3,
                 actionButton(inputId = "Restaurant",label="Restaurant", icon = icon("cutlery", lib = "glyphicon"), style="color: white; background-color: transparent; border-color: transparent")
          ),
          column(width=3,
                 actionButton(inputId = "Nightlife",label="Nightlife", icon = icon("glass", lib = "glyphicon"), style="color: white;background-color: transparent; border-color: transparent")
          ),
          column(width=3,
                 actionButton(inputId = "Home Service",label="Home Service", icon = icon("wrench", lib = "glyphicon"), style="color: white;background-color:transparent; border-color: transparent")
          ),
          column(width=3,
                 actionButton(inputId = "Delivery",label="Delivery", icon = icon("truck"), style="color: white; background-color: transparent; border-color: transparent")
          )
        )# close the second fluidRow
      )# close abs panel
    ),# close conditional panel
#####################################################################################################################  
##################################################   Main page Starts here   ########################################
#####################################################################################################################
    conditionalPanel(condition = "input.search",
      # Title Name
      titlePanel(div(img(src="Relp3.png", height = 100, width = 200))),
      
      # Side Panel
      fixedPanel(
        
        ## Text input for Location
        textInput(inputId = "location", label = h3("Near"), placeholder = "Ames, IA"),
        
        ## Text input for Food type
        selectizeInput(inputId = "interest", label="Find", choices = c("Restaurant", "Bars", "Delivery"), selected="Restaurant", options = list(placeholder = 'Please select an option below')),
      
        ## Button that refreshes input
        actionButton(inputId = "refresh",label = "Refresh", icon = icon("refresh", lib = "glyphicon")),
      
        ## Button that allows to do filter input
        actionButton(inputId = "filter",label = "Filters", icon = icon("filter", lib = "glyphicon"))
        
      ),# Close fixedPanel
      
      # Loading message
      conditionalPanel(paste("input.search > 0 &&", "$('html').hasClass('shiny-busy')"),
            absolutePanel(top = 110, left = 1140, width = 300,
              img(src="busy.gif", height = 300, width = 300)
            ),
            absolutePanel(top = 110, left = 420,
              img(src="Ad_here.png", height = 400, width = 680)
            )
        ),# Close conditionalPanel

      # Filter Panel
      fixedPanel(top = "400px",
        conditionalPanel(condition = "input.filter",
                       
          # Price filter
          checkboxGroupInput("price","Choose Price:",
                             choiceNames =list(div(icon("usd"), "Inexpensive"), div(icon("usd"),icon("usd"), "Moderate"), div(icon("usd"),icon("usd"),icon("usd"), "Pricey"), div(icon("usd"),icon("usd"),icon("usd"),icon("usd"), "Ultra High-End")),
                             choiceValues =list("$", "$$", "$$$", "$$$$"),
                             selected=c("$", "$$", "$$$", "$$$$")
                             
          )# Close checkboxGroupInput
        )# Close conditionalPanel
      ),# Close fixedPanel
    
      # Main Panel
      absolutePanel(top = 20, left = 400, width = 1040,
        navbarPage("Applications",
                   
          # 1st panel: Map and Data Table
          tabPanel("Map", icon = icon("globe", lib = "glyphicon"),
              ## Map output
              absolutePanel(width = 700,
                br(size=10),
                leafletOutput("map"),
                br(size=20),
                DT::dataTableOutput('table1')
              )# Close absolute
          ),# close the 1st tabPanel 
          
          # 2nd Panel: Review Panel
          tabPanel("Reviews", icon = icon("pencil", lib = "glyphicon"),
            
            htmlOutput('rest_name'),
            
            # abs review start
            absolutePanel(width=700,
              br(size=5),
              tableOutput('reviews')
            ),# abs reivew end
            
            # abs info start        
            absolutePanel(left=750,
              htmlOutput('phone'),
              br(size=5),
              htmlOutput('price'),
              br(size=5),
              htmlOutput('hours_title'),
              tableOutput('hours'),
              br(size=5),
              htmlOutput('m_info_title'),
              tableOutput('m_info')
            )# abs info closed
          ),# close the 2nd tabPanel
          
          # 3rd Panel: Photo Panel
          tabPanel("Photos", icon = icon("camera", lib = "glyphicon"),
            absolutePanel(width = 700,
              fluidRow(
                column(2,
                  actionButton(inputId = "Prev", label = "Previous", icon = icon("menu-left", lib = "glyphicon"))
                ),
                column(8,
                  imageOutput("myImage")
                ),
                column(2,
                  actionButton(inputId = "Next", label = "Next", icon = icon("menu-right", lib = "glyphicon"))
               )
              )# Close fluidRow
            )# close the abs panel
          )# close  the 3rd tabPanel
        )# navbarPage
      )# Close the absolute panel
    )# Close conditional panel: search
#####################################################################################################################
######################################################  End of Main Page  ###########################################
#####################################################################################################################
  )# Close Fluid page
)# Close for UI

