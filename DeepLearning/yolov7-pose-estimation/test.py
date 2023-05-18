import cv2
import time
import torch
import argparse
import numpy as np
from utils.datasets import letterbox
from utils.torch_utils import select_device
from models.experimental import attempt_load
from utils.plots import output_to_keypoint, plot_skeleton_kpts, plot_one_box_kpt, colors
from utils.general import non_max_suppression_kpt, strip_optimizer
from torchvision import transforms
import tensorflow
from PIL import ImageFont, ImageDraw, Image
import os

def load_classes(path):
    with open(path,'r') as f:
        names = f.read().split('\n')
        #filter통해 빈 string을 지우고 리스트에 class 저장함
    return list(filter(None, names))

#===============parameters===============
poseweight = 'C:\\Users\\ICT\\Desktop\\youda\\IoT_Capstone\\DeepLearning\\yolov7\\yolov7_w6_pose.pt' #yolov7 weight파일
source = 'C:/Users/ICT/Desktop/youda/data/nonviolence/33.mp4' #테스트할 영상 위치
device = 'CPU'
hide_conf = False
hide_labels = False
line_thickness = 3

sequence = []
pose_name = '' #LSTM 출력값 저장할 string 변수
frame_count = 0
actions = np.array(['violence', 'nonviolence']) #행동 action변수에 정의

#===============weight 파일 가져오기===============
model = attempt_load(poseweight, map_location=device) #yolov7 weight파일 가져오기
_ = model.eval() #평가 모드
names = model.module.names if hasattr(model, 'module') else model.names

lstm_model = tensorflow.keras.models.load_model("C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/model/fourthweight.h5") #LSTM weight파일 가져오기

capture = cv2.VideoCapture(source)
if capture.isOpened() == False:
    print("Video can't open. Please check video path again")

#영상처리에 필요한 parameters
frame_count = 0
frame_width = int(capture.get(3)/2) #video capture의 width 구해서 반으로 자른 크기로 영상 출력하기 

j = 1
seq = 140 #20frame 기준으로 자름
while(capture.isOpened):
    #영상 read시작함
    print(f"Frame {frame_count+1} Processing")
    ret, frame = capture.read()

    if ret:
        org_image = frame
        image = cv2.cvtColor(org_image,cv2.COLOR_BGR2RGB)
        image = transforms.ToTensor()(image)
        image = torch.tensor(np.array([image.numpy()]))

        image = image.to(device)
        image = image.float()
        image = image.float()

        with torch.no_grad():  #get predictions
            output_data, _ = model(image)

        output_data = non_max_suppression_kpt(output_data,   #Apply non max suppression
                                            0.70,   # Conf. Threshold.
                                            0.65, # IoU Threshold.
                                            nc=model.yaml['nc'], # Number of classes.
                                            nkpt=model.yaml['nkpt'], # Number of keypoints.
                                            kpt_label=True)
        output = output_to_keypoint(output_data)
        im0 = image[0].permute(1, 2, 0) * 255 # Change format [b, c, h, w] to [h, w, c] for displaying the image.
        im0 = im0.cpu().numpy().astype(np.uint8)
        
        im0 = cv2.cvtColor(im0, cv2.COLOR_RGB2BGR) #reshape image format to (BGR)
        gn = torch.tensor(im0.shape)[[1, 0, 1, 0]]  # normalization gain whwh
        
        for i, pose in enumerate(output_data):
            #객체 감지
            if len(output_data): #프레임 있다면
                for c in pose[:,5].unique():
                    #객체 감지 되는동안
                    n = (pose[:,5]==c).sum()
                    print(f"No of Object in Current Frame: {n}")
                
                for det_index, (*xyxy, conf, cls) in enumerate(reversed(pose[:,:6])):
                    c = int(cls)
                    kpts = pose[det_index, 6:]
                    label = None if hide_labels else (names[c] if hide_conf else f'{names[c]} {conf:.2f}')
                    plot_one_box_kpt(xyxy, im0, label=label, color=colors(c, True), 
                                        line_thickness=line_thickness,kpt_label=True, kpts=kpts, steps=3, 
                                        orig_shape=im0.shape[:2])
                
                if j<=seq:
                    for idx in range(output.shape[0]):
                        kpts = output[idx, 7:].T
                        plot_skeleton_kpts(im0, kpts, 3)
                        sequence.append(kpts.tolist())
                if len(sequence) == 140:  
                        result = lstm_model.predict(np.expand_dims(sequence, axis=0))
                        pose_name = actions[np.argmax(result)]

                        if pose_name == 'violence':
                                print("폭력이 감지되었어요!")

                        elif pose_name == 'nonviolence':
                            print("폭력이 감지되지 않았아요!")
                        else:
                            print(pose_name)
                if j == seq:
                    sequence = []
                    j = 0
                    j += 1
        cv2.imshow("Violence detect result", im0)
        if cv2.waitKey(1)==ord('c') : # 1 millisecond
            break
    else:
        break


                

