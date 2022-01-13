library(rvest)
library(dplyr)
library(RSelenium)
library(openxlsx)
library(httr)
library(stringr)
library(tidyr)
library(lubridate)

setwd('D:\\R_크롤링\\네이버 뉴스 댓글')

### 과거순 정렬
clk_order = function(){
  remDr$findElement('xpath','//*[@id="alex-area"]/div/div/div/div[3]/ul[1]/li[4]/button/span/span[1]')$clickElement()
}

## 댓글 추출

frame = data.frame()
url=c('https://news.v.daum.net/v/20210809222333268','https://news.v.daum.net/v/20210810000248839')

for(i in url){
  portn<-as.integer(runif(1,1,5000)) 
  rD<-rsDriver(port=portn, browser='chrome', chromever='91.0.4472.19') 
  remDr<-rD$client
  remDr$navigate(i)
  
  Sys.sleep(2)
  
  clk_order()
  
  Sys.sleep(0.5
            )
  t=remDr$executeScript('var performance = window.performance || window.mozPerformance || window.msPerformance || window.webkitPerformance || {}; var network = performance.getEntries() || {}; return network;')
  text=c()
  for(i in t){
    text=append(text,i$name)
  }
  link = text[grep('posts',text)[1]]
  post_base=str_extract(link,'posts/[0-9]+')
  post_id = gsub('[^0-9]','',post_base)
  offset=0
  limit=100
  repeat{
    
    post_url = paste0('https://comment.daum.net/apis/v1/posts/',post_id,'/comments?parentId=0&offset=',offset,'&limit=',limit,'&sort=CHRONOLOGICAL&isInitial=true&hasNext=true&randomSeed=1628536977')
    t=jsonlite::fromJSON(post_url)
    w=t[c('id','postId','content','createdAt','updatedAt','childCount','likeCount','dislikeCount','recommendCount')]
    w=cbind(w,t$user$providerId,t$user$providerUserId,t$user$displayName)
    
    frame = rbind(frame,w)
    offset= offset+100
    
    print(offset)
    if(nrow(t)!=100){
      remDr$close()
      break
    }
    
  }
  
}

### 대댓 추출
check=frame[frame$childCount!=0,]


frame1=data.frame()
for(i in check$id){
  offset=0
  limit = 100
  repeat{
    re_post_url = paste0('https://comment.daum.net/apis/v1/comments/',i,'/children?offset=',offset,'&limit=',limit,'&sort=CHRONOLOGICAL&hasNext=true')
    q = jsonlite::fromJSON(re_post_url)
    q_t=q[c('postId','parentId','content','createdAt','updatedAt')]
    q_w = cbind(q_t,q$post$title,q$post$url,q$post$createdAt,q$post$updatedAt,q$user$providerId,q$user$providerUserId,q$user$displayName)
    
    frame1=rbind(frame1,q_w)
    offset=offset+100
    
    print(offset)
    if(nrow(q)!=100){
      break
    }
  }
}

## 댓글 frame

## 대댓글 frame1
