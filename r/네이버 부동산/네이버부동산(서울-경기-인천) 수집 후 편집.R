library(dplyr)
library(openxlsx)
library(stringr)
setwd('D:/R_크롤링/작업중/klnssydjmay-자료/통합')

name<-list.files(pattern='xlsx')


content<-data.frame()
for(i in 1:length(name)){
  print(name[i])
  temp<-read.xlsx(name[i])
  content<-rbind(content,temp)
}

a<-str_replace_all(content[,2],'전국','인천시')
content[,2]<-a

content_sort<-arrange(content, 도,구,동)


s<-which(content[,2]=='서울시')
k<-which(content[,2]=='경기도')
i<-which(content[,2]=='인천시')

s<-content[s,]
k<-content[k,]
i<-content[i,]

content_sort<-rbind(s,k,i)

write.xlsx(content_sort, 'content통합.xlsx')

pattern<-"억.*"

pos1<-which(str_match(content_sort[,5],pattern)=='억')

a<-content_sort[pos1,5]
b<-str_replace_all(a,'매매','')
c<-str_replace_all(b,'억','0000')
content_sort[pos1,5]<-c

pos2<-which(str_match(content_sort[,5],pattern)!='억')
a1<-content_sort[pos2,5]
b1<-str_replace_all(a1,'매매','')
c1<-str_replace_all(b1,'억','')
d1<-str_replace_all(c1,'\\,','')
e1<-str_replace_all(d1,' ','')
content_sort[pos2,5]<-e1
content_sort[,5]<-str_replace_all(content_sort[,5],'매매','')

names(content_sort)[5]<-'매매가격(단위:만원)'


a<-str_replace_all(content_sort[,6],'만원/3.3㎡','')
a<-str_replace_all(a,'\\,','')
content_sort[,6]<-a
names(content_sort)[6]<-'평당가격(단위:만원/m만원/3.3㎡)'

pattern<-"[0-9]{2,10}.*"
a<-str_match(content_sort[,8],pattern)
b<-str_replace_all(a,'㎡','')
content_sort[,8]<-b
names(content_sort)[8]<-'대지/연 면적(단위:㎡)'

write.xlsx(content_sort,'서울~경기~인천.xlsx')
