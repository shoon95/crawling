library(rvest)
library(dplyr)
library(RSelenium)
library(openxlsx)
library(httr)
library(stringr)
library(tidyr)
library(lubridate)

getComment <- function(turl = url,
                       pageSize = 10,
                       page = 1,
                       sort = c("favorite", "reply", "old", "new", "best"),
                       type = c("df", "list")) {
  sort <- sort[1]
  tem <- strsplit(turl, "[=&]")[[1]]
  ticket <- "news"
  pool <- "cbox5"
  oid <- tem[grep("oid", tem) + 1]
  aid <- tem[grep("aid", tem) + 1]
  templateId <- "view_politics"
  useAltSort <- "&useAltSort=true"
  
  if (grepl("http(|s)://(m.|)sports.", turl)) {
    ticket <- "sports"
    pool <- "cbox2"
    templateId <- "view"
    useAltSort <- ""
  }
  
  url <-
    paste0(
      "https://apis.naver.com/commentBox/cbox/web_naver_list_jsonp.json?",
      "ticket=",
      ticket,
      "&templateId=",
      templateId,
      "&pool=",
      pool,
      "&lang=ko&country=KR&objectId=news",
      oid,
      "%2C",
      aid,
      "&categoryId=&pageSize=",
      pageSize,
      "&indexSize=10&groupId=&page=",
      page,
      "&initialize=true",
      useAltSort,
      "&replyPageSize=30&moveTo=&sort=",
      sort
    )
  
  con <- httr::GET(
    url,
    httr::user_agent("N2H4 using r by chanyub.park mrchypark@gmail.com"),
    httr::add_headers(Referer = turl)
  )
  tt <- httr::content(con, "text")
  
  tt <- gsub("_callback", "", tt)
  tt <- gsub("\\(", "[", tt)
  tt <- gsub("\\)", "]", tt)
  tt <- gsub(";", "", tt)
  tt <- gsub("\n", "", tt)
  
  dat <- jsonlite::fromJSON(tt)
  if (type[1] == "df") {
    dat <- dat$result$commentList[[1]]
    dat$snsList <- NULL
    if (length(dat) != 0) {
      dat <- tidyr::unnest(dat)
      dat <- tibble::as_tibble(dat)
    } else {
      dat <- tibble::tibble()
    }
  }
  return(dat)
}

url_base=c('https://news.naver.com/main/read.naver?m_view=1&includeAllCount=true&mode=LSD&mid=sec&sid1=100&oid=018&aid=0005001623','https://news.naver.com/main/read.naver?mode=LSD&mid=shm&sid1=100&oid=016&aid=0001872351')
frame=data.frame()
for(i in url_base){
  page=0
  repeat{
    page=page+1
    e=getComment(i,100,page)
    e=cbind(i,e)
    frame = rbind(frame,e)
    print(page)
    
    if(nrow(e)!=100){
      break
    }
  }
}


frame1=frame[c('i','commentNo','replyCount','contents','userIdNo','userName','regTime','sympathyCount','antipathyCount')]
check_1=frame1[which(frame1$replyCount!=0),]
check=check_1$commentNo

frame2=data.frame()

num=0
portn<-as.integer(runif(1,1,5000)) 
rD<-rsDriver(port=portn, browser='chrome', chromever='91.0.4472.19') 
remDr<-rD$client
remDr$navigate(check_1$i[1])
Sys.sleep(1)
for(i in check){
  page=0
  num=num+1

  repeat{
    t=remDr$executeScript('var performance = window.performance || window.mozPerformance || window.msPerformance || window.webkitPerformance || {}; var network = performance.getEntries() || {}; return network;')
    text=c()
    for(z in t){
      text=append(text,z$name)
    }
    text=text[grep('Query',text)[1]]
    text=str_extract(text,'jQuery[0-9]+_[0-9]+')
    query = gsub('jQuery','',text)
    
    t=remDr$executeScript('var performance = window.performance || window.mozPerformance || window.msPerformance || window.webkitPerformance || {}; var network = performance.getEntries() || {}; return network;')
    text=c()
    for(z in t){
      text=append(text,z$name)
    }
    text=text[grep('objectId=news',text)[1]]
    text=str_extract(text,'objectId=news[0-9]+%[0-9a-zA-Z]+')
    news=gsub('objectId=news','',text)  
    
    page=page+1
    print(num)
    url=paste0('https://apis.naver.com/commentBox/cbox/web_naver_list_jsonp.json?ticket=news&templateId=default_politics_m3&pool=cbox5&_wr&_callback=jQuery',query,'&lang=ko&country=KR&objectId=news',news,'&categoryId=&pageSize=100&indexSize=10&groupId=&listType=OBJECT&pageType=more&parentCommentNo=',i,'&page=',page,'&userType=&includeAllStatus=true&moreType=next&_=1628541263697')
    
    con <- httr::GET(
      url,
      httr::user_agent("N2H4 using r by chanyub.park mrchypark@gmail.com"),
      httr::add_headers(Referer = check_1$i[num])
    )
    tt <- httr::content(con, "text")
    
    tt <- gsub("_callback", "", tt)
    tt <- gsub("\\(", "[", tt)
    tt <- gsub("\\)", "]", tt)
    tt <- gsub(";", "", tt)
    tt <- gsub("\n", "", tt)
    tt <- gsub('jQuery[0-9]+_[0-9]+','',tt)
    dat <- jsonlite::fromJSON(tt)
    z=dat$result$commentList[[1]]
    frame=z[c('commentNo','parentCommentNo','contents','userIdNo','userName','regTime','sympathyCount','antipathyCount')]
    
    frame2 = rbind(frame2,frame)
    
    if(nrow(z)!=100){
      break
    }
  }
  if(num==length(check)){
    remDr$close()
    break
  }
  if(check_1$i[num]!=check_1$i[num+1]){
    remDr$close()  
    portn<-as.integer(runif(1,1,5000)) 
    rD<-rsDriver(port=portn, browser='chrome', chromever='91.0.4472.19') 
    remDr<-rD$client
    remDr$navigate(check_1$i[num+1])
    
    Sys.sleep(1)
  }
  
}

## ´ñ±Û frame1
## ´ë´ñ±Û frame2

