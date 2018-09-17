clearvars; close all; opengl hardware
% [List.f, List.p] = matlab.codetools.requiredFilesAndProducts([mfilename '.m']);
% List.f = List.f'; List.p = List.p';

addpath(genpath('src'))
addpath(genpath('data'))

data = createDataTLEM2();
gui = createInterfaceTLEM2(data);