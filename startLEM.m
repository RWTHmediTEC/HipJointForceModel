clearvars; close all; opengl hardware
warning off backtrace; warning off verbose

% Requires the toolbox, add-on or app:
% - GUI Layout Toolbox by David Sampson

addpath(genpath('src'))
addpath(genpath('data'))

data = createLEM();
gui = createInterfaceLEM(data);

% [List.f, List.p] = matlab.codetools.requiredFilesAndProducts([mfilename '.m']);
% List.f = List.f'; List.p = List.p';