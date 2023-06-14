from flask import Flask, render_template, Response
import cv2
from multiprocessing import Process, Value, Lock, Manager
import time

app = Flask(__name__)

def gen_frames(camera):  # 영상 스트리밍 함수
    while True:
        success, frame = camera.read()  # 카메라에서 영상 프레임 읽기
        if not success:
            break
        else:
            ret, buffer = cv2.imencode('.jpg', frame)
            frame = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')  # 프레임 바이트 스트림 반환

def stream1(shared_camera, shared_camera_lock):
    with shared_camera_lock:
        camera = cv2.VideoCapture(0)
        shared_camera.value = id(camera)
    while True:
        with shared_camera_lock:
            if shared_camera.value == id(camera):
                for frame in gen_frames(camera):
                    yield (b'--frame\r\n'
                           b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
            else:
                break
        time.sleep(0.1)
    camera.release()

def stream2(shared_camera, shared_camera_lock):
    with shared_camera_lock:
        camera = cv2.VideoCapture(1)
        shared_camera.value = id(camera)
    while True:
        with shared_camera_lock:
            if shared_camera.value == id(camera):
                for frame in gen_frames(camera):
                    yield (b'--frame\r\n'
                           b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
            else:
                break
        time.sleep(0.1)
    camera.release()

@app.route('/')
def index():
    return render_template('index.html')  # HTML 페이지 렌더링

@app.route('/video_feed1')
def video_feed1():
    return Response(stream1(shared_camera, shared_camera_lock),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/video_feed2')
def video_feed2():
    return Response(stream2(shared_camera, shared_camera_lock),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == '__main__':
    shared_camera = Value('i', 0)
    shared_camera_lock = Lock()
    p1 = Process(target=stream1, args=(shared_camera, shared_camera_lock))
    p2 = Process(target=stream2, args=(shared_camera, shared_camera_lock))
    p1.start()
    p2.start()
    app.run(host='0.0.0.0', debug=True)
    p1.join()
    p2.join()

