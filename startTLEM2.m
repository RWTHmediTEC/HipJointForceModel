clearvars; close all; opengl hardware

addpath(genpath('D:\Biomechanics\General\Code\#external\#Mesh\gptoolbox'))

addpath(genpath('src'))
addpath(genpath('data'))

data = createDataTLEM2();
gui = createInterfaceTLEM2(data);