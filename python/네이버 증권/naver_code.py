from bs4 import BeautifulSoup
import requests
import pandas as pd
import re
import time


def get_name_code():
    name_all = []
    code_all = []
    number_all = []
    for i in range(0, 2):
        for j in range(1, 50):

            url = 'https://finance.naver.com/sise/sise_market_sum.nhn?sosok=%d&page=%d' % (i, j)
            if i == 0 and j == 32 or i == 1 and j == 33:
                break

            res = requests.get(url)
            soup = BeautifulSoup(res.text, 'html.parser')

            for tr in soup.find_all('tr'):
                try:
                    name = tr.find('a').text

                    code = tr.find('a')['href'].split('=')[1]

                    if len(re.findall('page', code)) == 1:
                        pass

                    else:

                        name_all.append(name)
                        code_all.append(code)

                        print(code,':',name)

                except:
                    pass

    return pd.DataFrame({'코드': code_all, '이름': name_all})


df = get_name_code()

nows = time.localtime()
times = str(nows.tm_year) + '-' + str(nows.tm_mon) + '-' + str(nows.tm_mday)
name = times + '종목 코드.xlsx'


writer = pd.ExcelWriter(name, engine='xlsxwriter', options={'strings_to_urls': True})
df.to_excel(writer)
writer.close()