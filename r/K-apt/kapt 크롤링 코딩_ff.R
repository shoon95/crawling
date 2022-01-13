

########################################패키지 설치#######################
####(isntall.packages()는 한 번만 설치하면 영구적으로 사용가능, 설치할 때는 #을 없애고 실행)
#install.packages("rvest") #< :: 에서 크롤링 할 때 사용하는 패키지 
#install.packages('XML') # ::XML 처리를 위한 패키지 
#install.packages('xlsx') # :: r에서 엑셀 파일을 읽고 쓸 수 있도록 하는 패키지
#install.packages("dplyr")# :: 데이터 핸들링을 위한 패키지

####################################패키지 부착#########################

library(rvest) 
library(XML)
library(xlsx)
library(dplyr)

########################################## 법정동 코드로 kaptcode 가져오기 ############################
options(stringsAsFactors=FALSE) # :: 데이터 파일을 불러올 때 자동변환을 막아 숫자는 숫자, 문자는 문자 그대로 인식시키는 코드

options(scipen=100) # :: 숫자가 커지면 축약되는 것을 100자리 까지는 그대로 나타나도록만드는 코드

setwd("C:/Users/sanghoon/Desktop/크롤링/홍대 크롤링 부탁 자료/법정동코드 전체자료/크롤링 완료") # :: 작업 디렉토리 설정

loadcode<-read.csv("법정동코드 정리.csv", header=TRUE) # :: 인터넷에서 다운 받은 법정동 코드 엑셀 파일을 불러와 loadcode라는 변수명 넣어주기

loadcode_re<-subset(loadcode, 폐지여부=='존재') # :: 법정동 데이터 중 폐지여부가 존재인 데이터만 남기기

rownames(loadcode_re)<-1:nrow(loadcode_re) # :: 데이터의 rowname을 1~'마지막 데이터의 수'로 변환

loadcode_re<-unique(loadcode_re) # :: 중복되는 데이터 제거

loadcode<-loadcode_re[,1] # :: 법정동코드만(1열)을 뽑아서 loadcode변수명에 넣어주기

kaptcode1<-data.frame() # :: kaptcode를 담은 데이터 프레임 변수 생성(트래픽 문제로 3차례에 걸쳐 진행)
kaptcode2<-data.frame() # :: kaptcode를 담은 데이터 프레임 변수 생성
kaptcode3<-data.frame() # :: kaptcode를 담은 데이터 프레임 변수 생성

for(i in 1:100){	
  
  print(i) # ::'i' 출력(여기에서는 1~9000이 순차적으로 출력)
  
  loadcode_num<-loadcode[i] # :: loadcode의 i번 째 데이터를 loadcode_num 이라는 변수에 저장
  
  rest_url<-paste0("http://apis.data.go.kr/1611000/AptListService/getLegaldongAptList?loadCode=",loadcode_num,"&numOfRows=100&ServiceKey=") # :: ,를 기준으로 총 세 가지 문자를 공백없이 붙여서 rest_url 이라는 변수명에 저장
  
  service_key<-"YKIsIN881yttTiA68%2BBXZTvcGA3LR4bgDkSu2g5WNzUkVgaesK8i80Apcw%2BEMKJ6mBIEIZCPYM5EgCy8wuPW1w%3D%3D" # :: 서비스  키를 service_key라는 변수명에 저장
  
  list_url<-paste0(rest_url,service_key) # :: 위에서 만든 rest_url, service_key를 공백없이 붙여서 list_url 변수에 저장 
  
  data<-try(xmlRoot(xmlParse(list_url)), silent = TRUE) 
  
  # xmlParse : url을 읽어오는 함수
  # xmlRoot  : 가장 최상위 node 가져오기
  # try : 에러가 나더라도 skip하고 그대로 진행
  # :: url을 읽어와 최상위 노드를 뽑고 이 과정에서 에러가 나더라도 그대로 진행하는 코드를 data라는 변수에 저장  
  if(is.character(data)==TRUE){ # ::data가 true일 경우(에러가 발생한 경우) 
    
    Sys.sleep(100) # :: 100초 동안 쉼
    
    data<-try(xmlRoot(xmlParse(list_url)), silent = TRUE) 
    
    kaptcode_re<-xmlToDataFrame(getNodeSet(data, "//item")) 
    
    # getNodeSet : data에서 'item'이 들어가는 노드를 가져옴
    # xmlToDataFrame : xml 데이터를 데이터 프레임으로 저장
    # :: data에서 'item'이 들어가는 노드를 가져오고 이 자료들을 데이터 프레임 형식으로 저장해서 kaptcode_re 변수에 저장
    kaptcode_re<-mutate(kaptcode_re,loadcode_num=loadcode_num) 
    # :: kaptcode_re라는 데이터 프레임에 loadcode_num이라는 열을 추가하고 loadcode_num 데이터를 넣는다
    
    
  }else{
  
    kaptcode_re<-xmlToDataFrame(getNodeSet(data, "//item"))
  
    kaptcode_re<-mutate(kaptcode_re,loadcode_num=loadcode_num)
    
  }
 
   kaptcode1<-rbind(kaptcode1,kaptcode_re) # :: kaptcode1 과 kaptcode_re를 합쳐서 kaptcode1라는 변수에 저장
  
  
} # :: 변수 'i' 에1~9000을 순차적으로 넣으며 반복하여 데이터 수집

for(i in 9001:18000){
  print(i)
  
  loadcode_num<-loadcode[i]
  
  rest_url<-paste0("http://apis.data.go.kr/1611000/AptListService/getLegaldongAptList?loadCode=",loadcode_num,"&numOfRows=100&ServiceKey=")
  
  service_key<-"%2B7usPqpb3zxa9HoRrEQARmPHlwxjgaAwjAiHpqzzyQ71Ewd%2BeVtH53FPLgvz%2F4wFxSRHDltIdBN1k218wfZGMg%3D%3D"
  
  list_url<-paste0(rest_url,service_key)
  
  data<-try(xmlRoot(xmlParse(list_url)), silent = TRUE)
  
  if(is.character(data)==TRUE){
    
    
    Sys.sleep(100)
    
    kaptcode_re<-xmlToDataFrame(getNodeSet(data, "//item"))
    
    kaptcode_re<-mutate(kaptcode_re,loadcode_num=loadcode_num)
    
  }else{
    
    kaptcode_re<-xmlToDataFrame(getNodeSet(data, "//item"))
    
    kaptcode_re<-mutate(kaptcode_re,loadcode_num=loadcode_num)
    
  }
  
  kaptcode2<-rbind(kaptcode2,kaptcode_re)
  

  
} 

for(i in 18001:20542){
  print(i)
  
  loadcode_num<-loadcode[i]
  
  rest_url<-paste0("http://apis.data.go.kr/1611000/AptListService/getLegaldongAptList?loadCode=",loadcode_num,"&numOfRows=100&ServiceKey=")
  
  service_key<-"kh5Xsk08P28tegDzzlrTEUWPSEgRJmH4umI0nXVzBkYQXqOZcx%2BVeNY89FRP2kppEUEkJ9bkTrEsNcSXB5DqOQ%3D%3D"
  
  list_url<-paste0(rest_url,service_key)
  
  data<-try(xmlRoot(xmlParse(list_url)), silent = TRUE)
  
  if(is.character(data)==TRUE){
    
    Sys.sleep(100)
    
    kaptcode_re<-xmlToDataFrame(getNodeSet(data, "//item"))
    
    kaptcode_re<-mutate(kaptcode_re,loadcode_num=loadcode_num)
    
  }else{
    
    kaptcode_re<-xmlToDataFrame(getNodeSet(data, "//item"))
    
    kaptcode_re<-mutate(kaptcode_re,loadcode_num=loadcode_num)
    
  }
  
  kaptcode3<-rbind(kaptcode3,kaptcode_re)
  
  
} 

kaptcode<-rbind(kaptcode1,kaptcode2,kaptcode3) # :: 위에서 수집된 데이터 kaptcode 1~3을 합쳐서 kaptcode에 저장

kaptcode<-unique(kaptcode) # :: 중복된 데이터 제거

write.xlsx(kaptcode, "kaptcode최종.xlsx", row.names=FALSE) # ::kaptcode를 "kaptcode최종"이라는 엑셀 파일로 저장

################################## kapt 기본 정보 수집하기 #####################################################

options(stringsAsFactors=FALSE) # ::데이터 파일을 불러올 때 자동변환을 막아 숫자는 숫자, 문자는 문자 그대로 인식시키는 코드

name<-read.xlsx('kaptcode최종.xlsx',1, encoding='UTF-8') # ::"kaptcode최종" 엑셀 파일의 1번 시트 가져와서 name 이라는 변수에 저장

Code_list<-name[,1] # :: name의 1번 열의 kaptcode를 code_list 변수에 저장

Code<-Code_list[1] # :: code_list의 1번 데이터를 Code 변수에 저장

info_url<-paste0("http://apis.data.go.kr/1611000/AptBasisInfoService/getAphusBassInfo?kaptCode=",Code,"&ServiceKey=") # :: ,를 기준으로 문자열을 공백없이 합쳐 info_url에 저장

key<-"kh5Xsk08P28tegDzzlrTEUWPSEgRJmH4umI0nXVzBkYQXqOZcx%2BVeNY89FRP2kppEUEkJ9bkTrEsNcSXB5DqOQ%3D%3D" # :: 발급 받은 key를 key라는 변수에 저장

result_url<-paste0(info_url,key) # :: 위에서 만든 info_url, key를 공백없이 합쳐서 result_url 변수에 저장

apt_inf<-xmlRoot(xmlParse(result_url)) # ::result_url을 xml형식으로 읽고 최상위 노드를 apt_inf 변수에 저장

apt_item<-apt_inf[[2]][['item']] # :: 최상위 노드 중 2번 째에서 'item' 노드를 apt_item 변수에 저장

apt_value<-xmlSApply(apt_item, xmlValue)

# xmlSApply xml 형식의 각 데이터들에 동시 작업을 하게 하는 함수
# xmlValue 데이터의 값을 뽑아냄 ex(<title>아파트이름</title>) 이라면 title이라는 데이터의 값인 '아파트이름' 이라는 값을 뽑아냄)
# :: xmlSApply를 통해 xmlValue를 모든 데이터에 적용 

apt_df<-data.frame(명칭=apt_value['kaptName'], 법정동주소=apt_value['kaptAddr'], 분양형태=apt_value['codeSaleNm'],난방방식=apt_value['codeHeatNm'],
                     연면적=apt_value['kaptTarea'], 동수=apt_value['kaptDongCnt'], 세대수=apt_value['kaptdaCnt'], 시공사=apt_value['kaptBcompany'], 시행사=apt_value['kaptAcompany'],
                     관리사무소연락처_FAX=apt_value['kaptTel'], 관리사무소팩스=apt_value['kaptFax'], 홈페이지주소=apt_value['kaptUrl'], 단지분류=apt_value['codeAptNm'],
                     도로명주소=apt_value['doroJuso'], 관리방식=apt_value['codeMgrNm'], 복도유형=apt_value['codeHallNm'], 사용승인일=apt_value['kaptUsedate'],
                     주거전용면적=apt_value['privArea'], 면적별세대현황60이하=apt_value['kaptMparea_60'],면적별세대현황60_85이하=apt_value['kaptMparea_85'],
                     면적별세대현황85_135이하=apt_value['kaptMparea_135'],면적별세대현황136=apt_value['kaptMparea_136'])

# 위에서 뽑아낸 값들을 apt_df 라는 데이터 프레임에 크롤링 결과 예시로 주어진 열 이름과 동일하게 입력

for(i in 9000){ # Code<-'A61375703'
  
  print(i)  
  
  Code<-Code_list[i]
  
  info_url<-paste0("http://apis.data.go.kr/1611000/AptBasisInfoService/getAphusBassInfo?kaptCode=",Code,"&ServiceKey=")
  
  key<-"YKIsIN881yttTiA68%2BBXZTvcGA3LR4bgDkSu2g5WNzUkVgaesK8i80Apcw%2BEMKJ6mBIEIZCPYM5EgCy8wuPW1w%3D%3D"
  
  result_url<-paste0(info_url,key)
  
  apt_inf<-xmlParse(result_url)
  
  apt_inf<-xmlRoot(apt_inf)
  
  apt_item<-apt_inf[[2]][['item']]
  
  apt_value<-xmlSApply(apt_item, xmlValue)
  
  apt_df_re<-data.frame(명칭=apt_value['kaptName'], 법정동주소=apt_value['kaptAddr'], 분양형태=apt_value['codeSaleNm'],난방방식=apt_value['codeHeatNm'],
                          연면적=apt_value['kaptTarea'], 동수=apt_value['kaptDongCnt'], 세대수=apt_value['kaptdaCnt'], 시공사=apt_value['kaptBcompany'], 시행사=apt_value['kaptAcompany'],
                          관리사무소연락처_FAX=apt_value['kaptTel'], 관리사무소팩스=apt_value['kaptFax'], 홈페이지주소=apt_value['kaptUrl'], 단지분류=apt_value['codeAptNm'],
                          도로명주소=apt_value['doroJuso'], 관리방식=apt_value['codeMgrNm'], 복도유형=apt_value['codeHallNm'], 사용승인일=apt_value['kaptUsedate'],
                          주거전용면적=apt_value['privArea'], 면적별세대현황60이하=apt_value['kaptMparea_60'],면적별세대현황60_85이하=apt_value['kaptMparea_85'],
                          면적별세대현황85_135이하=apt_value['kaptMparea_135'],면적별세대현황136=apt_value['kaptMparea_136'])
  
  if(nrow(apt_df_re)<1){
    
    info_url<-paste0("http://apis.data.go.kr/1611000/AptBasisInfoService/getAphusBassInfo?kaptCode=",Code,"&ServiceKey=")
    
    key<-"YKIsIN881yttTiA68%2BBXZTvcGA3LR4bgDkSu2g5WNzUkVgaesK8i80Apcw%2BEMKJ6mBIEIZCPYM5EgCy8wuPW1w%3D%3D"
    
    result_url<-paste0(info_url,key)
    
    Sys.sleep(100)
    
    apt_inf<-xmlParse(result_url)
    
    apt_inf<-xmlRoot(apt_inf)
    
    apt_item<-apt_inf[[2]][['item']]
    
    apt_value<-xmlSApply(apt_item, xmlValue)
    
    apt_df_re<-data.frame(명칭=apt_value['kaptName'], 법정동주소=apt_value['kaptAddr'], 분양형태=apt_value['codeSaleNm'],난방방식=apt_value['codeHeatNm'],
                            연면적=apt_value['kaptTarea'], 동수=apt_value['kaptDongCnt'], 세대수=apt_value['kaptdaCnt'], 시공사=apt_value['kaptBcompany'], 시행사=apt_value['kaptAcompany'],
                            관리사무소연락처_FAX=apt_value['kaptTel'], 관리사무소팩스=apt_value['kaptFax'], 홈페이지주소=apt_value['kaptUrl'], 단지분류=apt_value['codeAptNm'],
                            도로명주소=apt_value['doroJuso'], 관리방식=apt_value['codeMgrNm'], 복도유형=apt_value['codeHallNm'], 사용승인일=apt_value['kaptUsedate'],
                            주거전용면적=apt_value['privArea'], 면적별세대현황60이하=apt_value['kaptMparea_60'],면적별세대현황60_85이하=apt_value['kaptMparea_85'],
                            면적별세대현황85_135이하=apt_value['kaptMparea_135'],면적별세대현황136=apt_value['kaptMparea_136'])
    
    apt_df<-rbind(apt_df,apt_df_re)
  }else{
    apt_df<-rbind(apt_df,apt_df_re)
  }
  
 
} # 위 함수들을 반복 (위의 코드와 동일하여 설명은 생략하겠습니다)



for(i in 9001:length(Code_list)){ # Code<-'A61375703'
  
  print(i)  
  
  Code<-Code_list[i]
  
  info_url<-paste0("http://apis.data.go.kr/1611000/AptBasisInfoService/getAphusBassInfo?kaptCode=",Code,"&ServiceKey=")
  
  key<-"DGXvy0wkdysMYl8zPIs6Q5bG%2FLI8qUiE9PSg7lvAIakgvVxZQzr%2F8QsT%2Bym8jZBGZLf7mOWn6JM9iYJChrKRQw%3D%3D"
  
  result_url<-paste0(info_url,key)
  
  apt_inf<-xmlParse(result_url)
  
  apt_inf<-xmlRoot(apt_inf)
  
  apt_item<-apt_inf[[2]][['item']]
  
  apt_value<-xmlSApply(apt_item, xmlValue)
  
  apt_df_re<-data.frame(명칭=apt_value['kaptName'], 법정동주소=apt_value['kaptAddr'], 분양형태=apt_value['codeSaleNm'],난방방식=apt_value['codeHeatNm'],
                          연면적=apt_value['kaptTarea'], 동수=apt_value['kaptDongCnt'], 세대수=apt_value['kaptdaCnt'], 시공사=apt_value['kaptBcompany'], 시행사=apt_value['kaptAcompany'],
                          관리사무소연락처_FAX=apt_value['kaptTel'], 관리사무소팩스=apt_value['kaptFax'], 홈페이지주소=apt_value['kaptUrl'], 단지분류=apt_value['codeAptNm'],
                          도로명주소=apt_value['doroJuso'], 관리방식=apt_value['codeMgrNm'], 복도유형=apt_value['codeHallNm'], 사용승인일=apt_value['kaptUsedate'],
                          주거전용면적=apt_value['privArea'], 면적별세대현황60이하=apt_value['kaptMparea_60'],면적별세대현황60_85이하=apt_value['kaptMparea_85'],
                          면적별세대현황85_135이하=apt_value['kaptMparea_135'],면적별세대현황136=apt_value['kaptMparea_136'])
  
  if(nrow(apt_df_re)<1){
    
    info_url<-paste0("http://apis.data.go.kr/1611000/AptBasisInfoService/getAphusBassInfo?kaptCode=",Code,"&ServiceKey=")
    
    key<-"YKIsIN881yttTiA68%2BBXZTvcGA3LR4bgDkSu2g5WNzUkVgaesK8i80Apcw%2BEMKJ6mBIEIZCPYM5EgCy8wuPW1w%3D%3D"
    
    result_url<-paste0(info_url,key)
    
    Sys.sleep(100)
    
    apt_inf<-xmlParse(result_url)
    
    apt_inf<-xmlRoot(apt_inf)
    
    apt_item<-apt_inf[[2]][['item']]
    
    apt_value<-xmlSApply(apt_item, xmlValue)
    
    apt_df_re<-data.frame(명칭=apt_value['kaptName'], 법정동주소=apt_value['kaptAddr'], 분양형태=apt_value['codeSaleNm'],난방방식=apt_value['codeHeatNm'],
                            연면적=apt_value['kaptTarea'], 동수=apt_value['kaptDongCnt'], 세대수=apt_value['kaptdaCnt'], 시공사=apt_value['kaptBcompany'], 시행사=apt_value['kaptAcompany'],
                            관리사무소연락처_FAX=apt_value['kaptTel'], 관리사무소팩스=apt_value['kaptFax'], 홈페이지주소=apt_value['kaptUrl'], 단지분류=apt_value['codeAptNm'],
                            도로명주소=apt_value['doroJuso'], 관리방식=apt_value['codeMgrNm'], 복도유형=apt_value['codeHallNm'], 사용승인일=apt_value['kaptUsedate'],
                            주거전용면적=apt_value['privArea'], 면적별세대현황60이하=apt_value['kaptMparea_60'],면적별세대현황60_85이하=apt_value['kaptMparea_85'],
                            면적별세대현황85_135이하=apt_value['kaptMparea_135'],면적별세대현황136=apt_value['kaptMparea_136'])
    
    apt_df<-rbind(apt_df,apt_df_re)
  }else{
    apt_df<-rbind(apt_df,apt_df_re)
  }
  
  
}


#################################

write.xlsx(apt_df, "apt_df수집완료.xlsx", row.names=FALSE) # :: 수집된 데이터들 엑셀 형식으로 저장
