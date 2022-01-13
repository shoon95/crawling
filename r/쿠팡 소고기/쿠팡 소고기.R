library(rvest)
library(dplyr)
library(RSelenium)
library(openxlsx)
library(httr)
library(stringr)
setwd('D:/R_크롤링/크몽_쿠팡_소고기')
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

remDr$deleteAllCookies()

remDr$navigate('https://www.coupang.com/np/categories/194692?listSize=120&brand=&offerCondition=&filterType=&isPriceRange=false&minPrice=&maxPrice=&page=1&channel=user&fromComponent=Y&selectedPlpKeepFilter=&sorter=bestAsc&filter=&component=194592&rating=0')

category_list = c(194692,194696,194703,194704,194709,194715,194721,194722)

category_name_list = c('양지/사태/국거리','등심/안심/구이용','갈비/찜','사골/꼬리/우족','기타부위/다짐육','불고기/갈비','스테이크','기타소양념가공육')

coupang_list=as.data.frame(cbind(category_name_list, category_list))

data_all=data.frame()

for(i in 1:nrow(coupang_list)){
  
  cat = coupang_list[i,2]
  
  url_base='https://www.coupang.com/np/categories/'
  url = paste0(url_base,cat)
  
  for (l in 1:9){
    
    page = l 
    
    url_page = paste0(url,'?listSize=120&page=',page)
    
    remDr$deleteAllCookies()
    
    remDr$navigate(url_page)
    
    remDr$deleteAllCookies()
    
    data_source = remDr$getPageSource()[[1]]
    
    data = read_html(data_source) %>% html_nodes(xpath='/html/body/div[2]/section/form/div/div/div[1]/div/ul/li[*]/a') %>% html_attr('href')
    
    data= cbind(data,coupang_list[i,1])
    
    data_all = rbind(data_all, data)
    
    Sys.sleep(2.5)
  }
    
}

table(data_all[,2])

product_list=data_all[,1]

product_id_all = data.frame()
item_id_all=data.frame()
for (i in product_list){
  
  product_id=gsub('[^0-9]','',strsplit(i, '?itemId=')[[1]][1])
  product_id_all= rbind(product_id_all, product_id)
  
  item_id=strsplit(strsplit(i, '?itemId=')[[1]][2],'&')[[1]][1]
  item_id_all = rbind(item_id_all, item_id)
}

###############################################################

title_all = data.frame()
where_all = data.frame()
url_all = data.frame()
cat_all = data.frame()

for (i in 6958:8639){
  
  print(i)
  
  url=paste0('https://www.coupang.com/vp/products/',product_id_all[i,1],'?itemId=',item_id_all[i,1])
  
  remDr$deleteAllCookies()
  
  remDr$navigate(url)
  
  tt=try({remDr$findElement('xpath','//*[@id="contents"]/div[1]/div/div[3]/div[3]/h2')},silent=T)
  
  if(is.character(tt)==TRUE){next}
  
  title=remDr$findElement('xpath','//*[@id="contents"]/div[1]/div/div[3]/div[3]/h2')$getElementText()[[1]]
  
  Sys.sleep(1)
  
  data_page = remDr$getPageSource()[[1]]
  
  Sys.setlocale("LC_ALL","english")
  
  data_table = read_html(data_page, options="HUGE") %>% html_nodes(xpath='//*[@id="itemBrief"]/div/table') %>% html_table()
  
  if(length(data_table)==0){
    
    repeat{
      remDr$deleteAllCookies()
      
      Sys.sleep(7)
      
      remDr$navigate(url)
      
      remDr$deleteAllCookies()
      
      title = remDr$findElement('xpath','//*[@id="contents"]/div[1]/div/div[3]/div[3]/h2')$getElementText()[[1]]
      
      data_page = remDr$getPageSource()[[1]]
      
      Sys.setlocale("LC_ALL","english")
      
      data_table = read_html(data_page, options="HUGE") %>% html_nodes(xpath='//*[@id="itemBrief"]/div/table') %>% html_table()
      
      if(length(data_table)!=0){
        break
      }
    }

  }
  
  data_table=data_table[[1]]
  
  
  Sys.setlocale("LC_ALL","korean")
  
  if((sum(data_table=="원산지")==TRUE)==1){
    if(sum(data_table$X1=='원산지')==1){
      where=data_table[which(data_table$X1=='원산지'),2]
    }else if(sum(data_table$X3=='원산지')==1){
      where=data_table[which(data_table$X3=='원산지'),4]
    }
  }
  else if((sum(data_table=="제조국(원산지)")==TRUE)==1){
    if(sum(data_table$X1=='제조국(원산지)')==1){
      where = data_table[which(data_table$X1=='제조국(원산지)'),2]
    }else if (sum(data_talbe$X3=='제조국(원산지)')==1){
      where = data_table[which(data_table$X3=='제조국(원산지)'),4]
    }
  }
  else if((sum(data_table=="원재료명 및 함량")==TRUE)==1){
    if(sum(data_table$X1=='원재료명 및 함량')==1){
      where=data_table[which(data_table$X1=='원재료명 및 함량'),2]
    }else if(sum(data_table$X3=='원재료명 및 함량')==1){
      where=data_table[which(data_table$X3=='원재료명 및 함량'),4]
    }
  }
  else{where='정보 없음'}
    
    title_all = rbind(title_all, title)
    where_all = rbind(where_all, where)
    url_all = rbind(url_all, url)
    cat_all = rbind(cat_all, data_all[i,2])
    
  }
  
  
remDr$deleteAllCookies()
  
  Sys.sleep(2)
  
  
}
tt=try({remDr$findElement('xpath','//*[@id="contents"]/div[1]/div/div[3]/div[3]/h2')$getElementText()[[1]]}, silent=T)

is.character(tt)

remDr$findElement('xpath','//*[@id="contents"]/div[1]/div/div[3]/div[3]/h2')$getElementText()[[1]]

all_contents= cbind(title_all, url_all, where_all, cat_all)
class(url_all) = 'data.frame'

colnames(all_contents)=c('상품명','URL','원산지','카테고리')

class(all_contents) = 'data.frame'
class(all_contents[,2])='hyperlink'
wb<-createWorkbook()
addWorksheet(wb,"Sheet1")

writeData(wb,sheet=1,x=all_contents)

saveWorkbook(wb,'coupang.xlsx', overwrite=TRUE)

write.xlsx(all_contents, 'coupang.xlsx')
