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
  page <- str_replace_all(page,"(\\s{2,}|\n)","")
  tableraw <- str_split(page,"<table.*?>",simplify = T)[1,-1]
  #initial clean
  badtable <- c()
  tableraw <- str_split(tableraw,"</table>",simplify = T)[,1]
  tableraw <- str_replace_all(tableraw,regex("<((/|)t(head|body)|tr).*?>",ignore_case = T),"")
  #actual work
  for(i in 1:length(tableraw)) {
    row <- str_split(tableraw[i],"</tr>",simplify = T)[1,]
    #row <- strsplit(tableraw[i],"</tr>")[[1]]
    if(!str_length(row[length(row)]))
      length(row) <- length(row) - 1
    rowspan <- list()
    for(j in 1:length(row)) {
      thd <- str_match_all(row[j],regex("<t(h|d).*?>",ignore_case = T))[[1]][,1]
      thd.cs <- str_match_all(thd,regex("colspan=\"(\\d+)\"",ignore_case = T))
      thd.rs <- str_match_all(thd,regex("rowspan=\"(\\d+)\"",ignore_case = T))
      elem <- str_split(row[j],"</t(h|d)>",simplify = T)[1,]
      if(!str_length(elem[length(elem)]))
        length(elem) <- length(elem) - 1
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
        if(type[1] == "csv" && str_detect(elem[k],'(?<=>)\\\"'))
          elem[k] <- str_replace_all(elem[k], '\\\"', '\"\"')
        if(type[1] == "csv" && str_detect(elem[k],'(?<=>).*(,|\\\"\\\")')) {
          elem[k] <- str_c('"',str_trim(elem[k]),'"')
        }
        if(type[1] == "txt" && str_detect(elem[k],"\\s")) {
          elem[k] <- str_replace_all(str_to_title(elem[k]),"\\s","")
        }
        if(copied.elem) {
          elem[k] <- str_c(rep(rowspan[[copied.elem]][4],times=as.numeric(rowspan[[copied.elem]][3])),elem[k],sep = sep,collapse = sep)
          if (as.numeric(rowspan[[copied.elem]][2]) - 1 == 0)
            rowspan[[copied.elem]] <- NULL
          else
            rowspan[[copied.elem]][2] <- as.numeric(rowspan[[copied.elem]][2])-1
        }
        if(colspan > 1) {
          elem[k] <- str_c(rep(elem[k],times=colspan),collapse = sep)
        }
        if(length(thd.rs[[k]]) && as.numeric(thd.rs[[k]][,2]) > 1)
          rowspan <- c(rowspan,list(c(k,as.numeric(thd.rs[[k]][,2])-1,colspan,elem[k])))
      }
      row[j] <- str_c(elem, collapse = sep)
    }
    tableraw[i] <- str_c(row, collapse = "\n")
    tableraw[i] <- str_replace_all(tableraw[i],"</?.+?>","")
    if(str_length(tableraw[i]) == 0)
      badtable <- c(badtable, i)
  }
  if(length(badtable))
    tableraw <- tableraw[-badtable]
  for(i in 1:length(tableraw)) {
    sink(str_c(str_replace_all(url,"http(s|)://([a-zA-Z.]+)/.*","\\2"),"~",i,".",type[1]))
    cat(tableraw[i])
    sink()
  }
}