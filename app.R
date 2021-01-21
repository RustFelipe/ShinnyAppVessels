library(shiny)
library(shiny.semantic)
library(leaflet)
source("selectModule.R")

ships <- read.csv(file = "ships.csv", header = TRUE, sep = ",", dec = ".")
#App

menu_content <- list(
  list(name = "Vessels movement overview ", link = "https://github.com/RustFelipe/ShinyAppVessels", icon = "ship"),
  list(name = "", link = "https://drive.google.com/file/d/1IeaDpJNqfgUZzGdQmR6cz2H3EQ3_QfCV/view", icon = "database"))

ui <- semanticPage(tags$head(
  tags$style(
    "body{
    background: #ededed;
        }"
    )
  ),
  horizontal_menu(menu_content),
    segment(selectModule("")),
      cards(
        class = "one",
        card(div(class = "map"),
             leafletOutput("map"))),
      cards(
        class = "one",
           card(
             class = "orange",
             align = "center",
             div(class = "content",
             tags$style(HTML("#text {font-size:22px;
             color: black;}")),
             textOutput("text")
                 )
             )
        )
  )
    
server <-  function(input, output, session){
  
 react <- reactive({
    df <- ships[ships$ship_type == input$type & ships$SHIPNAME == input$ship,]
    df
  })
  
  observe(
    {
    updateSelectInput(session, "ship", choices = unique(as.character(ships[ships$ship_type == input$type, ]$SHIPNAME)))
      }
    )
  output$map <- renderLeaflet({
    map <- leaflet(ships) %>% addProviderTiles(providers$Stamen.TonerLite)
    map <- map %>% setView(17.92, 57.72, zoom = 5)  %>%
      addCircleMarkers(lng = react()$LON, lat = react()$LAT, radius = 7, 
                       color= "#1E90FF", stroke = T, fillOpacity = 7) %>%
      addCircleMarkers(lng = react()$lonFinal, lat = react()$latFinal, radius = 7, 
                       color= "#db9200", stroke = T, fillOpacity = 7)
    map    
    })
  output$text <- renderText ({
    paste("The vessel", react()$SHIPNAME, "sailed", react()$finalDistance, "meters")
    
  })
  
}
shinyApp(ui, server)