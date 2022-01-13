library(rvest)
library(dplyr)
library(RSelenium)
library(openxlsx)
library(httr)
library(stringr)
setwd('D:\\R_크롤링\\네이버 카페')
#본인의 작업 디렉토리 설정

########################################## 원격 서버, 크롬 열기 ################

portn<-as.integer(runif(1,1,5000))  

# runif(a,b,c) : b~c사이의 수 하나를 랜덤하게 a 개 뽑는다 (실수 범위)
# as.integer(x) : x를 정수로 바꾼다
#::원격 서버를 열 때 포트 넘버를 넣어주기 위해 1~5000사이의 정수 하나를 랜덤으로 뽑아 portn에 넣어준다


rD<-rsDriver(port=portn, browser='chrome', chromever='90.0.4430.24') 
# :: 원격 서버를 여는 함수로 port 넘버, browser, browser의 버전 입력이 필요하다 (자동으로 브라우저가 열림) 
#<-크롬버전은 빈칸으로 입력후 에러 발생하면 자신의  크롬 정보에서 크롬 버전을 확인후 에러 창에서 가장 비슷한  버전을 적으면됨


remDr<-rD$client

### 카페로 이동

url ='https://cafe.naver.com/livejob'

remDr$navigate(url)

### 로그인 창 열기

login = remDr$findElement('xpath','//*[@id="gnb_login_button"]/span[3]')
login$clickElement()

### id, pw 입력

id = remDr$findElement('xpath','//*[@id="id"]')
pw = remDr$findElement('xpath', '//*[@id="pw"]')

id$setElementAttribute("value", '#아이디 입력') #비밀번호 입력
pw$setElementAttribute("value", '#비밀번호 입력')#아이디 입력  

### 로그인 하기

ok = remDr$findElement('xpath', '//*[@id="log.login"]')
ok$clickElement()

### 검색 창에 '전주' 검색

search = remDr$findElement('xpath', '//*[@id="topLayerQueryInput"]')
search$sendKeysToElement(list('전주'))
search_go = remDr$findElement('xpath','//*[@id="info-search"]/form/button')
search_go$clickElement()

### 페이지의 데이터가 있는 iframe 전환

iframe = remDr$findElement('xpath','//*[@id="cafe_main"]')
remDr$switchToFrame(iframe)

### 게시글 수 50개 씩 보기

list_show = remDr$findElement('xpath', '//*[@id="listSizeSelectDiv"]')
list_show$clickElement()

show50 = remDr$findElement('xpath', '//*[@id="listSizeSelectDiv"]/ul/li[7]/a')
show50$clickElement()

### 페이지 url 가져오기

page=remDr$findElement('xpath','//*[@id="main-area"]/div[7]/a[1]')
page_base=page$getElementAttribute('href')[[1]]

title_all = c()
writer_all = c()
date_all = c()
text_url_all = c()

i = 0
repeat{
  
  i = i+1
  print(i)
  
  ### 위에서 가져온 page url 에서 page=1부분만 바꿔주기 (ex: page=2,page=2 ~~)
  
  page_num = paste0('page=',i)
  url = gsub('page=1', page_num, page_base)
  
  ### 바뀐 페이지로 이동
  
  remDr$navigate(url)
  
  Sys.sleep(1)
  
  ### 데이터 있는 아이프레임 가져오기
  
  iframe = remDr$findElement('xpath','//*[@id="cafe_main"]')
  remDr$switchToFrame(iframe)
  
  ### 페이지 정보 가져오기
  
  data=remDr$getPageSource()[[1]]
  
  ### 제목 가져오기
  
  title = read_html(data) %>% html_nodes(xpath='//*[@id="main-area"]/div[5]/table/tbody/tr[*]/td[1]/div[2]/div/a[1]') %>% html_text()
  title = gsub('\n|  ','',title)
  
  ### 게시글 url 가져오기
  
  text_url = read_html(data) %>% html_nodes(xpath='//*[@id="main-area"]/div[5]/table/tbody/tr[*]/td[1]/div[2]/div/a[1]') %>% html_attr('href')
  
  ### 작성자 가져오기
  
  writer = read_html(data) %>% html_nodes(xpath ='//*[@id="main-area"]/div[5]/table/tbody/tr[*]/td[2]/div/table/tbody/tr/td/a') %>% html_text()
  
  ### 작성 날짜 가져오기
  
  date = read_html(data) %>% html_nodes(xpath = '//*[@id="main-area"]/div[5]/table/tbody/tr[*]/td[3]') %>% html_text()
  
  ### 위에서 가져온 내용들을 각각 계속해서 추가
  
  title_all = append(title_all, title)
  text_url_all = append(text_url_all, text_url)
  writer_all = append(writer_all, writer)
  date_all = append(date_all, date)
  
  ### 날짜가 2020.04.29.가 나타나면 반복문 종료
  
  if(sum(grepl('2020.04.29.',date))>0){
    break
  }
}

### 모인 데이터들 합쳐서 데이터 프레임으로 만들기

df = data.frame('title'=title_all, 'text_url'=text_url_all, 'writer'= writer_all, 'date'=date_all)

### 게시글 url을 사용 가능한 url 형식으로 바꾸기

df[,2]=paste0('https://cafe.naver.com',df[,2])

### 2020.04.29위치 찾아내서 바로 앞까지 데이터 자르기

df=df[c(1:which(df[,4]== "2020.04.29.")-1),]


### 게시글 가져오기

content_all = c()
k = 0
for(i in df[,2]){
  k= k+1
  
  now = paste0(k,'/',nrow(df))
  print(now)
  
  #### 게시글 url로 이동
  
  remDr$navigate(i)
  
  Sys.sleep(1)
  
  ### 데이터가 있는 iframe 으로 전환
  
  iframe = remDr$findElement('xpath','//*[@id="cafe_main"]')
  remDr$switchToFrame(iframe)
  
  ### content 수집 도중 에러가 발생해도 멈추지 말고 코드 진행, 에러는 t에 넣어두기

  t=try({content=remDr$findElement('xpath','//*[@id="app"]/div/div/div[2]/div[2]/div[1]/div/div[1]')},silent=T)
  
  ### 에러 발생 시 t는 is.character(t) 값이 TRUE, 즉 에러 발생 했을 시 , content에 '등업 시 열람 가능' 으로 값 넣어주고
  ### 밑에 코드는 돌리지 않고 다음 반복으로 건너 뜀

  if(is.character(t)==TRUE){
    content = '등업 시 열람 가능'
    content_all = append(content_all, content)
    next
  }
  
  content=content$getElementText()[[1]]
  content_all=append(content_all, content)
  
}

df[10,2]
df['본문']=content_all

class(df[1,2])='hyperlink'
wb<-createWorkbook()
addWorksheet(wb,"Sheet1")

writeData(wb,sheet=1,x=df)

saveWorkbook(wb,'NaverCafe.xlsx', overwrite=TRUE)

