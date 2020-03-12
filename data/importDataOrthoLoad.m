function importDataOrthoLoad()

% Import OrthoLoad data as OL (OrthoLoad) struct and save as OrthoLoad.mat 

sides={'R','L'};

%% Create structure OL
Subject = {'H1L' 'H2R' 'H3L' 'H4L' 'H5L' 'H6R' 'H7R' 'H8L' 'H9L' 'H10R'};
Sex     = {'m'   'm'   'm'   'm'   'f'   'm'   'm'   'm'   'm'   'f'};
Height  = [178   172   168   178   168   176   179   178   181   162];
OL = repmat(struct('Subject', [], 'Sex', []), length(Subject),1);

%% Hardcoding of implant parameters from '2016 - Bergmann - Standardized Loads Acting in Hip Implants'
NeckLength = [ 55.6  59.3  56.6  63.3  55.6 55.6  63.3 59.3  59.3 59.6];
alphaX =     [ 2.3   4.1   4.0   7.5   4.0  5.8   6.3  4.6   4.6  1.7];
alphaY =     [-2.3   0.6  -3.0  -1.7  -2.3 -1.7  -1.7 -1.7   0.6 -1.2];
alphaZ =     [-15.0 -13.8 -13.8 -18.9 -2.3 -31.0 -2.4 -15.5 -2.3 -9.7];  % Femoral version
CCD =         135;                                                       % CCD angle is always 135°

for s = 1:length(Subject)
    
OL(s).Subject    = Subject{s};
OL(s).Sex        = Sex{s};
OL(s).BodyHeight = Height(s);

Side_IL = Subject{s}(end);
Side_CL = sides{~strcmp(Side_IL,sides)};

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
% See createDataTLEM2.m for the exact definitions

% Pelvic parameters
% Transform the landmarks into the pelvic coordinate system (CS) [Wu 2002]
pTFM = createPelvisCS_TFM_Wu2002(OL(s).LM.ASIS_L, OL(s).LM.ASIS_R, OL(s).LM.PSIS_L, OL(s).LM.PSIS_R);

ASIS_IL = transformPoint3d(OL(s).LM.(['ASIS_' Side_IL]), pTFM);
ASIS_CL = transformPoint3d(OL(s).LM.(['ASIS_' Side_CL]), pTFM);
HJC_IL  = transformPoint3d(OL(s).LM.(['HJC_' Side_IL]),  pTFM);
HJC_CL  = transformPoint3d(OL(s).LM.(['HJC_' Side_CL]),  pTFM);
PSIS_IL = transformPoint3d(OL(s).LM.(['PSIS_' Side_IL]), pTFM);

OL(s).HipJointWidth = abs(HJC_IL(3)  - HJC_CL(3));
OL(s).PelvicWidth   = abs(ASIS_IL(3) - ASIS_CL(3));
OL(s).PelvicHeight  = abs(ASIS_IL(2) - HJC_IL(2));
OL(s).PelvicDepth   = abs(ASIS_IL(1) - PSIS_IL(1));

% Femoral parameters
% Transform the landmarks into the femoral CS [Wu 2002]
fTFM = createFemurCS_TFM_Wu2002(...
    OL(s).LM.(['MEC_' Side_IL]), ...
    OL(s).LM.(['LEC_' Side_IL]), ...
    OL(s).LM.(['HJC_' Side_IL]), Side_IL);
% FemoralLength
midPointEC = midPoint3d(OL(s).LM.(['LEC_' Side_IL]), OL(s).LM.(['MEC_' Side_IL]));
OL(s).FemoralLength = distancePoints3d(...
    transformPoint3d(midPointEC, fTFM), ...
    transformPoint3d(OL(s).LM.(['HJC_' Side_IL]), fTFM));
% FemoralWidth: Distance between the HJC and the greater trochanter along
% the Z-Axis.
try
    HJC2GreaterTrochanter = ...
        transformPoint3d(OL(s).LM.(['GT_' Side_IL]), fTFM) - ...
        transformPoint3d(OL(s).LM.(['HJC_' Side_IL]), fTFM);
    OL(s).FemoralWidth = abs(HJC2GreaterTrochanter(3));
catch
    OL(s).FemoralWidth = nan;
    warning(['Landmarks  of ' Subject{s} ' are missing! Returning: FemoralWidth = nan'])
end

% Transformation for the hip joint force from OrthoLoad CS [Bergmann 2016]
% to [Wu 2002] CS
try
    % Create transformation into OrthoLoad CS [Bergmann 2016].
    Bergman2016TFM = createFemurCS_TFM_Bergmann2016(...
        OL(s).LM.(['MPC_' Side_IL]),...
        OL(s).LM.(['LPC_' Side_IL]),...
        OL(s).LM.(['P1_' Side_IL]), ...
        OL(s).LM.(['P2_' Side_IL]), ...
        OL(s).LM.(['HJC_' Side_IL]), Side_IL);
    % Transform landmarks for [Wu 2002] into the [Bergmann 2016].
    MEC_IL = transformPoint3d(OL(s).LM.(['MEC_' Side_IL]), Bergman2016TFM);
    LEC_IL = transformPoint3d(OL(s).LM.(['LEC_' Side_IL]), Bergman2016TFM);
    HJC_IL = transformPoint3d(OL(s).LM.(['HJC_' Side_IL]), Bergman2016TFM);
    % Create transformation from [Bergmann 2016] to [Wu 2002].
    OL(s).Wu2002TFM = createFemurCS_TFM_Wu2002(MEC_IL, LEC_IL, HJC_IL, Side_IL);
catch
    OL(s).Wu2002TFM = nan(4);
    warning(['Landmarks of ' Subject{s} ' are missing! Returning: Wu2002TFM = nan(4)!'])
end

% Write selected landmarks of the femur as excel File:
fLandmarks={'HJC','P1','P2','MPC','LPC','MEC','LEC','GT','LT'};
excelLM(s).Subject=OL(s).Subject;
for lm=1:length(fLandmarks)
    if isfield(OL(s).LM, [fLandmarks{lm} '_' Side_IL])
        excelLM(s).([fLandmarks{lm}])=OL(s).LM.([fLandmarks{lm} '_' Side_IL]);
    else
        excelLM(s).([fLandmarks{lm}])=[nan nan nan];
    end
end


%% Add skinning parameters 
% NeckLength, FemoralVersion and CCD angle [CCD]
OL(s).NeckLength = NeckLength(s);
OL(s).FemoralVersion = alphaZ(s);
OL(s).CCD = CCD;

end

writetable(struct2table(excelLM),'data\OrthoLoadFemurLandmarks.xlsx','WriteVariableNames',false,'Range','B3')

%% Save data
save('data\OrthoLoad.mat', 'OL')

end