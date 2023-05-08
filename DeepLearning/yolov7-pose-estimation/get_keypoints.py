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

#opt error 방지
import os
os.environ['KMP_DUPLICATE_LIB_OK']='True'

@torch.no_grad()
def run(poseweights="yolov7-w6-pose.pt",source="football1.mp4",device='cpu',view_img=False,
        save_conf=False,line_thickness = 3,hide_labels=False, hide_conf=True):

    total_fps = 0  #count total fps
    time_list = []   #list to store time
    fps_list = []    #list to store fps
    
    device = select_device(opt.device) #select device
    half = device.type != 'cpu'

    model = attempt_load(poseweights, map_location=device)  #Load model
    _ = model.eval()
    names = model.module.names if hasattr(model, 'module') else model.names  # get class names

    #path 내 동영상 한 번에 열어서 학습시키기
    paths = 'C:/Users/ICT/Desktop/youda/IoT_Capstone/data/nonviolence'
    video_paths = list(os.listdir(paths))
    num_path = 63

    for path in video_paths:
        x_train=[]
        
        print("num_path: ",num_path)
        source = os.path.join(paths,path) #전체 파일 path 지정해서 한 번에 영상 keypoint받도록 하기
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
            # out = cv2.VideoWriter(f"{source}_keypoint.mp4",
            #                     cv2.VideoWriter_fourcc(*'mp4v'), 30,
            #                     (resize_width, resize_height))

            
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

                    
                    end_time = time.time()  #Calculatio for FPS
                    fps = 1 / (end_time - start_time)
                    # total_fps += fps
                    frame_count += 1
                    # print("kpts: ")
                    # print(kpts)
                    x_train.append(kpts.cpu().tolist()) #kpts를 리스트 형태로 변환 후 저장하기
                    # print("--------------x_train--------------")
                    # print(x_train)

                    
                    
                    # fps_list.append(total_fps) #append FPS in list
                    # time_list.append(end_time - start_time) #append time in list

                    if frame_count>=140:
                        break
                    print("FPS: ", fps)
                    # Stream results
                    if view_img:
                        cv2.imshow("YOLOv7 Pose Estimation Demo", im0)
                        cv2.waitKey(3)  # 1 millisecond# 
                
                else:
                    break
                
                    
                # out.write(im0)  #writing the video frame
                #frame하나 당 output 하나씩 저장하기
                # x_train.append(output)
                # y_train.append([0., 1.])
            

            
        cap.release()
        x_train = np.array([x_train])
        # x_np = np.array(x_train)
        print("shape: ", np.shape(x_train))
        y_np = np.array([1, 0])
        np.save(f"C:/Users/ICT/Desktop/youda/IoT_Capstone/numpydata/x/{num_path}_x",x_train)
        np.save(f"C:/Users/ICT/Desktop/youda/IoT_Capstone/numpydata/y/{num_path}_y",y_np)
        num_path += 1
        

        
        # out.release()
        # num_path += 1
        # print("영상: ",num_path)
        # cv2.destroyAllWindows()
        # avg_fps = total_fps / frame_count
        # print(f"Average FPS: {avg_fps:.3f}")
        
    #plot the comparision graph
    plot_fps_time_comparision(time_list=time_list,fps_list=fps_list)
    # x_np = np.array(x_train,dtype=np.float32)
    # y_np = np.array(y_train,dtype=np.float32)
    # np.save("C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/yolov7-pose-estimation/x_nvio_train",x_np)
    # np.save("C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/yolov7-pose-estimation/y_nvio_train",y_np)





def parse_opt():
    parser = argparse.ArgumentParser()
    parser.add_argument('--poseweights', nargs='+', type=str, default='C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/yolov7-pose-estimation/yolov7-w6-pose.pt', help='model path(s)')
    parser.add_argument('--source', type=str, default='http://192.168.118.107:8080/video_feed', help='video/0 for webcam') #video source
    parser.add_argument('--device', type=str, default='gpu', help='cpu/0,1,2,3(gpu)')   #device arugments
    parser.add_argument('--view-img', action='store_true', default=True, help='display results')  #display results
    parser.add_argument('--save-conf', action='store_true', help='save confidences in --save-txt labels') #save confidence in txt writing
    parser.add_argument('--line-thickness', default=3, type=int, help='bounding box thickness (pixels)') #box linethickness
    parser.add_argument('--hide-labels', default=False, action='store_true', help='hide labels') #box hidelabel
    parser.add_argument('--hide-conf', default=False, action='store_true', help='hide confidences') #boxhideconf
    opt = parser.parse_args()
    return opt

#function for plot fps and time comparision graph
def plot_fps_time_comparision(time_list,fps_list):
    plt.figure()
    plt.xlabel('Time (s)')
    plt.ylabel('FPS')
    plt.title('FPS and Time Comparision Graph')
    plt.plot(time_list, fps_list,'b',label="FPS & Time")
    plt.savefig("FPS_and_Time_Comparision_pose_estimate.png")
    

#main function
def main(opt):
    run(**vars(opt))

if __name__ == "__main__":
    opt = parse_opt()
    strip_optimizer(opt.device,opt.poseweights)
    main(opt)