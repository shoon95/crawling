import tkinter.ttk as ttk
import tkinter.messagebox as msgbox
from tkinter import *  # __all__
from tkinter import filedialog
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
import pandas as pd
import re
import time
import os, sys
import urllib.request as req
import xlsxwriter
import string
from io import BytesIO
from PIL import Image

root = Tk("")
root.title("네이버 스마트 스토어 리뷰 수집")


# 파일 추가
def add_file():
    files = txt_dest_path1.get()
    # 사용자가 선택한 파일 목록
    if len(re.findall('naver',files)) ==0:
        msgbox.showwarning("경고", 'URL을 다시 입력해주세요')
        return

    list_file.insert(END, files)
    txt_dest_path1.delete(0, END)


# 선택 삭제
def del_file():
    # print(list_file.curselection())
    for index in reversed(list_file.curselection()):
        list_file.delete(index)


# 저장 경로 (폴더)
def browse_dest_path():
    folder_selected = filedialog.askdirectory()
    if folder_selected == "":  # 사용자가 취소를 누를 때
        print("폴더 선택 취소")
        return
    # print(folder_selected)
    txt_dest_path.delete(0, END)
    txt_dest_path.insert(0, folder_selected)


# 이미지 통합
def merge_image():
    try:
        options = webdriver.ChromeOptions()
        # options.headless = True
        options.add_argument("window-size=1920x1080")

        if getattr(sys, 'frozen', False):
            chromedriver_path = os.path.join(sys._MEIPASS, "chromedriver.exe")
            driver = webdriver.Chrome(chromedriver_path, options=options)
        else:
            driver = webdriver.Chrome(options=options)

        seller_review_all = []
        seller_date_all = []
        id_all = []
        date_all = []
        title_all = []
        content_all = []
        star_all = []
        image_frame_all = pd.DataFrame()

        nows = time.localtime()
        times = str(nows.tm_year) + '-' + str(nows.tm_mon) + '-' + str(nows.tm_mday)
        name = times + 'naver_shop_review.xlsx'

        dest_path = os.path.join(txt_dest_path.get(), name)

        writer = pd.ExcelWriter(dest_path, engine='xlsxwriter')


        check_point = 0

        for get in list_file.get(0, END):
            trt = 1
            if re.findall('smartstore',get):
                check_point = check_point + 1
                driver.get(get)

                time.sleep(1)

                id_all = []
                date_all = []
                title_all = []
                content_all = []
                star_all = []
                image_frame_all = pd.DataFrame()

                num = []
                for i in range(3, 13):
                    num.append(i)
                num_end = num * 100

                page = []


                for page_num in num_end:

                    ### 게시글 열기

                    for z in driver.find_elements_by_class_name("_19SE1Dnqkf"):
                        try:
                            action = ActionChains(driver)
                            action.move_to_element(z).click(z).perform()


                            time.sleep(0.3)
                        except:
                            continue

                    for i in driver.find_elements_by_class_name("_2389dRohZq"):

                        base_1 = i.find_elements_by_class_name('_3QDEeS6NLn')

                        ### id 가져오기

                        id = base_1[0].text
                        id_all.append(id)

                        ### date 가져오기

                        date = base_1[1].text
                        date_all.append(date)
                        ### 상품명 가져오기

                        try:
                            title = i.find_element_by_class_name('_38yk3GGMZq').text
                            title_all.append(title)
                        except:
                            title = '없음'
                            title_all.append(title)
                        ### 리뷰 내용 가져오기

                        content = i.find_element_by_class_name('_19SE1Dnqkf').text
                        content_all.append(content)
                        ### 별점 가져오기

                        star = i.find_element_by_class_name('_15NU42F3kT').text
                        star_all.append(star)

                        if len(i.find_elements_by_class_name('_2EKqsWv0U4')) != 0:
                            name_num_all = []
                            img_1 = []
                            for j in i.find_elements_by_class_name('_2EKqsWv0U4'):
                                img = j.get_attribute('src')
                                if len(re.findall('gif', img)):
                                    continue
                                img_1.append(img)

                            for number in range(1, len(img_1) + 1):
                                name_num = 'img_' + str(number)
                                name_num_all.append(name_num)

                            image_frame = pd.DataFrame(data=[img_1], columns=name_num_all)
                            image_frame_all = pd.concat([image_frame_all, image_frame], axis=0)
                        else:
                            image_frame = pd.DataFrame(data=[''], columns=['img_1'])
                            image_frame_all = pd.concat([image_frame_all, image_frame], axis=0)

                    # 페이지 넘기기

                    try:
                        page_base = driver.find_element_by_xpath(
                            '//*[@id="REVIEW"]/div/div[3]/div/div[2]/div/div/a[%d]' % page_num)
                        print('page' + page_base.text)
                        page_base.click()

                        time.sleep(0.5)


                    except:
                        break

                df = {'구입 상품': title_all, '아이디': id_all, '댓글 내용': content_all, '별점': star_all, '댓글 날짜': date_all}
                df = pd.DataFrame(df)

                image_frame_all_2 = image_frame_all.reset_index().drop(['index'], axis=1)
                df1 = pd.concat([df, image_frame_all_2], axis=1)

                df1.iloc[:, :4].to_excel(writer, sheet_name='Sheet%d' % check_point)

                workbook = writer.book
                worksheet = writer.sheets['Sheet%d' % check_point]

                for i in range(0, len(df1)):
                    for j in range(5, len(df1.columns)):
                        col_alpha = string.ascii_uppercase[j]
                        col_num = str(i + 2)
                        col = col_alpha + col_num

                        try:
                            im = BytesIO(req.urlopen(df1.iloc[i, j]).read())
                            t = Image.open(im).size
                            x_scale = 64 / t[0]
                            y_scale = 20 / t[1]
                            worksheet.insert_image(col, df1.iloc[i, j],
                                                   {'image_data': im, 'x_scale': x_scale, 'y_scale': y_scale,
                                                    'positioning': 1})
                        except:
                            continue

            else:

                check_point = check_point + 1
                driver.get(get)

                time.sleep(1)


                id_all = []
                date_all = []
                title_all = []
                content_all = []
                star_all = []
                image_frame_all = pd.DataFrame()

                num = []
                for i in range(3, 13):
                    num.append(i)
                num_end = num * 100

                page = []

                for page_num in num_end:
                    trt = trt + 1
                    ### 게시글 열기

                    for z in driver.find_elements_by_class_name("eBQ2qaKgOU"):
                        try:
                            action = ActionChains(driver)
                            action.move_to_element(z).click(z).perform()


                            time.sleep(0.3)
                        except:
                            continue

                    for i in driver.find_elements_by_class_name("KHHDezUtRz"):

                        base_1 = i.find_elements_by_class_name('_2Xe0HVhCew')

                        ### id 가져오기

                        id = base_1[0].text
                        id_all.append(id)

                        ### date 가져오기

                        date = base_1[1].text
                        date_all.append(date)
                        ### 상품명 가져오기

                        title = driver.find_element_by_class_name('CxNYUPvHfB').text
                        title_all.append(title)

                        ### 리뷰 내용 가져오기

                        content = i.find_element_by_class_name('eBQ2qaKgOU').text
                        content_all.append(content)
                        ### 별점 가져오기

                        star = i.find_element_by_class_name('_15NU42F3kT').text
                        star_all.append(star)

                        if len(i.find_elements_by_class_name('_2EKqsWv0U4')) != 0:
                            name_num_all = []
                            img_1 = []
                            for j in i.find_elements_by_class_name('_2EKqsWv0U4'):
                                img = j.get_attribute('src')
                                if len(re.findall('gif', img)):
                                    continue
                                img_1.append(img)

                            for number in range(1, len(img_1) + 1):
                                name_num = 'img_' + str(number)
                                name_num_all.append(name_num)

                            image_frame = pd.DataFrame(data=[img_1], columns=name_num_all)
                            image_frame_all = pd.concat([image_frame_all, image_frame], axis=0)
                        else:
                            image_frame = pd.DataFrame(data=[''], columns=['img_1'])
                            image_frame_all = pd.concat([image_frame_all, image_frame], axis=0)

                    # 페이지 넘기기

                    try:
                        page_base = driver.find_element_by_xpath(
                            '//*[@id="REVIEW"]/div/div[3]/div/div[2]/a[12]')
                        print('page' + str(trt))
                        page_base.click()

                        time.sleep(0.5)

                    except:
                        break

                df = {'구입 상품': title_all, '아이디': id_all, '댓글 내용': content_all, '별점': star_all, '댓글 날짜': date_all}
                df = pd.DataFrame(df)

                image_frame_all_2 = image_frame_all.reset_index().drop(['index'], axis=1)
                df1 = pd.concat([df, image_frame_all_2], axis=1)

                df1.iloc[:, :4].to_excel(writer, sheet_name='Sheet%d' % check_point)

                workbook = writer.book
                worksheet = writer.sheets['Sheet%d' % check_point]

                for i in range(0, len(df1)):
                    for j in range(5, len(df1.columns)):
                        col_alpha = string.ascii_uppercase[j]
                        col_num = str(i + 2)
                        col = col_alpha + col_num

                        try:
                            im = BytesIO(req.urlopen(df1.iloc[i, j]).read())
                            t = Image.open(im).size
                            x_scale = 64 / t[0]
                            y_scale = 20 / t[1]
                            worksheet.insert_image(col, df1.iloc[i, j],
                                                   {'image_data': im, 'x_scale': x_scale, 'y_scale': y_scale,
                                                    'positioning': 1})
                        except:
                            continue




        writer.save()
        writer.close()



        msgbox.showinfo("알림", "작업이 완료되었습니다.")

        driver.quit()
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
        msgbox.showwarning("경고", "URL을 입력해 주세요")
        return

    # 저장 경로 확인
    if len(txt_dest_path.get()) == 0:
        msgbox.showwarning("경고", "저장 경로를 선택하세요")
        return


    # 이미지 통합 작업
    merge_image()


# 파일 프레임 (파일 추가, 선택 삭제)
file_frame = LabelFrame(root, text='URL 입력')
file_frame.pack(fill="x", padx=5, pady=5, ipadx=75)  # 간격 띄우기

txt_dest_path1 = Entry(file_frame)
txt_dest_path1.pack(side="left", fill='x', expand=True, padx=5, pady=5, ipady=4)  # 높이 변경

btn_add_file = Button(file_frame, padx=5, pady=5, width=12, text="URL 추가", command=add_file)
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

# 저장 경로 프레임
path_frame = LabelFrame(root, text="저장경로")
path_frame.pack(fill="x", padx=5, pady=5, ipady=5)

txt_dest_path = Entry(path_frame)
txt_dest_path.pack(side="left", fill="x", expand=True, padx=5, pady=5, ipady=4)  # 높이 변경

btn_dest_path = Button(path_frame, text="찾아보기", width=10, command=browse_dest_path)
btn_dest_path.pack(side="right", padx=5, pady=5)


# 실행 프레임
frame_run = Frame(root)
frame_run.pack(fill="x", padx=5, pady=5)

btn_close = Button(frame_run, padx=5, pady=5, text="닫기", width=12, command=root.quit)
btn_close.pack(side="right", padx=5, pady=5)

btn_start = Button(frame_run, padx=5, pady=5, text="시작", width=12, command=start)
btn_start.pack(side="right", padx=5, pady=5)

root.resizable(True, True)
root.mainloop()
