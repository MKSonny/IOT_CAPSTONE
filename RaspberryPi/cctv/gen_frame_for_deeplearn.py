from flask import Flask, render_template, Response, url_for, redirect
from PIL import ImageFont, ImageDraw, Image
import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage
from firebase_admin import firestore
from firebase_admin import messaging
from moviepy.video.io.VideoFileClip import VideoFileClip
from uuid import uuid4
import os
import datetime
import threading
import time
import cv2
import numpy as np

#firebase cofig 3/6 -> 3/24 edited to firebase flutter project
# cred = credentials.Certificate('./firebase/videoapp-2207b-firebase-adminsdk-mn7hl-0a759f2e08.json')
cred = credentials.Certificate('./firebase/flutter-4798c-firebase-adminsdk-apes2-583e445d37.json')
# PROJECT_ID = 'videoapp-2207b'
PROJECT_ID = 'flutter-4798c'
default_app = firebase_admin.initialize_app(cred, {
    'storageBucket': f"{PROJECT_ID}.appspot.com"
    })
bucket = storage.bucket()
# Firestore 데이터베이스 객체 생성
db = firestore.client()
#firebase config

app = Flask(__name__)
global is_capture, is_record, start_record            # is_capture와 is_record, start_record를 전역변수로 지정
capture = cv2.VideoCapture(-1)                       # 카메라 영상을 불러와 capture class에 저장
fourcc = cv2.VideoWriter_fourcc(*'H264')            # 녹화파일을 저장할 코덱 설정
capture.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
capture.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)

# capture_deeplearn = cv2.VideoCapture(-1)          # 녹화파일을 저장할 코덱 설정
# capture_deeplearn.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
# capture_deeplearn.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)    

font = ImageFont.truetype('fonts/SCDream6.otf', 20)
is_record = False
is_capture = False
start_record = False                                    # 각 변수들은 처음엔 거짓(버튼을 누르지 않음)
            
def gen_frames_for_deeplearn():  
    while True:                                     
        now = datetime.datetime.now()               # 현재시각 받아옴        
        nowDatetime = now.strftime('%Y-%m-%d %H:%M:%S') # 현재시각을 문자열 형태로 저장
        nowDatetime_path = now.strftime('%Y-%m-%d %H_%M_%S')
        ref, frame = capture.read()  # 현재 영상을 받아옴
        if not ref:                     # 영상이 잘 받아지지 않았으면(ref가 거짓)
            print("gen_frames_for_deeplearn error")
            break                       # 무한루프 종료
        else:
            frame = Image.fromarray(frame)    
            draw = ImageDraw.Draw(frame)    
            # xy는 텍스트 시작위치, text는 출력할 문자열, font는 글꼴, fill은 글자색(파랑,초록,빨강)   
            draw.text(xy=(10, 15),  text="WEB CAM "+nowDatetime, font=font, fill=(255, 255, 255))
            frame = np.array(frame)
            ref, buffer = cv2.imencode('.jpg', frame)            
            frame1 = frame              # 현재화면을 frame1에 복사해둠
            frame = buffer.tobytes()
    
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')  # 그림파일들을 쌓아두고 호출을 기다림


@app.route('/video_feed_for_deeplearn')
def video_feed_for_deeplearn():
    return Response(gen_frames_for_deeplearn(), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == "__main__":  # 웹사이트를 호스팅하여 접속자에게 보여주기 위한 부분
    app.run(host="0.0.0.0", port = "8080")
    # host는 현재 라즈베리파이의 내부 IP, port는 임의로 설정
    # 해당 내부 IP와 port를 포트포워딩 해두면 외부에서도 접속가능
