library(rvest)
library(RCurl)
library(tools)
library(stringr)
library(utils)
library(shiny)
shinyServer(function(input, output, session) {
  #Reactive data to be shared back and forth with the UI
  data <- reactiveValues(url=NULL, tables=NULL, selected=NULL, showing=0, ntables=0, name = NULL)
  #On submitting the URL, it sets out to create both types of tables as well as checking for malformed urls or missing tables
  observeEvent(input$submitURL,{
    #Progress bar so people understand that things are in fact happening
    withProgress(message = "Analysing site", value=0, {
      if(url.exists(input$url)) {
        incProgress(.5, detail = "Cleaning Tables")
        #Detect missing "http" in front of link
        #Save the URL so that changes only take effect on submit
        if(!str_detect(input$url,"^https?://")) {
          data$url <- str_c("https://",input$url)
        } else {
          data$url <- input$url
        }
        badURL <- F
        tryCatch({
          #Begin the function for building the tables
          data$tables <- TableEater(data$url)
        }, warning = function(w) {
          session$sendCustomMessage(type = "alert", "No Tables Found")
          badURL <<- T
        }, error = function(e) {
          session$sendCustomMessage(type = "alert", "No Tables Found")
          badURL <<- T
        })
        if(badURL) {
          setProgress(1)
          return()
        }
        #Simple filenames from url
        data$name <- str_replace_all(data$url,"https?://([a-zA-Z.]+)/.*","\\1")
        #Keep the number of total tables saved for easy reference
        data$ntables <- length(data$tables[[2]])
        #Update the list of choices for downloading
        updateSelectInput(session, "tablesChosen", choices = 1:data$ntables)
        #Display the tables
        output$tableOut <- renderUI({
          HTML(data$tables[[1]][1])
        })
        data$showing <- 1
        #Display position in previewed table list
        output$position <- renderText(str_c(data$showing,"/",data$ntables))
        setProgress(1)
      } else {
        setProgress(1)
        session$sendCustomMessage(type = "alert", "Bad URL")
      }
    })
  })
  #Preview the previous table
  observeEvent(input$goLeft,{
    if(data$showing>1) {
      data$showing <- data$showing - 1
      output$position <-renderText(str_c(data$showing,"/",data$ntables))
      output$tableOut <- renderUI({
        HTML(data$tables[[1]][data$showing])
      })
    }
  })
  #Preview the next table
  observeEvent(input$goRight,{
    if(data$showing<data$ntables) {
      data$showing <- data$showing + 1
      output$position <-renderText(str_c(data$showing,"/",data$ntables))
      output$tableOut <- renderUI({
        HTML(data$tables[[1]][data$showing])
      })
    }
  })
  #Save list of tables selected for downloading
  observeEvent(input$tablesChosen,{
    data$selected <- input$tablesChosen
  })
  #Inverse the selection of the user's selected tables (In case you happened to want all but one table)
  observeEvent(input$invertSel,{
    data$selected <- (1:data$ntables)[-as.numeric(data$selected)]
    updateSelectInput(session, "tablesChosen", selected = data$selected)
  })
  #CSV Downloader
  output$dCSV <- downloadHandler(filename = function(){
    #If more than one selected table, download as zip, else just a single csv
    if(length(as.numeric(data$selected))>1) str_c(data$name,".zip") else str_c(data$name,".csv")}, 
    content = function(file) {
      #reduce the list down to only the user's selected tables
      t <- data$tables$csv[as.numeric(data$selected)]
      if (length(t) > 1) {
        for(i in 1:length(t)) {
          #USe "sink" to convert the tables into csv files
          sink(str_c(data$name,"~",data$selected[i],".csv"))
          cat(t[i])
          sink()
        }
        #Requires zip installed on the server through command line
        zip(file, str_c(data$name,"~",data$selected,".csv"))
        for(i in 1:length(t))
          unlink(str_c(data$name,"~",data$selected[i],".csv"))
      } else {
        sink(file)
        cat(t)
        sink()
      }
    })
  #TXT Downloader (Same as above)
  output$dTXT <- downloadHandler(filename = function(){if(length(as.numeric(data$selected))>1) str_c(data$name,".zip") else str_c(data$name,".txt")}, content = function(file) {
    t <- data$tables$txt[as.numeric(data$selected)]
    if (length(t) > 1){
      for(i in 1:length(t)) {
        sink(str_c(data$name,"~",data$selected[i],".txt"))
        cat(t[i])
        sink()
      }
      zip(file, str_c(data$name,"~",data$selected,".txt"))
      for(i in 1:length(t))
        unlink(str_c(data$name,"~",data$selected[i],".txt"))
    } else {
      sink(file)
      cat(t)
      sink()
    }
  })
})

TableEater <- function (url) {
  sep <- c(","," ")
  #Read in the webpage with rvest
  page <- read_html(url)
  #Remove hidden data within tables
  page <- str_replace_all(page,regex("<span.*sortkey.*?span>",ignore_case = T),"")
  page <- str_replace_all(page,regex("(?:.(?!<\\w+))+display:\\s*none.+?</\\s*\\w+>",ignore_case = T),"")
  #Remove extra spaces
  page <- str_replace_all(page,"(\\s{2,}|\n)","")
  #Separate the string by individual tables skipping the first section since it's nothing
  tableraw <- str_split(page,"<table.*?>",simplify = T)[1,-1]
  #Remove the nonsense between the tables
  tableraw <- str_split(tableraw,"</table>",simplify = T)[,1]
  badtable <- c()
  #Basic recreation of table with current HTML for previewing
  tables <- list(orig = str_c("<table>",tableraw,"</table>"))
  tables$csv <- tables$txt <- tableraw
  #Remove the useless tags
  tableraw <- str_replace_all(tableraw,regex("<((/|)t(head|body)|tr).*?>",ignore_case = T),"")
  #Remove &nbsp;
  tableraw <- str_replace_all(tableraw,intToUtf8(160),"")
  #Start cleaning individual tables
  for(i in 1:length(tableraw)) {
    #Split the table by rows
    row <- str_split(tableraw[i],"</tr>",simplify = T)[1,]
    #Check the final entry in the table if it is empty
    if(!str_length(row[length(row)]))
      length(row) <- length(row) - 1
    rowCSV <- rowTXT <- row
    #rowspan is a list of which elements of a table spanned multiple rows
    #it has to be located outside of the following loop so that it keeps
    #the data between rows
    rowspan <- list()
    for(j in 1:length(row)) {
      #Break apart rows by individual elements
      thd <- str_match_all(row[j],regex("<t(h|d).*?>",ignore_case = T))[[1]][,1]
      thd.cs <- str_match_all(thd,regex("colspan=\"(\\d+)\"",ignore_case = T))
      thd.rs <- str_match_all(thd,regex("rowspan=\"(\\d+)\"",ignore_case = T))
      elem <- str_split(row[j],"</t(h|d)>",simplify = T)[1,]
      if(!str_length(elem[length(elem)]))
        length(elem) <- length(elem) - 1
      elemCSV <- elemTXT <- elem
      for(k in 1:length(elem)) {
        #Check to see if the element spans multiple columns
        colspan <- if(length(thd.cs[[k]])) as.numeric(thd.cs[[k]][,2]) else 1
        copied.elem <- 0
        #Check to see if there is any elements that span to this row
        if(length(rowspan)) {
          iter <- 1
          while(!copied.elem && iter <= length(rowspan)) {
            if(k == as.numeric(rowspan[[iter]][1]))
              copied.elem <- iter
            iter <- iter+1
          }
        }
        #Check if there's any quotes inside the element and solve the issue for CSV
        if(str_detect(elem[k],'(?<=>).*\"'))
          elemCSV[k] <- str_replace_all(elemCSV[k], '\"', '\"\"')
        if(str_detect(elemCSV[k],'(?<=>).*(,|\"\")'))
          elemCSV[k] <- str_c('"',str_trim(elemCSV[k]),'"')
        #Check if there's any spaces inside the element and solve the issue for TXT
        if(str_detect(elem[k],"\\s"))
          elemTXT[k] <- str_replace_all(str_to_title(elemTXT[k]),"\\s","")
        #If the data spans multiple columns, duplicate it
        if(colspan > 1) {
          elemCSV[k] <- str_c(rep(elemCSV[k],times=colspan),collapse = sep[1])
          elemTXT[k] <- str_c(rep(elemTXT[k],times=colspan),collapse = sep[2])
        }
        #If there's an element supposed to be spanned to this position, place them in front
        if(copied.elem) {
          elemCSV[k] <- str_c(rep(rowspan[[copied.elem]][4],times=as.numeric(rowspan[[copied.elem]][3])),elem[k],sep = sep[1],collapse = sep[1])
          elemTXT[k] <- str_c(rep(rowspan[[copied.elem]][5],times=as.numeric(rowspan[[copied.elem]][3])),elem[k],sep = sep[2],collapse = sep[2])
          #Decrement the number of rows needed to be spanned to, if it hits 0, delete it
          if (as.numeric(rowspan[[copied.elem]][2]) - 1 == 0)
            rowspan[[copied.elem]] <- NULL
          else
            rowspan[[copied.elem]][2] <- as.numeric(rowspan[[copied.elem]][2])-1
        }
        #If the element spans multiple rows save it in the rowspan variable
        # list( the position of the element, the number of rows it has to span still, 
        #       the number of columns it has to span, the CSV-coded elem, the TXT-coded elem )
        if(length(thd.rs[[k]]) && as.numeric(thd.rs[[k]][,2]) > 1)
          rowspan <- c(rowspan,list(c(k,as.numeric(thd.rs[[k]][,2])-1,colspan,elemCSV[k],elemTXT[k])))
      }
      #put it all back together
      rowCSV[j] <- str_c(elemCSV, collapse = sep[1])
      rowTXT[j] <- str_c(elemTXT, collapse = sep[2])
    }
    tables$csv[i] <- str_c(rowCSV, collapse = "\n")
    tables$txt[i] <- str_c(rowTXT, collapse = "\n")
    tables$csv[i] <- str_replace_all(tables$csv[i],"</?.+?>","")
    tables$txt[i] <- str_replace_all(tables$txt[i],"</?.+?>","")
    #empty tables are bad
    if(str_length(tables$csv[i]) == 0)
      badtable <- c(badtable, i)
  }
  #Delete the bad
  if(length(badtable)) {
    tables$orig <- tables$orig[-badtable]
    tables$csv <- tables$csv[-badtable]
    tables$txt <- tables$txt[-badtable]
  }
  return(tables)
}