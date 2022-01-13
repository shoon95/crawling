#뉴스, 조선비즈, 위클리비즈만 가능
ls()
rm(list = ls())

setwd("C:\\Users\\sjhty\\Desktop")


x <- c("rvest", "data.table", "pbapply", "dplyr",
       "xml2", "topicmodels", "tm", "quanteda",
       "parallel", "doParallel", "foreach",
       "ggplot2", "reshape", "openxlsx", "stm",
       "lubridate", "tidyr", "stringr","RSelenium")

#install.packages(x)
lapply(x, require, character.only = TRUE)

portn<-as.integer(runif(1,1,5000))
rD<-rsDriver(port=portn, browser='chrome', chromever ='88.0.4324.27')
remDr<-rD$client




chosun <- "https://www.chosun.com/nsearch/?query=%EB%8F%99%EB%AC%BC%EB%B3%B4%ED%97%98%20or%20%ED%8E%AB%EB%B3%B4%ED%97%98&siteid=chosunbiz,weeklybiz&sort=1&date_period=all&writer=&field=&emd_word=&expt_word=&opt_chk=false&app_check=0" 

remDr$navigate(chosun)

Sys.sleep(2)

article_num_ele<- remDr$findElement(using='xpath', value='//*[@id="main"]/div[1]/div[1]/div[1]/p')
article_num<-article_num_ele$getElementText()[[1]] %>% str_extract('[0-9]+')



repeat{
  scroll_but<-remDr$findElement(using='xpath', value='//*[@id="load-more-stories"]')
  scroll_but$clickElement()
  Sys.sleep(2)
  page <- remDr$getPageSource()[[1]]
  num<-length(read_html(page) %>% html_nodes(xpath='//*[@id="main"]/div[4]/div[*]/div/div[1]/div[2]/div[1]/h3'))
  text="현재 기사 수 : "
  print(paste0(text,num," (전체:",article_num,")"))
  
  if (num==article_num){break}
}


page <- remDr$getPageSource()[[1]]

all_urls<-page %>% read_html() %>% html_nodes("h3 a")  %>% html_attr('href')
length(all_urls)
grep("(http://srchdb1*)", all_urls, value = FALSE)
all_urls <- all_urls[-(grep("(http://srchdb1*)", all_urls, value = FALSE))]
all_urls<-unique(all_urls)
# list of html tags
# https://www.w3schools.com/tags/default.asp
# get the stories from urls
story_scrape1 <- function(x){
  page <- read_html(x)
  Sys.sleep(1)
  headline <- page %>% html_nodes("h1#news_title_text_id") %>% html_text() %>% unique()
  headline <- paste0(headline)
  body2 <- page %>% html_nodes("div#news_body_id") %>% html_text() %>% unique()
  body2 <- gsub("(\r|\n|\t|기자)|\r\n|제휴안내구독신청|Copyright ⓒ 조선비즈 & Chosun.com\r\n|좋아요 [0-9]+|입력 [0-9]+.[0-9]{2}.[0-9]{2} [0-9]{2}:[0-9]{2}|수정 [0-9]+.[0-9]{2}.[0-9]{2} [0-9]{2}:[0-9]{2}|\\|", "", body2)
  body2
  
  story <- paste0(body2)
  date <- page %>% html_nodes("div.news_date") %>% html_text() %>% unique() # covariate 
  date <- gsub("(입력 )", "", date)
  corpus <- data.frame(headline, story, date, stringsAsFactors = FALSE)
  return(corpus) 
}

length(all_urls)
all_storyt <- pblapply(all_urls, story_scrape1)
all_storyt <- do.call(rbind, all_storyt)
write.xlsx(all_storyt, "story펫보험.xlsx")
