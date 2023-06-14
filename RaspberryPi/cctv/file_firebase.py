import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage
from uuid import uuid4
import os

cred = credentials.Certificate('./firebase/videotest-ffe11-firebase-adminsdk-stv5k-1ec68086c9.json')

PROJECT_ID = 'videotest-ffe11'

defalut_app = firebase_admin.initialize_app(cred, {
    'storageBucket': f"{PROJECT_ID}.appspot.com"
    })

bucket = storage.bucket()

file_n = './uploads/working2.mp4'

#file_open = open('./uploads/working.mp4', 'rb')

# firebase storage에 새 객체를 생성한다.
blob = bucket.blob('working3.mp4')
new_token = uuid4()
metadata = {'firebaseStorageDownloadTokens': new_token}

# 이유는 모르겠지만 메타데이터가 없으면 영상을 재생할 수 없다.
blob.metadata = metadata

with open('./uploads/working2.mp4', 'rb') as video_file:
    blob.upload_from_file(video_file, content_type = 'video/mp4')

#blob.upload_from_filename(filename = file_n, content_type = 'video/mp4')
