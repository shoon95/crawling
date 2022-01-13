library(RSelenium)
library(dplyr)
library(rvest)


portn<-as.integer(runif(1,1,5000))
rD<-rsDriver(port=portn, browser='chrome',chromever='84.0.4147.30')
remDr<-rD[['client']]

url<-'https://onland.kbstar.com/quics?page=C059710'
remDr$navigate(url)

# Sys. sleep(2)

iframe<-remDr$findElement(using='xpath', value='//*[@id="taein"]')
remDr$switchToFrame(iframe)

do_all<-c(1,2,3,4,5,6,7,9,10,11,12,13,14,15,16,17)

content<-data.frame()
table1_all<-data.frame()
table2_all<-data.frame()
table3_all<-data.frame()
table4_all<-data.frame()
table5_all<-data.frame()


for(d in 1:length(do_all)){ #d<-1
  do_select<-remDr$findElement(using='xpath', value='//*[@id="addr1-button"]/span[1]')
  do_select$clickElement()
  
  #d<-1
  value<-paste0('/html/body/div[2]/ul/li[',do_all[d],']/div')
  do<-remDr$findElement(using='xpath', value=value)
  do$clickElement()
  
  op<-remDr$findElement(using='xpath',value='//*[@id="mulgun_kind-button"]/span[1]')
  op$clickElement()
  
  apt<-remDr$findElement(using='xpath', value='/html/body/div[8]/ul/li[3]/div')
  apt$clickElement()
  
  start<-remDr$findElement(using='xpath', value='//*[@id="start_date"]')
  start$clearElement()
  start$sendKeysToElement(list('20050101'))
  
  end<-remDr$findElement(using='xpath', value='//*[@id="end_date"]')
  end$clearElement()
  end$sendKeysToElement(list('20181231'))
  
  sear<-remDr$findElement(using='xpath',value='/html/body/div[1]/div[2]/button')
  sear$clickElement()
  
  if(d==8){Sys.sleep(7)}else{Sys.sleep(3)}
  
  data<-remDr$getPageSource()[[1]]

  last<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[7]/div[2]/div/form[12]/span/button') %>% html_attrs() %>% as.character()
  pattern<-'[^0-9]'
  last_num<-gsub(pattern,"",last[[3]])

  for(i in 1:last_num){ #i<-1
    page<-paste0("dataSearch('tmpFrm', '",i,"');")
    pagemove <- remDr$executeScript(page, args = 1:2)
    
    Sys.sleep(1)
    
    data<-remDr$getPageSource()[[1]]
    
    Sys.setlocale('LC_ALL', locale='ENGLISH')
    content_re<-read_html(data) %>% html_node(xpath='//*[@id="mulList"]/div[1]/table') %>% html_table()
    Sys.setlocale('LC_ALL', 'KOREAN')
    
    
    
    for(t in 1 : nrow(content_re)){ #t<-2
      
      ID<-paste0(d,'-',i*10-10+t)
      
      base<-paste0('//*[@id="mulList"]/div[1]/table/tbody/tr[',t,']/td[3]/a')
      click<-remDr$findElement('xpath',base)
      click$clickElement()
      
      Sys.sleep(1)
      
      data<-remDr$getPageSource()[[1]]
      
      
      Sys.setlocale('LC_ALL', locale='ENGLISH')
      test1<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[2]/div[2]/div[2]/table') %>% html_table() %>% t()
      Sys.setlocale('LC_ALL', 'KOREAN')
      
      test1<-cbind(ID,test1)
      table1_all<-rbind(table1_all,test1)
      
      Sys.setlocale('LC_ALL', locale='ENGLISH')
      test2<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[3]/table') %>% html_table()
      Sys.setlocale('LC_ALL', 'KOREAN')
      
      
      
      if(grepl('대법원공고|중복',test2[1,1])){
        if(ncol(test2)==1){
          test2<-cbind(ID,test2,NA)
          colnames(test2)<-c('ID','V2','V3')
          table2_all<-rbind(table2_all,test2)
          
          Sys.setlocale('LC_ALL', locale='ENGLISH')
          test3<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[4]/table') %>% html_table() %>% t()
          Sys.setlocale('LC_ALL', 'KOREAN')
          
          #'감정기일',   '소유자',   '건물면적',   '개시결정일',   '채무자'   ,'토지면적'   ,'배당종기일'   ,'채권자',   '경매대상'
          
          test3_1<-data.frame(test3[2,]) %>% t()
          test3_2<-data.frame(test3[4,]) %>% t()
          test3_3<-data.frame(test3[6,]) %>% t()
          table3<-cbind(ID,test3_1,test3_2,test3_3)
          
          table3_all<-rbind(table3_all,table3)
          
          Sys.setlocale('LC_ALL', locale='ENGLISH')
          test4<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[5]/table') %>% html_table(fill = TRUE)
          Sys.setlocale('LC_ALL', 'KOREAN')
          
          test4<-cbind(ID,test4)
          table4_all<-rbind(table4_all,test4)
          
          Sys.setlocale('LC_ALL', locale='ENGLISH')
          test5<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[6]/table') %>% html_table()
          Sys.setlocale('LC_ALL', 'KOREAN')
          
          test5_1<-test5[,1:4]
          test5_2<-test5[,6:9]
          table5<-rbind(test5_1,test5_2)
          table5<-cbind(ID,table5)
          table5_all<-rbind(table5_all,table5)
          
          remDr$goBack()
          
          Sys.sleep(1)
          
          iframe<-remDr$findElement(using='xpath', value='//*[@id="taein"]')
          remDr$switchToFrame(iframe)
          
          pagemove <- remDr$executeScript(page, args = 1:2)
          
          Sys.sleep(1)
        }else{
          test2<-cbind(ID,test2)
          colnames(test2)<-c('ID','V2','V3')
          table2_all<-rbind(table2_all,test2)
          
          Sys.setlocale('LC_ALL', locale='ENGLISH')
          test3<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[4]/table') %>% html_table() %>% t()
          Sys.setlocale('LC_ALL', 'KOREAN')
          
          #'감정기일',   '소유자',   '건물면적',   '개시결정일',   '채무자'   ,'토지면적'   ,'배당종기일'   ,'채권자',   '경매대상'
          
          test3_1<-data.frame(test3[2,]) %>% t()
          test3_2<-data.frame(test3[4,]) %>% t()
          test3_3<-data.frame(test3[6,]) %>% t()
          table3<-cbind(ID,test3_1,test3_2,test3_3)
          
          table3_all<-rbind(table3_all,table3)
          
          Sys.setlocale('LC_ALL', locale='ENGLISH')
          test4<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[5]/table') %>% html_table(fill = TRUE)
          Sys.setlocale('LC_ALL', 'KOREAN')
          
          test4<-cbind(ID,test4)
          table4_all<-rbind(table4_all,test4)
          
          Sys.setlocale('LC_ALL', locale='ENGLISH')
          test5<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[6]/table') %>% html_table()
          Sys.setlocale('LC_ALL', 'KOREAN')
          
          test5_1<-test5[,1:4]
          test5_2<-test5[,6:9]
          table5<-rbind(test5_1,test5_2)
          table5<-cbind(ID,table5)
          table5_all<-rbind(table5_all,table5)
          
          remDr$goBack()
          
          Sys.sleep(1)
          
          iframe<-remDr$findElement(using='xpath', value='//*[@id="taein"]')
          remDr$switchToFrame(iframe)
          
          pagemove <- remDr$executeScript(page, args = 1:2)
          
          Sys.sleep(1)
        }

        
      }else{
        V2<-'경매목록 제공하지 않음'
        V2<-cbind(ID,V2,NA)
        table2_all<-rbind(table2_all,V2)
        
        Sys.setlocale('LC_ALL', locale='ENGLISH')
        test3<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[3]/table') %>% html_table() %>% t()
        Sys.setlocale('LC_ALL', 'KOREAN')
        
        test3_1<-data.frame(test3[2,]) %>% t()
        test3_2<-data.frame(test3[4,]) %>% t()
        test3_3<-data.frame(test3[6,]) %>% t()
        table3<-cbind(ID,test3_1,test3_2,test3_3)
        table3_all<-rbind(table3_all,table3)
        
        Sys.setlocale('LC_ALL', locale='ENGLISH')
        test4<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[4]/table') %>% html_table(fill=TRUE)
        Sys.setlocale('LC_ALL', 'KOREAN')
        test4<-cbind(ID,test4)
        table4_all<-rbind(table4_all,test4)
        
        Sys.setlocale('LC_ALL', locale='ENGLISH')
        test5<-read_html(data) %>% html_node(xpath='/html/body/div[1]/div[5]/table') %>% html_table(fill = TRUE)
        Sys.setlocale('LC_ALL', 'KOREAN')
        
        test5_1<-test5[,1:4]
        test5_2<-test5[,6:9]
        table5<-rbind(test5_1,test5_2)
        table5<-cbind(ID,table5)
        table5_all<-rbind(table5_all,table5)
        
        
        remDr$goBack()
        
        Sys.sleep(1)
        
        iframe<-remDr$findElement(using='xpath', value='//*[@id="taein"]')
        remDr$switchToFrame(iframe)
        
        pagemove <- remDr$executeScript(page, args = 1:2)
        
        Sys.sleep(1)
      }
      
    }

    
  }
  

  
 
}


