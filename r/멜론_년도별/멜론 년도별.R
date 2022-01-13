install.packages(pacman)
library(pacman)
p_load('rvest','dplyr','stringr','RSelenium','RCurl','curl','httr','xlsx')

setwd('C:/Users/sjhty/OneDrive - incubate B2C technologies/바탕 화면')
portn<-as.integer(runif(1,1,5000))

#################################### chromever 에 값은 본인 거로 채워넣으셈

rD<-rsDriver(port=portn, browser='chrome', chromever ='83.0.4103.14')

remDr<-rD$client

remDr$navigate('https://www.melon.com/')
a<-remDr$findElement(using='xpath', value='//*[@id="gnb_menu"]/ul[1]/li[1]/a/span[2]')
a$clickElement()
b<-remDr$findElement(using='xpath', value='//*[@id="gnb_menu"]/ul[1]/li[1]/div/div/button/span')
b$clickElement()


first<-remDr$findElement(using='xpath', value='//*[@id="d_chart_search"]/div/h4[2]/a')
first$clickElement()
all_contents<-data.frame()
for(i in 2:3){#i<-2
  if(i==1){
    value<-paste0('//*[@id="d_chart_search"]/div/div/div[1]/div[1]/ul/li[',i,']/span/label')
    
    
    y2020s<-remDr$findElement(using='xpath', value=value)
    y2020s$clickElement()
    
    Sys.sleep(1)
    
    y2020<-remDr$findElement(using='xpath', value='//*[@id="d_chart_search"]/div/div/div[2]/div[1]/ul/li/span/label')
    y2020$clickElement()
    
    Sys.sleep(1)
    
    for(t in 1:5){ #t<-1
      value<-paste0('/html/body/div/div[3]/div/div/form/div[1]/div/div/div[3]/div[1]/ul/li[',t,']/span/label')
      y2020_1<-remDr$findElement(using='xpath',value=value)
      y2020_1$clickElement()
      
      Sys.sleep(1)
      
      sel<-remDr$findElement(using='xpath', value='//*[@id="d_chart_search"]/div/div/div[5]/div[1]/ul/li[1]/span/label')
      sel$clickElement()
      
      Sys.sleep(1)
      
      search<-remDr$findElement(using='xpath', value='//*[@id="d_srch_form"]/div[2]/button/span/span')
      search$clickElement()
      
      Sys.sleep(1)
      
      data<-remDr$getPageSource()[[1]]
      
      Sys.sleep(1)
      
      title1<-read_html(data) %>% html_nodes(xpath='//*[@id="lst50"]/td[3]/div/a/img') %>% html_attr('alt') %>% data.frame()
      title1<-sapply(title1, function(x) str_remove(x,' - 페이지 이동')) %>% data.frame()
      title2<-read_html(data) %>% html_nodes(xpath='//*[@id="lst100"]/td[3]/div/a/img') %>% html_attr('alt') %>% data.frame()
      title2<-sapply(title2, function(x) str_remove(x,' - 페이지 이동')) %>% data.frame()
      title<-rbind(title1,title2)
      
      
      name1<-read_html(data) %>% html_nodes('.t_left')%>%html_nodes(xpath='//*[@id="lst50"]/td[4]/div/div/div[2]/div[1]/span') %>% html_text() %>% data.frame()
      name2<-read_html(data) %>% html_nodes('.t_left')%>%html_nodes(xpath='//*[@id="lst100"]/td[4]/div/div/div[2]/div[1]/span') %>% html_text() %>% data.frame()
      name<-rbind(name1,name2)
      
      
      rank1<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst50"]/td[2]/div') %>% html_nodes('.rank') %>% html_text() %>% data.frame()
      rank2<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst100"]/td[2]/div') %>% html_nodes('.rank') %>% html_text() %>% data.frame()
      rank_d1<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst50"]/td[2]/div/span[3]') %>% html_attr('title') %>% data.frame()
      rank_d2<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst100"]/td[2]/div/span[3]') %>% html_attr('title') %>% data.frame()
      rank<-rbind(rank1, rank2)
      rank_d<-rbind(rank_d1,rank_d2)
      
      time<-read_html(data) %>% html_node('.serch_cnt') %>% html_nodes('.datelk') %>% html_text()
      time<-str_trim(time)
      time<-paste0(time[1],time[2])
      
      all<-cbind(title,name,rank,rank_d,time)
      
      sour1<-read_html(data) %>%  html_nodes(xpath='//*[@id="lst50"]/td[3]/div/a') %>% html_attr('href') %>% data.frame()
      sour1<-sapply(sour1, function(x) gsub("[^0-9]", "",x)) %>% data.frame()
      sour2<-read_html(data) %>%  html_nodes(xpath='//*[@id="lst100"]/td[3]/div/a') %>% html_attr('href') %>% data.frame()
      sour2<-sapply(sour2, function(x) gsub("[^0-9]", "",x)) %>% data.frame() 
      sour_all<-rbind(sour1,sour2)
      
      
      base_url<-'https://www.melon.com/album/detail.htm?albumId='
      contents<-data.frame()
      
      
      all_contents_re<-cbind(all,sour_all)
      
  
      all_contents<-rbind(all_contents,all_contents_re)
      
    }
    

    
  }
  else if(i==2){
    
    value<-paste0('//*[@id="d_chart_search"]/div/div/div[1]/div[1]/ul/li[',i,']/span/label')
    
    
    y2020s<-remDr$findElement(using='xpath', value=value)
    y2020s$clickElement()
    
    Sys.sleep(1)
    
    for(z in 1: 10){ #z<-2
      value<-paste0('//*[@id="d_chart_search"]/div/div/div[2]/div[1]/ul/li[',z,']/span/label')
    
      y2020<-remDr$findElement(using='xpath', value=value)
      y2020$clickElement()
      
      Sys.sleep(1)
      
      for(t in 1:12){ #t<-1
        value<-paste0('/html/body/div/div[3]/div/div/form/div[1]/div/div/div[3]/div[1]/ul/li[',t,']/span/label')
        y2020_1<-remDr$findElement(using='xpath',value=value)
        y2020_1$clickElement()
        
        Sys.sleep(1)
        
        sel<-remDr$findElement(using='xpath', value='//*[@id="d_chart_search"]/div/div/div[5]/div[1]/ul/li[1]/span/label')
        sel$clickElement()
        
        Sys.sleep(1)
        
        search<-remDr$findElement(using='xpath', value='//*[@id="d_srch_form"]/div[2]/button/span/span')
        search$clickElement()
        
        Sys.sleep(1)
        
        data<-remDr$getPageSource()[[1]]
        
        Sys.sleep(1)
        
        title1<-read_html(data) %>% html_nodes(xpath='//*[@id="lst50"]/td[3]/div/a/img') %>% html_attr('alt') %>% data.frame()
        title1<-sapply(title1, function(x) str_remove(x,' - 페이지 이동')) %>% data.frame()
        title2<-read_html(data) %>% html_nodes(xpath='//*[@id="lst100"]/td[3]/div/a/img') %>% html_attr('alt') %>% data.frame()
        title2<-sapply(title2, function(x) str_remove(x,' - 페이지 이동')) %>% data.frame()
        title<-rbind(title1,title2)
        
        
        name1<-read_html(data) %>% html_nodes('.t_left')%>%html_nodes(xpath='//*[@id="lst50"]/td[4]/div/div/div[2]/div[1]/span') %>% html_text() %>% data.frame()
        name2<-read_html(data) %>% html_nodes('.t_left')%>%html_nodes(xpath='//*[@id="lst100"]/td[4]/div/div/div[2]/div[1]/span') %>% html_text() %>% data.frame()
        name<-rbind(name1,name2)
        
        rank1<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst50"]/td[2]/div') %>% html_nodes('.rank') %>% html_text() %>% data.frame()
        rank2<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst100"]/td[2]/div') %>% html_nodes('.rank') %>% html_text() %>% data.frame()
        rank_d1<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst50"]/td[2]/div/span[3]') %>% html_attr('title') %>% data.frame()
        rank_d2<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst100"]/td[2]/div/span[3]') %>% html_attr('title') %>% data.frame()
        rank<-rbind(rank1, rank2)
        rank_d<-rbind(rank_d1,rank_d2)

        
        time<-read_html(data) %>% html_node('.serch_cnt') %>% html_nodes('.datelk') %>% html_text()
        time<-str_trim(time)
        time<-paste0(time[1],time[2])
        
        all<-cbind(title,name,rank,rank_d,time)
        
        sour1<-read_html(data) %>%  html_nodes(xpath='//*[@id="lst50"]/td[3]/div/a') %>% html_attr('href') %>% data.frame()
        sour1<-sapply(sour1, function(x) gsub("[^0-9]", "",x)) %>% data.frame()
        sour2<-read_html(data) %>%  html_nodes(xpath='//*[@id="lst100"]/td[3]/div/a') %>% html_attr('href') %>% data.frame()
        sour2<-sapply(sour2, function(x) gsub("[^0-9]", "",x)) %>% data.frame() 
        sour_all<-rbind(sour1,sour2)
        
        
        
        base_url<-'https://www.melon.com/album/detail.htm?albumId='
        
        
        
        contents<-data.frame()
        
        
        all_contents_re<-cbind(all,sour_all)
        

        all_contents<-rbind(all_contents,all_contents_re)
      }
      
    }
    
    
    
  }
  else if(i==3){
    value<-paste0('//*[@id="d_chart_search"]/div/div/div[1]/div[1]/ul/li[',i,']/span/label')
    
    
    y2020s<-remDr$findElement(using='xpath', value=value)
    y2020s$clickElement()
    
    Sys.sleep(1)
    
    for(z in 1: 10){ #z<-6
      value<-paste0('//*[@id="d_chart_search"]/div/div/div[2]/div[1]/ul/li[',z,']/span/label')
      
      y2020<-remDr$findElement(using='xpath', value=value)
      y2020$clickElement()
      
      Sys.sleep(1)
      if(z>5){
        for(t in 1:12){ #t<-1
          value<-paste0('/html/body/div/div[3]/div/div/form/div[1]/div/div/div[3]/div[1]/ul/li[',t,']/span/label')
          y2020_1<-remDr$findElement(using='xpath',value=value)
          y2020_1$clickElement()
          
          Sys.sleep(1)
          
          sel<-remDr$findElement(using='xpath', value='//*[@id="d_chart_search"]/div/div/div[5]/div[1]/ul/li[1]/span/label')
          sel$clickElement()
          
          Sys.sleep(1)
          
          search<-remDr$findElement(using='xpath', value='//*[@id="d_srch_form"]/div[2]/button/span/span')
          search$clickElement()
          
          Sys.sleep(1)
          
          data<-remDr$getPageSource()[[1]]
          
          Sys.sleep(1)
          
          title1<-read_html(data) %>% html_nodes(xpath='//*[@id="lst50"]/td[3]/div/a/img') %>% html_attr('alt') %>% data.frame()
          title1<-sapply(title1, function(x) str_remove(x,' - 페이지 이동')) %>% data.frame()
          title2<-read_html(data) %>% html_nodes(xpath='//*[@id="lst100"]/td[3]/div/a/img') %>% html_attr('alt') %>% data.frame()
          title2<-sapply(title2, function(x) str_remove(x,' - 페이지 이동')) %>% data.frame()
          title<-rbind(title1,title2)
          
          
          name1<-read_html(data) %>% html_nodes('.t_left')%>%html_nodes(xpath='//*[@id="lst50"]/td[4]/div/div/div[2]/div[1]/span') %>% html_text() %>% data.frame()
          name2<-read_html(data) %>% html_nodes('.t_left')%>%html_nodes(xpath='//*[@id="lst100"]/td[4]/div/div/div[2]/div[1]/span') %>% html_text() %>% data.frame()
          name<-rbind(name1,name2)
          
          
          rank1<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst50"]/td[2]/div') %>% html_nodes('.rank') %>% html_text() %>% data.frame()
          rank2<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst100"]/td[2]/div') %>% html_nodes('.rank') %>% html_text() %>% data.frame()
          
          rank<-rbind(rank1, rank2)
          rank_d<-NA
          time<-read_html(data) %>% html_node('.serch_cnt') %>% html_nodes('.datelk') %>% html_text()
          time<-str_trim(time)
          time<-paste0(time[1],time[2])
          
          all<-cbind(title,name,rank,rank_d,time)
          
          sour1<-read_html(data) %>%  html_nodes(xpath='//*[@id="lst50"]/td[3]/div/a') %>% html_attr('href') %>% data.frame()
          sour1<-sapply(sour1, function(x) gsub("[^0-9]", "",x)) %>% data.frame()
          sour2<-read_html(data) %>%  html_nodes(xpath='//*[@id="lst100"]/td[3]/div/a') %>% html_attr('href') %>% data.frame()
          sour2<-sapply(sour2, function(x) gsub("[^0-9]", "",x)) %>% data.frame() 
          sour_all<-rbind(sour1,sour2)
          
          
          
          base_url<-'https://www.melon.com/album/detail.htm?albumId='
          
          
          
          
          
          #j<-2
          
          
          all_contents_re<-cbind(all,sour_all)
          colnames(all_contents_re)<-colnames(all_contents)
          all_contents<-rbind(all_contents,all_contents_re)
        }}
        else{
          for(t in 1:12){ #t<-1
            value<-paste0('/html/body/div/div[3]/div/div/form/div[1]/div/div/div[3]/div[1]/ul/li[',t,']/span/label')
            y2020_1<-remDr$findElement(using='xpath',value=value)
            y2020_1$clickElement()
            
            Sys.sleep(1)
            
            sel<-remDr$findElement(using='xpath', value='//*[@id="d_chart_search"]/div/div/div[5]/div[1]/ul/li[1]/span/label')
            sel$clickElement()
            
            Sys.sleep(1)
            
            search<-remDr$findElement(using='xpath', value='//*[@id="d_srch_form"]/div[2]/button/span/span')
            search$clickElement()
            
            Sys.sleep(1)
            
            data<-remDr$getPageSource()[[1]]
            
            Sys.sleep(1)
            
            title1<-read_html(data) %>% html_nodes(xpath='//*[@id="lst50"]/td[3]/div/a/img') %>% html_attr('alt') %>% data.frame()
            title1<-sapply(title1, function(x) str_remove(x,' - 페이지 이동')) %>% data.frame()
            title2<-read_html(data) %>% html_nodes(xpath='//*[@id="lst100"]/td[3]/div/a/img') %>% html_attr('alt') %>% data.frame()
            title2<-sapply(title2, function(x) str_remove(x,' - 페이지 이동')) %>% data.frame()
            title<-rbind(title1,title2)
            
            
            name1<-read_html(data) %>% html_nodes('.t_left')%>%html_nodes(xpath='//*[@id="lst50"]/td[4]/div/div/div[2]/div[1]/span') %>% html_text() %>% data.frame()
            name2<-read_html(data) %>% html_nodes('.t_left')%>%html_nodes(xpath='//*[@id="lst100"]/td[4]/div/div/div[2]/div[1]/span') %>% html_text() %>% data.frame()
            name<-rbind(name1,name2)
            
            
            rank1<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst50"]/td[2]/div') %>% html_nodes('.rank') %>% html_text() %>% data.frame()
            rank2<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst100"]/td[2]/div') %>% html_nodes('.rank') %>% html_text() %>% data.frame()
            rank_d1<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst50"]/td[2]/div/span[3]') %>% html_attr('title') %>% data.frame()
            rank_d2<-read_html(data) %>% html_nodes('.t_left') %>% html_nodes(xpath='//*[@id="lst100"]/td[2]/div/span[3]') %>% html_attr('title') %>% data.frame()
            rank<-rbind(rank1, rank2)
            rank_d<-rbind(rank_d1,rank_d2)
            
            time<-read_html(data) %>% html_node('.serch_cnt') %>% html_nodes('.datelk') %>% html_text()
            time<-str_trim(time)
            time<-paste0(time[1],time[2])
            
            all<-cbind(title,name,rank,rank_d,time)
            
            sour1<-read_html(data) %>%  html_nodes(xpath='//*[@id="lst50"]/td[3]/div/a') %>% html_attr('href') %>% data.frame()
            sour1<-sapply(sour1, function(x) gsub("[^0-9]", "",x)) %>% data.frame()
            sour2<-read_html(data) %>%  html_nodes(xpath='//*[@id="lst100"]/td[3]/div/a') %>% html_attr('href') %>% data.frame()
            sour2<-sapply(sour2, function(x) gsub("[^0-9]", "",x)) %>% data.frame() 
            sour_all<-rbind(sour1,sour2)
            
            
            
            base_url<-'https://www.melon.com/album/detail.htm?albumId='
            
            
            
            
            
            #j<-2
            
            
            all_contents_re<-cbind(all,sour_all)
            all_contents<-rbind(all_contents,all_contents_re)
        }
     
  }
    
  
  
  }
}
}

colnames(all_contents)<-c('title','singer','rank','change','time','code')

save.image('half.Rdata')

code<-tt[,7]

dd<-data.frame()
for(i in 2647: 3001){ #i<-1
  num<-code[i]
  base_url<-'https://www.melon.com/album/detail.htm?albumId='
  url<-paste0(base_url,num)
  data<- read_html(curl(url, handle = new_handle("useragent" = "Mozilla/5.0")))
  
  metadata <-data %>% html_nodes('.list dd') %>% html_text() %>% data.frame() %>% t()
  grade <- data %>% html_node('.grade') %>% html_nodes('.cnt') %>% html_text()
  dd_re<-cbind(metadata,grade)
  
  dd<-rbind(dd,dd_re)
  print(i)
}


write.xlsx(dd,'dd2647-3001.xlsx')
22312-19283   
