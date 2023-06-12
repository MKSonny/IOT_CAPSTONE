import cv2
import time
import torch
import argparse
import numpy as np
import matplotlib.pyplot as plt
from torchvision import transforms
from utils.datasets import letterbox
from utils.torch_utils import select_device
from models.experimental import attempt_load
from utils.general import non_max_suppression_kpt,strip_optimizer,xyxy2xywh
from utils.plots import output_to_keypoint, plot_skeleton_kpts,colors,plot_one_box_kpt
import os
#==================parameters==========================
print(torch.cuda.get_device_name(0))
poesweights = 'C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/yolov7-pose-estimation/yolov7-w6-pose.pt'
device = 'cuda'

strip_optimizer(device, poesweights)
device = select_device(device)
hide_conf = False
hide_labels = False
model = attempt_load(poesweights, map_location=device)
_ = model.eval()
names = model.modules.names if hasattr(model, 'module') else model.names

##==================디렉토리 내 영상 파일 한 번에 열어 학습하기 위한 변수들==========================
paths = 'C:/Users/ICT/Desktop/youda/violence_data/train/nonviolence'
video_paths = list(os.listdir(paths))
num_path = 2765

#==========================frame에 객체 감지 되면 keypoint값 저장하기 위해 사용하는 parameter==========================
j = 1
seq = 10 #50frame마다 저장합니다.

for path in video_paths: #한 폴더 내 파일들 path로 받아오기
    frame_count = 0
    sequence = np.empty(51)#pose estimation결과 받기 위한 빈 numpy 배열
    source = os.path.join(paths,path) #영상 하나씩 받아서 절대경로 만들기
    cap = cv2.VideoCapture(source)

    if (cap.isOpened() == False):
        print("비디오를 읽어올 수 없습니다. path를 체크해보세요")

    frame_width = int(cap.get(3)/2) #정확도 위해 영상 사이즈 조금 줄임
    while(cap.isOpened):
        print("Frame {} Processing".format(frame_count))

        ret, frame = cap.read()
        if ret:
            '''영상 실행'''
            org_img = frame
            image = cv2.cvtColor(org_img, cv2.COLOR_BGR2RGB)
            image = letterbox(image, (frame_width), stride=64, auto=True)[0]
            image = transforms.ToTensor()(image)
            image = torch.tensor(np.array([image.numpy()]))

            image = image.to(device)  #GPU연산을 위해 image GPU에 올림
            start_time = time.time()

            with torch.no_grad():  #get predictions
                output_data, _ = model(image)
            output_data = non_max_suppression_kpt(output_data,   #Apply non max suppression
                                                0.70,   # Conf. Threshold.
                                                0.65, # IoU Threshold.
                                                nc=model.yaml['nc'], # Number of classes.
                                                nkpt=model.yaml['nkpt'], # Number of keypoints.
                                                kpt_label=True)
            
            output = output_to_keypoint(output_data) #객체 감지되는 프레임 찾기 위한 output
                                        
            im0 = image[0].permute(1, 2, 0) * 255 # Change format [b, c, h, w] to [h, w, c] for displaying the image.
            im0 = im0.cpu().numpy().astype(np.uint8)

            im0 = cv2.cvtColor(im0, cv2.COLOR_RGB2BGR) #reshape image format to (BGR)

            for i, pose in enumerate(output_data):  # detections per image
                # if frame_out ==True:
                #     break

                if len(output_data):  #pose 감지된다면
                    for c in pose[:, 5].unique():
                        n = (pose[:, 5] == c).sum()
                        print(f"No of Objects in Current Frame : {n}")
                    
                    for det_index, (*xyxy, conf, cls) in enumerate(reversed(pose[:,:6])):
                        c = int(cls)  # integer class
                        kpts = pose[det_index, 6:]
                        label = None if hide_labels else (names[c] if hide_conf else f'{names[c]} {conf:.2f}')
                        plot_one_box_kpt(xyxy, im0, label=label, color=colors(c, True), 
                                    line_thickness=3,kpt_label=True, kpts=kpts, steps=3, 
                                    orig_shape=im0.shape[:2])
                        
                        kpts = kpts.cpu().numpy()
                        # print(kpts.shape)
                                    
                    if j <= seq:
                        '''50 프레임이 지나면 sequence에 저장하기'''
                        for idx in range(output.shape[0]):
                            kpts = output[idx, 7:].T
                            plot_skeleton_kpts(im0, kpts, 3)

                            #keypoint값 sequence에 넣기
                            sequence = np.vstack([sequence,kpts])
                            print("sequence : ",sequence.shape)

                            if sequence.shape == (10,51):
                                '50개 지났을 때'
                                #frame 50배수 단위로 저장하기
                                print("sequence : ",sequence.shape)
                                np.save(f"C:/Users/ICT/Desktop/youda/IoT_Capstone/10framedataset/x/{num_path}_x",sequence)
                                sequence = np.empty(51)
                                y_np = np.array([0., 1.])
                                np.save(f"C:/Users/ICT/Desktop/youda/IoT_Capstone/10framedataset/y/{num_path}_y",y_np)
                                print(f"------------------------------------------------------------{num_path}.npy 저장------------------------------------------------------------")
                                num_path += 1
                
                # cv2.imshow("YOLOv7 Pose Estimation Demo", im0)
                frame_count += 1
                cv2.waitKey(3)  # 1 millisecond#
        
        else:
             '''영상 없으면 break'''
             break
    cap.release()
    print(f"============================================================================={path}.wav 끝=============================================================================")

    