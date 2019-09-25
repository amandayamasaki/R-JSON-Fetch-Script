install.packages("rjson")
library("rjson")

install.packages("httr")
library(httr)

nextURI<- "/Advertisers/IRFnMdgZzMDu74466hEcGK6DV9shzD2Ab1/Reports/EventLevelAttributionOutput?PageSize=20000&ADV_CHANNEL_61=0&ATT_MODEL=36&START_DATE=2019-09-01&timeRange=CUSTOM&ACTION_NAME_MS=5243%2C6446&END_DATE=2019-09-14&compareEnabled=false&SUBAID=2379&Page=1"

while (nextURI != ""){
  baseURL <- "https://[INSERT SUPER SECRET KEY HERE]@api.impact.com"
  currentURL <- paste(baseURL,nextURI,sep="")
  test <- GET(currentURL)
  
  nextURI <- content(test)$'@nextpageuri'
  page <- content(test)$'@page'
  numpages <- content(test)$'@numpages'
  name <- paste("2019_09-01_09-14_",page, "_",numpages,sep="")
  
  reqJSON <- content(test)$Records
  json_file <- lapply(reqJSON, function(x) {
    x[sapply(x, is.null)] <- NA
    unlist(x)
  })
  df<-as.data.frame(do.call("rbind", json_file))
  
  filename <- paste("impact/",name,".csv",sep="")
  write.csv(df,filename)
}