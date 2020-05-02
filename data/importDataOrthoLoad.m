function importDataOrthoLoad(varargin)

%% Input parsing
p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p, 'WriteExcel', false, logParValidFunc);
parse(p, varargin{:});
writeExcel = p.Results.WriteExcel;

% Import OrthoLoad data as OL (OrthoLoad) struct and save as OrthoLoad.mat 

sides={'R','L'};

%% Create structure OL
Subject = {'H1L' 'H2R' 'H3L' 'H4L' 'H5L' 'H6R' 'H7R' 'H8L' 'H9L' 'H10R'};
Sex     = {'m'   'm'   'm'   'm'   'f'   'm'   'm'   'm'   'm'   'f'};
Height  = [178   172   168   178   168   176   179   178   181   162];
OL = repmat(struct('Subject', [], 'Sex', []), length(Subject),1);
excelLM = repmat(struct('Subject',[]), length(Subject),1);

%% Hardcoding of implant parameters from '2016 - Bergmann - Standardized Loads Acting in Hip Implants'
NeckLength = [ 55.6  59.3  56.6  63.3  55.6 55.6  63.3 59.3  59.3 59.6];
% alphaX =     [ 2.3   4.1   4.0   7.5   4.0  5.8   6.3  4.6   4.6  1.7];
% alphaY =     [-2.3   0.6  -3.0  -1.7  -2.3 -1.7  -1.7 -1.7   0.6 -1.2];
alphaZ =     [-15.0 -13.8 -13.8 -18.9 -2.3 -31.0 -2.4 -15.5 -2.3 -9.7];  % Femoral version
CCD =         135;                                                       % CCD angle is always 135°

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
    OL(s).LM.Pelvis.(tempContent{t,12}) = tempPos(t,:);
end
% Read femur landmark file
tempContent = read_mixed_csv([Subject{s} '_FemurLandmarks.fcsv'], ',');
tempContent(1:3,:) = [];
tempPos = cellfun(@str2double, tempContent(:,2:4));
% Write landmarks
for t = 1:size(tempContent,1)
    OL(s).LM.Femur.(tempContent{t,12}) = tempPos(t,:);
end

%% Write selected landmarks of the femur as excel file:
if writeExcel
    femurLM = {'PSA','DSA','MNA','LNA','MEC','LEC','MPC','LPC','HJC','P1','P2','GT','LT'};
    excelLM(s).Subject=OL(s).Subject;
    for lm=1:length(femurLM)
        if isfield(OL(s).LM.Femur, [femurLM{lm} '_' Side_IL])
            excelLM(s).([femurLM{lm}]) = OL(s).LM.Femur.([femurLM{lm} '_' Side_IL]) .* [-1 -1 1];
        else
            excelLM(s).([femurLM{lm}]) = [nan nan nan];
        end
    end
    % Reconstruct P1
    NeckAxis = createLine3d(OL(s).LM.Femur.(['MNA_' Side_IL]),OL(s).LM.Femur.(['LNA_' Side_IL]));
    ShaftAxis = createLine3d(OL(s).LM.Femur.(['PSA_' Side_IL]),OL(s).LM.Femur.(['DSA_' Side_IL]));
    [~, P1_NA, P1_SA] = distanceLines3d(NeckAxis, ShaftAxis);
    excelLM(s).P1_Fischer = midPoint3d(P1_NA,P1_SA) .* [-1 -1 1];
    excelLM(s).Distance_P1_Damm_Fischer = ...
        distancePoints3d(OL(s).LM.Femur.(['P1_' Side_IL]), midPoint3d(P1_NA,P1_SA));
end

%% Calculate scaling parameters
% See createDataTLEM2.m for the exact definitions
% !!! Create functions for the parameter definitions !!!

% Pelvis parameters
% Transform the landmarks into the pelvic coordinate system (CS) [Wu 2002]
pelvisTFM = createPelvisCS_TFM_Wu2002(OL(s).LM.Pelvis.ASIS_L, OL(s).LM.Pelvis.ASIS_R, ...
    OL(s).LM.Pelvis.PSIS_L, OL(s).LM.Pelvis.PSIS_R);
OL(s).LM.Pelvis = structfun(@(x) transformPoint3d(x, pelvisTFM),  OL(s).LM.Pelvis, 'uni', 0);

ASIS_IL = OL(s).LM.Pelvis.(['ASIS_' Side_IL]);
ASIS_CL = OL(s).LM.Pelvis.(['ASIS_' Side_CL]);
HJC_IL  = OL(s).LM.Pelvis.(['HJC_' Side_IL]);
HJC_CL  = OL(s).LM.Pelvis.(['HJC_' Side_CL]);
PSIS_IL = OL(s).LM.Pelvis.(['PSIS_' Side_IL]);

OL(s).HipJointWidth = abs(HJC_IL(3)  - HJC_CL(3));
OL(s).PelvicWidth   = abs(ASIS_IL(3) - ASIS_CL(3));
OL(s).PelvicHeight  = abs(ASIS_IL(2) - HJC_IL(2));
OL(s).PelvicDepth   = abs(ASIS_IL(1) - PSIS_IL(1));

% Femoral parameters
% Transform the landmarks into the femur CS [Wu 2002] with the MEC-LEC midpoint as origin
midPointEC = midPoint3d(OL(s).LM.Femur.(['LEC_' Side_IL]), OL(s).LM.Femur.(['MEC_' Side_IL]));
femurTFM = createFemurCS_TFM_Wu2002(...
    OL(s).LM.Femur.(['MEC_' Side_IL]), OL(s).LM.Femur.(['LEC_' Side_IL]), ...
    OL(s).LM.Femur.(['HJC_' Side_IL]), Side_IL, 'origin', midPointEC);
OL(s).LM.Femur = structfun(@(x) transformPoint3d(x, femurTFM),  OL(s).LM.Femur, 'uni', 0);
midPointEC = transformPoint3d(midPointEC, femurTFM);
assert(all(ismembertol(midPointEC,[0 0 0], 'ByRows',1,'DataScale',10)))
% FemoralLength
OL(s).FemoralLength = distancePoints3d(midPointEC, OL(s).LM.Femur.(['HJC_' Side_IL]));
% FemoralWidth: Distance between the HJC and the greater trochanter along the Z-Axis.
HJC2GreaterTrochanter = OL(s).LM.Femur.(['GT_' Side_IL]) - OL(s).LM.Femur.(['HJC_' Side_IL]);
OL(s).FemoralWidth = abs(HJC2GreaterTrochanter(3));

% Transformation for the hip joint force from OrthoLoad CS [Bergmann 2016] to [Wu 2002] CS
% Create transformation into OrthoLoad CS [Bergmann 2016].
Bergman2016TFM = createFemurCS_TFM_Bergmann2016(...
    OL(s).LM.Femur.(['MPC_' Side_IL]),...
    OL(s).LM.Femur.(['LPC_' Side_IL]),...
    OL(s).LM.Femur.(['P1_' Side_IL]), ...
    OL(s).LM.Femur.(['P2_' Side_IL]), ...
    OL(s).LM.Femur.(['HJC_' Side_IL]), Side_IL);
% Transform landmarks for [Wu 2002] into the [Bergmann 2016].
MEC_IL = transformPoint3d(OL(s).LM.Femur.(['MEC_' Side_IL]), Bergman2016TFM);
LEC_IL = transformPoint3d(OL(s).LM.Femur.(['LEC_' Side_IL]), Bergman2016TFM);
HJC_IL = transformPoint3d(OL(s).LM.Femur.(['HJC_' Side_IL]), Bergman2016TFM);
% Create transformation from [Bergmann 2016] to [Wu 2002].
OL(s).Wu2002TFM = createFemurCS_TFM_Wu2002(MEC_IL, LEC_IL, HJC_IL, Side_IL);

% NeckLength, FemoralVersion and CCD angle [CCD]
OL(s).NeckLength = NeckLength(s);
OL(s).FemoralVersion = -alphaZ(s);
OL(s).CCD = CCD;

end

if writeExcel
    writetable(struct2table(excelLM),'data\OrthoLoad\Landmarks\OrthoLoadFemurLandmarks.xlsx',...
        'WriteVariableNames',false,'Range','B4')
end
%% Save data
save('data\OrthoLoad.mat', 'OL')

end