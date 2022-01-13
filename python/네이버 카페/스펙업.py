from selenium import webdriver
import pandas as pd
import re
import time
import os, sys

options = webdriver.ChromeOptions()
options.headless = True
options.add_argument("window-size=1920x1080")

if getattr(sys, 'frozen', False):
    chromedriver_path = os.path.join(sys._MEIPASS, "chromedriver.exe")
    driver = webdriver.Chrome(chromedriver_path, options=options)
else:
    driver = webdriver.Chrome(options=options)

keyword = ['대면', '비대면', '강의', '수업', '코로나', '싸강', '온라인', '오프라인']

### 페이지 이동 (스펙업)

driver.get('https://cafe.naver.com/specup')

### 로그인 페이지 이동

log_in = driver.find_element_by_xpath('//*[@id="gnb_login_button"]/span[3]')
log_in.click()

### 아이디, 비밀번호 입력

id = driver.find_element_by_xpath('//*[@id="id"]')
pw = driver.find_element_by_xpath('//*[@id="pw"]')

id_value = input('아이디를 입력해주세요')
pw_value = input('비밀번호를 입력해주세요')

driver.execute_script("arguments[0].setAttribute('value', arguments[1])", id, id_value)

time.sleep(0.5)

driver.execute_script("arguments[0].setAttribute('value', arguments[1])", pw, pw_value)

time.sleep(0.5)
### 로그인 버튼 클릭

login = driver.find_element_by_xpath('//*[@id="log.login"]')
login.click()

time.sleep(1)

if (driver.current_url) == 'https://nid.naver.com/nidlogin.login':
    driver.quit()
    raise Exception('로그인 실패 오류')

title_all = []
url_all = []
word_all = []

for word in keyword:

    ### 페이지 이동 (스펙업)

    driver.get('https://cafe.naver.com/specup')

    #### 대학생 | 이야기방 카테고리 이동

    driver.find_element_by_xpath('//*[@id="menuLink1211"]').click()

    ### 게시글이 있는 iframe으로 전환

    iframe = driver.find_element_by_xpath('//*[@id="cafe_main"]')
    driver.switch_to.frame(iframe)

    ### 기간 설정
    driver.find_element_by_xpath('//*[@id="currentSearchDate"]').click()

    time.sleep(0.5)

    try:
        start = driver.find_element_by_xpath('//*[@id="input_1"]')

        start.clear()

        start.send_keys('2019-11-01')

        time.sleep(1)

        driver.find_element_by_xpath('//*[@id="btn_set"]').click()
    except:
        driver.find_element_by_xpath('//*[@id="MessageBoxLayer"]/div/div/div/div/div/div/div[2]/a[2]/img').click()

        start = driver.find_element_by_xpath('//*[@id="input_1"]')
        start.clear()
        start.send_keys('2019-11-01')

        time.sleep(1)

        driver.find_element_by_xpath('//*[@id="btn_set"]').click()

    ### 키워드 검색

    search_space = driver.find_element_by_xpath('//*[@id="query"]')
    search_space.clear()
    search_space.send_keys(word)

    driver.find_element_by_xpath('//*[@id="main-area"]/div[7]/form/div[3]/button').click()

    ### 60개씩 보기
    driver.find_element_by_xpath('//*[@id="listSizeSelectDiv"]').click()

    time.sleep(0.1)

    driver.find_element_by_xpath('//*[@id="listSizeSelectDiv"]/ul/li[7]/a').click()

    time.sleep(0.1)

    ### 페이지 url 가져오기

    page = driver.find_element_by_xpath('//*[@id="main-area"]/div[7]/a[1]')
    page_base = page.get_attribute('href')

    num = 0
    while True:
        print(word)
        num = num + 1
        page_num = 'page=%d' % num
        url = re.sub('page=1', page_num, page_base)

        driver.get(url)

        ### 게시글이 있는 iframe으로 전환

        iframe = driver.find_element_by_xpath('//*[@id="cafe_main"]')
        driver.switch_to.frame(iframe)

        ### 게시글의 제목, url 가져오기

        title = driver.find_elements_by_xpath('//*[@id="main-area"]/div[5]/table/tbody/tr[*]/td[1]/div[2]/div/a[1]')

        for i in title:
            title_all.append(i.text)
            url_all.append(i.get_attribute('href'))

            word_all.append(word)

        if (len(title) == 0):
            break

url

### 게시글 가져오기
content_all = []
review_all = []
date_all = []

page = 0
for i in url_all:

    page = page + 1

    print(page, '/', len(url_all))

    driver.get(i)
    time.sleep(1)
    try:
        result = driver.switch_to.alert
        result.accept()

        content = ' 삭제된 게시글'
        content_all.append(content)
        date = None
        date_all.append(date)
        review = None
        review_all.append(review)

        continue
    except:
        None
    time.sleep(1.2)

    ### 게시글의 데이터가 있는 iframe으로 전환
    try:
        iframe = driver.find_element_by_xpath('//*[@id="cafe_main"]')
        driver.switch_to.frame(iframe)
    except:
        if len(driver.switch_to.alert) != 0:
            result = driver.switch_to.alert
            result.accept()
            content = ' 삭제된 게시글'
            content_all.append(content)
            date = None
            date_all.append(date)
            review = None
            review_all.append(review)
            continue
        else:
            driver.get(i)

            time.sleep(3)

            iframe = driver.find_element_by_xpath('//*[@id="cafe_main"]')
            driver.switch_to.frame(iframe)

    ### 게시글 내용 가져오기

    try:
        content = driver.find_element_by_class_name('article_viewer')
        content_all.append(content.text)
    except:
        time.sleep(2)

        content = driver.find_element_by_class_name('article_viewer')
        content_all.append(content.text)

    ### 댓글 내용 가져오기

    review_base = []

    review = driver.find_elements_by_class_name('text_comment')

    if len(review) == 0:
        review = None
        review_base.append(review)
        review_all.append(review_base)

    elif len(review) == 1:
        review_base.append(driver.find_element_by_class_name('text_comment').text)
        review_all.append(review_base)
    else:
        for i in review:
            review_base.append(i.text)
        review_all.append("/".join(review_base))

    ### 날짜 가져오기
    try:
        date = driver.find_elements_by_class_name('date')
        for d in date:
            date_all.append("".join(d.text.split('.')[0:3]))
    except:
        time.sleep(2)
        date = driver.find_elements_by_class_name('date')
        for d in date:
            date_all.append("".join(d.text.split('.')[0:3]))

df_original = {'Keyword': word_all, 'Title': title_all, 'Date': date_all, 'Content': content_all, 'Review': review_all,
               'URL': url_all}
df_original = pd.DataFrame(df_original)

#### 불필요한 텍스트 삭제
rt = re.compile('https://vo.la/VJbP7\n')
content_all_2 = []
content_all_3 = []
content_all_4 = []

for i in df_original['Content']:
    try:
        if len(rt.findall(i)) == 0:
            content = i
            content_all_2.append(content)
        else:
            content = re.split('https://vo.la/VJbP7\n', i)[0]
            content_all_2.append(content)
    except:
        content = i
        content_all_2.append(content)

rt = re.compile('🍀스펙업이 5만원을 아낌없이 드립니다')

for i in content_all_2:
    try:
        if len(rt.findall(i)) == 0:
            content = i
            content_all_3.append(content)
        else:
            content = re.split('🍀스펙업이 5만원을 아낌없이 드립니다', i)[0]
            content_all_3.append(content)
    except:
        content = i
        content_all_3.append(content)

rt = re.compile('🚨대학생 베스트 인기글🚨')

for i in content_all_3:
    try:
        if len(rt.findall(i)) == 0:
            content = i
            content_all_4.append(content)
        else:
            content = re.split('🚨대학생 베스트 인기글🚨', i)[0]
            content_all_4.append(content)
    except:
        content = i
        content_all_4.append(content)

df_original['Content'] = content_all_4

df_original.to_excel('스펙업 원본_엑셀.xlsx')

df_preprocessed = df_original.drop_duplicates(['Title', 'Date', 'Content', ]).reset_index().drop(['index'], axis=1)
df_preprocessed.to_excel('스펙업 중복 제거_엑셀.xlsx')

