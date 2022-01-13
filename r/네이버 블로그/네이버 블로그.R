install.packages('pacman')
pacman::p_load('rvest','dplyr','openxlsx','stringr','httr','jsonlite')

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

########################

### 게시글 url 가져오기

crawl_function = function(x){
  
  post_url_all = data.frame()

  keyword = readline(prompt ="키워드 : ")
  start = readline(prompt ="시작 날짜 : ")
  end = readline(prompt ="마지막 날짜 : ")
  last_page = readline(prompt ="페이지 수 : ")


  
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
  content_all = c()
  post_all_1=c()
  date_all = c()

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
      
      
    })
    
    if(is.character(t)==TRUE){
      next
      
    }
      
    }
    

  
  
  # 게시글 본문과 링크 합치기
  df = data.frame('본문'=content_all,'링크'=post_all_1, '날짜'= date_all)
  return(df)
}

#################################################

#### 크롤링 시작
#### 밑에 라인 실행 후 콘솔 창에 필요한 값 입력
data = crawl_function()


