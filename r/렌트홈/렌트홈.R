library(rvest)
library(dplyr)
library(RSelenium)
library(openxlsx)
library(httr)
library(stringr)

setwd('D:\\R_크롤링\\렌트홈')


########################################## 원격 서버, 크롬 열기 ################

eCaps <- list(chromeOptions = list(
  args = c('--headless', '--disable-gpu', '--window-size=1280,800')
))
portn<-as.integer(runif(1,1,5000))  

# runif(a,b,c) : b~c사이의 수 하나를 랜덤하게 a 개 뽑는다 (실수 범위)
# as.integer(x) : x를 정수로 바꾼다
#::원격 서버를 열 때 포트 넘버를 넣어주기 위해 1~5000사이의 정수 하나를 랜덤으로 뽑아 portn에 넣어준다


rD<-rsDriver(port=portn, browser='chrome', chromever='90.0.4430.24',extraCapabilities = eCaps) 
# :: 원격 서버를 여는 함수로 port 넘버, browser, browser의 버전 입력이 필요하다 (자동으로 브라우저가 열림) 
#<-크롬버전은 빈칸으로 입력후 에러 발생하면 자신의  크롬 정보에서 크롬 버전을 확인후 에러 창에서 가장 비슷한  버전을 적으면됨


remDr<-rD$client



### 렌트홈 페이지 이동
remDr$navigate('https://www.myhome.go.kr/hws/portal/gis/rentHome.do#')

tt = try({
  check = remDr$findElement('xpath','/html/body/div[2]/div[3]/div/button/span')
  check$clickElement()
},silent=T)

### 주소지와 같은 곳 클릭 함수
matching = function(x){
  
  si_name = si_view$getElementText()[[1]]
  gu_name = gu$getElementText()[[1]]
  dong_name = dong$getElementText()[[1]]
  
  address = paste(si_name, gu_name,dong_name, sep=' ')
  
  data = remDr$getPageSource()[[1]]
  
  Sys.setlocale('LC_ALL','english')
  
  table = data %>% read_html() %>% html_nodes(xpath='//*[@id="searchResultId"]/table/tbody') %>% html_table()
  table=table[[1]]
  
  Sys.setlocale('LC_ALL','korean')
  
  number = which(table[,7]==address)
  
  sel = remDr$findElement('xpath',paste0('//*[@id="searchResultId"]/table/tbody/tr[',number,']'))
  sel$clickElement()
}

### 스크롤 내리기 함수
scroll_down = function(x) {
  repeat{
    last_num = length(remDr$findElements('xpath','//*[@id="privteHse"]/tbody/tr'))
    
    last = remDr$findElement('xpath',paste0('//*[@id="privteHse"]/tbody/tr[',last_num,']'))
    last$clickElement()
    
    Sys.sleep(0.5)
    
    remDr$deleteAllCookies()
    
    print(last_num)
    
    if(last_num == length(remDr$findElements('xpath','//*[@id="privteHse"]/tbody/tr'))){
      break
    }
  }
  
}

### 데이터  가져오기 함수
get_data = function(x){
  table_all = remDr$findElements('xpath','//*[@id="privteHse"]/tbody/tr')

  data_all = data.frame()
  
  t = 0
  for(i in table_all){
    
    t= t+1
    
    si_name = si_view$getElementText()[[1]]
    gu_name = gu$getElementText()[[1]]
    dong_name = dong$getElementText()[[1]]
    
    addr = paste(si_name,gu_name,dong_name, sep=' ')
    
    text = paste0(t,'/',length(table_all),' ',addr)
    
    print(text)
    
    i$clickElement()
    
    Sys.sleep(0.3)
    
    page = remDr$getPageSource()[[1]]
    
    Sys.setlocale('LC_ALL','english')
    
    table = page %>% read_html() %>% html_nodes(xpath='//*[@id="bassInfoDiv"]/div[2]/table/tbody') %>% html_table() 
    table = table[[1]]
    
    Sys.setlocale('LC_ALL','korean')
    
    col1_name  = str_sub(table[1,1],1,2) 
    col1_content  = str_sub(table[1,1],3,str_count(table[1,1]))
    
    col2_name = str_sub(table[1,2],1,4)
    col2_content = str_sub(table[1,2],5,str_count(table[1,2]))
    
    col3_name = str_sub(table[2,1],1,4)
    col3_content = str_sub(table[2,1],5,str_count(table[2,1]))
    
    col4_name = str_sub(table[2,2],1,7)
    col4_content = str_sub(table[2,2],8,str_count(table[2,2]))
    
    col5_name = str_sub(table[3,1],1,4)
    col5_content = str_sub(table[3,1],5,str_count(table[3,1]))
    
    col6_name = str_sub(table[3,2],1,6)
    col6_content = str_sub(table[3,2],7,str_count(table[3,2]))
    
    col7_name = str_sub(table[4,1],1,6)
    col7_content = str_sub(table[4,1],7,str_count(table[4,1]))
    
    col8_name = str_sub(table[4,2],1,9)
    col8_content = str_sub(table[4,2],10,str_count(table[4,2]))
    
    name=c(col1_name,col2_name,col3_name,col4_name,col5_name,col6_name,col7_name,col8_name)
    data=data.frame(col1_content,col2_content,col3_content,col4_content,col5_content,col6_content,col7_content,col8_content)
    colnames(data)=name
    
    data_all = rbind(data_all, data)
  }
  return(data_all)
}


##### 크롤링 시작
data_all = data.frame()
for(i in 2:18){ #i=2
  
  if(i!=2){break}

  si_view = remDr$findElement('xpath',paste0('//*[@id="brtcCode"]/option[',i,']'))
  si_view$clickElement()
  
  gu_len = length(remDr$findElements('xpath','//*[@id="signguCode"]/option'))
  
  Sys.sleep(1)
  
  for(j in 2:gu_len){
    gu = remDr$findElement('xpath',paste0('//*[@id="signguCode"]/option[',j,']'))
    gu$clickElement()
    
    Sys.sleep(1)
    
    dong_len = length(remDr$findElements('xpath','//*[@id="lglDngCode"]/option'))
    
    for(k in 6:dong_len){
      dong = remDr$findElement('xpath',paste0('//*[@id="lglDngCode"]/option[',k,']'))
      dong$clickElement()
      
      Sys.sleep(3)
      
      go = remDr$findElement('xpath', '//*[@id="searchAreaPVR"]/span/a/img')
      go$clickElement()
      
      Sys.sleep(4)
    
      matching()
      
      Sys.sleep(2)
      
      scroll_down()
      
      data = get_data()
      
      si_name = si_view$getElementText()[[1]]
      gu_name = gu$getElementText()[[1]]
      dong_name = dong$getElementText()[[1]]
      
      addr = data.frame(si_name,gu_name,dong_name)
      colnames(addr)=c('도','구','동') 
      
      data=cbind(addr, data)
      
      data_all = rbind(data_all, data)
      
      remDr$deleteAllCookies()
      
      Sys.sleep(1)
      
      #### 재시작
      
      remDr$close()
      
      eCaps <- list(chromeOptions = list(
        args = c('--headless', '--disable-gpu', '--window-size=1280,800')
      ))
      portn<-as.integer(runif(1,1,5000))
      
      rD<-rsDriver(port=portn, browser='chrome', chromever='90.0.4430.24',extraCapabilities = eCaps)
      
      remDr<-rD$client
      
      Sys.sleep(3)
      
      remDr$navigate('https://www.myhome.go.kr/hws/portal/gis/rentHome.do#')
      
      Sys.sleep(3)
      
      tt = try({
        check = remDr$findElement('xpath','/html/body/div[2]/div[3]/div/button/span')
        check$clickElement()
      },silent=T)
      
      si_view = remDr$findElement('xpath',paste0('//*[@id="brtcCode"]/option[',i,']'))
      si_view$clickElement()
      
      Sys.sleep(3)
      
      gu = remDr$findElement('xpath',paste0('//*[@id="signguCode"]/option[',j,']'))
      gu$clickElement()
      
      Sys.sleep(3)

    }
  }
 
}

write.xlsx(data_all, 'data_2.xlsx')

