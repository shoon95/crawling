ls()
rm(list = ls())

setwd("C:\\Users\\sjhty\\Desktop")

getwd()

x <- c("rvest", "data.table", "pbapply", "dplyr",
       "xml2", "topicmodels", "tm", "quanteda",
       "parallel", "doParallel", "foreach",
       "ggplot2", "reshape", "openxlsx", "stm",
       "lubridate", "tidyr", "stringr")

install.packages(x)
lapply(x, require, character.only = TRUE)

# 모바일 결제 문제 스크래핑
hani_url_base <- "http://search.hani.co.kr/Search?command=query"
keyword <-"keyword=동물보험"
news <- "media=news"
submedia<- "submedia="
sort<-"sort=s" #s = 정확도순, d= 최신순
period <- "period=all"
date <-"datefrom=1988.01.01&dateto=2021.02.20" #날짜 수정

hani_url0 <- paste(hani_url_base,keyword,news,submedia,sort,period,date, sep='&')


hani_url <- paste0(hani_url0  ,"&pageseq=", 
  seq(0, 7, by = 1))
hani_url
length(hani_url)


# %>% # pipe operator: link the left object and the right object
url_scrape <- function(x){
  page <- read_html(x)
  links <- page %>% html_nodes("dt a") %>% html_attr("href") %>%
    unique() 
  }

all_urls <- pblapply(hani_url, url_scrape)
class(all_urls)
all_urls <- unlist(all_urls)
all_urls <-paste0('http:',all_urls)
length(all_urls)
all_urls[3]
# list of html tags
# https://www.w3schools.com/tags/default.asp

# get the stories from urls
# x<-"//www.hani.co.kr/arti/economy/it/917588.html"
story_scrape1 <- function(x){
  page <- read_html(x)
  Sys.sleep(1)
  headline <- page %>% html_nodes("span.title") %>% html_text() %>% unique()
  headline <- paste0(headline)
  body2 <- page %>% html_nodes("div.text") %>% html_text() %>% unique()
  body2 <- gsub("(\r|\n|\t|rl기자)", "", body2)
  story <- paste0(headline, body2)
  date <- page %>% html_nodes("p.date-time") %>% html_text() %>% unique() # covariate 
  date <- gsub("(등록 :)", "", date)
  corpus <- data.frame(headline,story, date, stringsAsFactors = FALSE)
  return(corpus) 
}

length(all_urls)
all_storyh <- pblapply(all_urls, story_scrape1)
all_storyh <- do.call(rbind, all_storyh)

write.xlsx(all_storyh, 'sample.xlsx')
