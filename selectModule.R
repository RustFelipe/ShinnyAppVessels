selectModule <- function(id) {
  cards(
  class = "two",
  card(class = "blue",
       size = 10, 
       div(div(class = "header", "Select vessel type:"),
           class = "content",
           selectInput(
             inputId = "type",
             label = "",
             choices = unique(as.character(ships$ship_type)),
             selected = "Cargo")
       )
  ),
  card(class = "blue",
       div(class = "content",
           div(class = "header", "Select vessel name:"),
           selectInput(inputId = "ship",
                       label = "",
                       choices = unique(as.character(ships$SHIPNAME))
                       )
           )
       )
  )
}