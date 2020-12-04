clearvars; close all; opengl hardware
warning off backtrace; warning off verbose

addpath(genpath('src'))
addpath(genpath('data'))

data = createDataTLEM2();
gui = createInterfaceLEM(data);

% [List.f, List.p] = matlab.codetools.requiredFilesAndProducts([mfilename '.m']);
% List.f = List.f'; List.p = List.p';