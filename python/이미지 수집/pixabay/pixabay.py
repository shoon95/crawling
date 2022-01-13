import tkinter.ttk as ttk
import tkinter.messagebox as msgbox
from tkinter import *  # __all__
from tkinter import filedialog
import re
import os, sys
import chromedriver_autoinstaller
from selenium import webdriver
import time

root = Tk("")
root.title("Pixabay")

def open_chromedriver():
    chrome = chromedriver_autoinstaller.install(os.getcwd())

    options = webdriver.ChromeOptions()
    #options.headless = True

    driver = webdriver.Chrome(options=options)
    return(driver)


# 파일 추가
def add_file():
    if txt_dest_path1.get()=='':
        msgbox.showerror("에러",'검색어를 정확히 입력해주세요')
        return
    elif txt_dest_path1.get() == ' ':
        msgbox.showerror("에러", '검색어를 정확히 입력해주세요')
        return
    elif txt_dest_path1.get() == '  ':
        msgbox.showerror("에러", '검색어를 정확히 입력해주세요')
        return
    elif txt_dest_path1.get() == '   ':
        msgbox.showerror("에러", '검색어를 정확히 입력해주세요')
        return
    elif txt_dest_path1.get() == '    ':
        msgbox.showerror("에러", '검색어를 정확히 입력해주세요')
        return
    elif txt_dest_path1.get() == '     ':
        msgbox.showerror("에러", '검색어를 정확히 입력해주세요')
        return

    else:
        files = txt_dest_path1.get()
        # 사용자가 선택한 파일 목록

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

        os.chdir(txt_dest_path.get())
        try:
            os.mkdir('Pixabay')
        except:
            pass
        os.chdir(os.getcwd() + '\\Pixabay')
        path=os.getcwd()

        try:
            for i in list_file.get(0,END):
                os.mkdir(i)
        except:
            pass

        driver = open_chromedriver()

        for i in list_file.get(0,END):

            path2=path + '\\' + i
            path2.replace('\\','/')
            os.chdir(path2)
            url = 'https://pixabay.com/images/search/%s' % i
            driver.get(url)

            time.sleep(1)

            image_all = []
            num=0
            while True:
                driver.execute_script("window.scrollTo(0, document.body.scrollHeight)")
                time.sleep(1)
                data = driver.page_source


                for z in driver.find_elements_by_xpath(
                        '//*[@id="app"]/div/div[3]/div/div/div[2]/div/div[*]/div/div/div/a/img'):
                    if '.jpg' in z.get_attribute('src'):
                        image_all.append(re.sub('__[0-9]+', '__', z.get_attribute('src')))
                    elif '.png' in z.get_attribute('src'):
                        image_all.append(re.sub('__[0-9]+', '__', z.get_attribute('src')))

                    else:
                        continue


                num = num + 1
                print(num, '-', len(image_all), '-', txt_dest_path2.get())

                if len(image_all) >= int(txt_dest_path2.get()):
                    break

                try:
                    if driver.find_element_by_xpath('//*[@id="app"]/div/div[4]/div[1]/div[2]/a').text == "Next page\n›":
                        driver.find_element_by_xpath('//*[@id="app"]/div/div[4]/div[1]/div[2]/a').click()
                        time.sleep(1)
                    else:
                        break

                except:
                    break
            name = []
            for z in image_all:
                name.append(re.sub('__[0-9]+', '', re.split('/', z)[len(re.split('/', z)) - 1]))
            image_path = []
            for i, j in zip(image_all[0:int(txt_dest_path2.get())], name[0:int(txt_dest_path2.get())]):

                image_path.append("curl " + i + " > " + j)

            check=0
            for i in image_path:
                check = check + 1
                progress = check / len(image_path) * 100
                p_var.set(progress)
                progress_bar.update()
                os.system(i)



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
        msgbox.showwarning("경고", "검색어를 입력해 주세요")
        return
    if txt_dest_path2.get()=='':
        msgbox.showerror("에러", '사진의 수를 입력해주세요')
        return
    # 저장 경로 확인
    if len(txt_dest_path.get()) == 0:
        msgbox.showwarning("경고", "저장 경로를 선택하세요")
        return


    # 이미지 통합 작업
    merge_image()


# 파일 프레임 (파일 추가, 선택 삭제)
file_frame = LabelFrame(root, text='검색어 입력')
file_frame.pack(fill="x", padx=5, pady=5, ipadx=75)  # 간격 띄우기

txt_dest_path1 = Entry(file_frame)
txt_dest_path1.pack(side="left", fill='x', expand=True, padx=5, pady=5, ipady=4)  # 높이 변경

btn_add_file = Button(file_frame, padx=5, pady=5, width=12, text="검색어 추가", command=add_file)
btn_add_file.pack(side="left")

btn_del_file = Button(file_frame, padx=5, pady=5, width=12, text="선택삭제", command=del_file)
btn_del_file.pack(side="right")

# 리스트 프레임
list_frame = LabelFrame(root,text='검색어 목록')
list_frame.pack(fill="both", padx=5, pady=5)

scrollbar = Scrollbar(list_frame)
scrollbar.pack(side="right", fill="y")

list_file = Listbox(list_frame, selectmode="extended", height=15, yscrollcommand=scrollbar.set)
list_file.pack(side="left", fill="both", expand=True)
scrollbar.config(command=list_file.yview)

# 옵션 프레임


# 2. 간격 옵션
# 간격 옵션 레이블
path_frame2 = LabelFrame(root, text="사진 수 입력")
path_frame2.pack(fill="x", padx=5, pady=5, ipady=5)

txt_dest_path2 = Entry(path_frame2)
txt_dest_path2.pack(side="left", fill="x", expand=True, padx=5, pady=5, ipady=4)  # 높이 변경

# 저장 경로 프레임
path_frame = LabelFrame(root, text="저장경로")
path_frame.pack(fill="x", padx=5, pady=5, ipady=5)

txt_dest_path = Entry(path_frame)
txt_dest_path.pack(side="left", fill="x", expand=True, padx=5, pady=5, ipady=4)  # 높이 변경

btn_dest_path = Button(path_frame, text="찾아보기", width=10, command=browse_dest_path)
btn_dest_path.pack(side="right", padx=5, pady=5)

# 진행 상황 Progress Bar
frame_progress = LabelFrame(root, text="진행상황")
frame_progress.pack(fill="x", padx=5, pady=5, ipady=5)

p_var = DoubleVar()
progress_bar = ttk.Progressbar(frame_progress, maximum=100, variable=p_var)
progress_bar.pack(fill="x", padx=5, pady=5)

# 실행 프레임
frame_run = Frame(root)
frame_run.pack(fill="x", padx=5, pady=5)

btn_close = Button(frame_run, padx=5, pady=5, text="닫기", width=12, command=root.quit)
btn_close.pack(side="right", padx=5, pady=5)

btn_start = Button(frame_run, padx=5, pady=5, text="시작", width=12, command=start)
btn_start.pack(side="right", padx=5, pady=5)

root.resizable(True, True)
root.mainloop()
