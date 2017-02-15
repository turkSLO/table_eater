library(RCurl)
library(tools)
TableEater <- function (url, type=c("csv","txt")) {
  if (type[1] == "csv") {
    sep <- ","
  } else {
    sep <- " "
  }
  page <- getURL(url)
  page <- gsub("<(\\w+).*?>","<\\1>",page,ignore.case = T)
  page <- gsub("(\\s{2,}|\n)","",page)
  tableraw <- strsplit(page,"<table?>")[[1]][-1]
  #initial clean
  badtable <- c()
  for(i in 1:length(tableraw)) {
    tableraw[i] <- strsplit(tableraw[i],"</table>")[[1]][1]
    tableraw[i] <- gsub("<((/|)t(able|head|body)|tr|td|th)>","",tableraw[i],ignore.case = T)
    if(nchar(tableraw[i]) == 0)
      badtable <- c(badtable, i)
  }
  if(length(badtable))
    tableraw <- tableraw[-badtable]
  #actual work
  for(i in 1:length(tableraw)) {
    row <- strsplit(tableraw[i],"</tr>")[[1]]
    for(j in 1:length(row)) {
      elem <- strsplit(row[j],"</t(h|d)>")[[1]]
      for(k in 1:length(elem)) {
        if(type[1] == "csv" && grepl(",",elem[k])) {
          elem[k] <- paste0('"',elem[k],'"')
        }
        if(type[1] == "txt" && grepl("\\s",elem[k])) {
          elem[k] <- gsub("\\s","",toTitleCase(elem[k]))
        }
      }
      row[j] <- paste0(elem, collapse = sep)
    }
    tableraw[i] <- paste0(row, collapse = "\n")
    tableraw[i] <- gsub("<(/|).+?>","",tableraw[i])
  }
  for(i in 1:length(tableraw)) {
    sink(paste0(gsub("http(s|)://([a-zA-Z.]+)/.*","\\2",url),"~",i,".",type[1]))
    cat(tableraw[i])
    sink()
  }
}