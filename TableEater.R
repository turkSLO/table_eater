library(curl)
library(tools)
TableEater <- function (url, type=c("csv","txt")) {
  page <- curl(url, "r")
  line <- 0
  tableraw <- c()
  tables <- c()
  pos <- c()
  found <- F
  if (type[1] == "csv") {
    sep <- ","
  } else {
    sep <- " "
  }
  while(length(x <- readLines(page, n=1))) {
    if (grepl("<table",x,ignore.case = T)) {
      line <- line+1
      found <- T
      pos <- c(pos,line)
    }
    if (found) {
      line <- line+1
      tableraw <- c(tableraw,x)
    }
    if (grepl("</table",x,ignore.case = T)) {
      found <- F
    }
  }
  close(page)
  for(x in 1:length(tableraw)) {
    tableraw[x] <- gsub("<td .*>","<td>",
        gsub("<th .*>","<th>",
        gsub("<tr .*>","<tr>",
        gsub("<thead .*>","<thead>",
        gsub("<table .*>","<table>",
             tableraw[x],ignore.case = T),
        ignore.case = T),ignore.case = T),
        ignore.case = T),ignore.case = T)
    if(type[1] == "csv" && grepl(",",tableraw[x])) {
      tableraw[x] <- paste0("\"",gsub("</t(h|d)>","\"</t\\1>",tableraw[x],ignore.case = T))
    }
    if(type[1] == "txt" && grepl("\\s",tableraw[x])) {
      tableraw[x] <- gsub("\\s","",toTitleCase(tableraw[x]))
    }
  }
  if (length(pos)==1) {
    tables <- c(tables,paste0(tableraw,collapse = ""))
  } else {
    for(x in 1:length(pos)) {
      start <- pos[x]
      end <- if(x+1 <= length(pos)) pos[x+1]-1 else length(tableraw)
      tables <- c(tables,paste0(tableraw[start:end],collapse = ""))
    }
  }
  for(x in 1:length(tables)) {
    tables[x] <- gsub("<(/|)\\w+>","",
                    gsub(paste0(sep,"</tr>"),"\n",
                    gsub("</t(h|d)>",sep,
                    gsub("<((/|)t(able|head|body)|tr|td|th)>","",
                    tables[x],ignore.case = T),ignore.case = T),ignore.case = T),ignore.case = T)
    sink(paste0(gsub("http(s|)://([a-zA-Z.]+)/.*","\\2",url),"~",x,".",type[1]))
    cat(tables[x])
    sink()
  }
}