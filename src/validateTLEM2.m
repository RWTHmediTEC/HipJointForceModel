function [HRC, PW, PH, PD, FL, FW, BW, rMagP] = validateTLEM2(Name)
% Validation of TLEM 2.0 by comparison with in vivo data from OrthoLoad

%% Scaling with OrthoLoad data
% Load landmark data
% Name -> H1L H3L* H5L* H8L H9L H10R *_Femur
Side = Name(end);

if strcmp(Name,'H3L') || strcmp(Name,'H5L')
    Suffix1 = '_Femur';
else 
    Suffix1 = '';
end

% Read landmark file
tempContent1 = read_mixed_csv([Name '_Landmarks' Suffix1 '.fcsv'], ',');
tempContent1(1:3,:) = [];
tempPos1 = cellfun(@str2double, tempContent1(:,2:4));

% Write landmarks
for t = 1:size(tempContent1,1)
    LM.(tempContent1{t,12}) = tempPos1(t,:);
end

% Calculate scaling parameters HRC, PW, PH, PD, FL and FW
% Femoral parameters
midPointEC = midPoint3d(LM.(['LEC_' Side]), LM.(['MEC_' Side]));
FL=distancePoints3d(midPointEC, LM.(['HJC_' Side]));
FW=distancePoints3d(LM.(['GT_' Side]), LM.(['HJC_' Side]));

% Pelvic parameters
if strcmp(Suffix1,'_Femur')
    Suffix2  = '_Pelvis';
    tempContent2 = read_mixed_csv([Name '_Landmarks' Suffix2 '.fcsv'], ',');
    tempContent2(1:3,:) = [];
    tempPos2 = cellfun(@str2double, tempContent2(:,2:4));
    for t=1:size(tempContent2,1)
        LM.(tempContent2{t,12})=tempPos2(t,:);
    end
end

HRC = distancePoints3d(LM.HJC_R, LM.HJC_L);
PW = distancePoints3d(LM.ASIS_R, LM.ASIS_L);

midPointPSIS = midPoint3d(LM.PSIS_L, LM.PSIS_R);

% Create rotation into the pelvic coordiante system
SISplane=createPlane(LM.ASIS_L,midPointPSIS,LM.ASIS_R);
pCSrot(3,:)=normalizeVector3d(LM.ASIS_R-LM.ASIS_L);
pCSrot(2,:)=normalizeVector3d(planeNormal(SISplane));
pCSrot(1,:)=normalizeVector3d(crossProduct3d(pCSrot(2,:),pCSrot(3,:)));

% Pelvic hight
ASIS=transformPoint3d(LM.(['ASIS_' Side]), pCSrot);
HJC=transformPoint3d(LM.(['HJC_' Side]), pCSrot);
PH=abs(ASIS(2)-HJC(2));

% Pelvic depth
PSIS=transformPoint3d(LM.(['PSIS_' Side]), pCSrot);
PD=abs(ASIS(1)-PSIS(1));

%% Load body weight and forces
load([Name '_OLS' '.mat']) % OLS: One-legged stance
BW = meanPFP.Weight_N / 9.81;

rMagP = sqrt(sum(meanPFP.HJF_pBW.^2));

end