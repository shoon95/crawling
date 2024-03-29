install.packages('pacman')
pacman::p_load('rvest','dplyr','openxlsx','stringr','httr','jsonlite','tidyverse','KoNLP')

setwd('D:\\R_크롤링\\네이버 블로그')

######################################

### 시작 날짜와 마지막 날짜 만드는 함수

start_date = function(start){
  if(grepl('-',start)==TRUE){
    return(start)
    
  }else{
    year=stringr::str_sub(start,1,4)
    month=stringr::str_sub(start,5,6)
    day=stringr::str_sub(start,7,8)
    startdate = paste(year,month,day, sep='-')
    return(startdate)
  } 
  
}
end_date = function(end){
  if(grepl('-',end)==TRUE){
    return(end)
    
  }
  
  year=stringr::str_sub(end,1,4)
  month=stringr::str_sub(end,5,6)
  day=stringr::str_sub(end,7,8)
  enddate = paste(year,month,day, sep='-')
  
  return(enddate)
}


t1 = seq(20210401,20210430,1)
t2= seq(20210501,20210514,1)

t=append(t1,t2)

content_all = c()
post_all_1=c()
date_all = c()


for(time in t){
  print(time)
  post_url_all = data.frame()
  
  keyword = '이해충돌방지법'
  start = time
  end = time
  last_page = 15
  
  
  
  post_url_crawl=function(keyword,start,end,last_page){
    post_url = data.frame()
    for (i in 1:last_page){
      GET("https://section.blog.naver.com/ajax/SearchList.nhn", ### 블로그 리스트 base_url
          #### 사이트에 요청하는 query
          query = list("countPerPage"= 7,
                       "currentPage"  = i,
                       "endDate"      = end_date(end),
                       "keyword"      = keyword,
                       "orderBy"      = "sim",
                       "startDate"    = start_date(start),
                       "type"         = "post"),
          add_headers("referer" = "https://section.blog.naver.com/Search/Post.nh")) %>%content("text") %>% str_remove('\\)\\]\\}\',') %>% fromJSON() -> data_all
      data <- data_all$result$searchList[,c(1,2)]
      post_url = rbind(post_url,data)
      cat(i,"페이지\n")}
    return(post_url)
  }
  
  post_url=post_url_crawl(keyword,start,end,last_page)    
  
  
  #  게시글 url 담을 공간 생성
  post_all = c()
  
  #  게시글 url 수집
  for (i in 1:nrow(post_url)){
    id=post_url[i,1]
    logno=post_url[i,2]
    
    post = sprintf('http://blog.naver.com/PostView.nhn?blogId=%s&logNo=%s',id,logno)
    post_all = append(post_all,post)
  }
  
  #  게시글 내용 담을 공간 생성

  
  #  게시글 내용 수집
  for( i in 1:length(post_all)){
    
    print(i)
    
    t=try({
      content=read_html(post_all[i]) %>% html_nodes('.se-main-container') %>% html_text()
      if(length(content)==0){
        content = read_html(post_all[i]) %>% html_nodes(xpath=sprintf('//*[@id="post-view%s"]',post_url[i,2])) %>% html_text()
        
      }
      content=gsub('\n|  ','',content)
      if(length(content)==0){
        next}
      
      content_all=append(content_all, content)
      
      post = post_all[i]
      post_all_1 = append(post_all_1,post)
      date = time
      date_all = append(date_all,date)
      
    })
    
    if(is.character(t)==TRUE){
      next
      
    }
    
  }
  
}





# 게시글 본문과 링크 합치기
df = data.frame('본문'=content_all,'링크'=post_all_1, '날짜'= date_all)


load('tt.Rdata')

useNIADic() 

# 명사/ 형용사/ 동사 추출
ko.words <- function(doc){
  d <- as.character(doc)
  pos <- paste(SimplePos09(d))
  extracted <- str_match(pos, '([가-힣0-9]+)/N')
  keyword <- extracted[,2]
  keyword[!is.na(keyword)]
}

# SimplePos22(doc)
# extractNoun(doc)
# doc <- "회원님 점심은 도시락 준비하겠습니다"
# doc <- "회원님 점심 감사합니다"
# ko.words(doc) 

# https://www.rdocumentation.org/packages/tm/versions/0.7-6/topics/VectorSource

# install.packages("tm")
library(tm)



i = t[1]
data_all=data.frame()
for(i in t){
  print(i)
  df1=df %>% group_by(날짜) %>% filter(날짜==i) 
  cafe_content = df1[,1]
  cafe_content=unlist(cafe_content)                   
  cafe_content=gsub('<.*{6}>','',cafe_content)

  
  cps <- VCorpus(VectorSource(cafe_content))
  
  tdm <- TermDocumentMatrix(cps,
                            control = list(weighting= weightBin, 
                                           tokenize=ko.words,
                                           removePunctuation = T,
                                           removeNumbers = T,
                                           stopwords = c()))
  
  tdm <- as.matrix(tdm)
  
  v <- sort(slam::row_sums(tdm), decreasing = T)
  
  data <- data.frame(X=names(v),freq=v)
  
  table(data$freq)
  
  data1 <- data[data$freq>=10,]
  data_all=rbind(data_all,data_1)

}

data1



df[,1]=gsub('.<U+200B>','',df1[,1])

content[56]