import tkinter.ttk as ttk
import tkinter.messagebox as msgbox
from tkinter import *  # __all__
from tkinter import filedialog
import chromedriver_autoinstaller
from selenium import webdriver
import pandas as pd
import re
import time
import os, sys



root = Tk()
root.title("경매장 데이터 추출기")


def open_chromedriver():
    chrome = chromedriver_autoinstaller.install(os.getcwd())

    options = webdriver.ChromeOptions()
    options.headless = True
    options.add_argument("--start-maximized")
    driver = webdriver.Chrome(options=options)
    return (driver)

def page_scroll():
    while True:
        num=len(driver.find_elements_by_xpath('//*[@id="__next"]/div/div[2]/div[2]/div[3]/div[1]/ul/div/div[*]'))
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
        time.sleep(0.2)

        if num==len(driver.find_elements_by_xpath('//*[@id="__next"]/div/div[2]/div[2]/div[3]/div[1]/ul/div/div[*]')):
            break

def get_name():
    name =[]
    for i in driver.find_elements_by_class_name('basicList_title__3P9Q7'):
        name.append(i.text)
    return(name)

def get_url():
    url=[]
    for i in driver.find_elements_by_class_name('basicList_title__3P9Q7'):
        url.append(i.find_element_by_class_name('basicList_link__1MaTN').get_attribute('href'))
    return(url)

def get_review_num():
    review_num=[]
    for i in driver.find_elements_by_xpath('//*[@id="__next"]/div/div[2]/div[2]/div[3]/div[1]/ul/div/div[*]/li/div/div[2]/div[5]'):
        try:
            review_num.append(re.sub('[^0-9]','',re.findall('리뷰[ 0-9,]+',i.text)[0]))
        except:
            review_num.append('')
    return(review_num)

def get_buy_num():
    buy_num=[]
    for i in driver.find_elements_by_xpath('//*[@id="__next"]/div/div[2]/div[2]/div[3]/div[1]/ul/div/div[*]/li/div/div[2]/div[5]'):
        try:
            buy_num.append(re.sub('[^0-9]','',re.findall('구매건수[0-9,]+',i.text)[0]))
        except:
            buy_num.append('')
    return(buy_num)

def get_like_num():
    like_num=[]
    for i in driver.find_elements_by_xpath('//*[@id="__next"]/div/div[2]/div[2]/div[3]/div[1]/ul/div/div[*]/li/div/div[2]/div[5]'):
        try:
            like_num.append(re.sub('[^0-9]','',re.findall('찜하기[0-9,]+',i.text)[0]))
        except:
            like_num.append('')
    return(like_num)

def get_ad():
    last= len(driver.find_elements_by_xpath('//*[@id="__next"]/div/div[2]/div[2]/div[3]/div[1]/ul/div/div[*]'))
    ad=[]
    for i in range(1,last+1):
        try:
            ad.append(driver.find_element_by_xpath('//*[@id="__next"]/div/div[2]/div[2]/div[3]/div[1]/ul/div/div[%s]/li/div/div[2]/div[2]/button' %i).text)
        except:
            ad.append('')
    return(ad)


def get_rank(ad):
    z = pd.DataFrame(ad, columns=['ad'])
    z['rank'] = ''
    num1 = []
    for i in range(len(z['ad'].index[z['ad'] == '광고'].tolist())):
        num1.append(i + 1)
    num2 = []
    for i in range(len(z['ad'].index[z['ad'] != '광고'].tolist())):
        num2.append(i + 1)

    z['rank'][z['ad'].index[z['ad'] == '광고'].tolist()] = num1
    z['rank'][z['ad'].index[z['ad'] != '광고'].tolist()] = num2
    return (z)

# 파일 추가
def add_file():
    files = filedialog.askopenfilenames(title="엑셀 파일을 불러와주세요", \
                                        filetypes=(("엑셀 파일", "*.xlsx"), ("모든 파일", "*.*")), \
                                        initialdir=r"C:\Users\Nadocoding\Desktop\PythonWorkspace")
    # 최초에 사용자가 지정한 경로를 보여줌

    # 사용자가 선택한 파일 목록
    for file in files:
        list_file.insert(END, file)


def get_title():
    try:
        title = driver.find_element_by_class_name('KasFrJs3SA').text
    except:
        title = driver.find_element_by_xpath('//*[@id="pc-storeNameWidget"]/div/div/a/img').text
    return (title)

def get_price():
    return(driver.find_element_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[1]/div[2]/div/strong/span[2]').text)

def get_delivery_fee():
    try:
        a=driver.find_element_by_class_name('bd_3uare').text
    except:
        a=driver.find_element_by_class_name('bd_ChMMo').text
    return(a)

def get_delivery_info():
    try:
        a=driver.find_element_by_class_name('bd_1g_zz').text
    except:
        a=''
    return(a)


def get_list_info():
    list_name = []
    list_price = []

    if len(driver.find_elements_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[*]/a')) == 0:
        list_name.append('')
        list_price.append('')

    elif len(driver.find_elements_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[*]/a')) == 1:
        driver.find_element_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/a').click()
        time.sleep(0.8)

        num = len(driver.find_elements_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[*]/a'))
        for i in range(1, num + 1):
            try:
                driver.find_element_by_xpath(
                    '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[%s]/a' % i).click()
            except:
                driver.find_element_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/a').click()
                time.sleep(0.8)
                driver.find_element_by_xpath(
                    '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[%s]/a' % i).click()
            time.sleep(0.8)
            try:
                a = driver.switch_to.alert
                a.accept()

                continue
            except:
                None
            try:
                list_name.append(driver.find_element_by_xpath(
                    '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[6]/ul/li/div/p').text)
            except:
                try:
                    list_name.append(driver.find_element_by_xpath(
                        '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[7]/ul/li/div/p').text)
                except:
                    list_name.append('')
            try:
                list_price.append(driver.find_element_by_xpath(
                    '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[7]/div[2]/strong/span').text)
            except:
                try:
                    list_price.append(driver.find_element_by_xpath(
                        '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[8]/div[2]/strong/span')[0].text)
                except:
                    list_price.append('')
            if i == num:
                break
            driver.find_element_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[*]/ul/li/button').click()
            time.sleep(0.8)
            driver.find_element_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/a').click()
            time.sleep(0.8)

    elif len(driver.find_elements_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[*]/a')) == 2:

        driver.find_element_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[1]/a').click()
        time.sleep(0.8)
        num1 = len(driver.find_elements_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[*]/a'))
        for i in range(1, num1 + 1):
            driver.find_element_by_xpath(
                '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[%s]/a' % i).click()
            time.sleep(0.8)
            try:
                a = driver.switch_to.alert
                a.accept()

                continue
            except:
                None
            driver.find_element_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[2]/a').click()
            time.sleep(0.8)
            num2 = len(
                driver.find_elements_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[*]/a'))
            for j in range(1, num2 + 1):
                driver.find_element_by_xpath(
                    '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[%s]/a' % j).click()
                time.sleep(0.8)

                try:
                    a = driver.switch_to.alert
                    a.accept()
                    time.sleep(1.5)

                    if j == num2:
                        driver.find_element_by_xpath(
                            '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[1]/a').click()
                        time.sleep(0.8)

                    else:
                        driver.find_element_by_xpath(
                            '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[2]/a').click()
                        time.sleep(0.8)
                    continue

                except:
                    None
                try:
                    list_name.append(driver.find_element_by_xpath(
                        '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[6]/ul/li/div/p').text)
                except:
                    try:
                        list_name.append(driver.find_element_by_xpath(
                            '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[7]/ul/li/div/p').text)
                    except:
                        list_name.append('')
                try:
                    list_price.append(driver.find_element_by_xpath(
                        '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[7]/div[2]/strong/span').text)
                except:
                    try:
                        list_price.append(driver.find_element_by_xpath(
                            '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[8]/div[2]/strong/span').text)
                    except:
                        list_price.append('')
                driver.find_element_by_xpath(
                    '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[6]/ul/li/button').click()
                time.sleep(0.8)

                driver.find_element_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[1]/a').click()
                time.sleep(0.8)

                driver.find_element_by_xpath(
                    '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[%s]/a' % i).click()
                time.sleep(0.8)

                if j == num2:
                    driver.find_element_by_xpath(
                        '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[1]/a').click()
                    time.sleep(0.8)
                else:
                    driver.find_element_by_xpath(
                        '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[2]/a').click()
                    time.sleep(0.8)
    elif len(driver.find_elements_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[*]/a')) == 3:

        driver.find_element_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[1]/a').click()
        time.sleep(0.8)
        num1 = len(driver.find_elements_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[*]/a'))
        for i in range(1, num1 + 1):
            driver.find_element_by_xpath(
                '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[%s]/a' % i).click()
            time.sleep(0.8)
            try:
                a = driver.switch_to.alert
                a.accept()

                continue
            except:
                None
            driver.find_element_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[2]/a').click()
            time.sleep(0.8)
            num2 = len(
                driver.find_elements_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[*]/a'))
            for j in range(1, num2 + 1):
                driver.find_element_by_xpath(
                    '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[%s]/a' % j).click()
                time.sleep(0.8)

                try:
                    a = driver.switch_to.alert
                    a.accept()
                    time.sleep(1)

                    if j == num2:
                        driver.find_element_by_xpath(
                            '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[1]/a').click()
                        time.sleep(0.8)
                    else:
                        driver.find_element_by_xpath(
                            '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[2]/a').click()
                        time.sleep(0.8)
                    continue

                except:
                    None

                driver.find_element_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[3]/a').click()
                time.sleep(0.8)
                num3 = len(driver.find_elements_by_xpath(
                    '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[*]/a'))
                for k in range(1, num3 + 1):
                    driver.find_element_by_xpath(
                        '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[%s]/a' % k).click()
                    time.sleep(0.8)

                    try:
                        a = driver.switch_to.alert
                        a.accept()
                        time.sleep(1.5)

                        if k == num3:
                            if j == num2:
                                driver.find_element_by_xpath(
                                    '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[1]/a').click()
                                time.sleep(0.8)
                            else:
                                driver.find_element_by_xpath(
                                    '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[2]/a').click()
                                time.sleep(0.8)
                        else:
                            driver.find_element_by_xpath(
                                '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[3]/a').click()
                            time.sleep(0.8)

                        continue

                    except:
                        None
                    driver.find_elements_by_xpath('//*[@id="content"]/div/div[2]/div[2]/fieldset/div[*]/ul/li/button')[
                        0].click()
                    time.sleep(0.8)

                    try:
                        list_name.append(driver.find_element_by_xpath(
                            '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[6]/ul/li/div/p').text)
                    except:
                        try:
                            list_name.append(driver.find_element_by_xpath(
                                '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[7]/ul/li/div/p').text)
                        except:
                            list_name.append('')
                    try:
                        list_price.append(driver.find_element_by_xpath(
                            '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[7]/div[2]/strong/span').text)
                    except:
                        try:
                            list_price.append(driver.find_element_by_xpath(
                                '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[8]/div[2]/strong/span').text)
                        except:
                            list_price.append('')

                    driver.find_element_by_xpath(
                        '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[1]/a').click()
                    time.sleep(0.8)

                    driver.find_element_by_xpath(
                        '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[%s]/a' % i).click()
                    time.sleep(0.8)

                    driver.find_element_by_xpath(
                        '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[2]/a').click()
                    time.sleep(0.8)

                    driver.find_element_by_xpath(
                        '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div/ul/li[%s]/a' % j).click()
                    time.sleep(0.8)
                    if k == num3:
                        if j == num2:
                            driver.find_element_by_xpath(
                                '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[1]/a').click()
                            time.sleep(0.8)
                        else:
                            driver.find_element_by_xpath(
                                '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[2]/a').click()
                            time.sleep(0.8)
                    else:
                        driver.find_element_by_xpath(
                            '//*[@id="content"]/div/div[2]/div[2]/fieldset/div[5]/div[3]/a').click()
                        time.sleep(0.8)
    if len(list_name) == 0:
        list_name = None
        list_price = None
    try:
        a= pd.DataFrame({'목록': list_name, '목록 별 가격': list_price})
    except:
        a = pd.DataFrame({'목록': list_name, '목록 별 가격': list_price},index=[0])
    return (a)
def get_table1():
    page= driver.page_source
    for i in pd.read_html(page):
        try:
            index1=i.index[i.iloc[:,0]=='모델명'].tolist()[0]
            model=i.iloc[index1,1]
        except:
            try:
                index1=i.index[i.iloc[:,2]=='모델명'].tolist()[0]
                model=i.iloc[index1,3]
            except:
                continue
    for i in pd.read_html(page):
        try:
            index2=i.index[i.iloc[:,0]=='브랜드'].tolist()[0]
            brand=i.iloc[index2,1]
        except:
            try:
                index2=i.index[i.iloc[:,2]=='브랜드'].tolist()[0]
                brand=i.iloc[index2,3]
            except:
                continue
    try:
        if len(brand)==0:
            brand=''
    except:
        brand=''
    try:
        if len(model)==0:
            model=''
    except:
        model=''
    return(pd.DataFrame({'모델명':model,'브랜드':brand},index=[0]))


def get_table2():
    page = driver.page_source
    for i in pd.read_html(page):

        try:
            index1 = i.index[i.iloc[:, 0] == 'A/S 안내'].tolist()[0]
            AS = i.iloc[index1, 1]
        except:
            continue
    try:
        if len(AS) == 0:
            AS = ''
    except:
        AS = ''

    return (pd.DataFrame({'AS안내': AS}, index=[0]))


def get_table3():
    page = driver.page_source
    for i in pd.read_html(page):
        try:
            index1 = i.index[i.iloc[:, 0] == '원산지'].tolist()[0]
            origin = i.iloc[index1, 1]
        except:
            continue
    for i in pd.read_html(page):
        try:
            index2 = i.index[i.iloc[:, 0] == '생산자'].tolist()[0]
            producer = i.iloc[index2, 1]
        except:
            continue

    try:
        if len(origin) == 0:
            origin = ''
    except:
        origin = ''
    try:
        if len(producer) == 0:
            producer = ''
    except:
        producer = ''
    return (pd.DataFrame({'원산지': origin, '생산자': producer}, index=[0]))


def get_table4():
    page = driver.page_source
    for i in pd.read_html(page):
        try:
            index1 = i.index[i.iloc[:, 0] == '제품하자가 아닌 소비자의 단순변심, 착오구매에 따른 청약철회가 불가능한 경우 그 구체적 사유와 근거'].tolist()[0]
            delivery_else = i.iloc[index1, 1]

        except:
            continue
    for i in pd.read_html(page):
        try:
            index2 = i.index[i.iloc[:, 0] == '재화등의 A/S 관련 전화번호'].tolist()[0]
            AS_call = i.iloc[index2, 1]
        except:
            continue

    try:
        if len(delivery_else) == 0:
            delivery_else = ''
    except:
        delivery_else = ''
    try:
        if len(AS_call) == 0:
            AS_call = ''
    except:
        AS_call = ''
    return (pd.DataFrame({'환불 택배비': delivery_else, 'A/S 관련': AS_call}, index=[0]))


def get_table5():
    page = driver.page_source
    for i in pd.read_html(page):
        try:
            index1 = i.index[i.iloc[:, 0] == '반품배송비'].tolist()[0]
            refund_fee = i.iloc[index1, 1]
        except:
            continue
    for i in pd.read_html(page):
        try:
            index2 = i.index[i.iloc[:, 0] == '보내실 곳'].tolist()[0]
            where = i.iloc[index2, 1]
        except:
            continue
    for i in pd.read_html(page):
        try:
            index3 = i.index[i.iloc[:, 2] == '교환배송비'].tolist()[0]
            exchange_fee = i.iloc[index3, 3]
        except:
            continue

    try:
        if len(refund_fee) == 0:
            refund_fee = ''
    except:
        refund_fee = ''
    try:
        if len(where) == 0:
            where = ''
    except:
        where = ''
    try:
        if len(exchange_fee) == 0:
            exchange_fee = ''
    except:
        exchange_fee = ''
    return (pd.DataFrame({'반품배송비': refund_fee, '보내실 곳': where, '교환배송비': exchange_fee}, index=[0]))


def get_seller_info():
    page=driver.page_source
    for i in pd.read_html(page):
        if '상호명' in i.iloc[:,0].tolist():
            break
    a=i.iloc[:,0]
    b=i.iloc[:,2]
    a= a.append(b)
    colum=a[0:len(a)-1]
    a=i.iloc[:,1]
    b=i.iloc[:,3]
    c= a.append(b)
    data = c[0:len(c)-1]
    data=data.reset_index(drop=True)
    w=pd.DataFrame(data=[data.tolist()],columns=colum.reset_index(drop=True).tolist())
    return(w)

# 선택 삭제
def del_file():
    # print(list_file.curselection())
    for index in reversed(list_file.curselection()):
        list_file.delete(index)




# 이미지 통합
def merge_image():
    check_2 = 0
    global driver
    driver = open_chromedriver()
    try:
        data = pd.read_excel(list_file.get(0, END)[0])
        name_all = data.iloc[:, 1]

        for key in name_all:
            link = 'https://search.shopping.naver.com/search/all?frm=NVSHATC&origQuery=%EC%BD%94%EB%81%BC%EB%A6%AC%EB%A7%88%EB%8A%98&pagingIndex=1&pagingSize=80&productSet=total&query=' + key + '&sort=rel&timestamp=&viewType=list'
            driver.get(link)
            time.sleep(3)
            page_scroll()
            time.sleep(1)
            name = get_name()
            url = get_url()
            review_num = get_review_num()
            buy_num = get_buy_num()
            like_num = get_like_num()
            ad = get_ad()
            rank = get_rank(ad)

            try:
                first_table = pd.concat(
                    [pd.DataFrame({'Index': range(len(rank)), '상품명': name, 'url': url, '리뷰 수': review_num}), rank], axis=1)
            except:
                first_table = pd.concat(
                    [pd.DataFrame({'Index': range(len(rank)), '상품명': name, 'url': url, '리뷰 수': review_num},index=[0]), rank],
                    axis=1)
            num_last = int(txt_dest_path2.get())
            table_all = pd.DataFrame()
            pro_check=0
            for i in range(0, num_last):
                print(i, '/', num_last)

                driver.get(url[i])
                time.sleep(1.5)

                if len(re.findall('smartstore.naver.com', driver.current_url)) == 0:
                    check = 'X'
                    Index = first_table['Index'][i]
                    try:
                        a = pd.DataFrame(
                            {'Index': Index, '스마트스토어 여부': check, '쇼핑몰명': '', '가격': '', '배송 요금': '', '배송 조건': '', '목록': '',
                             '목록 별 가격': '', '모델명': '',
                             '브랜드': '', 'AS안내': '', '원산지': '', '생산자': '', '환불 택배비': '', 'A/S관련': '', '반품배송비': '',
                             '보내실 곳': '', '교환배송비': '', '상호명': '',
                             '사업자등록번호': '', '사업장소재지': '', '대표자': '', '통신판매업번호': ''})
                    except:
                        a = pd.DataFrame(
                            {'Index': Index, '스마트스토어 여부': check, '쇼핑몰명': '', '가격': '', '배송 요금': '', '배송 조건': '',
                             '목록': '',
                             '목록 별 가격': '', '모델명': '',
                             '브랜드': '', 'AS안내': '', '원산지': '', '생산자': '', '환불 택배비': '', 'A/S관련': '', '반품배송비': '',
                             '보내실 곳': '', '교환배송비': '', '상호명': '',
                             '사업자등록번호': '', '사업장소재지': '', '대표자': '', '통신판매업번호': ''}, index=[0])
                    table = pd.merge(first_table, a)
                    table_all = pd.concat([table_all, table], axis=0)
                    continue
                else:
                    check = 'O'
                    Index = first_table['Index'][i]
                    title = get_title()
                    price = get_price()
                    delivery_fee = get_delivery_fee()
                    delivery_info = get_delivery_info()
                    list_info = get_list_info()
                    table1 = get_table1()
                    table2 = get_table2()
                    table3 = get_table3()
                    table4 = get_table4()
                    table5 = get_table5()
                    seller_info = get_seller_info()
                    try:
                        second_table = pd.concat([pd.DataFrame(
                            {'Index': Index, '스마트스토어 여부': check, '쇼핑몰명': [title] * len(list_info), '가격': price,
                             '배송 요금': delivery_fee, '배송 조건': delivery_info}), list_info, table1, table2, table3, table4,
                                                  table5, seller_info], axis=1)
                    except:
                        second_table = pd.concat([pd.DataFrame(
                            {'Index': Index, '스마트스토어 여부': check, '쇼핑몰명': [title] * len(list_info), '가격': price,
                             '배송 요금': delivery_fee, '배송 조건': delivery_info},index=[0]), list_info, table1, table2, table3, table4,
                            table5, seller_info], axis=1)
                    second_table = second_table.fillna(method='ffill')
                    table = pd.merge(first_table, second_table)
                    table_all = pd.concat([table_all, table], axis=0)
                    table_all=table_all.reset_index(drop=True)

                    pro_check = pro_check + 1
                    progress = pro_check / (num_last-1) * 100
                    p_var.set(progress)
                    progress_bar.update()

            nows = time.localtime()
            times = str(nows.tm_year) + '-' + str(nows.tm_mon) + '-' + str(nows.tm_mday) + '_' + str(
                nows.tm_hour) + str(nows.tm_min) + str(nows.tm_sec)
            down_name = times +key + '.xlsx'

            dest_path = os.path.join(txt_dest_path.get(), down_name)
            writer = pd.ExcelWriter(dest_path, engine='xlsxwriter', options={'strings_to_urls': True})
            table_all.to_excel(writer)
            writer.close()


            check_2 = check_2 + 1
            progress2 = check_2 / len(name_all) * 100
            p_var2.set(progress2)
            progress_bar2.update()
        driver.quit()
        msgbox.showinfo("알림", "작업이 완료되었습니다.")

    except Exception as err:  # 예외처리
        msgbox.showerror("에러", err)


# 시작
def start():
    # 각 옵션들 값을 확인
    # print("가로넓이 : ", cmb_width.get())
    # print("간격 : ", cmb_space.get())
    # print("포맷 : ", cmb_format.get())

    # 파일 목록 확인
    if list_file.size() == 0:
        msgbox.showwarning("경고", "엑셀 파일을 추가해주세요")
        return

    if len(txt_dest_path.get()) == 0:
        msgbox.showwarning("경고", "저장 위치를 입력해주세요")
        return

    if len(txt_dest_path2.get()) == 0:
        msgbox.showwarning("경고", "수집할 상품 수를 입력해주세요")
        return

    # 저장 경로 확인
    # 이미지 통합 작업
    merge_image()

def browse_dest_path():
    folder_selected = filedialog.askdirectory()
    if folder_selected == "":  # 사용자가 취소를 누를 때
        print("폴더 선택 취소")
        return
    # print(folder_selected)
    txt_dest_path.delete(0, END)
    txt_dest_path.insert(0, folder_selected)

# 파일 프레임 (파일 추가, 선택 삭제)
file_frame = LabelFrame(root, text='엑셀 파일 입력')
file_frame.pack(fill="x", padx=5, pady=5)  # 간격 띄우기

txt_dest_path1 = Entry(file_frame)
txt_dest_path1.pack(side="left", fill="x", expand=True, padx=5, pady=5, ipady=4)  # 높이 변경
txt_dest_path1.insert(0, '엑셀 파일을 추가해주세요')

btn_add_file = Button(file_frame, padx=5, pady=5, width=12, text="파일추가", command=add_file)
btn_add_file.pack(side="left")

btn_del_file = Button(file_frame, padx=5, pady=5, width=12, text="선택삭제", command=del_file)
btn_del_file.pack(side="right")

# 리스트 프레임
list_frame = Frame(root)
list_frame.pack(fill="both", padx=5, pady=5)

scrollbar = Scrollbar(list_frame)
scrollbar.pack(side="right", fill="y")

list_file = Listbox(list_frame, selectmode="extended", height=15, yscrollcommand=scrollbar.set)
list_file.pack(side="left", fill="both", expand=True)
scrollbar.config(command=list_file.yview)


# 옵션 프레임
frame_option = LabelFrame(root, text="옵션")
frame_option.pack(padx=5, pady=5, ipady=5)

# 3. 파일 포맷 옵션

# 파일 포맷 옵션 콤보
path_frame2 = LabelFrame(root, text="옵션")
path_frame2.pack(fill="x", padx=5, pady=5)

txt_dest_path2 = Entry(path_frame2,text='상품 표시 수')
txt_dest_path2.pack(side="left", fill="x", expand=True, padx=5, pady=5,ipady=4)
txt_dest_path2.bind("<Button-1>", lambda e: txt_dest_path2.delete(0, END))
txt_dest_path2.insert(0, '몇 개씩 가져올지 입력')


# 저장 경로 프레임
path_frame = LabelFrame(root, text="저장경로")
path_frame.pack(fill="x", padx=5, pady=5, ipady=5)

txt_dest_path = Entry(path_frame)
txt_dest_path.pack(side="left", fill="x", expand=True, padx=5, pady=5, ipady=4)  # 높이 변경

btn_dest_path = Button(path_frame, text="찾아보기", width=10, command=browse_dest_path)
btn_dest_path.pack(side="right", padx=5, pady=5)

# 진행 상황 Progress Bar
frame_progress = LabelFrame(root, text="진행 상황")
frame_progress.pack(fill="x", padx=5, pady=5, ipady=5)

p_var = DoubleVar()
progress_bar = ttk.Progressbar(frame_progress, maximum=100, variable=p_var)
progress_bar.pack(fill="x", padx=5, pady=5)

# 진행 상황 Progress Bar
frame_progress2 = LabelFrame(root, text="전체 진행 상황")
frame_progress2.pack(fill="x", padx=5, pady=5, ipady=5)

p_var2 = DoubleVar()
progress_bar2 = ttk.Progressbar(frame_progress2, maximum=100, variable=p_var2)
progress_bar2.pack(fill="x", padx=5, pady=5)

# 실행 프레임1
frame_run = Frame(root)
frame_run.pack(fill="x", padx=5, pady=5)

btn_close = Button(frame_run, padx=5, pady=5, text="닫기", width=12, command=root.quit)
btn_close.pack(side="right", padx=5, pady=5)



btn_start = Button(frame_run, padx=5, pady=5, text="시작", width=12, command=start)
btn_start.pack(side="right", padx=5, pady=5)

root.resizable(False, False)
root.mainloop()
