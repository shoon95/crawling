import chromedriver_autoinstaller
from selenium import webdriver
import re
import os, sys
import requests
from bs4 import BeautifulSoup as bs
import json
import urllib.request
import pandas as pd


def open_chromedriver():
    chrome = chromedriver_autoinstaller.install(os.getcwd())

    options = webdriver.ChromeOptions()
    options.headless = True

    driver = webdriver.Chrome(options=options)
    return (driver)


driver = open_chromedriver()

driver.get('https://www.wadiz.kr/web/wreward/main?keyword=&endYn=ALL&order=recommend')

category = []
for i in driver.find_elements_by_xpath('//*[@id="main-app"]/div[2]/div/div[2]/div/div/div/a[*]'):
    category.append(i.get_attribute('href'))

category = category[1:]

driver.get(category[0])

category_num = []
for i in category:
    category_num.append(re.sub('[^0-9]', '', i))

driver.quit()

url = 'https://www.wadiz.kr/web/wreward/ajaxGetCardList?startNum=96&limit=48&order=recommend&custValueCode=%s&keyword=&endYn=ALL' % \
      category_num[0]

id = []
title = []
num = 0
for i in category_num:
    num = num + 1
    limit = 48
    startNum = 0
    while True:
        url = 'https://www.wadiz.kr/web/wreward/ajaxGetCardList?startNum=%s&limit=48&order=recommend&custValueCode=%s&keyword=&endYn=ALL' % (
        startNum, i)
        text_data = urllib.request.urlopen(url).read().decode('utf-8')
        data = json.loads(text_data)

        if len(data['data']) == 0:
            break

        for j in data['data']:
            id.append(j['campaignId'])
            title.append(j['title'])

        startNum = startNum + limit

        print(num, '-', len(category_num), '::', startNum, '/', data['additionalParams']['totalCount'])

df = {'title': title,'id':id}

df = pd.DataFrame(df)

email = []
num = 0
for i in df['id']:
    url = 'https://www.wadiz.kr/web/campaign/detail/%s' % i
    res = requests.get(url)
    soup = bs(res.text, 'html.parser')
    email.append(soup.find('div', {'class': 'project-maker-info'}).find('div')['data-host-email'])
    num = num + 1
    print(num, '/', len(df), '-', soup.find('div', {'class': 'project-maker-info'}).find('div')['data-host-email'])

df_2 = pd.DataFrame(email, columns=['email'])

url_all = []
for i in df['id']:
    url_all.append('https://www.wadiz.kr/web/campaign/detail/%s' % i)

df_url = pd.DataFrame(url_all, columns=['url'])

data = pd.concat([df, df_2, df_url], axis=1)

writer = pd.ExcelWriter(r'와디즈.xlsx', engine='xlsxwriter', options={'strings_to_urls': True})
data.to_excel(writer)
writer.close()