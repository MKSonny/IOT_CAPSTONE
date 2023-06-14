from flask import Flask, render_template, Response, url_for, redirect
from PIL import ImageFont, ImageDraw, Image
import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage
from firebase_admin import firestore
from firebase_admin import messaging
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
font = ImageFont.truetype('fonts/SCDream6.otf', 20)
is_record = False
is_capture = False
start_record = False                                    # 각 변수들은 처음엔 거짓(버튼을 누르지 않음)

def get_detection():
    while True:
        global detection
        detection = db.collection('detect').document('yolov5').get().get('detect')
        # print(f"detection: {detection}")

detection_thread = threading.Thread(target=get_detection)
detection_thread.start()

def gen_frames():  
    global is_record, start_record, is_capture, video, filename   # capture와 push_btn, is_capture, video를 전역변수로 지정(위의 전역변수를 가져옴)
    while True:                                     # 무한루프
        #detection = db.collection('detect').document('yolov5').get().get('detect')
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
            draw.text(xy=(10, 15),  text="WEB CAM "+nowDatetime, font=font, fill=(255, 255, 255))
            frame = np.array(frame)
            ref, buffer = cv2.imencode('.jpg', frame)            
            frame1 = frame              # 현재화면을 frame1에 복사해둠
            frame = buffer.tobytes()

            # detection = db.collection('detect').document('yolov5').get().get('detect')

            if detection == 'true' and is_record == False:  # 현재 녹화상태가 아니며 start_record가 참이면(녹화버튼 누름)
            # if start_record == True and is_record == False:  # 현재 녹화상태가 아니며 start_record가 참이면(녹화버튼 누름)
                is_record = True            # 녹화상태로 만들어줌
                start_record = False        # start_record는 거짓으로
                # 비디오 객체에 (파일이름(한글가능), 인코더, 초당프레임률(정확하지 않음), 영상크기) 로 영상을 쓸 준비

                filename = 'cctv_' + now.strftime('%Y-%m-%dT%H:%M:%S') + '.mp4'
                print(filename)
                video = cv2.VideoWriter('./uploads/' + filename, fourcc, 15, (frame1.shape[1], frame1.shape[0]))
                time.sleep(10)

            elif detection == 'false' and is_record == True: # 녹화중인 상태에서 다시 녹화버튼을 누르면
            # elif start_record and is_record == True: # 녹화중인 상태에서 다시 녹화버튼을 누르면
                is_record = False       # 녹화상태를 꺼줌
                start_record = False
                video.release()         # 녹화 종료

                # firebase upload method starts from here
                blob = bucket.blob('uploads/' + filename)
                #file_uri = blob.public_url
                
                # meta data config
                new_token = uuid4()
                metadata = {'firebaseStorageDownloadTokens':new_token}
                blob.metadata = metadata
                file_uri = blob.public_url
                print("please work: ", file_uri)
                
                platform = db.collection('version').document('KS9DVXtJaKszqMcRK5eO').get().get('who')
                print('platform:', platform)
                
                # if platform == 'android':
                #      message = messaging.Message(
                #         notification = messaging.Notification(
                #             title = '알림',
                #             body = filename
                #             ),
                #         token = 'cf26pp7ES46KPLU6PXoxl9:APA91bEwbAZyusOdwh24H9LV0QSJYEM5K5KTS-uBVBw99CO2QtK3kxIYkjpwkVmQMoDqj5jUaZ3nbTg6S4_qbnmKv_ryGWj3QSrNhZ7MtsUc1QmfCYMHPaWQqzdqGIrKqJl0fz3t1p4i'
                #         )
                #      response = messaging.send(message)
                #      print('response = ', response)
                
                
                with open('./uploads/'+ filename, 'rb') as video_file:
                        blob.upload_from_file(video_file, content_type = 'video/mp4')

                url = blob.generate_signed_url(expiration = datetime.timedelta(minutes=60))

                # 추가할 document 데이터
                
                data = {
                    "file_uri": url,
                    "metadata": str(new_token)
                }
                
                # 새로운 document 추가
                doc_ref = db.collection("chats").document(str(new_token))
                doc_ref.set(data)

                print("Document added with ID: {}".format(doc_ref.id))  


                with open('./uploads/'+ filename, 'rb') as video_file:
                        blob.upload_from_file(video_file, content_type = 'video/mp4')


            elif is_capture:       # 캡쳐버튼을 누르면
                # (파일이름(한글불가, 영어만), 이미지)로 영상을 캡쳐하여 그림파일로 저장
                is_capture = False
                message = messaging.Message(
                        notification = messaging.Notification(
                            title = '알림',
                            body = '새 영상이 추가되었습니다.'
                            ),
                        token = 'dhbZHPrSSy23tYqQ57tnCS:APA91bGc2kKw9K4jZxasRRZ0ntW6SA_gecZ2G49-lylBoyid7-M70HeNrans48CdjsszaJsMDaMuKWLg6fMbspV9hVPUWhlUXoG0pcetSbRpTmK00J-NaxVLv9kK3Yst1u_NtuGoOBns',
                        )
                response = messaging.send(message)
                print('response = ', response)

                # 추가할 document 데이터
                data = {
                    "name": "John Doe",
                    "email": "johndoe@example.com",
                    "age": 30
                }

                # 새로운 document 추가
                doc_ref = db.collection("Post").document()
                doc_ref.set(data)

                print("Document added with ID: {}".format(doc_ref.id)) 
                #cv2.imwrite("capture " + nowDatetime_path + ".png", frame1)  # 파일이름(한글안됨), 이미지 
            if is_record == True:       # 현재 녹화상태이면            
                # 비디오 객체에 현재 프레임 저장
                video.write(frame1)
    
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')  # 그림파일들을 쌓아두고 호출을 기다림

def create_video_name():
    return './uploads/cctv' + nowDatetime_path + '.mp4'

@app.route('/')
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

if __name__ == "__main__":  # 웹사이트를 호스팅하여 접속자에게 보여주기 위한 부분
    app.run(host="0.0.0.0", port = "8080")
    # host는 현재 라즈베리파이의 내부 IP, port는 임의로 설정
    # 해당 내부 IP와 port를 포트포워딩 해두면 외부에서도 접속가능
