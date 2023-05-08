import numpy as np
import os
from sklearn.model_selection import train_test_split
from keras.utils import np_utils
import torch
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, LayerNormalization
from tensorflow.python.client import device_lib

print(device_lib.list_local_devices())

paths = "C:/Users/ICT/Desktop/youda/IoT_Capstone/numpydata/x"
numpy_paths = list(os.listdir(paths))
x_train = np.load("C:/Users/ICT/Desktop/youda/IoT_Capstone/0_x.npy")
for path in numpy_paths:
    "저장한 numpy배열 열어서 training data 만들기"
    array = os.path.join(paths,path)
    x = np.load(array)
    x_train = np.concatenate((x,x_train), axis=0)
    print(x_train.shape)

y_train = np.load("C:/Users/ICT/Desktop/youda/IoT_Capstone/0_y.npy")
paths = "C:/Users/ICT/Desktop/youda/IoT_Capstone/numpydata/y"
numpy_paths = list(os.listdir(paths))
for path in numpy_paths:
    "저장한 numpy배열 열어서 training data 만들기"
    array = os.path.join(paths,path)
    y = np.load(array)
    y_train = np.vstack((y,y_train))
    print(y_train.shape)
# print(y_train)

X_train, X_test, y_train, y_test = train_test_split(x_train,y_train, test_size = 0.20, shuffle= True)
actions = np.array(['violence', 'nonviolence'])
model = Sequential()
model.add(LSTM(64,return_sequences=True, activation='relu', input_shape=(140,51), recurrent_dropout=0.0))
model.add(LayerNormalization(axis=1))
model.add(LSTM(128, return_sequences=True, activation='relu'))
model.add(LSTM(128, return_sequences=True, activation='relu'))
model.add(LayerNormalization(axis=1))
model.add(LSTM(64, return_sequences=False, activation='relu'))
model.add(Dense(64, activation='relu'))
model.add(Dense(32, activation='relu'))
model.add(Dense(actions.shape[0],  activation='softmax'))

model.compile(optimizer='Adam', loss='categorical_crossentropy', metrics=['categorical_accuracy'])

model.fit(X_train, y_train, validation_data = (X_test, y_test), epochs=500)
model.save("C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/firstweight.h5")
