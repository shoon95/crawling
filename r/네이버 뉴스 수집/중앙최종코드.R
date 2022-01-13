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


#중앙일보 스크래핑

JA <- paste0("https://news.joins.com/Search/JoongangNews?page=", 
             seq(from = 1, to = 11, by = 1))
mid <- "&Keyword=동물보험%20펫보험&SortType=New&SearchCategoryType=TotalNews"
JA
target <- c()
target <- paste(target, JA, sep = "")
target <- paste(target, mid, sep = "")
target

JA_urls <- target


url_scrape <- function(x){
  page <- read_html(x)
  links <- page %>% html_nodes("h2 a") %>% html_attr("href") %>%
    unique() 
}

all_urls <- pblapply(JA_urls, url_scrape)
class(all_urls)
all_urls <- unlist(all_urls)
length(all_urls)
all_urls

grep("(https://joongang.joins.com)", all_urls, value = FALSE)
all_urls <- all_urls[-(grep("(https://joongang.joins.com)", all_urls, value = FALSE))]
length(all_urls)
# list of html tags
# https://www.w3schools.com/tags/default.asp

# get the stories from urls

story_scrape1 <- function(x){
  page <- read_html(x)
  Sys.sleep(1)
  headline <- page %>% html_nodes("h1#article_title") %>% html_text() %>% unique()
  headline <- paste0(headline)
  body2 <- page %>% html_nodes("div.article_body") %>% html_text() %>% unique()
  body2 <- gsub("(\r|\n|\t|기자)", "", body2)
  story <- paste0(headline, body2)
  date <- page %>% html_nodes("div.byline") %>% html_text() %>% unique() # covariate 
  date <- gsub("(입력 )", "", date)
  corpus <- data.frame(headline, story, date, stringsAsFactors = FALSE)
  return(corpus) 
}

length(all_urls)
all_storyt <- pblapply(all_urls, story_scrape1)
all_storyt <- do.call(rbind, all_storyt)
write.xlsx(all_storyt, "ja_petins.xlsx")

