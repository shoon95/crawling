library(rvest)
library(dplyr)
library(RSelenium)
library(openxlsx)
library(httr)
library(stringr)

setwd('D:\\R_크롤링\\크몽_국민청원')

portn<-as.integer(runif(1,1,5000))  

# runif(a,b,c) : b~c사이의 수 하나를 랜덤하게 a 개 뽑는다 (실수 범위)
# as.integer(x) : x를 정수로 바꾼다
#::원격 서버를 열 때 포트 넘버를 넣어주기 위해 1~5000사이의 정수 하나를 랜덤으로 뽑아 portn에 넣어준다


rD<-rsDriver(port=portn, browser='chrome', chromever='90.0.4430.24') 
# :: 원격 서버를 여는 함수로 port 넘버, browser, browser의 버전 입력이 필요하다 (자동으로 브라우저가 열림) 
#<-크롬버전은 빈칸으로 입력후 에러 발생하면 자신의  크롬 정보에서 크롬 버전을 확인후 에러 창에서 가장 비슷한  버전을 적으면됨


remDr<-rD$client



link_all = c()


for( i in 1064:2013){
  print(i)
  url = sprintf('https://www1.president.go.kr/petitions/?c=0&only=2&page=%d&order=1', i)

  ### 페이지 이동
  remDr$navigate(url)
  
  Sys.sleep(runif(1,2,3))
  
  ###페이지 정보 가져오기
  data= remDr$getPageSource()[[1]]

  ### 해당 부분 텍스 가져와서 분리
  for(j in 1:7){
    text=read_html(data) %>% html_nodes(xpath=sprintf('//*[@id="cont_view"]/div[2]/div/div/div[2]/div[2]/div[4]/div/div[2]/div[2]/ul/li[%d]',j)) %>% html_text()
    text1=gsub('번호 ','',text)
    text2=gsub('번호 |분류 |제목 |청원 종료일 |참여인원 ','/',text1)
    
    ### 번호 가져오기
    num = strsplit(text2,'/')[[1]][1]
    num_all = append(num_all,num)
    
    ### 카테고리 분류 가져오기
    category = strsplit(text2,'/')[[1]][2]
    category_all= append(category_all, category)
    
    ### 청원 제목 가져오기
    title = strsplit(text2,'/')[[1]][3]
    title_all = append(title_all, title)
    
    ### 청원 마감 날짜 가져오기
    date = strsplit(text2,'/')[[1]][4]
    date_all = append(date_all,date)
    
    ### 청원 인원 가져오기
    people = strsplit(text2,'/')[[1]][5]
    people_all = append(people_all,people)
    
    
  }
  
  #### 청원 링크 가져오기
  link=read_html(data) %>% html_nodes(xpath='//*[@id="cont_view"]/div[2]/div/div/div[2]/div[2]/div[4]/div/div[2]/div[2]/ul/li[*]/div/div[3]/a') %>% html_attr('href')
  link_all = append(link_all,link)
  
  
}



link=paste0('https://www1.president.go.kr',link_all)

link[1]

content_all=c()
page=0

num_all = c()
category_all =c()
title_all = c()
start_date_all=c()
people_all=c()
end_date_all=c()
for( i in link){
  page= page+1
  
  print(page)
  
  data =read_html(i)
  
  ### 청원 내용
  
  content=data %>% html_nodes(xpath='//*[@id="cont_view"]/div[2]/div[1]/div/div[1]/div/div[4]/div[2]') %>% html_text()
  if(content==''){
    content = data %>% html_nodes(xpath ='//*[@id="cont_view"]/div[2]/div[1]/div/div[1]/div/div[4]/div[4]') %>% html_text()
  }
  
  content=gsub('\n\t\t\t\t\t\t\t\t\t\t|\t\t','',content)
  if (length(content)==0){
    print(i)
    print(page)
    print('weflwkefwefwef')
    break
  }
  content_all=append(content_all, content)
  
  ### 청원 제목 가져오기
  
  title= data %>% html_nodes(xpath='//*[@id="cont_view"]/div[2]/div[1]/div/div[1]/div/h3') %>% html_text()
  title_all = append(title_all, title)
  
  ### 카테고리 가져오기
  category= data %>% html_nodes(xpath='//*[@id="cont_view"]/div[2]/div[1]/div/div[1]/div/div[2]/ul/li[1]/text()') %>% html_text()
  category_all = append(category_all,category)
  
  ### 청원 시작 날짜
  start_date= data %>% html_nodes(xpath='//*[@id="cont_view"]/div[2]/div[1]/div/div[1]/div/div[2]/ul/li[2]/text()') %>% html_text()
  start_date_all = append(start_date_all,start_date)
  
  ### 청원 마감 날짜
  end_date = data %>% html_nodes(xpath='//*[@id="cont_view"]/div[2]/div[1]/div/div[1]/div/div[2]/ul/li[3]/text()') %>% html_text()
  end_date_all = append(end_date_all, end_date)
  
  ### 청원 인원
  people = data %>% html_nodes(xpath='//*[@id="cont_view"]/div[2]/div[1]/div/div[1]/div/h2/span') %>% html_text()
  people_all = append(people_all, people)
  
  Sys.sleep(runif(1,1,2))
}





df= data.frame('카테고리'=category_all, '청원 제목' = title_all,'청원 시작' = start_date_all, '청원 마감'=end_date_all, '청원 내용'=content_all,'링크'=link)
df= unique(df)

class(df) = 'data.frame'
class(df[,6])='hyperlink'
wb<-createWorkbook()
addWorksheet(wb,"Sheet1")

writeData(wb,sheet=1,x=df)

saveWorkbook(wb,'국민청원.xlsx', overwrite=TRUE)


write.xlsx(df, '국민청원.xlsx')


