library(rvest)
library(RCurl)
library(tools)
library(stringr)
library(utils)
library(shiny)
shinyServer(function(input, output, session) {
  data <- reactiveValues(url=NULL, tables=NULL, selected=NULL, showing=0, ntables=0, name = NULL)
  observeEvent(input$submitURL,{
    withProgress(message = "Analysing site", value=0, {
      if(url.exists(input$url)) {
        incProgress(.5, detail = "Cleaning Tables")
        data$url <- input$url
        badURL <- F
        tryCatch({
          data$tables <- TableEater(data$url)
        }, warning = function(w) {
          session$sendCustomMessage(type = "alert", "No Tables Found")
          badURL <<- T
        }, error = function(e) {
          session$sendCustomMessage(type = "alert", "No Tables Found")
          badURL <<- T
        })
        if(badURL) {
          return()
        }
        data$name <- str_replace_all(data$url,"http(s|)://([a-zA-Z.]+)/.*","\\2")
        data$ntables <- length(data$tables[[2]])
        updateSelectInput(session, "tablesChosen", choices = 1:data$ntables)
        output$tableOut <- renderUI({
          HTML(data$tables[[1]][1])
        })
        data$showing <- 1
        output$position <- renderText(str_c(data$showing,"/",data$ntables))
        setProgress(1)
      } else {
        setProgress(1)
        session$sendCustomMessage(type = "alert", "Bad URL")
      }
    })
  })
  observeEvent(input$goLeft,{
    if(data$showing>1) {
      data$showing <- data$showing - 1
      output$position <-renderText(str_c(data$showing,"/",data$ntables))
      output$tableOut <- renderUI({
        HTML(data$tables[[1]][data$showing])
      })
    }
  })
  observeEvent(input$goRight,{
    if(data$showing<data$ntables) {
      data$showing <- data$showing + 1
      output$position <-renderText(str_c(data$showing,"/",data$ntables))
      output$tableOut <- renderUI({
        HTML(data$tables[[1]][data$showing])
      })
    }
  })
  observeEvent(input$tablesChosen,{
    data$selected <- input$tablesChosen
  })
  observeEvent(input$invertSel,{
    data$selected <- (1:data$ntables)[-as.numeric(data$selected)]
    updateSelectInput(session, "tablesChosen", selected = data$selected)
  })
  output$dCSV <- downloadHandler(filename = function(){if(length(as.numeric(data$selected))>1) str_c(data$name,".zip") else str_c(data$name,".csv")}, content = function(file) {
    t <- data$tables$csv[as.numeric(data$selected)]
    if (length(t) > 1) {
      for(i in 1:length(t)) {
        sink(str_c(data$name,"~",data$selected[i],".csv"))
        cat(t[i])
        sink()
      }
      zip(file, str_c(data$name,"~",data$selected,".csv"))
      for(i in 1:length(t))
        unlink(str_c(data$name,"~",data$selected[i],".csv"))
    } else {
      sink(file)
      cat(t)
      sink()
    }
  })
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
  #### END ####
  #On URL change, delete files
  #On session end, delete current URL files (if any)
  #session$onSessionEnded(clearfiles(session$ns("name")))
  #unlink(zipname and all the individual tables)
  ### Do I even need to do this? ###
})

TableEater <- function (url) {
  sep <- c(","," ")
  page <- read_html(url)
  page <- str_replace_all(page,regex("<span.*sortkey.*?span>",ignore_case = T),"")
  page <- str_replace_all(page,regex("(?:.(?!<\\w+))+display:\\s*none.+?</\\s*\\w+>",ignore_case = T),"")
  page <- str_replace_all(page,"(\\s{2,}|\n)","")
  tableraw <- str_split(page,"<table.*?>",simplify = T)[1,-1]
  #initial clean
  badtable <- c()
  tableraw <- str_split(tableraw,"</table>",simplify = T)[,1]
  tables <- list(orig = str_c("<table>",tableraw,"</table>"))
  tables$csv <- tables$txt <- tableraw
  tableraw <- str_replace_all(tableraw,regex("<((/|)t(head|body)|tr).*?>",ignore_case = T),"")
  #actual work
  for(i in 1:length(tableraw)) {
    row <- str_split(tableraw[i],"</tr>",simplify = T)[1,]
    if(!str_length(row[length(row)]))
      length(row) <- length(row) - 1
    rowCSV <- rowTXT <- row
    rowspan <- list()
    for(j in 1:length(row)) {
      thd <- str_match_all(row[j],regex("<t(h|d).*?>",ignore_case = T))[[1]][,1]
      thd.cs <- str_match_all(thd,regex("colspan=\"(\\d+)\"",ignore_case = T))
      thd.rs <- str_match_all(thd,regex("rowspan=\"(\\d+)\"",ignore_case = T))
      elem <- str_split(row[j],"</t(h|d)>",simplify = T)[1,]
      if(!str_length(elem[length(elem)]))
        length(elem) <- length(elem) - 1
      elemCSV <- elemTXT <- elem
      for(k in 1:length(elem)) {
        colspan <- if(length(thd.cs[[k]])) as.numeric(thd.cs[[k]][,2]) else 1
        copied.elem <- 0
        if(length(rowspan)) {
          iter <- 1
          while(!copied.elem && iter <= length(rowspan)) {
            if(k == as.numeric(rowspan[[iter]][1]))
              copied.elem <- iter
            iter <- iter+1
          }
        }
        if(str_detect(elem[k],'(?<=>)\\\"'))
          elemCSV[k] <- str_replace_all(elemCSV[k], '\\\"', '\"\"')
        if(str_detect(elem[k],'(?<=>).*(,|\\\"\\\")'))
          elemCSV[k] <- str_c('"',str_trim(elemCSV[k]),'"')
        if(str_detect(elem[k],"\\s"))
          elemTXT[k] <- str_replace_all(str_to_title(elemTXT[k]),"\\s","")
        if(copied.elem) {
          elemCSV[k] <- str_c(rep(rowspan[[copied.elem]][4],times=as.numeric(rowspan[[copied.elem]][3])),elem[k],sep = sep[1],collapse = sep[1])
          elemTXT[k] <- str_c(rep(rowspan[[copied.elem]][5],times=as.numeric(rowspan[[copied.elem]][3])),elem[k],sep = sep[2],collapse = sep[2])
          if (as.numeric(rowspan[[copied.elem]][2]) - 1 == 0)
            rowspan[[copied.elem]] <- NULL
          else
            rowspan[[copied.elem]][2] <- as.numeric(rowspan[[copied.elem]][2])-1
        }
        if(colspan > 1) {
          elemCSV[k] <- str_c(rep(elemCSV[k],times=colspan),collapse = sep[1])
          elemTXT[k] <- str_c(rep(elemTXT[k],times=colspan),collapse = sep[2])
        }
        if(length(thd.rs[[k]]) && as.numeric(thd.rs[[k]][,2]) > 1)
          rowspan <- c(rowspan,list(c(k,as.numeric(thd.rs[[k]][,2])-1,colspan,elemCSV[k],elemTXT[k])))
      }
      rowCSV[j] <- str_c(elemCSV, collapse = sep[1])
      rowTXT[j] <- str_c(elemTXT, collapse = sep[2])
    }
    tables$csv[i] <- str_c(rowCSV, collapse = "\n")
    tables$txt[i] <- str_c(rowTXT, collapse = "\n")
    tables$csv[i] <- str_replace_all(tables$csv[i],"</?.+?>","")
    tables$txt[i] <- str_replace_all(tables$txt[i],"</?.+?>","")
    if(str_length(tables$csv[i]) == 0)
      badtable <- c(badtable, i)
  }
  if(length(badtable)) {
    tables$orig <- tables$orig[-badtable]
    tables$csv <- tables$csv[-badtable]
    tables$txt <- tables$txt[-badtable]
  }
  return(tables)
}