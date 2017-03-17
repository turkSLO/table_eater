library(shiny)
shinyUI(bootstrapPage(
  titlePanel("Table Eater"),
  sidebarLayout(
    sidebarPanel(
      textInput("url", NULL, placeholder = "URL address of table(s)"),
      actionButton("submitURL", "Submit")
    ),
    mainPanel(
      column(2,actionButton("goLeft", NULL,icon("arrow-left"))),
      column(2,textOutput("position")),
      column(2,actionButton("goRight", NULL,icon("arrow-right"))),
      HTML("</br>"),
      HTML("</br>"),
      HTML("</br>"),
      htmlOutput("tableOut"),
      selectInput("tablesChosen", NULL, NULL, multiple = T),
      actionButton("invertSel", "Invert Selection"),
      actionButton("dCSV","Download CSV"),
      actionButton("dTXT","Download TXT")
    )
  ),
  tags$script(
    type = "text/javascript",
    paste0("
      $(document).ready(function(){
        Shiny.addCustomMessageHandler('alert',function(msg) {
          alert(msg);
        });
      });"
    )
  )
))