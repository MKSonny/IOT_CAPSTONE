import numpy as np
import os
from sklearn.model_selection import train_test_split
from keras.utils import np_utils
import torch
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, LayerNormalization, Dropout
from tensorflow.python.client import device_lib
from tensorflow.keras.optimizers import SGD

print(device_lib.list_local_devices())
os.environ["CUDA_VISIBLE_DEVICES"] = "0"#GPU 사옹하기

x_train = np.load('C:/Users/ICT/Desktop/youda/IoT_Capstone/50framedataset/x_train.npy')
y_train = np.load('C:/Users/ICT/Desktop/youda/IoT_Capstone/50framedataset/y_train.npy')

if np.any(np.isnan(x_train)):
    print("nan을 0으로 변경함")
    x_train = np.nan_to_num(x_train)
    y_train = np.nan_to_num(y_train)
print("load Training data")

assert not np.any(np.isnan(x_train)) 
X_train, X_test, y_train, y_test = train_test_split(x_train,y_train, test_size = 0.10, shuffle= True)
print("make train and test dataset")
X_train = X_train.astype(float)
y_train = y_train.astype(float)
X_test = X_test.astype(float)
y_test = y_test.astype(float)

actions = np.array(['violence', 'nonviolence'])
print("num: ",actions.shape[0])

model = Sequential()
model.add(LSTM(64,return_sequences=True, activation='relu', input_shape=(50,51), recurrent_dropout=0.0))
model.add(LayerNormalization(axis=1))
model.add(LSTM(128, return_sequences=True, activation='relu'))
model.add(LSTM(128, return_sequences=True, activation='relu'))
model.add(LayerNormalization(axis=1))
model.add(LSTM(64, return_sequences=False, activation='relu'))

model.add(Dense(64, activation='relu'))
model.add(Dense(32, activation='relu'))
model.add(Dense(actions.shape[0],  activation='softmax'))

# learning_rate = 0.0005
# momentum = 0.9
# sgd = SGD(lr=learning_rate, momentum=momentum,  nesterov=False)
# adamw = AdamW(learning_rate=0.001,weight_decay=0.004)
# optimizer = tfa.optimizers.AdamW(learning_rate=lr, weight_decay=wd)

model.compile(loss='categorical_crossentropy', optimizer='Adam', metrics=['categorical_accuracy'])
print(model.summary())

history = model.fit(X_train, y_train, validation_data = (X_test, y_test), epochs=100)

print('\nhistory dict:', history.history)
print('\n# Evaluate on test data')
results = model.evaluate(X_test, y_test, batch_size=1)
print('test loss, test acc:', results)

model.save("C:/Users/ICT/Desktop/youda/IoT_Capstone/DeepLearning/model/LSTMhweight.h5")
