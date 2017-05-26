library(shiny)
shinyUI(bootstrapPage(
  #Creating the basic things for the tutorial
  HTML("<div class='overlay-back'></div>
       <div class='overlay'>
        <center><span style='color:white; font-weight: bold; font-size: 48px;'>Tutorial</span></center></br>
        <button id='exit-guide' class='btn btn-default' type='button'>Exit Tutorial</button>
        <span id='guide-content' style='position:fixed; color:white; font-size: 18px' />
       </div>
       <center>"),
  titlePanel("Table Eater"),
  HTML("</center>"),
  sidebarLayout(
    sidebarPanel(
      textInput("url", NULL, placeholder = "URL address of table(s)"),
      actionButton("submitURL", "Submit"),
      #If there's no table, then we have no reason for preview controls
      conditionalPanel(condition="output.tableOut",
                       HTML("</br><center>"),
                       column(4,actionButton("goLeft", NULL,icon("arrow-left"))),
                       column(4,textOutput("position")),
                       column(4,actionButton("goRight", NULL,icon("arrow-right"))),
                       HTML("</center></br></br>")
      ),
      #If no tables are picked, we don't need a download button
      conditionalPanel(condition="output.tableOut",
                       conditionalPanel(condition="input.tablesChosen",
                                        HTML("<center>"),
                                        actionButton("invertSel", "Invert Selection"),
                                        downloadButton("dCSV","Download CSV"),
                                        downloadButton("dTXT","Download TXT"),
                                        HTML("</center>")
                       ),
                       selectInput("tablesChosen", "Select Tables:", NULL, multiple = T)
      ),
      #Contribution section
      HTML("</br><div align='right' style='font-size:10px;'>Shiny app by Brandon Turk</br>
           Base R code by Brandon Turk</br>
           Shiny source files: <a href='https://github.com/turkSLO/table_eater'>Github</a></div>")
    ),
    mainPanel(
      HTML("<div class='well'><center>"),
      h4("Tables"),
      htmlOutput("tableOut"),
      HTML("</center></div>")
    )
  ),
  HTML("
    <button id='enter-guide' class='btn btn-default' type='button'>Enter Tutorial</button>
  "),
  #CSS and JS used for tutorial as well as the alert system
  tags$head(
    tags$style(HTML("
      .overlay-back {
        position   : fixed;
        top        : 0;
        left       : 0;
        width      : 100%;
        height     : 100%;
        background : #000;
        opacity    : 0.6;
        filter     : alpha(opacity=60);
        z-index    : 5;
        display    : none;
      }

      .overlay {
        position : fixed;
        top      : 0;
        left     : 0;
        width    : 100%;
        height   : 100%;
        z-index  : 10;
        display  : none;
      }

      .guided {
        z-index  : 11;
      }
                    
      #exit-guide {
        position : fixed;
        bottom   : 10px;
        right    : 10px;
        z-index  : 11;
      }
      #enter-guide {
        position : fixed;
        bottom   : 10px;
        right    : 10px;
        z-index  : 0;
      }"
  )),
  tags$script(
    type = "text/javascript",
    HTML("
      $(document).ready(function(){
        Shiny.addCustomMessageHandler('alert',function(msg) {
          alert(msg);
        });
        if(localStorage.firstTime !== 'false') {
           $('.overlay, .overlay-back').each(function(){$(this).toggle();});
           firstTime.next($('.col-sm-4'), 'Please insert:</br>' +
            '<input type=\"text\" style=\"width:575px; color:black;\" value=\"https://en.wikipedia.org/wiki/List_of_current_United_States_Senators\" /></br>' +
            'into the bar on the left and press Submit.</br></br></br></br>'+
            '<center><h3>Purpose and Limitations</h3></center></br>'+
            'There are data tables online everywhere that lack simple ways to retrieve them.</br>' +
            'This Shiny App was designed for the purpose of taking those tables and ripping them into a file that is commonly used for data management programs and statistical software.' +
            'However, even this app has its shortcomings.' +
            'This app cannot clean the data for you, it just gives you what it sees on the webpage and does its best to create a properly formatted data file.' +
            'So you should always check the data table you download carefully for any weirdness that might have been hidden away by the web designer.</br>' +
            'There are other limitations of this app and they are:</br>' +
            '<ul>'+
            '<li>The table cannot be something you have to search up to have appear. (Tables must be static on the page.)</li>' +
            '<li>Web pages must be accessible to anyone. (There cannot be a login page that the tables are hidden behind.)</li>' +
            '<li>The tables must use standard HTML formatting. (Some web designers makes things that are not tables, look like tables.)</li>' +
            '</ul>', 'right');
        }
        $('#exit-guide').click(function(){
          $('.overlay, .overlay-back').each(function(){$(this).toggle();});
          localStorage.firstTime = false;
          firstTime.clean();
        });
        $('#enter-guide').click(function(){
          $('.overlay, .overlay-back').each(function(){$(this).toggle();});
          localStorage.firstTime = true;
          firstTime.next($('.col-sm-4'), 'Please insert:</br>' +
            '<input type=\"text\" style=\"width:575px; color:black;\" value=\"https://en.wikipedia.org/wiki/List_of_current_United_States_Senators\" /></br>' +
            'into the bar on the left and press Submit.</br></br></br></br>'+
            '<center><h3>Purpose and Limitations</h3></center></br>'+
            'There are data tables online everywhere that lack simple ways to retrieve them.</br>' +
            'This Shiny App was designed for the purpose of taking those tables and ripping them into a file that is commonly used for data management programs and statistical software.' +
            'However, even this app has its shortcomings.' +
            'This app cannot clean the data for you, it just gives you what it sees on the webpage and does its best to create a properly formatted data file.' +
            'So you should always check the data table you download carefully for any weirdness that might have been hidden away by the web designer.</br>' +
            'There are other limitations of this app and they are:</br>' +
            '<ul>'+
            '<li>The table cannot be something you have to search up to have appear. (Tables must be static on the page.)</li>' +
            '<li>Web pages must be accessible to anyone. (There cannot be a login page that the tables are hidden behind.)</li>' +
            '<li>The tables must use standard HTML formatting. (Some web designers makes things that are not tables, look like tables.)</li>' +
            '</ul>', 'right');
        });
        $('#submitURL').click(function(){
          if(localStorage.firstTime !== 'false' && /https:\\/\\/en\\.wikipedia\\.org\\/wiki\\/List_of_current_United_States_Senators/.test($('#url').val())) {
            firstTime.next($('.col-sm-8'), 'On the right will populate the tables located within that page.</br>' +
              '<button id=\"continue\" class=\"btn btn-default\" type=\"button\">Continue</button>', 'left');
          }
        });
        $('#guide-content').on('click','#continue',function(){
         firstTime.next($('.col-sm-4'), 'Using the arrow buttons above, you can preview the tables within the page.</br>' +
          'With the empty bar below, you can select which tables you wish to download.</br>' +
          'After selecting one or more tables, more buttons appear:</br>' +
          'You can choose to invert the selection (pick the opposite of what you had selected).</br>' +
          'You can choose to download the tables in CSV format.</br>' +
          'You can choose to download the tables in TXT format.</br></br>' +
          'This is the end of the tutorial. To close, hit the button on the bottom right.', 'bottom');
        $('.col-sm-8').addClass('guided');
         });
        $('#guide-content').on('click','input:text',function(){
         $(this).select();
         });
      });
      $('#url').keydown(function(event){
        if (event.which == 13) {
          event.preventDefault();
          $('#submitURL').trigger('click');
        }
      });
      var firstTime = {
        next:
          function(el,str, loc) {
            var pos, top, left;
            if(firstTime.el != null)
              firstTime.el.removeClass('guided');
            el.addClass('guided');
            pos = el.offset();
            if (loc == 'bottom') {
              left = pos.left > 0 ? pos.left : 10;
              top = pos.top + el.outerHeight()+30;
            } else if (loc == 'right') {
              top = pos.top;
              left = pos.left + el.outerWidth();
            } else {
              top = pos.top;
              left = 10;
            }
            $('#guide-content').html(str).css({top: top+'px', left: left+'px'});
            firstTime.el = el;
          },
        clean: function() {
          $('.guided').each(function(){$(this).removeClass('guided');});
        },
        el: null
      }
    ")
  ))
))