#javac
#cd C:\selenium
#java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-4.0.0-alpha-2.jar -port 4445

## 크롤링에 사용하는 라이브러리 불러오기
install.packages('pacman')
library(pacman)
p_load('httr','rvest','RSelenium','dplyr','stringr')


## Rselenium을 사용해서 R에서 크롬 열기
portn<-as.integer(runif(1,1,5000))
rD<-rsDriver(port=portn, browser='chrome',chromever='96.0.4664.45')
remDr<-rD[['client']]

left <- "https://search.naver.com/search.naver?&where=news&query="
key <- "동물보험%20%7C%20펫보험" ##검색어 입력
mid1 <- "&nso=so%3Ar%2Cp%3Afrom"
date1 <- "20070101" ##검색시작일 입력
mid2 <- "to"
date2 <- "20210210" ##검색종료일 입력

## 최초의 검색 주소 이어붙이기
target <- c()
target <- paste(target, left, sep = "")
target <- paste(target, key, sep = "")
target <- paste(target, mid1, sep = "")
target <- paste(target, date1, sep = "")
target <- paste(target, mid2, sep = "")
target <- paste(target, date2, sep = "")

## 합쳐진 주소 확인
target
remDr$navigate(target)


## "검색옵션"창이 열려있지 않은 경우 클릭하여 옵션 창을 열어줌
## 옵션창이 열려있을 경우 해 줄 필요 없음
## element <- remDr$findElement("css", "#_m_option_btn")
## element$clickElement()



## 언론사 선택창을 켠다. 
element <- remDr$findElement("css", "#snb > div > ul > li:nth-child(7) > a")
element$clickElement()

## 신문사를 선택함. 아래의 코드를 참고할 것. 예시로 경향신문(ca_1032)을 선택함
element <- remDr$findElement("css", "#ca_p1")
element$clickElement()

## 주요 신문사 코드(중앙지)
## 경향신문 ca_1032 국민일보 ca_1005 내일신문 ca_2312 동아일보 ca_1020
## 매일일보 ca_2385 문화일보 ca_1021 서울신문 ca_1081 세계일보 ca_1022
## 조선일보 ca_1023 중앙일보 ca_1025 한겨레 ca_1028 한국일보 ca_1469 
## 아시아투데이 ca_2268 
##
## 지방지의 경우 마우스 우클릭 + 검사 기능을 통해 확인 

## "확인" 버튼을 클릭함 (관련순)
element <- remDr$findElement("css", "#snb > div > ul > li:nth-child(7) > div > span > span:nth-child(1) > button > span > strong")
element$clickElement()

## "최신순" 버튼을 클릭하여 최신 기사부터 조회되게 하고 싶을 경우 아래 코드 두 줄을 설정함
#element <- remDr$findElement("css", "#main_pack > div.news.mynews.section > div > div.news_option > ul > li:nth-child(2) > a")
#element$clickElement()


## 지금부터 해당 기간동안 경향신문의 관련 기사 주소를 먼저 가져올 것임
## 에러 안 뜨게 하려고 while문 안에 조건 삽입 



a.addr <- c()

i <- 0
while(1){
  i <- i + 1
  src <- remDr$getPageSource()[[1]]
  h <- read_html(src) 
  a.addr_text <- h %>% html_nodes('.info_group') %>% html_nodes('.info') %>% html_attr('href')
  a.addr_re<-a.addr_text[grepl('naver',a.addr_text)]
  a.addr<-append(a.addr,a.addr_re)
  element <- remDr$findElement("css", "#main_pack > div.api_sc_page_wrap > div > a.btn_next > i")
  element$clickElement()
  Sys.sleep(0.2)
  print(i)
  if(src==remDr$getPageSource()[[1]]){
    print('끝')
    break}
  
}

a.addr<-unique(a.addr)

## a.addr 변수에 검색결과 네이버 기사 주소가 모두 저장되어있음

title <- c()
article <- c()
web.addr <- c()
date <-c()

for (i in 1:length(a.addr)){
  remDr$navigate(a.addr[i])
  
  Sys.sleep(0.2)
  
  data <- remDr$getPageSource()[[1]]
  body <- read_html(data)
  
  date.temp <- html_nodes(body,'span.t11')
  if(length(date.temp)==0){
    date.temp <- html_nodes(body,'.author') %>% html_nodes('em')
    date.temp <- html_text(date.temp)[length(date.temp)]
    date_text<-date.temp %>% stringr::str_split(' ')
    date_re<-date_text[[1]][1]
    date<-append(date,date_re)
  }else{
    date.temp <- html_text(date.temp)[length(date.temp)]
    date_text<-date.temp %>% stringr::str_split(' ')
    date_re<-date_text[[1]][1]
    date<-append(date,date_re)
  }
  
  title.temp <- body %>% html_nodes('title') %>% html_text()
  title_re<-gsub(' : 네이버 뉴스| :: 네이버 TV연예','',title.temp)
  if (length(title_re) == 0) title <- append(title, "수동확인")
  else title <- append(title, title_re)
  
  
  article.temp <- html_nodes(body,'div#articleBodyContents')
  article.temp <- html_text(article.temp)
  article<-append(article, article.temp)
  if (length(article.temp) ==0) {
    article.temp <- html_nodes(body,'#articeBody') %>% html_text()
    article<-append(article,article.temp)
  }  
  
  web.addr <- append(web.addr, a.addr[i])
  print(i)
}


# 본문의 공백, 줄바꿈 등 쓸떼없는 텍스트를 날림
article <- gsub("\n", "", article)
article <- gsub("\t", "", article)
article <- gsub("//", "", article)
article <- gsub("flash 오류를 우회하기 위한 함수 추가", "", article)
article <- gsub("function _flash_removeCallback()", "", article)
article <- gsub("\\()", "", article)
article <- gsub("\\{}", "", article)
article <- gsub("이미지 원본보기", "", article)
## 검색결과를 일관되게 저장하기 위해 paper 변수에 신문 이름을 명시함
paper <- rep("일간지2문", length(date)) ## 신문 이름을 변수명으로 명시

## 하나의 데이터프레임으로 합침
paper02 <- data.frame(paper, date, title, article, web.addr)

## 최종 결과 확인 
head(paper02,1)
dim(paper02)
colnames(paper02)
str(paper02)
getwd()
write.csv(paper02, "news.csv")
paper02
