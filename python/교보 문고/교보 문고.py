import chromedriver_autoinstaller
from selenium import webdriver
import os
import pandas as pd
import time
import re


def open_chromedriver():
    ### 크롬 드라이버를 자신의 크롬 버전에 맞는 버전으로 자동 설치, 만약 설치 되어있다면 자신의 크롬 버전에 맞게 업데이트

    chrome = chromedriver_autoinstaller.install(os.getcwd())

    ### 크롬 실행 시 적용할 옵션 설정

    options = webdriver.ChromeOptions()

    ### options.headless=True 이 부분의 주석 처리를 제거해서 해당 부분을 적용시키면 크롬 화면을 띄우지 않고 작업 진행 가능
    # options.headless = True

    ### driver라는 변수에 chromedriver 원격 함수를 넣음

    driver = webdriver.Chrome(options=options)
    return (driver)


### 크롬 실행 후 함수를 driver 변수에 넣어서 사용

driver = open_chromedriver()

### 특정 url로 크롬 페이지 이동, 여기서는 교보문고 로그인 페이지로 이동

driver.get(
    'http://www.kyobobook.co.kr/login/login.laf?Kc=GNHHNOlogin&orderClick=c03&retURL=http%3A//www.kyobobook.co.kr/bestSellerNew/bestseller.laf')


### 네이버 계정으로 교보문고 로그인
### 사전에 네이버 계정으로 교보문고 회원가입 후 사용 가능

def log_by_naver():
    ###네이버 ID로 가입/로그인에 해당하는 부분의 값을 ctrl+shift+c를 눌러서 해당 위치에 마우스 올리고 클릭하여 개발자 도구에서 확인
    ###개발자 도구에서 해당 값을 마우스 우클릭 ->copy->xpath 복사
    ### 밑의 함수에 xpath 값을 넣어준 후 .click()을 활용하여 클릭

    driver.find_element_by_xpath('//*[@id="contents"]/div/div[1]/div[1]/div[1]/div/a[1]').click()

    time.sleep(1.5)

    ### 로그인 화면이 새로운 창으로 뜨기 때문에 작업 창 전환 필요
    ### 현재 떠있는 창들을 driver.window_handles함수로 확인하며 naver login창은 두 번째 이므로 [1]인덱스에 있음
    ### 따라서 driver.window_handles[1]을 선택 후 해당 탕으로 밑의 함수를 통해 전환

    driver.switch_to.window(driver.window_handles[1])

    ### ctrl+shift+c를 눌러서 id, pw 입력 부분의 xpath 값을 가져옴

    id = driver.find_element_by_xpath('//*[@id="id"]')
    pw = driver.find_element_by_xpath('//*[@id="pw"]')

    ### id와 pw를 입력

    id_value = input('아이디를 입력해주세요')
    pw_value = input('비밀번호를 입력해주세요')

    ### id에 해당하는 element value에 새로운 id_value를 넣어줌(로그인 할 id)

    driver.execute_script("arguments[0].setAttribute('value', arguments[1])", id, id_value)

    time.sleep(0.5)

    ### pw에 해당하는 element value에 새로운 id_value를 넣어줌(로그인 할 pw)

    driver.execute_script("arguments[0].setAttribute('value', arguments[1])", pw, pw_value)

    ## ctrl+shift+c를 눌러서 로그인 버튼 부분의 xpath값을 가져와 밑의 함수에 넣고.click()을 활요하여 클릭

    driver.find_element_by_xpath('//*[@id="log.login"]').click()

    ### 다시 교보 문고 원래 페이지로 화면 전환

    driver.switch_to.window(driver.window_handles[0])


log_by_naver()

time.sleep(3)

### 왼쪽의 '연간' 클릭
### ctrl+shift+c 누른 후 마우스로 연간 부분에 갖다대면 개발자 도구에서 해당 부분의 값들을 찾을 수 있음
### 개발자 도구에서 해당 부분 값에서 우클릭 -> copy -> xpath 를 가져옴

driver.find_element_by_xpath('//*[@id="main_snb"]/div[1]/ul/li[1]/ul/li[3]/a').click()

time.sleep(3)

### 50개씩 보기
### ctrl+shift+c 누른 후 마우스로 연간 부분에 갖다대면 개발자 도구에서 해당 부분의 값들을 찾을 수 있음
### 개발자 도구에서 해당 부분 값을 확인하여 javascript에 페이지 관련한 값을 찾을 수 있음. 해당 부분을 driver.execute_script에 적용하면 해당 페이지로 변경 가능

driver.execute_script("javascript: setPerpage('50')")

time.sleep(3)

###수집할 년도를 생성하여 search_date라는 변수에 담음

search_date = list(range(2000000, 2021000, 1000))

### 수집된 데이터를 담을 data라는 빈 데이터프레임 변수 미리 생성

data = pd.DataFrame()

### 년도와 페이지를 이동하며 데이터 수집

for i in search_date:

    ### 수집할 제목, url, 순위를 담을 변수를 미리 생성
    title = []
    link = []
    rank = []

    ### ctrl+shift+c를 눌러서 연도 옵션에 해당하는 부분에서 페이지로 이동하는 부분의 값을 확인 후 해당 값을
    ### driver.excute_script에 넣어서 해당 페이지로 이동, 이때 ('')안의 부분이 년도에 해당함으로 해당 부분만 for구문을 통해 바꾸어줌
    driver.execute_script("javascript:goSellBestYmw('%s')" % i)

    ### 페이지가 이동하기 충분하도록 1초간 기다려줌
    time.sleep(1)

    ### 페이지를 이동하며 가져옴, 한 페이지에 50개 씩 총 4페이지(200개)
    for num in range(1, 5):

        ### ctrl+shift+c를 눌러서 페이지 옵션에 해당하는 부분에서 페이지로 이동하는 부분의 값을 확인 후 해당 값을
        ### driver.excute_script에 넣어서 해당 페이지로 이동, 이때 ('')안의 부분이 페이지에 해당함으로 해당 부분만 for구문을 통해 바꾸어줌

        driver.execute_script("javascript:_go_targetPage('%s')" % num)
        time.sleep(1)

        ### ctrl+shift+c를 눌러서 책의 제목에 해당하는 부분의 값을 개발자 도구에서 확인-> li[]부분의 값이 바뀌면서 책들이 바뀜
        ### li부분만 바꾸어주면서 전체 책의 데이터를 가져옴, 만약 책의 데이터에 해당하는 부분이 값이 없다면 해당 페이지에 책들이 존재하지 않는다는 것으로 break를 통해 해당 년도 종료
        if len(driver.find_elements_by_xpath(
                '/html/body/div/div[1]/div[2]/form/div/div[3]/ul/li[*]/div[2]/div[2]/a')) == 0:
            break

        ### 위에서 확인한 개발자 도구를 보았을 때 책의 제목은 text로 들어있고, url은 'href'의 항목에 들어있으므로 각각 밑에 함수로 데이터를 가져옴
        for j in driver.find_elements_by_xpath('/html/body/div/div[1]/div[2]/form/div/div[3]/ul/li[*]/div[2]/div[2]/a'):
            link.append(j.get_attribute('href'))
            title.append(j.text)

        ### ctrl+shift+c를 눌러서 책의 랭크에 해당하는 부분 xpath 값을 가져옴
        ### li값을 변경하면서 전체 랭크를 가져와서 rank라는 변수에 순서대로 담음
        for k in driver.find_elements_by_xpath('//*[@id="main_contents"]/ul/li[*]/div[1]/a/strong'):
            rank.append(k.text)
        print('date:', str(i)[0:4], ' page:', num)

    ### 한 년도의 데이터 수집이 끝나면 데이터프레임으로 만들어 temp라는 변수에 저장
    temp = pd.DataFrame({'date': str(i)[0:4], 'rank': rank, 'title': title, 'link': link})

    ### temp에 담긴 데이터 프레임을 기존에 만들어 놓은 data라는 데이터프레임에 차곡차곡 쌓음
    data = pd.concat([data, temp], axis=0)

### 데이터 수집이 전부 끝나면 data의 인덱스를 재정렬함
data = data.reset_index(drop=True)


### 키워드 수집 함수

def get_keyword():
    ### 키워드를 담을 리스트를 key라는 변수명으로 생성
    key = []

    ###키워드 부분은 class값을 개발자 도구에서 확인-> 하위 태그'a'에 키워드에 해당하는 값들이 들어있음
    ###class->tag 순서로 접근하여 해당 키워드를 가져옴
    for i in driver.find_element_by_class_name('book_keyword').find_elements_by_tag_name('a'):
        key.append(i.text)
    return (key)


### 책의 제목 수집 함수
def get_title():
    ### 책의 제목에 해당하는 xpath 값을 개발자 도구에서 확인 후 해당 부분의 텍스트를 가져옴
    return (driver.find_element_by_xpath('//*[@id="container"]/div[2]/form/div[1]/h1/strong').text)


### 출판 날짜 수집
def get_publishing():
    ### 출판 날짜에 해당하는 class 값을 개발자 도구에서 확인 후 해당 부분의 텍스트를 가져옴, 이후 숫자만 남기고 다른 모든 문자 제거
    return (re.sub('[^0-9]', '', driver.find_element_by_class_name('date').text))

### 저자 수집
def get_writer():
    ### 저자에 해당하는 class 값을 개발자 도구에서 확인 후 해당 부분의 텍스트를 가져옴
    return(driver.find_element_by_class_name('detail_author').text)
### writer,keyworkd,title,publishing,link 데이터를 담을 빈 리스트를 미리 생성 후 for 구문을 통해 기존에 수집한 책의 url을 이동하며 데이터 수집

writer = []
keyword = []
title = []
publishing = []
link = []
num = 0
for i in data['link'][1353:]:
    driver.get(i)
    time.sleep(0.5)

    ### 해당 도서의 페이지가 사라진 경우 title과 link는 기존 data 값으로 대체하고 나머지는 None 값으로 채움
    try:
        driver.find_element_by_xpath('//*[@id="container"]/table/tbody/tr[1]/td').text
        writer.append(None)
        keyword.append(None)
        title.append(data['title'][num])
        publishing.append(None)
        link.append(i)
        driver.delete_all_cookies()
        print(num, '/', len(data))
        num += 1

    except:
        writer.append(get_writer())
        keyword.append(get_keyword())
        title.append(get_title())
        publishing.append(get_publishing())
        link.append(i)
        driver.delete_all_cookies()
        print(num, '/', len(data))
        num += 1

data2 = pd.DataFrame({'writer': writer, 'keyword': keyword, 'title': title, 'publishing': publishing, 'link': link})

total = pd.concat([data, data2], axis=1).iloc[:, 0:6]

total.to_csv('교보문고 데이터 수집.csv', encoding='euckr')