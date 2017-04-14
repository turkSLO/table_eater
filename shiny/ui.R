library(shiny)
shinyUI(bootstrapPage(
  HTML("<center>"),
  titlePanel("Table Eater"),
  HTML("</center>"),
  sidebarLayout(
    sidebarPanel(
      textInput("url", NULL, placeholder = "URL address of table(s)"),
      actionButton("submitURL", "Submit"),
      conditionalPanel(condition="output.tableOut",
                       HTML("</br><center>"),
                       column(4,actionButton("goLeft", NULL,icon("arrow-left"))),
                       column(4,textOutput("position")),
                       column(4,actionButton("goRight", NULL,icon("arrow-right"))),
                       HTML("</center></br></br>")
      ),
      conditionalPanel(condition="output.tableOut",
                       conditionalPanel(condition="input.tablesChosen",
                                        HTML("<center>"),
                                        actionButton("invertSel", "Invert Selection"),
                                        downloadButton("dCSV","Download CSV"),
                                        downloadButton("dTXT","Download TXT"),
                                        HTML("</center>")
                       ),
                       selectInput("tablesChosen", "Select Tables:", NULL, multiple = T)
      )
    ),
    mainPanel(
      HTML("<div class='well'><center>"),
      h4("Tables"),
      htmlOutput("tableOut"),
      HTML("</center></div>")
    )
  ),
  tags$script(
    type = "text/javascript",
    paste0("
      $(document).ready(function(){
        Shiny.addCustomMessageHandler('alert',function(msg) {
          alert(msg);
        });
      });
      $('#url').keydown(function(event){
        if (event.which == 13) {
          event.preventDefault();
          $('#submitURL').trigger('click');
        }
      });"
    )
  )
))