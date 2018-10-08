% Import OrthoLoad data and save as OrthoLoad.mat in data
% including structure OL (OrthoLoad)

%% Create structure OL
Subject = {'H1L' 'H2R' 'H3L' 'H4L' 'H5L' 'H6R' 'H7R' 'H8L' 'H9L' 'H10R'};
Sex = {'m' 'm' 'm' 'm' 'f' 'm' 'm' 'm' 'm' 'f'};
OL = repmat(struct('Subject', [], 'Sex', []), length(Subject),1);

%% Hardcoding of implant parameters from '2016 - Bergmann - Standardized Loads Acting in Hip Implants'
NeckLength = [ 55.6  59.3  56.6  63.3  55.6 55.6  63.3 59.3  59.3 59.6];
alphaX =     [ 2.3   4.1   4.0   7.5   4.0  5.8   6.3  4.6   4.6  1.7];
alphaY =     [-2.3   0.6  -3.0  -1.7  -2.3 -1.7  -1.7 -1.7   0.6 -1.2];
alphaZ =     [-15.0 -13.8 -13.8 -18.9 -2.3 -31.0 -2.4 -15.5 -2.3 -9.7];  % Femoral version
CCD =         135;                                                       % CCD angle is always 135�

for s = 1:length(Subject)
    
OL(s).Subject = Subject{s};
OL(s).Sex     = Sex{s};

Side = Subject{s}(end);

%% Load landmark data
% Read landmark file
tempContent = read_mixed_csv([Subject{s} '_Landmarks.fcsv'], ',');
tempContent(1:3,:) = [];
tempPos = cellfun(@str2double, tempContent(:,2:4));

% Write landmarks
for t = 1:size(tempContent,1)
    OL(s).LM.(tempContent{t,12}) = tempPos(t,:);
end

%% Calculate scaling parameters
% HipJointWidth, PelvicWidth, PelvicHeight, PelvicDepth and FemoralLength

% Pelvic parameters
OL(s).HipJointWidth = distancePoints3d(OL(s).LM.HJC_R, OL(s).LM.HJC_L);
OL(s).PelvicWidth = distancePoints3d(OL(s).LM.ASIS_R, OL(s).LM.ASIS_L);

midPointPSIS = midPoint3d(OL(s).LM.PSIS_L, OL(s).LM.PSIS_R);

% Create rotation into pelvic coordiante system
SISplane = createPlane(OL(s).LM.ASIS_L, midPointPSIS, OL(s).LM.ASIS_R);
pCSrot(3,:) = normalizeVector3d(OL(s).LM.ASIS_R - OL(s).LM.ASIS_L);
pCSrot(2,:) = normalizeVector3d(planeNormal(SISplane));
pCSrot(1,:) = normalizeVector3d(crossProduct3d(pCSrot(2,:), pCSrot(3,:)));

% Pelvic height
ASIS = transformPoint3d(OL(s).LM.(['ASIS_' Side]), pCSrot);
HJC = transformPoint3d(OL(s).LM.(['HJC_' Side]), pCSrot);
OL(s).PelvicHeight = abs(ASIS(2) - HJC(2));

% Pelvic depth
PSIS = transformPoint3d(OL(s).LM.(['PSIS_' Side]), pCSrot);
OL(s).PelvicDepth = abs(ASIS(1) - PSIS(1));

% Femoral parameters
% Femoral length [Wu2002]
midPointEC = midPoint3d(OL(s).LM.(['LEC_' Side]), OL(s).LM.(['MEC_' Side]));
OL(s).FemoralLength = distancePoints3d(midPointEC, OL(s).LM.(['HJC_' Side]));

%% Add skinning parameters 
% NeckLength, FemoralVersion and CCD angle [CCD]
OL(s).NeckLength = NeckLength(s);
OL(s).FemoralVersion = alphaZ(s);
OL(s).CCD = CCD;

%% Load body weight and forces
load([Subject{s} '_OLS' '.mat']) % OLS: One-legged stance % !!! Add Level Walking here???
OL(s).BodyWeight = meanPFP.Weight_N / 9.81;

OL(s).rMagP = norm(meanPFP.HJF_pBW);

load('femurTLEM2Controls', 'fwTFM2AFCS') % !!! ['femur' data.TLEMversion 'Controls.mat']
% !!! OL different for TLEM 2.0 and TLEM 2.1, transformation need to be
% executed in validateTLEM2
HJFtrans = transpose(fwTFM2AFCS(1:3,1:3)) * transpose(meanPFP.HJF_pBW);

OL(s).rPhi   = atand(HJFtrans(3) / HJFtrans(2));
OL(s).rTheta = atand(HJFtrans(1) / HJFtrans(2));
OL(s).rAlpha = atand(HJFtrans(1) / HJFtrans(3));

end

%% Save data
save('data\OrthoLoad.mat', 'OL')