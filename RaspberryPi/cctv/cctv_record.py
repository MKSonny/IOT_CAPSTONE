#
#      공대선배 라즈베리파이 CCTV 프로젝트 #6 버튼으로 영상녹화
#      youtube 바로가기: https://www.youtube.com/c/공대선배
#      웹페이지의 버튼을 눌러 현재화면 녹화, 캡쳐
#

from flask import Flask, render_template, Response, url_for, redirect,request,send_file
from PIL import ImageFont, ImageDraw, Image
from werkzeug.utils import secure_filename
import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage
from uuid import uuid4
import os
import datetime
import cv2
import numpy as np

'''
cred = credentials.Certificate('./firebase/videotest-ffe11-firebase-adminsdk-stv5k-1ec68086c9.json')

PROJECT_ID = 'videotest-ffe11'

default_app = firebase_admin.initialize_app(cred, {
    'storageBucket': f"{PROJECT_ID}.appspot.com"
})
bucket = storage.bucket()

file_n = './uploads/working.mp4'
blob = bucket.blob('upload/')
new_token = uuid4()
metadata = {"firebaseStorageDownloadTokens": new_token}
blob.metadata = metadata
blob.upload_from_filename(filename=file_n, content_type='video/mp4')
'''

app = Flask(__name__)
global is_capture, is_record, start_record            # is_capture와 is_record, start_record를 전역변수로 지정
capture = cv2.VideoCapture(-1)                       # 카메라 영상을 불러와 capture class에 저장
fourcc = cv2.VideoWriter_fourcc(*'H264')            # 녹화파일을 저장할 코덱 설정
capture.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
capture.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
font = ImageFont.truetype('fonts/SCDream6.otf', 20)
is_record = False

def gen_frames():  
    global is_record, start_record, is_capture, video   # capture와 push_btn, is_capture, video를 전역변수로 지정(위의 전역변수를 가져옴)
    while True:                                     # 무한루프
        now = datetime.datetime.now()               # 현재시각 받아옴        
        nowDatetime = now.strftime('%Y-%m-%d %H:%M:%S') # 현재시각을 문자열 형태로 저장
        nowDatetime_path = now.strftime('%Y-%m-%d %H_%M_%S')
        ref, frame = capture.read()  # 현재 영상을 받아옴
        if not ref:                     # 영상이 잘 받아지지 않았으면(ref가 거짓)
            break                       # 무한루프 종료
        else:
            frame = Image.fromarray(frame)    
            draw = ImageDraw.Draw(frame)    
            # xy는 텍스트 시작위치, text는 출력할 문자열, font는 글꼴, fill은 글자색(파랑,초록,빨강)   
            draw.text(xy=(10, 15),  text="웹캠 테스트 "+nowDatetime, font=font, fill=(255, 255, 255))
            frame = np.array(frame)
            ref, buffer = cv2.imencode('.jpg', frame)            
            frame1 = frame              # 현재화면을 frame1에 복사해둠
            frame = buffer.tobytes()
            if start_record == True and is_record == False:  # 현재 녹화상태가 아니며 start_record가 참이면(녹화버튼 누름)
                is_record = True            # 녹화상태로 만들어줌
                start_record = False        # start_record는 거짓으로
                # 비디오 객체에 (파일이름(한글가능), 인코더, 초당프레임률(정확하지 않음), 영상크기) 로 영상을 쓸 준비

                #video = cv2.VideoWriter("working.mp4", fourcc, 15, (frame1.shape[1], frame1.shape[0]))
                video = cv2.VideoWriter("cctv_" + nowDatetime_path + ".mp4", fourcc, 15, (frame1.shape[1], frame1.shape[0]))
            elif start_record and is_record == True: # 녹화중인 상태에서 다시 녹화버튼을 누르면
                print('make_mp4')
                is_record = False       # 녹화상태를 꺼줌
                start_record = False
                video.release()         # 녹화 종료
            elif is_capture:       # 캡쳐버튼을 누르면
                # (파일이름(한글불가, 영어만), 이미지)로 영상을 캡쳐하여 그림파일로 저장
                is_capture = False
                cv2.imwrite("capture " + nowDatetime_path + ".png", frame1)  # 파일이름(한글안됨), 이미지 
            if is_record == True:       # 현재 녹화상태이면            
                # 비디오 객체에 현재 프레임 저장
                video.write(frame1)
    
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')  # 그림파일들을 쌓아두고 호출을 기다림

@app.route('/streaming')
def index():
    global is_record
    return render_template('web_record.html', is_record=is_record)             # index4#6.html의 형식대로 웹페이지를 보여줌

@app.route('/video_feed')
def video_feed():
    return Response(gen_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/push_record')
def push_record():                      # 녹화버튼을 눌렀을때 실행되는 함수
    global start_record                 # start_record를 전역변수로 불러옴
    start_record = not start_record     # start_record를 토글
    return redirect(url_for('index'))

@app.route('/push_capture')
def push_capture():                     # 캡쳐버튼을 눌렀을때 실행되는 함수
    global is_capture                   # is_capture를 전역변수로 불러옴
    is_capture = True                   # is_capture를 참으로 만들어줌
    return redirect(url_for('index'))

# <파일 업로드 코드 머지>

@app.route('/')
def home_page():
    return render_template('home.html')

@app.route('/upload')
def upload_page():
    return render_template('upload.html')

@app.route('/fileUpload', methods = ['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        f = request.files['file']
        f.save('./uploads/' + secure_filename(f.filename))
        files = os.listdir("./uploads")
        return render_template('check.html')

        #다운로드 HTML 렌더링
@app.route('/downfile')
def down_page():
	files = os.listdir("./uploads")
	return render_template('filedown.html',files=files)

#리스트를 받아서 안드로이드에 넘겨서
#리사이클러뷰의 list.Of()에 넣을 수 있도록 한다.
#list는 레트로핏에서 get 할 수 있도록 json으로 넘긴다.
@app.route('/get_list')
def get_list():
    file_list = os.listdir("./uploads")
    return file_list

@app.route('/list')
def list_page():
	file_list = os.listdir("./uploads")
	html = """<center><a href="/">홈페이지</a><br><br>""" 
	html += "file_list: {}".format(file_list) + "</center>"
	return html

#파일 다운로드 처리
@app.route('/fileDown', methods = ['GET', 'POST'])
def down_file():
	if request.method == 'POST':
		sw=0
		files = os.listdir("./")
		for x in files:
			if(x==request.form['file']):
				sw=1

		path = "./" 
		return send_file(path + request.form['file'],
				download_name = request.form['file'],
				as_attachment=True)

if __name__ == "__main__":  # 웹사이트를 호스팅하여 접속자에게 보여주기 위한 부분
    app.run(host="192.168.20.107", port = "8080", debug=True)
    # host는 현재 라즈베리파이의 내부 IP, port는 임의로 설정
    # 해당 내부 IP와 port를 포트포워딩 해두면 외부에서도 접속가능
