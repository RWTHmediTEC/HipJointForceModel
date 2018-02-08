clearvars; close all; opengl hardware

addpath(genpath('src'))
addpath(genpath('data'))

data = createDataTLEM2();
gui = createInterfaceTLEM2(data);