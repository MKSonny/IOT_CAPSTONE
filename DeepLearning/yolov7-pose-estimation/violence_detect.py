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

def run(poseweights="yolov7-w6-pose.pt",source="football1.mp4",device='cpu',view_img=False,
        save_conf=False,line_thickness = 3,hide_labels=False, hide_conf=True):

    x_test = []
    pose_name = ''
    frame_count = 0
    
    device = select_device(opt.device) #select device

    model = attempt_load(poseweights, map_location=device)  #Load model
    _ = model.eval()
    names = model.module.names if hasattr(model, 'module') else model.names  # get class names

    tf_model = tensorflow.keras.models.load_model('C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/firstweight.h5')


    actions = np.array(['violence', 'nonviolence'])
    if source.isnumeric() :    
        cap = cv2.VideoCapture(int(source))    #pass video to videocapture object
    else :
        cap = cv2.VideoCapture(source)    #pass video to videocapture object

    if (cap.isOpened() == False):   #check if videocapture not opened
        print('Error while trying to read video. Please check path again')


    else:
        frame_count = 0
        frame_width = int(cap.get(3)/2)  #get video frame width
        frame_height = int(cap.get(4)/2) #get video frame height

        
        vid_write_image = letterbox(cap.read()[1], (frame_width), stride=64, auto=True)[0] #init videowriter
        resize_height, resize_width = vid_write_image.shape[:2]
        out_video_name = f"{source.split('/')[-1].split('.')[0]}"
        out = cv2.VideoWriter(f"{source}_keypoint.mp4",
                            cv2.VideoWriter_fourcc(*'mp4v'), 30,
                            (resize_width, resize_height))

        
        while(cap.isOpened): #프레임 하나 시작
        
            print("Frame {} Processing".format(frame_count+1))

            ret, frame = cap.read()  #get frame and success from video capture
            
            if ret: #if success is true, means frame exist
                orig_image = frame #store frame
                image = cv2.cvtColor(orig_image, cv2.COLOR_BGR2RGB) #convert frame to RGB
                image = letterbox(image, (frame_width), stride=64, auto=True)[0]
                image_ = image.copy()
                image = transforms.ToTensor()(image)
                image = torch.tensor(np.array([image.numpy()]))
            
                image = image.to(device)  #convert image data to device
                image = image.float() #convert image to float precision (cpu)
                start_time = time.time() #start time for fps calculation
            
                with torch.no_grad():  #get predictions
                    output_data, _ = model(image)

                output_data = non_max_suppression_kpt(output_data,   #Apply non max suppression
                                            0.25,   # Conf. Threshold.
                                            0.65, # IoU Threshold.
                                            nc=model.yaml['nc'], # Number of classes.
                                            nkpt=model.yaml['nkpt'], # Number of keypoints.
                                            kpt_label=True)
            
                output = output_to_keypoint(output_data)
                
                # print("output: ", output.shape)

                im0 = image[0].permute(1, 2, 0) * 255 # Change format [b, c, h, w] to [h, w, c] for displaying the image.
                im0 = im0.cpu().numpy().astype(np.uint8)
                
                im0 = cv2.cvtColor(im0, cv2.COLOR_RGB2BGR) #reshape image format to (BGR)
                gn = torch.tensor(im0.shape)[[1, 0, 1, 0]]  # normalization gain whwh

                for i, pose in enumerate(output_data):  # detections per image
                
                    if len(output_data):  #check if no pose
                        for c in pose[:, 5].unique(): # Print results
                            n = (pose[:, 5] == c).sum()  # detections per class
                            print("No of Objects in Current Frame : {}".format(n))
                        
                        for det_index, (*xyxy, conf, cls) in enumerate(reversed(pose[:,:6])): #loop over poses for drawing on frame
                            c = int(cls)  # integer class
                            kpts = pose[det_index, 6:]
                            label = None if opt.hide_labels else (names[c] if opt.hide_conf else f'{names[c]} {conf:.2f}')
                            plot_one_box_kpt(xyxy, im0, label=label, color=colors(c, True), 
                                        line_thickness=opt.line_thickness,kpt_label=True, kpts=kpts, steps=3, 
                                        orig_shape=im0.shape[:2])
                        
                if frame_count>=140:
                    break
                # Stream results
                x_test.append(kpts.cpu().tolist()) #kpts를 리스트 형태로 변환 후 저장하기
                # print("x_test: ", np.shape(x_test))
                frame_count += 1
                if view_img:
                    cv2.imshow("YOLOv7 Pose Estimation Demo", im0)
                    cv2.waitKey(3)  # 1 millisecond
            else:
                    break
    print("x_test: ", np.shape(x_test))
    x_test = np.array([x_test])
    result = tf_model.predict(x_test)
    pose_name =actions[np.argmax(result)]
    
    print(pose_name)
    if pose_name == 'violence':
        print("폭력이 감지되었어요!")

    elif pose_name =='nonviolence':
        print("폭력이 감지되지 않았아요!")

    cap.release()

def parse_opt():
    parser = argparse.ArgumentParser()
    parser.add_argument('--poseweights', nargs='+', type=str, default='C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/yolov7-pose-estimation/yolov7-w6-pose.pt', help='model path(s)')
    parser.add_argument('--source', type=str, default='C:/Users/ICT/Desktop/youda/IoT_Capstone/data/violence/0.mp4', help='video/0 for webcam') #video source
    parser.add_argument('--device', type=str, default='gpu', help='cpu/0,1,2,3(gpu)')   #device arugments
    parser.add_argument('--view-img', action='store_true', default=True, help='display results')  #display results
    parser.add_argument('--save-conf', action='store_true', help='save confidences in --save-txt labels') #save confidence in txt writing
    parser.add_argument('--line-thickness', default=3, type=int, help='bounding box thickness (pixels)') #box linethickness
    parser.add_argument('--hide-labels', default=False, action='store_true', help='hide labels') #box hidelabel
    parser.add_argument('--hide-conf', default=False, action='store_true', help='hide confidences') #boxhideconf
    opt = parser.parse_args()
    return opt

#main function
def main(opt):
    run(**vars(opt))

if __name__ == "__main__":
    opt = parse_opt()
    strip_optimizer(opt.device,opt.poseweights)
    main(opt)