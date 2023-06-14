from flask import Flask, send_file, render_template,Response,url_for,redirect,request
from werkzeug.utils import secure_filename
import os
import datetime
import cv2
import numpy as py

app = Flask(__name__)


@app.route('/movie')
def get():
    return send_file("uploads/working.mp4") 

@app.route('/video/<string:videoName>')
def video(videoName):
    return send_file("uploads/"+videoName)

if __name__ == "__main__":
    app.run(host="192.168.125.107", port="8080")
