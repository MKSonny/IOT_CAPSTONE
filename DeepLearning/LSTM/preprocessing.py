import torch
import numpy as np
import os

paths = "C:/Users/ICT/Desktop/youda/IoT_Capstone/50framedataset/x"
numpy_paths = list(os.listdir(paths))
# x_train = np.load("C:/Users/ICT/Desktop/youda/IoT_Capstone/dataset/x/0_x.npy")
x_train=[]
for path in numpy_paths:
        array = os.path.join(paths,path)
        x = np.load(array, allow_pickle=True)
        x_train.append(x)
        print(np.shape(x_train))
x_data = np.stack(x_train)
print(x_data.shape)

paths = "C:/Users/ICT/Desktop/youda/IoT_Capstone/50framedataset/y"
numpy_paths = list(os.listdir(paths))
y_train=[]

for path in numpy_paths:
        array = os.path.join(paths,path)
        y = np.load(array, allow_pickle=True)
        y_train.append(y)
y_data = np.stack(y_train)
print(y_data.shape)

np.save("C:/Users/ICT/Desktop/youda/IoT_Capstone/50framedataset/x_train", x_data)
np.save("C:/Users/ICT/Desktop/youda/IoT_Capstone/50framedataset/y_train", y_data)