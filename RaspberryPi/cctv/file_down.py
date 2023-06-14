from flask import Flask, render_template, Response, url_for, redirect,request,send_file
from flask import jsonify, send_from_directory
from PIL import ImageFont, ImageDraw, Image
from werkzeug.utils import secure_filename
import os
import datetime
import cv2
import numpy as np

app = Flask(__name__)

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

@app.route('/get_list')
def get_list():
    file_list = os.listdir("./uploads")
    data = {'file_list' : file_list}
    return jsonify(data) 

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

		path = "./uploads/" 
		return send_file(path + request.form['file'],
				download_name = request.form['file'],
				as_attachment=True)

#안드로이드 스트리밍 연동을 위한 영상 재생 url
@app.route('/video')
def stream_video():
    return send_file('./uploads/working.mp4', mimetype='video/mp4')

@app.route('/second')
def second():
    file_list = os.listdir('./uploads')
    return url_for('videos', )

@app.route('/third/<list:list_>')
def videos(list):


if __name__ == '__main__':
    app.run(host="192.168.164.107", port = "8080", debug=True)
    # host는 현재 라즈베리파이의 내부 IP, port는 임의로 설정
    # 해당 내부 IP와 port를 포트포워딩 해두면 외부에서도 접속가능
