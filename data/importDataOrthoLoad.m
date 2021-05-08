function OL = importDataOrthoLoad(varargin)
%IMPORTDATAORTHOLOAD Import OrthoLoad (OL) HipIII data as struct
%
% References:
% [Bergmann 2016] 2016 - Bergmann - Standardized Loads Acting in Hip 
%   Implants
% https://doi.org/10.1371/journal.pone.0155612
% [Wu 2002] 2002 - Wu et al. - ISB recommendation on definitions of joint 
%   coordinate systems of various joints for the reporting of human joint 
%   motion - part 1: ankle, hip, and spine
% https://doi.org/10.1016/s0021-9290(01)00222-6
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

%% Input parsing
p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p, 'WriteExcel', false, logParValidFunc);
parse(p, varargin{:});
writeExcel = p.Results.WriteExcel;

sides={'R','L'};

%% Create OrthoLoad (OL) struct
% Biometric parameters [Bergmann 2016]
Subject = {'H1L' 'H2R' 'H3L' 'H4L' 'H5L' 'H6R' 'H7R' 'H8L' 'H9L' 'H10R'};
Sex     = {'m'   'm'   'm'   'm'   'f'   'm'   'm'   'm'   'm'   'f'};
Height  = [178   172   168   178   168   176   179   178   181   162];
OL = repmat(struct('Subject', [], 'Sex', []), length(Subject),1);

% Implant and implantation parameters [Bergmann 2016]
NeckLength = [55.6  59.3  56.6  63.3  55.6 55.6  63.3 59.3  59.3 59.6]; % [mm]
% alphaX = [ 2.3   4.1   4.0   7.5   4.0  5.8   6.3  4.6   4.6  1.7]; % [°]
% alphaY = [-2.3   0.6  -3.0  -1.7  -2.3 -1.7  -1.7 -1.7   0.6 -1.2]; % [°]
alphaZ = [-15.0 -13.8 -13.8 -18.9 -2.3 -31.0 -2.4 -15.5 -2.3 -9.7]; % Femoral version [°]
CCD = 135; % CCD angle is always 135°

if writeExcel
    excelLM = repmat(struct('Subject',[]), length(Subject),1);
end

for s = 1:length(Subject)
    
OL(s).Subject    = Subject{s};
OL(s).Sex        = Sex{s};
OL(s).BodyHeight = Height(s);

Side_IL = Subject{s}(end);
Side_CL = sides{~strcmp(Side_IL,sides)};

%% Load landmark data
% Read pelvis landmark file
tempContent = read_mixed_csv([Subject{s} '_PelvisLandmarks.fcsv'], ',');
tempContent(1:3,:) = [];
tempPos = cellfun(@str2double, tempContent(:,2:4));
% Write landmarks
for t = 1:size(tempContent,1)
    OL(s).Landmarks.Pelvis.(tempContent{t,12}) = tempPos(t,:);
end
% Read femur landmark file
tempContent = read_mixed_csv([Subject{s} '_FemurLandmarks.fcsv'], ',');
tempContent(1:3,:) = [];
tempPos = cellfun(@str2double, tempContent(:,2:4));
% Write landmarks
for t = 1:size(tempContent,1)
    OL(s).Landmarks.Femur.(tempContent{t,12}) = tempPos(t,:);
end

%% Write selected landmarks of the pelvis and femur as excel file:
if writeExcel
    excelLM(s).Subject = OL(s).Subject;
    pelvisLM_BL = {'ASIS_R','ASIS_L','HJC_R','HJC_L','PSIS_R','PSIS_L'};
    for lm = 1:length(pelvisLM_BL)
        if isfield(OL(s).Landmarks.Pelvis, pelvisLM_BL{lm})
            excelLM(s).([pelvisLM_BL{lm}]) = OL(s).Landmarks.Pelvis.(pelvisLM_BL{lm}) .* [-1 -1 1];
        else
            excelLM(s).([pelvisLM_BL{lm}]) = nan(1,3);
        end
    end
    pelvisLM_IL = {'AIIS','MP','PT','IIT', 'PIT','IS','PIIS','SIC','IT'};
    for lm = 1:length(pelvisLM_IL)
        if isfield(OL(s).Landmarks.Pelvis, [pelvisLM_IL{lm} '_' Side_IL])
            excelLM(s).([pelvisLM_IL{lm}]) = OL(s).Landmarks.Pelvis.([pelvisLM_IL{lm} '_' Side_IL]) .* [-1 -1 1];
        else
            excelLM(s).([pelvisLM_IL{lm}]) = nan(1,3);
        end
    end
    femurLM_IL = {'HJC','GT','P1','LT','MEC','LEC','MPC','LPC','P2'};
    for lm = 1:length(femurLM_IL)
        if isfield(OL(s).Landmarks.Femur, [femurLM_IL{lm} '_' Side_IL])
            excelLM(s).([femurLM_IL{lm}]) = OL(s).Landmarks.Femur.([femurLM_IL{lm} '_' Side_IL]) .* [-1 -1 1];
        else
            excelLM(s).([femurLM_IL{lm}]) = nan(1,3);
        end
    end
end

%% Convert left to right sides
% For scaling, landmarks have to be mirrored to the right side as the 
% cadavers are always right sided.
switch Side_IL
    case 'R'
        mirrorZTFM = eye(4);
    case 'L'
        mirrorZTFM = eye(4); mirrorZTFM(3,3) = -1;
end

% Pelvic parameters
% Transform the landmarks into the pelvic coordinate system (CS) [Wu 2002]
pelvisTFM = createPelvisCS_TFM_Wu2002(...
    OL(s).Landmarks.Pelvis.ASIS_R, OL(s).Landmarks.Pelvis.ASIS_L, ...
    OL(s).Landmarks.Pelvis.PSIS_R, OL(s).Landmarks.Pelvis.PSIS_L, ...
    OL(s).Landmarks.Pelvis.(['HJC_' Side_IL]));
OL(s).Landmarks.Pelvis = structfun(@(x) transformPoint3d(x, mirrorZTFM*pelvisTFM),...
    OL(s).Landmarks.Pelvis, 'uni', 0);

% Femoral parameters
% Transform the landmarks into the femur CS [Wu 2002] with the MEC-LEC midpoint as origin.
femurTFM = createFemurCS_TFM_Wu2002(...
    OL(s).Landmarks.Femur.(['MEC_' Side_IL]), OL(s).Landmarks.Femur.(['LEC_' Side_IL]), ...
    OL(s).Landmarks.Femur.(['HJC_' Side_IL]), Side_IL);
OL(s).Landmarks.Femur = structfun(@(x) transformPoint3d(x, mirrorZTFM*femurTFM),  OL(s).Landmarks.Femur, 'uni', 0);
assert(all(ismembertol(OL(s).Landmarks.Femur.(['HJC_' Side_IL]),[0 0 0], 'ByRows',1,'DataScale',10)))

%% Calculate scaling parameters
% See createLEM.m for the exact definitions
% !!! Create functions for the parameter definitions !!!
ASIS_IL = OL(s).Landmarks.Pelvis.(['ASIS_' Side_IL]);
ASIS_CL = OL(s).Landmarks.Pelvis.(['ASIS_' Side_CL]);
HJC_IL  = OL(s).Landmarks.Pelvis.(['HJC_' Side_IL]);
HJC_CL  = OL(s).Landmarks.Pelvis.(['HJC_' Side_CL]);
PSIS_IL = OL(s).Landmarks.Pelvis.(['PSIS_' Side_IL]);
IT_IL = OL(s).Landmarks.Pelvis.(['IT_' Side_IL]);
MP_IL = OL(s).Landmarks.Pelvis.(['MP_' Side_IL]);
SIC_IL = OL(s).Landmarks.Pelvis.(['SIC_' Side_IL]);
IIT_IL = OL(s).Landmarks.Pelvis.(['IIT_' Side_IL]);

% See createLEM.m for the exact definitions
OL(s).PelvicDepth   = abs(ASIS_IL(1) - PSIS_IL(1));
OL(s).PelvicHeight  = abs(SIC_IL(2) - IIT_IL(2));
OL(s).HJCASISHeight = abs(ASIS_IL(2) - HJC_IL(2));
% !!! Assuming symmetry of the pelvis. No consideration of the width of the pubic symphysis !!!
OL(s).PelvicWidth   = 2 * abs(IT_IL(3) - MP_IL(3));
OL(s).HipJointWidth = abs(HJC_IL(3)  - HJC_CL(3));
OL(s).ASISDistance  = abs(ASIS_IL(3) - ASIS_CL(3));

% FemoralLength
OL(s).FemoralLength = distancePoints3d(...
    midPoint3d(OL(s).Landmarks.Femur.(['LEC_' Side_IL]), OL(s).Landmarks.Femur.(['MEC_' Side_IL])), ...
    OL(s).Landmarks.Femur.(['HJC_' Side_IL]));
% FemoralWidth: Distance between the HJC and the greater trochanter along the Z-Axis.
HJC2GreaterTrochanter = OL(s).Landmarks.Femur.(['GT_' Side_IL]) - OL(s).Landmarks.Femur.(['HJC_' Side_IL]);
OL(s).FemoralWidth = abs(HJC2GreaterTrochanter(3));
% NeckLength, FemoralVersion and CCD angle
OL(s).NeckLength = NeckLength(s);
OL(s).FemoralVersion = -alphaZ(s);
OL(s).CCD = CCD;

% Create transformation from [Wu 2002] into OrthoLoad CS [Bergmann 2016].
Bergman2016TFM = createFemurCS_TFM_Bergmann2016(...
    OL(s).Landmarks.Femur.(['MPC_' Side_IL]),...
    OL(s).Landmarks.Femur.(['LPC_' Side_IL]),...
    OL(s).Landmarks.Femur.(['P1_' Side_IL]), ...
    OL(s).Landmarks.Femur.(['P2_' Side_IL]), ...
    OL(s).Landmarks.Femur.(['HJC_' Side_IL]), 'R'); % <- Always 'R' since landmarks were mirrored to the right side
% Create transformation for the hip joint force from [Bergmann 2016] to [Wu 2002].
OL(s).Wu2002TFM = [Bergman2016TFM(1:4,1:3)'; 0 0 0 1];

end

if writeExcel
    writetable(struct2table(excelLM),'OrthoLoadLandmarks.xlsx',...
        'WriteVariableNames',0,'Range','B5')
end

end