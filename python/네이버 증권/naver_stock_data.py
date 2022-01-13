from bs4 import BeautifulSoup
import requests
import pandas as pd
import re
import time
import sys,os

header = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.220 Whale/1.3.51.7 Safari/537.36',
}


list = pd.read_excel(os.getcwd()+'\\'+'종목 선택.xlsx', dtype='object')





code_list = list.iloc[:, 0]
page_list = list.iloc[:, 1]


def get_data():
    date_all = []
    times_now_all = []
    title_all = []
    writer_all = []
    view_all = []
    like_all = []
    dislike_all = []
    code_num_all = []
    name_all = []
    page_all = []
    for code, last_page in zip(code_list, page_list):
        for page in range(1, last_page + 1):
            url = 'https://finance.naver.com/item/board.nhn?code=%s&page=%s' % (code, page)

            print(url)
            res = requests.get(url, headers=header)
            soup = BeautifulSoup(res.text, 'html.parser')

            ### 종목 명
            name = soup.select_one('#middle > div.h_company > div.wrap_company > h2 > a').text

            soup = soup.select_one('#content > div.section.inner_sub > table.type2 > tbody')

            ### 날짜, 시간

            dates = soup.select('#content > div.section.inner_sub > table.type2 > tbody > tr > td:nth-child(1) > span')
            for t in dates:
                date_all.append(t.text.split(' ')[0])
                times_now_all.append(t.text.split(' ')[1])

            ### 제목

            titles = soup.select('#content > div.section.inner_sub > table.type2 > tbody > tr > td.title > a')
            for t in titles:
                title_all.append(re.sub('\n|\t', '', t.text))

            ### 글쓴이

            writers = soup.select('#content > div.section.inner_sub > table.type2 > tbody > tr> td.p11')
            for t in writers:
                writer_all.append(re.sub('\n|\t', '', t.text))

            # 페이지, 종목 명, 종목 코드 추가
            for i in range(1, len(titles) + 1):
                page_all.append(page)
                name_all.append(name)
                code_num_all.append(code)

            ### 조회

            views = soup.select('#content > div.section.inner_sub > table.type2 > tbody > tr > td:nth-child(4) > span')
            for t in views:
                view_all.append(t.text)

                ### 공감

            likes = soup.select(
                '#content > div.section.inner_sub > table.type2 > tbody > tr > td:nth-child(5) > strong')
            for t in likes:
                like_all.append(t.text)

            ### 비공감

            dislikes = soup.select(
                '#content > div.section.inner_sub > table.type2 > tbody > tr > td:nth-child(6) > strong')
            for t in dislikes:
                dislike_all.append(t.text)

    return pd.DataFrame({'종목 코드': code_num_all, '종목 명': name_all, '날짜': date_all, '시간': times_now_all, '제목': title_all,
                         '글쓴이': writer_all, '조회': view_all, '공감': like_all, '비공감': dislike_all, '페이지': page_all})


df = get_data()

nows = time.localtime()
times = str(nows.tm_year) + '-' + str(nows.tm_mon) + '-' + str(nows.tm_mday)+'_' + str(nows.tm_hour)+str(nows.tm_min)+str(nows.tm_sec)
name = times + '네이버 증권 데이터 수집' + '.xlsx'

writer = pd.ExcelWriter(name, engine='xlsxwriter')
df.to_excel(writer)
writer.close()