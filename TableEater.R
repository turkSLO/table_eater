library(RCurl)
library(tools)
library(stringr)
TableEater <- function (url, type=c("csv","txt")) {
  if (type[1] == "csv") {
    sep <- ","
  } else {
    sep <- " "
  }
  page <- getURL(url)
  page <- str_replace_all(page,regex("<span.*sortkey.*?span>",ignore_case = T),"")
  #page <- gsub("<(\\w+).*?>","<\\1>",page,ignore.case = T)
  page <- str_replace_all(page,"(\\s{2,}|\n)","")
  tableraw <- strsplit(page,"<table.*?>")[[1]][-1]
  #initial clean
  badtable <- c()
  for(i in 1:length(tableraw)) {
    tableraw[i] <- strsplit(tableraw[i],"</table>")[[1]][1]
    tableraw[i] <- gsub("<((/|)t(head|body)|tr).*?>","",tableraw[i],ignore.case = T)
  }
  #actual work
  for(i in 1:length(tableraw)) {
    row <- strsplit(tableraw[i],"</tr>")[[1]]
    rowspan <- list()
    for(j in 1:length(row)) {
      thd <- str_match_all(row[j],regex("<t(h|d).*?>",ignore_case = T))[[1]][,1]
      thd.cs <- str_match_all(thd,regex("colspan=\"(\\d+)\"",ignore_case = T))
      thd.rs <- str_match_all(thd,regex("rowspan=\"(\\d+)\"",ignore_case = T))
      elem <- strsplit(row[j],"</t(h|d)>")[[1]]
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
        if(type[1] == "csv" && grepl(",",elem[k])) {
          elem[k] <- paste0('"',elem[k],'"')
        }
        if(type[1] == "txt" && grepl("\\s",elem[k])) {
          elem[k] <- str_replace_all(str_to_title(elem[k]),"\\s","")
        }
        if(copied.elem) {
          elem[k] <- paste(rep(rowspan[[copied.elem]][4],times=as.numeric(rowspan[[copied.elem]][3])),elem[k],sep = sep,collapse = sep)
          if (as.numeric(rowspan[[copied.elem]][2]) - 1 == 0)
            rowspan[[copied.elem]] <- NULL
          else
            rowspan[[copied.elem]][2] <- as.numeric(rowspan[[copied.elem]][2])-1
        }
        if(colspan > 1) {
          elem[k] <- paste0(rep(elem[k],times=colspan),collapse = sep)
        }
        if(length(thd.rs[[k]]))
          rowspan <- c(rowspan,list(c(k,as.numeric(thd.rs[[k]][,2])-1,colspan,elem[k])))
      }
      row[j] <- paste0(elem, collapse = sep)
    }
    tableraw[i] <- paste0(row, collapse = "\n")
    tableraw[i] <- gsub("</?.+?>","",tableraw[i])
    if(nchar(tableraw[i]) == 0)
      badtable <- c(badtable, i)
  }
  if(length(badtable))
    tableraw <- tableraw[-badtable]
  for(i in 1:length(tableraw)) {
    sink(paste0(gsub("http(s|)://([a-zA-Z.]+)/.*","\\2",url),"~",i,".",type[1]))
    cat(tableraw[i])
    sink()
  }
}