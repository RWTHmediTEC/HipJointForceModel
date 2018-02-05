function [HRC, PW, PH, PD, FL, FW, BW, rMagP] = validateTLEM2(opat)
% Validation of TLEM 2.0 by comparison with in vivo measured data provided
% by Orthoload

%% Scaling with Orthoload data
% Load landmark data
Subject.Name = opat; % H1L H3L* H5L* H8L H9L H10R *_Femur

if strcmp(opat,'H3L') || strcmp(opat,'H5L')
    Suffix1 = '_Femur';
else 
    Suffix1 = '';
end

Suffix2  = '_Pelvis';

% Read landmark file
tempContent1 = read_mixed_csv([Subject.Name '_Landmarks' Suffix1 '.fcsv'], ',');
tempContent1(1:3,:) = [];
tempPos1 = cellfun(@str2double, tempContent1(:,2:4));

% Write landmarks
for t = 1:size(tempContent1,1)
    Subject.Landmarks.(tempContent1{t,12}) = tempPos1(t,:);
end

% Calculate scaling parameters HRC, PW, PH, PD, FL and FW
% Femoral parameters
if strcmp(Subject.Name,'H10R')
    midPointFEs = Subject.Landmarks.MEC_R +...
        (Subject.Landmarks.LEC_R - Subject.Landmarks.MEC_R) / 2;
    FL = norm(midPointFEs - Subject.Landmarks.HJC_R); 
    FW = norm(Subject.Landmarks.GT_R - Subject.Landmarks.HJC_R);
else
    midPointFEs = Subject.Landmarks.MEC_L +...
        (Subject.Landmarks.LEC_L - Subject.Landmarks.MEC_L) / 2;
    FL = norm(midPointFEs - Subject.Landmarks.HJC_L); 
    FW = norm(Subject.Landmarks.GT_L - Subject.Landmarks.HJC_L);
end

% Pelvic parameters
if strcmp(Suffix1,'_Femur')
    tempContent2 = read_mixed_csv([Subject.Name '_Landmarks' Suffix2 '.fcsv'], ',');
    tempContent2(1:3,:) = [];
    tempPos2 = cellfun(@str2double, tempContent2(:,2:4));
    for t=1:size(tempContent2,1)
        Subject.Landmarks.(tempContent2{t,12})=tempPos2(t,:);
    end
end

HRC = norm(Subject.Landmarks.HJC_R - Subject.Landmarks.HJC_L);
PW = norm(Subject.Landmarks.ASIS_R - Subject.Landmarks.ASIS_L);
    
midPointPSISs = Subject.Landmarks.PSIS_L +...
    (Subject.Landmarks.PSIS_R - Subject.Landmarks.PSIS_L) / 2;
Z = Subject.Landmarks.ASIS_L - Subject.Landmarks.ASIS_R;

% Project midPointPSISs onto Z-Axis via orthogonal projection
projMidP = Subject.Landmarks.ASIS_R +...
    ((dot(midPointPSISs,Z) - dot(Subject.Landmarks.ASIS_R,Z)) / dot(Z,Z)) * Z;
X = projMidP - midPointPSISs;
    
Y = cross((Subject.Landmarks.ASIS_L-midPointPSISs),...
          (Subject.Landmarks.ASIS_R-midPointPSISs));
normalY = Y ./ norm(Y);

if strcmp(Subject.Name,'H10R')
    % Project PSIS onto X-Z plane via orthogonal projection
    projPSISPlane = Subject.Landmarks.ASIS_R +...
        ((dot(Subject.Landmarks.PSIS_R,X) - dot(Subject.Landmarks.ASIS_R,X)) / dot(X,X)) * X +...
        ((dot(Subject.Landmarks.PSIS_R,Z) - dot(Subject.Landmarks.ASIS_R,Z)) / dot(Z,Z)) * Z;
    
    PH = abs(dot(normalY,(Subject.Landmarks.ASIS_R - Subject.Landmarks.HJC_R)));
else
    % Project PSIS onto X-Z plane via orthogonal projection
    projPSISPlane = Subject.Landmarks.ASIS_R +...
        ((dot(Subject.Landmarks.PSIS_L,X) - dot(Subject.Landmarks.ASIS_R,X)) / dot(X,X)) * X +...
        ((dot(Subject.Landmarks.PSIS_L,Z) - dot(Subject.Landmarks.ASIS_R,Z)) / dot(Z,Z)) * Z;
    
    PH = abs(dot(normalY,(Subject.Landmarks.ASIS_R - Subject.Landmarks.HJC_L)));
end

% Project PSIS in X-Y plane onto Z-Axis via orthogonal projection
projPSISLine = Subject.Landmarks.ASIS_R +...
    ((dot(projPSISPlane,Z) - dot(Subject.Landmarks.ASIS_R,Z)) / dot(Z,Z)) * Z;
PD = norm(projPSISLine - projPSISPlane);

% Visualize PD
%     hold on
%     drawPoint3d(projPSISPlane)
%     drawPoint3d(projPSISLine)
%     drawPoint3d(Subject.Landmarks.PSIS_L)
%     drawPoint3d(Subject.Landmarks.PSIS_R)
%     line([Subject.Landmarks.PSIS_L(1),Subject.Landmarks.PSIS_R(1)], ...
%         [Subject.Landmarks.PSIS_L(2),Subject.Landmarks.PSIS_R(2)], ...
%         [Subject.Landmarks.PSIS_L(3),Subject.Landmarks.PSIS_R(3)])
%     line([Subject.Landmarks.ASIS_L(1),Subject.Landmarks.ASIS_R(1)], ...
%         [Subject.Landmarks.ASIS_L(2),Subject.Landmarks.ASIS_R(2)], ...
%         [Subject.Landmarks.ASIS_L(3),Subject.Landmarks.ASIS_R(3)])
%     line([projmidP(1),midPointPSISs(1)], ...
%         [projmidP(2),midPointPSISs(2)], ...
%         [projmidP(3),midPointPSISs(3)])
%     drawPoint3d(Subject.Landmarks.ASIS_L)
%     drawPoint3d(Subject.Landmarks.ASIS_R)
%     drawPoint3d(midPointPSISs)
%     drawPoint3d(projmidP)

%% Load body weight and forces

load([Subject.Name '_OLS' '.mat']) % OLS: One-legged stance
BW = meanPFP.Weight_N / 9.81;

rMagP = sqrt(sum(meanPFP.HJF_pBW.^2));