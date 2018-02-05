clearvars; close all; opengl hardware

addpath(genpath('src'))
addpath(genpath('data'))

%% Load landmark data
Subject.Name='H10R';
Suffix='';

% Read landmark file
tempContent = read_mixed_csv([Subject.Name '_Landmarks' Suffix '.fcsv'], ',');
tempContent(1:3,:)=[];
tempPos = cellfun(@str2double, tempContent(:,2:4));
% Write landmarks
for l=1:size(tempContent,1)
    Subject.Landmarks.(tempContent{l,12})=tempPos(l,:);
end

midPointFEs = Subject.Landmarks.MEC_R+(Subject.Landmarks.LEC_R-Subject.Landmarks.MEC_R)/2;
norm(midPointFEs-Subject.Landmarks.HJC_R)

midPointPSISs = Subject.Landmarks.PSIS_L+(Subject.Landmarks.PSIS_R-Subject.Landmarks.PSIS_L)/2;
dirVec = Subject.Landmarks.ASIS_L-Subject.Landmarks.ASIS_R;
helpVec = midPointPSISs-Subject.Landmarks.ASIS_R;
PD = norm(cross(helpVec,dirVec))/norm(dirVec);

N = cross((Subject.Landmarks.ASIS_L-midPointPSISs),(Subject.Landmarks.ASIS_R-midPointPSISs));
normal = N ./ norm(N);
PH = abs(dot(normal,(midPointPSISs-Subject.Landmarks.HJC_R)));

hold on
drawPoint3d(midPointPSISs)

% Patient Specific Parameters:
% pPW = Hip width measured as the distance between the hrcs in the
%       direction of z
% pPH = Hip height measured as the distance between the hrc and ASIS of the
%       pelvis in the direction of y
% pPD = Hip depth measured as the distance between ASIS and PSIS in the
%       direction of x
% pFL = Femoral length measured as the distance between greater trochanter
%       and medial epicondyle in the frontal plane or related to the patient height if
%       position of the medial epicondyle is not available
% pFW = Femoral width measured as the distance between greater trochanter 
%       and hrc in the direction of z

% PW = Subject.Landmarks.HJC_R(1)-Subject.Landmarks.HJC_L(1);
% PH = Subject.Landmarks.ASIS_R(3)-Subject.Landmarks.HJC_R(3);
% PD = Subject.Landmarks.ASIS_R(2)-Subject.Landmarks.PSIS_R(2);
% FL = norm(Subject.Landmarks.GT_R(1:2:3) - ...
%         Subject.Landmarks.MEC_R(1:2:3));
% FW = Subject.Landmarks.GT_R(1)-Subject.Landmarks.HJC_R(1);


% Visualize landmarks
figure('Color','w'); hold on;
for l=1:size(tempContent,1)
    tempPos=Subject.Landmarks.(tempContent{l,12});
    drawPoint3d(tempPos)
    text(tempPos(1),tempPos(2),tempPos(3),tempContent{l,12})
end
mouseControl3d



% ------------------------------------------------------------------------
% function validateTLEM2
% %% orthoload forces
% clearvars; close all; opengl hardware
% 
% addpath(genpath('src'))
% addpath(genpath('data'))
% 
% % Load landmark data
% Subject.Name='H9L';
% Suffix1='';
% Suffix2='_Pelvis';
% % Read landmark file
% tempContent1 = read_mixed_csv([Subject.Name '_Landmarks' Suffix1 '.fcsv'], ',');
% tempContent1(1:3,:)=[];
% tempPos1 = cellfun(@str2double, tempContent1(:,2:4));
% 
% % Write landmarks
% for t=1:size(tempContent1,1)
%     Subject.Landmarks.(tempContent1{t,12})=tempPos1(t,:);
% end
% 
% if strcmp(Subject.Name,'H10R')
%     FL = norm(Subject.Landmarks.GT_R(1:2:3) - ...
%         Subject.Landmarks.MEC_R(1:2:3));
%     FW = Subject.Landmarks.GT_R(1)-Subject.Landmarks.HJC_R(1);
% else
%     FL = norm(Subject.Landmarks.GT_L(1:2:3) - ...
%         Subject.Landmarks.MEC_L(1:2:3));
%     FW = Subject.Landmarks.HJC_L(1)-Subject.Landmarks.GT_L(1);
% end
% 
% if strcmp(Suffix1,'_Femur')
%     tempContent2 = read_mixed_csv([Subject.Name '_Landmarks' Suffix2 '.fcsv'], ',');
%     tempContent2(1:3,:)=[];
%     tempPos2 = cellfun(@str2double, tempContent2(:,2:4));
%     for t=1:size(tempContent2,1)
%         Subject.Landmarks.(tempContent2{t,12})=tempPos2(t,:);
%     end
% end
% 
% if strcmp(Subject.Name,'H10R')
%     PW = Subject.Landmarks.HJC_R(1)-Subject.Landmarks.HJC_L(1);
%     PH = Subject.Landmarks.ASIS_R(3)-Subject.Landmarks.HJC_R(3);
%     PD = Subject.Landmarks.ASIS_R(2)-Subject.Landmarks.PSIS_R(2);
% else
%     PW = Subject.Landmarks.HJC_R(1)-Subject.Landmarks.HJC_L(1);
%     PH = Subject.Landmarks.ASIS_L(3)-Subject.Landmarks.HJC_L(3);
%     PD = Subject.Landmarks.ASIS_L(2)-Subject.Landmarks.PSIS_L(2);
% end


% % Visualize landmarks
% figure('Color','w'); hold on;
% for l=1:size(tempContent,1)
%     tempPos=Subject.Landmarks.(tempContent{l,12});
%     drawPoint3d(tempPos)
%     text(tempPos(1),tempPos(2),tempPos(3),tempContent{l,12})
% end
% mouseControl3d





% Patient Specific Parameters:
% pPW = Hip width measured as the distance between the hrcs in the
%       direction of z
% pPH = Hip height measured as the distance between the hrc and ASIS of the
%       pelvis in the direction of y
% pPD = Hip depth measured as the distance between ASIS and PSIS in the
%       direction of x
% pFL = Femoral length measured as the distance between greater trochanter
%       and medial epicondyle in the frontal plane or related to the patient height if
%       position of the medial epicondyle is not available
% pFW = Femoral width measured as the distance between greater trochanter 
%       and hrc in the direction of z



% 
% load('C:\Users\bjoern\Desktop\TLEM2MATLAB\data\OrthoLoad\Forces\H8L_OLS.mat')
% mag_BW = norm(meanPFP.HJF_pBW);
% mag = meanPFP.Weight_N*mag_BW/100;
% 
% %% landmarks
% 
% addpath(genpath('..\LoadBasedTargetZone'));
% 
% % Load the patient data from FileName and copy them to data
% 
% sheet = 8;
% xlRange1 = 'C2:E29';
% xlRange2 = 'H3';
% xlRange3 = 'I3';
% xlRange4 = 'H5';
% xlRange5 = 'H6';
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Matrix Landmarken:
% Landmarken = xlsread('Landmarken.xlsx',sheet,xlRange1); %[mm]
% 
% Weight = xlsread('Landmarken.xlsx',sheet,xlRange4); %Masse Patient [kg]
% Height = xlsread('Landmarken.xlsx',sheet,xlRange5); %Körpergröße Patient [m]
% 
% 
% j = xlsread('Landmarken.xlsx',sheet,xlRange2); % CT-Aufloesung in Bildebene [mm]
% t = xlsread('Landmarken.xlsx',sheet,xlRange3); % CT-Aufloesung Schichtdicke [mm]
% Landmarks = convertCT2mm(Landmarken, j, t); % Konvertierung mittels gegebener CT-Auflösung
% f = figure;
% axis on
% hold on
% drawPoint3d(Landmarks(:,1),Landmarks(:,2),Landmarks(:,3));
% 
% line(Landmarks(3:4:7,1),Landmarks(3:4:7,2),Landmarks(3:4:7,3));
% 
% dsp = Landmarks(7,1)-Landmarks(21,1);
% 
% 
% %     'The most lateral point of pelvis',...
% %     'Anterior Superior Iliac Spine (ASIS)',...
% %     'Trochanter major',...
% %     'Hip rotation center',...
% %     'Trochanter minor',...
% %     'The most caudal point of tuber isschiadicum',...
% %     'Symphysis pubica (SP)',...
% %     'The most medial point of Pelvic',...
% %     'The most caudal point of pelvic',...
% %     'The upper mittle point of vetebra L5',...
% %     'The most cranial edge of acetabulum',...
% %     'Anterior inferior spina iliaca ',...
% %     'Posterior superior spina iliaca ',...
% %     'Posterior inferior spina iliaca '};
% 
% % Patient Specific Parameters:
% % pHD = Hip depth measured as the distance between ASIS and PSIS in the
% %       direction of x
% pHD = Landmarks(13,2)-Landmarks(2,2);
% % pHH = Hip height measured as the distance between the hrc and ASIS of the
% %       pelvis in the direction of y
% pHH = Landmarks(2,3)-Landmarks(4,3);
% % pHW = Hip width measured as the distance between the hrcs in the
% %       direction of z
% pHW = norm(Landmarks(4,1:3)-Landmarks(18,1:3));
% % pFL = Femoral length measured as the distance between greater trochanter
% %       and medial epicondyle in the frontal plane or related to the patient height if
% %       position of the medial epicondyle is not available
% pH=1780;
% pFL = (0.53-0.285)*pH;
% % pFW = Femoral width measured as the distance between greater trochanter 
% %       and hrc in the direction of z
% pFW = Landmarks(3,1)-Landmarks(4,1);
% % pH  = Height of the patient
% % pFLh = (0.53-0.285)*pH;  % Femoral length according to [Winter 2005]