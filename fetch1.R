# OTHER IDEA:
#   bc we know all pages should get a response. so make it a for loop and print what page if any fail as reference

# install.packages("rjson")
# install.packages("httr")
# install.packages("xml2")
# install.packages("svMisc")
# install.packages("sys")

library("xml2")
library("rjson")
library(httr)
#require(svMisc)
#library(sys)


baseURL #<- "https://[INSERT SUPER SECRET KEY HERE]@api.impact.com"

# starting page (to avoid having to edit 'nextURI' every freakin time...)
page = '1'
nextURI <- paste("/Advertisers/IRFnMdgZzMDu74466hEcGK6DV9shzD2Ab1/Reports/EventLevelAttributionOutput?PageSize=20000&ADV_CHANNEL_61=0&ATT_MODEL=36&START_DATE=2019-08-11&timeRange=CUSTOM&ACTION_NAME_MS=5243%2C6446&END_DATE=2019-08-17&compareEnabled=false&SUBAID=2379&Page=", page, sep="")

# NOTE: you need to run the inner for loop once in order to know how many pages you will need to iterate
numpages <- 112
firstPage <- as.integer(page)


for (x in firstPage:numpages) {
  
  print(x)
  
  # make it pretty
  #progress(x, progress.bar = TRUE)
  #sys.sleep(0.01)
  #if (x == numpages) cat("DONE!\n")
  
  # update the outgoing uri
  currentURL <- paste(baseURL, nextURI, sep="")
  
  # make the request
  response <- GET(currentURL)
  
  # collect data from the request
  nextURI <- content(response)$'@nextpageuri'
  page <- content(response)$'@page'
  actual_numpages <- content(response)$'@numpages'
  name <- paste("2019_08-11_08-17_", page, "_", numpages, sep="")
  reqJSON <- content(response)$Records
  
  # handle nulls
  json_file <- lapply(reqJSON, function(x) {
    x[sapply(x, is.null)] <- NA
    unlist(x)
  })
  
  # put into a dataframe
  df <- as.data.frame(do.call("rbind", json_file))
  
  # prepare the outgoing filename
  filename <- paste("./impact/", name, ".csv", sep="")
  
  # write out the file as CSV
  write.csv(df, filename)
}