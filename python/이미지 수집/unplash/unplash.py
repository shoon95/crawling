import tkinter.ttk as ttk
import tkinter.messagebox as msgbox
from tkinter import *  # __all__
from tkinter import filedialog
import json
import requests
from tkinter import scrolledtext
import urllib.request
import re
import time
import os, sys

root = Tk("")
root.title("unplash")


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
            os.mkdir('unplash')
        except:
            pass
        os.chdir(os.getcwd() + '\\unplash')
        path=os.getcwd()

        try:
            for i in list_file.get(0,END):
                os.mkdir(i)
        except:
            pass


        for i in list_file.get(0,END):

            path2=path + '\\' + i
            path2.replace('\\','/')
            os.chdir(path2)
            url = requests.get("https://unsplash.com/napi/search/photos?query=%s&page=1000&xp=" %i)
            text = url.text
            data = json.loads(text)

            last_page = data['total_pages']

            image_all = []
            image_all2 = []
            for num in range(1, int(last_page) + 1):
                url_text = "https://unsplash.com/napi/search/photos?query=%s&page=%d&xp=" % (i, num)
                url = requests.get(url_text)

                if url.status_code==503:
                    while url.status_code==503:
                        time.sleep(5)
                        url = requests.get(url_text)
                        if url.status_code!=503:
                            break

                if url.status_code == 200:
                    text = url.text

                    data = json.loads(text)

                    for z in data['results']:
                        image_all.append(z['urls']['raw'])

                    for z in data['results']:
                        image_all2.append(z['links']['download'])

                    if int(txt_dest_path2.get())<= len(image_all):
                        break
                else:
                    print(i+num + 'error')
                    continue

            name = []
            for j in image_all2:
                name.append(os.getcwd() + '/' + re.split('/', j)[4] + '.jpg')

            num_re=0
            check =  1
            for j, k in zip(image_all[0:int(txt_dest_path2.get())+1], name[0:int(txt_dest_path2.get())+1]):
                urllib.request.urlretrieve(j, k)
                check=check+1
                progress = check / len(image_all[0:int(txt_dest_path2.get())+1]) *100
                p_var.set(progress)
                progress_bar.update()



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
