import cv2
import time
import numpy as np
from random import randint
import argparse
from pathlib import Path
import json
import csv
import os

#body_25 Output Format
nPoints = 25
keypointsMapping = ["Nose","Neck","RShoulder", "RElbow", "RWrist", "LShoulder", "LElbow",
                    "LWrist", "MidHip", "RHip","RKnee", "RAnkle", "LHip", "LKnee",
                    "LAnkle", "REye", "LEye", "REar", "LEar", "LBigToe", "LSmallToe",
                     "LHeel",  "RBigToe", "RSmallToe", "RHeel"]

POSE_PAIRS = [[1,2], [1,5], [2,3], [3,4], [5,6], [6,7],[1,8], [8,9], [9,10], [10,11], 
              [8,12], [12,13], [13,14], [11,24], [11,22], [22,23], [14,21],[14,19],[19,20], [1,0], 
              [0,15], [15,17], [0,16], [16,18],[2,17], [5,18]]

mapIdx = [[40,41],[48,49],[42,43],[44,45],[50,51],[52,53],
          [26,27],[32,33],[28,29],[30,31],[34,35],[36,37],
          [38,39],[76,77],[72,73],[74,75],[70,71],[66,67],
          [68,69],[56,57],[58,59],[62,63],[60,61],[64,65],
          [46,47],[54,55]]

colors = [ [0,100,255], [0,100,255], [0,255,255], [0,100,255], [0,255,255], [0,100,255],
         [0,255,0], [255,200,100], [255,0,255], [0,255,0], [255,200,100], [255,0,255],
         [0,0,255], [255,0,0], [200,200,0], [255,0,0], [125,200,125], [125,200,0],
         [200,200,200],[200,100,200],[200,200,0],[0,200,0],[200,0,255],[0,250,125],
         [0,200,0],[0,120,200]]

device = 'gpu'

# 각 파일 path
BASE_DIR = Path(__file__).resolve().parent

#body_25 모델 적용
protoFile ="C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/Human-Violence-Detection/models/pose/body_25/pose_deploy.prototxt"
weightsFile ="C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/Human-Violence-Detection/models/pose/body_25/pose_iter_584000.caffemodel"

net = cv2.dnn.readNetFromCaffe(protoFile, weightsFile)
net.setPreferableBackend(cv2.dnn.DNN_BACKEND_CUDA)
net.setPreferableTarget(cv2.dnn.DNN_TARGET_CUDA)
print("Using GPU device")

#path 내 동영상 한 번에 열어서 학습시키기
path = 'C:/Users/ICT/Desktop/youda/ViolenceData/Violence'
video_paths = list(os.listdir(path))


num_path = 0
#동영상 연결
for file in video_paths:
    print("num_path: ",num_path)
    capture = cv2.VideoCapture(os.path.join(path,file))

    #파라미터값 설정
    inputWidth = 320
    inputHeight = 240
    inputScale = 1.0 / 255
    w = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
    h = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = 24
    fourcc = cv2.VideoWriter_fourcc(*'DIVX')
    # out = cv2.VideoWriter('./output_inv.avi', fourcc, fps, (w, h))
    total_keypoints = []
    #while문 통해 동엿상 열기
    while True: #어떤 키든 입력할 경우 중지
        #웹캠으로부터 영상 가져오기
        hasframe , frame = capture.read()

        #웹캠에서 영상 가져올 수 없다면 웹캠 중지하기
        if not hasframe:
            break

        t = time.time()
        frameWidth = frame.shape[1]
        frameHeight = frame.shape[0]

        inpBlob = cv2.dnn.blobFromImage(frame, inputScale, (inputWidth, inputHeight),(0, 0, 0), swapRB=False, crop=False)
        # imgb = cv2.dnn.imagesFromBlob(inpBlob)

        net.setInput(inpBlob)
        
        # 결과 받아오기
        output = net.forward()
        print("Time Taken in forward pass = {}".format(time.time() - t))
        fps = capture.get(cv2.CAP_PROP_FPS)
        print("fps: ",fps)

        detect_keypoints = []
        keypoints_list = np.zeros((0,3))
        keypoint_id = 0
        threshold = 0.1

        for part in range(nPoints):
            probMap = output[0, part, :, :]
            probMap = cv2.resize(probMap, (frameWidth, frameHeight))
            
            #특징점 추출(Keypoints)-> 원래 함수에 있던 애
            mapSmooth = cv2.GaussianBlur(probMap, (3,3), 0, 0)
            mapMask = np.uint8(mapSmooth>threshold)
            keypoints = []
            contours, _ = cv2.findContours(mapMask, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

            #각 blobs의 max, min값 찾기
            for cnt in contours:
                blobMask = np.zeros(mapMask.shape)
                blobMask = cv2.fillConvexPoly(blobMask, cnt, 1)
                maskedProbMap = mapSmooth * blobMask
                _, maxVal, _, maxLoc = cv2.minMaxLoc(maskedProbMap)
                keypoints.append(maxLoc + (probMap[maxLoc[1], maxLoc[0]],))
            print("Keypoints - {} : {}".format(keypointsMapping[part], keypoints))
            keypoints_with_id = []
            for i in range(len(keypoints)):
                keypoints_with_id.append(keypoints[i]+(keypoint_id,))
                # print("keypoints with id: ", keypoints_with_id)
                keypoints_list = np.vstack([keypoints_list, keypoints[i]])
                keypoint_id += 1

            detect_keypoints.append(keypoints_with_id)
            # print("detect_keypoints: ",detect_keypoints)
        
        # Clone해서 특징점 원형으로 그리기
        frameClone = frame.copy()

        '''json파일로 저장하기 위해 pose_keypoints 정의'''
        pose_keypoints = []
        for i in range(nPoints):
            if detect_keypoints[i] == []:
                pose_keypoints.append(0)
                pose_keypoints.append(0)
                pose_keypoints.append(0)

            for j in range(len(detect_keypoints[i])):
                pose_keypoints.append(detect_keypoints[i][j][0])
                pose_keypoints.append(detect_keypoints[i][j][1])
                pose_keypoints.append(float(detect_keypoints[i][j][2]))
                cv2.circle(frameClone, detect_keypoints[i][j][0:2], 5, colors[i], -1, cv2.LINE_AA)
        total_keypoints.append(pose_keypoints)
        cv2.imshow("Detected Pose" , frameClone)

    '''keypoints값 json파일에 저장하기'''
    json_data = {
        f"{file}":[total_keypoints],
        "label" : "violence"
        }
    with open(f'C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/{file}.json','w') as outfile:
        json.dump(json_data, outfile)

    num_path += 1
 
        
    capture.release()  # 카메라 장치에서 받아온 메모리 해제
    # out.release()
    cv2.destroyAllWindows()
