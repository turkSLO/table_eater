library(shiny)
shinyUI(bootstrapPage(
  HTML("<!--<div class='overlay-back'></div>
       <div class='overlay' style='display:none;'>
        <span>Tutorial</span></br>
        <span id='guide-content'>Please place *this* is the text zone on the left and press submit.</span>
       </div>-->
       <center>"),
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
 # tags$style(HTML("
 #   overlay-back {
 #       position   : absolute;
 #       top        : 0;
 #       left       : 0;
 #       width      : 100%;
 #       height     : 100%;
 #       background : #000;
 #       opacity    : 0.6;
 #        filter     : alpha(opacity=60);
 #        z-index    : 5;
 #        display    : none;
 #    }
 # 
 #    overlay {
 #        position : absolute;
 #        top      : 0;
 #        left     : 0;
 #        width    : 100%;
 #        height   : 100%;
 #        z-index  : 10;
 #        display  : none;
 #    }"
 #  )),
  tags$script(
    type = "text/javascript",
    paste0("
      $(document).ready(function(){
        Shiny.addCustomMessageHandler('alert',function(msg) {
          alert(msg);
        });
        //if(localStorage contains the thing) {
        //  $('$url').addClass('overlay');
        //  $('overlay, overlay-back').fadeIn(500);
        //}
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