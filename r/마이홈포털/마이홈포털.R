library(rvest)
library(dplyr)
library(RSelenium)
library(xlsx)

setwd('C:/Users/sanghoon/Desktop/박사님 크롤링 자료')

########################################## 원격 서버, 크롬 열기 ################

portn<-as.integer(runif(1,1,5000))  

# runif(a,b,c) : b~c사이의 수 하나를 랜덤하게 a 개 뽑는다 (실수 범위)
# as.integer(x) : x를 정수로 바꾼다
#::원격 서버를 열 때 포트 넘버를 넣어주기 위해 1~5000사이의 정수 하나를 랜덤으로 뽑아 portn에 넣어준다


rD<-rsDriver(port=portn, browser='chrome', chromever='76.0.3809.25') 

# :: 원격 서버를 여는 함수로 port 넘버, browser, browser의 버전 입력이 필요하다 (자동으로 브라우저가 열림)


remDr<-rD$client

# :: 위 rsDriver 함수로 서버를 열었을 경우 server와 client 두 가지 접근 권한이 생기는데 client에 접근


########################################### 페이지 이동 #################

url<-'https://www.myhome.go.kr/hws/portal/sch/selectRentalHouseInfoListView.do'

# :: url 변수에 이동하고자 하는 홈페이지의 url을 넣어줌(마이홈)

remDr$navigate(url)

# :: url 페이지로 이동 

########################################### 페이지 정보 가져오기 ###############

data<-remDr$getPageSource()[[1]]

# :: 현재 크롬 원격에 떠있는 페이지의 정보를 가져와서 data라는 변수에 저장(우리가 원하는 정보는 1번 리스트에 있음)

sour<-read_html(data)

# :: 가져온 정보를 읽어 sour라는 변수에 저장

Sys.setlocale("LC_ALL", "English")

# :: 가져오고자 하는 데이터가 한국어라 문자 충돌이 발생 (인코딩 관련 문제로 추정), 때문에 r의 기본 언어 옵션을 영어로 바꾸어줌

con_table<-sour %>% html_nodes(xpath='//*[@id="sub_content"]/div[3]/div[1]/table') %>% html_table()

# :: 원하는 데이터가 table 형태로 존재, xpath값을 넣어 노드 위치를 알려주고 html_table()함수를 통해 table 형태로 데이터를 가져옴

Sys.setlocale("LC_ALL", "Korean")

# :: 데이터를 가져왔으니 다시 한국어로 전환

content<-data.frame(con_table)

# :: 가져온 데이터를 데이터 프레임 형태로 content라는 변수에 저장

######################################### 마지막 페이지의 데이터 가져오기 ##########################

end<- remDr$findElement(using='xpath',value='//*[@id="page_last"]')

# :: xpath 값을 이용하여 마지막 페이지로 가는 버튼의 위치를 찾아 end 변수에 저장

end$clickElement()

# :: end 클릭(마지막으로 가는 버튼 클릭)

sour<-remDr$getPageSource()[[1]]

# :: 페이지 정보를 가져와 sour이라는 변수에 저장

sour<-read_html(sour)

# :: 가져온 정보를 읽어 sour라는 변수에 저장

Sys.setlocale("LC_ALL", "English")

# :: 가져오고자 하는 데이터가 한국어라 문자 충돌이 발생 (인코딩 관련 문제로 추정), 때문에 r의 기본 언어 옵션을 영어로 바꾸어줌

last_table<- sour %>% html_nodes(xpath='//*[@id="sub_content"]/div[3]/div[1]/table') %>% html_table()

# :: 원하는 데이터가 table 형태로 존재, xpath값을 넣어 노드 위치를 알려주고 html_table()함수를 통해 table 형태로 데이터를 가져옴

Sys.setlocale("LC_ALL", "Korean")

# :: 데이터를 가져왔으니 다시 한국어로 전환

last_con<-data.frame(last_table)

# :: 마지막 페이지에서 가져온 데이터를 last_con 데이터 프레임으로 바꿔 last_con에 넣어주기

########################################첫 페이지로 이동 ###########################

first<- remDr$findElement(using='xpath',value='//*[@id="page_first"]')

# :: xpath 값을 이용하여 첫 번째 페이지로 가는 버튼의 위치를 찾아 first 라는 변수에 저장

first$clickElement()

# :: first 클릭(첫 번째 페이지로 가는 버튼 클릭)
######################################## 페이지 이동 ###############################

#########데이터를 계속해서 수집하다 수집된 데이터가 마지막 페이지와 같으면 반복을 멈춤

num_re<-rep(4:13,600)

i<-0
repeat{
  i<-i+1
  print(i)
  num_g<-num_re[i]
  
  value<-paste0('//*[@id="pageDiv"]/ul/li[',num_g,']')
  
  mouse<-remDr$findElement(using='xpath', value=value)
  
  err<-try(mouse$clickElement(), silent=TRUE)
  
  if(is.character(err)){
    Sys.sleep(10)
    
    data<-remDr$getPageSource()[[1]]
    
    sour<-read_html(data)
    
    Sys.setlocale("LC_ALL", "English")
    
    cont_table<-sour %>% html_nodes(xpath='//*[@id="sub_content"]/div[3]/div[1]/table') %>% html_table()
    
    Sys.setlocale("LC_ALL", "Korean")
    
    content_re<-data.frame(cont_table)
    
    content<-rbind(content, content_re)
    
    if(all(last_con[,3]==content_re[,3])){
      break
    }
  }else{
    Sys.sleep(5)
    
    data<-remDr$getPageSource()[[1]]
    
    sour<-read_html(data)
    
    Sys.setlocale("LC_ALL", "English")
    
    cont_table<-sour %>% html_nodes(xpath='//*[@id="sub_content"]/div[3]/div[1]/table') %>% html_table()
    
    Sys.setlocale("LC_ALL", "Korean")
    
    content_re<-data.frame(cont_table)
    
    content<-rbind(content, content_re)
    
    if(all(last_con[,3]==content_re[,3])){
      break
    }
  }
  
  
}

write.xlsx(content, 'content.xlsx', row.names=FALSE)


