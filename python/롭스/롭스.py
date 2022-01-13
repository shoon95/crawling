#!/usr/bin/env python
# coding: utf-8

# In[2]:


from bs4 import BeautifulSoup
from selenium import webdriver
import requests
import pandas as pd
import re
import math
from selenium.webdriver.common.action_chains import ActionChains
import time
import os, sys
import random
import numpy as np


# In[22]:


options = webdriver.ChromeOptions()
options.headless = True
options.add_argument("window-size=1920x1080")

if getattr(sys, 'frozen', False):
    chromedriver_path = os.path.join(sys._MEIPASS, "chromedriver.exe")
    driver = webdriver.Chrome(chromedriver_path,options=options)
else:
    driver = webdriver.Chrome(options=options)


# -메이크업-
# https://www.lotteon.com/search/render/render.ecn?render=nqapi&platform=pc&collection_id=401&u9=navigate&u8=LB10100002&login=Y&mallId=7
# -스킨케어-
# https://www.lotteon.com/search/render/render.ecn?render=nqapi&platform=pc&collection_id=401&u9=navigate&u8=LB10100005&login=Y&mallId=7
# -헤어케어-
# https://www.lotteon.com/search/render/render.ecn?render=nqapi&platform=pc&collection_id=401&u9=navigate&u8=LB10100009&login=Y&mallId=7
# -바디케어-
# https://www.lotteon.com/search/render/render.ecn?render=nqapi&platform=pc&collection_id=401&u9=navigate&u8=LB10100003&login=Y&mallId=7
#     

# In[23]:


category = pd.Series(['https://www.lotteon.com/search/render/render.ecn?render=nqapi&platform=pc&collection_id=401&u9=navigate&u8=LB10100002&login=Y&mallId=7','https://www.lotteon.com/search/render/render.ecn?render=nqapi&platform=pc&collection_id=401&u9=navigate&u8=LB10100005&login=Y&mallId=7','https://www.lotteon.com/search/render/render.ecn?render=nqapi&platform=pc&collection_id=401&u9=navigate&u8=LB10100009&login=Y&mallId=7','https://www.lotteon.com/search/render/render.ecn?render=nqapi&platform=pc&collection_id=401&u9=navigate&u8=LB10100003&login=Y&mallId=7'], index=['메이크업','스킨헤어','헤어케어','바디케어'])


# In[24]:


header = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.220 Whale/1.3.51.7 Safari/537.36'}


# In[25]:


url = []
cate_all=[]
for cat in category:
    driver.get(cat)
    time.sleep(1)
    cate=category[category==cat].index[0]
    
    pagination=driver.find_elements_by_xpath('//*[@id="c401_navigate"]/div/a')
    last_page=len(pagination)-1
    last_num=int(driver.find_element_by_xpath('//*[@id="c401_navigate"]/div/a[%d]' %last_page).text)
    
    i=1
    
    while True:
        print('현재 페이지 정보 : '+cate+str(i)+'p'+' (전체:%dp)' %last_num)
    
        link = driver.find_elements_by_class_name('srchGridProductUnitLink')
    
        for a in link:
            text = a.get_attribute('href')
            url.append(text)
            
            cate_all.append(cate)
    
        if i == 1 :
            page_move = driver.find_element_by_xpath('//*[@id="c401_navigate"]/div/a[7]')
            page_move.click()
        
            time.sleep(1)
        
        elif i == last_num:
            break
        else :
            
            page_move = driver.find_element_by_xpath('//*[@id="c401_navigate"]/div/a[8]')
            page_move.click()

            time.sleep(1)

        i= i+1
        
new_list = []
for v in url:
    if v not in new_list:
        new_list.append(v)
        
new_list=pd.DataFrame(data=new_list, columns=['url'])
        
cate_all=cate_all[1::2]
cate_all=pd.DataFrame(data=cate_all,columns=['카테고리'])

match=pd.concat([new_list,cate_all], axis=1)


# In[125]:


i=1

frame_all = pd.DataFrame()
frame=pd.DataFrame()

for site in new_list.iloc[:,0]:
    print('현재 진행 상황 : '+str(i)+ ' (전체 물품:%d)' % len(new_list))
    i=i+1
    driver.get(site)
    
    ########## url 링크
    frame=pd.DataFrame(data=[site],columns=['url'])
   
    ########## 제품명
    try: 
        title = driver.find_element_by_xpath('//*[@id="stickyTopParent"]/div[2]/div[1]/div[3]/h1').text
    except:
        print('페이지 없음')
        continue
    title=pd.DataFrame(data=[title],columns=['제품명'])
    frame=pd.concat([frame,title],axis=1)
    
    ########## 가격
    price =  driver.find_element_by_xpath('//*[@id="stickyTopParent"]/div[2]/div[2]/div/div[1]/div/span')
    price=price.text.replace(',','')
    price=pd.DataFrame(data=[price], columns=['가격'])
    frame=pd.concat([frame,price],axis=1)
    
    ########## 옵션
    try:
        opt = driver.find_element_by_xpath('//*[@id="stickyTopParent"]/div[2]/div[3]/div[1]/div')
        if len(driver.find_elements_by_xpath('//*[@id="stickyTopParent"]/div[2]/div[3]/div[1]/div/div[2]/label[*]'))>0 :
                
            opt_but=driver.find_elements_by_xpath('//*[@id="stickyTopParent"]/div[2]/div[3]/div[1]/div/div[2]/label[*]')

            for a in opt_but:
                a.click()
                time.sleep(0.3)

                opt_text = driver.find_element_by_xpath('//*[@id="stickyTopParent"]/div[2]/div[3]/div[1]/div/div[1]/span[2]')
                word_re=opt_text.text
                word.append(word_re)
        else:
            opt_list=driver.find_element_by_xpath('//*[@id="stickyTopParent"]/div[2]/div[3]/div[1]/div/div/div')
            opt_list.click()
            opt_text = driver.find_elements_by_xpath('//*[@id="select-pageOpt-12438"]/li[*]/div/span[1]')
            time.sleep(0.2)
            for a in opt_text:
                word_re=a.text
                word.append(word_re)

    except:
        print('')
    
    ########## 제품 상세 설명
    
    try :
        view1 = driver.find_element_by_xpath('//*[@id="stickyTabParent"]/div[3]/div[1]/div/div/div/div[1]/div[1]/div[2]/button/span')
        view1.click()
        
        data1 = driver.find_elements_by_xpath('//*[@id="stickyTabParent"]/div[3]/div[1]/div/div/div/div[1]/div[1]/div[1]/dl[*]') 
    except:
        data1 = driver.find_elements_by_xpath('//*[@id="stickyTabParent"]/div[3]/div[1]/div/div/div/div[1]/div[1]/dl[*]')
        
    try :
        view2 = driver.find_element_by_xpath('//*[@id="stickyTabParent"]/div[3]/div[1]/div/div/div/div[1]/div[2]/div[2]/button')
        view2.click()
    except:
        print('')
       
    data2 = driver.find_elements_by_xpath('//*[@id="stickyTabParent"]/div[3]/div[1]/div/div/div/div[1]/div[2]/div[1]/dl[*]')
    
    data1_name=[]
    data1_value=[]
    data2_name=[]
    data2_value=[]
    
    for a in data1:
        try:
            name=a.text.split(sep='\n')[0]
            value = a.text.split(sep='\n')[1]

            data1_name.append(name)
            data1_value.append(value)
        except:
            name=''
            value=''
            
            data1_name.append(name)
            data1_value.append(value)

    frame1 = pd.DataFrame(data=[data1_value],columns=data1_name)
    
    my_suffix = '_2'
    frame1.columns = [name if duplicated == False else name + my_suffix for duplicated, name in zip(frame1.columns.duplicated(), frame1.columns)]
    
   
    for b in data2:
        name = b.text.split(sep='\n')[0]
        value =b.text.split(sep='\n')[1]
    
        data2_name.append(name)
        data2_value.append(value)
    
    frame2 = pd.DataFrame(data=[data2_value], columns=data2_name)
    frame2.columns = [name if duplicated == False else name + my_suffix for duplicated, name in zip(frame2.columns.duplicated(), frame2.columns)]
    
    
    
    frame=pd.concat([frame,frame1,frame2], axis=1)
    
    my_suffix = '_2'
    frame.columns = [name if duplicated == False else name + my_suffix for duplicated, name in zip(frame.columns.duplicated(), frame.columns)]
    
    frame_all = pd.concat([frame_all,frame])
    frame_all = pd.concat([frame_all,cate_all],axis=1)

frame_all=pd.merge(frame_all, match, how='inner',on='url')

writer = pd.ExcelWriter(r'DB_롭슨.xlsx', engine='xlsxwriter', options={'strings_to_urls': False})
frame_all.to_excel(writer)
writer.close()

