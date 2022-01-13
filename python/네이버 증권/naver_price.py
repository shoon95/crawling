from bs4 import BeautifulSoup
import requests
import pandas as pd
import time
import os,sys

header = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.220 Whale/1.3.51.7 Safari/537.36',
}


list = pd.read_excel(os.getcwd()+'\\'+'종목 선택_시세용.xlsx', dtype='object')
code_list = list.iloc[:, 0]
page_list = list.iloc[:, 1]


def get_data():
    table_df_all = pd.DataFrame()

    for code, last_page in zip(code_list, page_list):
        for page in range(1, last_page + 1):
            url = 'https://finance.naver.com/item/sise_day.nhn?code=%s&page=%s' % (code, page)
            print(url)
            res = requests.get(url, headers=header)
            soup = BeautifulSoup(res.text, 'html.parser')

            table_html = soup.select('body > table.type2')
            table_html = str(table_html)
            table_df = pd.read_html(table_html)[0]

            table_df = pd.concat([pd.DataFrame(data=[code] * len(table_df), columns=['Code']), table_df], axis=1)

            table_df_all = pd.concat([table_df_all, table_df], axis=0)

    table_df_all = table_df_all.dropna(axis=0).reset_index().drop(['index', '전일비'], axis=1)

    table_df_all.iloc[:, 2:7] = table_df_all.iloc[:, 2:7].astype(int)

    return (table_df_all)

df = get_data()

nows = time.localtime()
times = str(nows.tm_year) + '-' + str(nows.tm_mon) + '-' + str(nows.tm_mday)+'_' + str(nows.tm_hour)+str(nows.tm_min)+str(nows.tm_sec)
name = times + '네이버 시세 수집' + '.xlsx'

writer = pd.ExcelWriter(name, engine='xlsxwriter')
df.to_excel(writer)
writer.close()