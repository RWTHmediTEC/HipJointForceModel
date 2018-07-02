% Import OrthoLoad data and save as OrthoLoad.mat in data
% including structure OL (OrthoLoad)

Subject = {'H1L' 'H2R' 'H3L' 'H4L' 'H5L' 'H6R' 'H7R' 'H8L' 'H9L' 'H10R'};
Sex = {'m' 'm' 'm' 'm' 'f' 'm' 'm' 'm' 'm' 'f'};
OL = repmat(struct('Subject', [], 'Sex', []), length(Subject),1);

for s = 1:length(Subject)
    
OL(s).Subject = Subject{s};
OL(s).Sex = Sex{s};

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

%% Calculate scaling parameters HRC, PW, PH, PD, FL and FW

% Femoral parameters
midPointEC = midPoint3d(OL(s).LM.(['LEC_' Side]), OL(s).LM.(['MEC_' Side]));
OL(s).FL = distancePoints3d(midPointEC, OL(s).LM.(['HJC_' Side]));
%FW = distancePoints3d(OL(s).LM.(['GT_' Side]), OL(s).LM.(['HJC_' Side]));
OL(s).FW = 70; % changed because GT for H4L is missing

% Pelvic parameters
OL(s).HRC = distancePoints3d(OL(s).LM.HJC_R, OL(s).LM.HJC_L);
OL(s).PW = distancePoints3d(OL(s).LM.ASIS_R, OL(s).LM.ASIS_L);

midPointPSIS = midPoint3d(OL(s).LM.PSIS_L, OL(s).LM.PSIS_R);

% Create rotation into pelvic coordiante system
SISplane = createPlane(OL(s).LM.ASIS_L, midPointPSIS, OL(s).LM.ASIS_R);
pCSrot(3,:) = normalizeVector3d(OL(s).LM.ASIS_R - OL(s).LM.ASIS_L);
pCSrot(2,:) = normalizeVector3d(planeNormal(SISplane));
pCSrot(1,:) = normalizeVector3d(crossProduct3d(pCSrot(2,:), pCSrot(3,:)));

% Pelvic height
ASIS = transformPoint3d(OL(s).LM.(['ASIS_' Side]), pCSrot);
HJC = transformPoint3d(OL(s).LM.(['HJC_' Side]), pCSrot);
OL(s).PH = abs(ASIS(2) - HJC(2));

% Pelvic depth
PSIS = transformPoint3d(OL(s).LM.(['PSIS_' Side]), pCSrot);
OL(s).PD = abs(ASIS(1) - PSIS(1));

%% Load bodyweight and forces
load([Subject{s} '_OLS' '.mat']) % OLS: One-legged stance
OL(s).BW = meanPFP.Weight_N / 9.81;

OL(s).rMagP = norm(meanPFP.HJF_pBW);

load('femoralCS_RM')

HJFtrans = meanPFP.HJF_pBW * orthoload2TLEM_RM;

OL(s).rPhi   = atand(HJFtrans(3) / HJFtrans(2));
OL(s).rTheta = atand(HJFtrans(1) / HJFtrans(2));
OL(s).rAlpha = atand(HJFtrans(1) / HJFtrans(3));

end

%% Save data
save('data\OrthoLoad.mat', 'OL')