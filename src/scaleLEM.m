function data = scaleLEM(data)
%SCALELEM scales the lower extremity model
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

% Create scaling matrices
scaleTFM = repmat(eye(4), 1, 1, length(data.T.LE));

%% Scale factors
switch data.ScalingLaw
    case 'NonUniformLinearA'
        PD = 1;
        PH =  data.S.Scale(1).PelvicHeight / data.T.Scale(1).PelvicHeight;
        PW = (data.S.Scale(1).PelvicWidth - data.S.Scale(1).HipJointWidth) / ...
             (data.T.Scale(1).PelvicWidth - data.T.Scale(1).HipJointWidth);
        FemoralLength = (0.53-0.285)*data.S.BodyHeight*10; % [cm] to [mm] [Winter 2009, S.83, Fig.4.1]
        FL = FemoralLength / data.T.Scale(2).FemoralLength;
        FW = data.S.Scale(2).FemoralWidth / data.T.Scale(2).FemoralWidth;
    case 'NonUniformLinearB'
        PD = data.S.Scale(1).PelvicDepth   / data.T.Scale(1).PelvicDepth;
        PH = data.S.Scale(1).HJCASISHeight / data.T.Scale(1).HJCASISHeight;
        PW = data.S.Scale(1).ASISDistance  / data.T.Scale(1).ASISDistance;
        FL = data.S.Scale(2).FemoralLength / data.T.Scale(2).FemoralLength;
        FW = 1;
    case 'ParameterDeformableFemur'
        PD = data.S.Scale(1).PelvicDepth   / data.T.Scale(1).PelvicDepth;
        PH = data.S.Scale(1).HJCASISHeight / data.T.Scale(1).HJCASISHeight;
        PW = data.S.Scale(1).ASISDistance  / data.T.Scale(1).ASISDistance;
        FL = 1;
        FW = 1;
    case {'None','LandmarkDeformableBones'}
        [PD, PH, PW, FL, FW] = deal(1);
    otherwise
        error('Invalid scaling law!')
end

if any(isnan([PD, PH, PW, FL, FW]))
    errMessage = ['At least one of the scaling parameters is nan. '...
        'Choose another cadaver to use this scaling law!'];
    msgbox(errMessage,mfilename,'error')
    error(errMessage)
end


% Pelvis
scaleTFM(1,1,1) = PD;
scaleTFM(2,2,1) = PH;
scaleTFM(3,3,1) = PW;

% Femur
scaleTFM(2,2,2) = FL;
scaleTFM(3,3,2) = FW;

% Scaling of patella, tibia, talus and foot by femoral length
if size(scaleTFM,3) > 2 && ~isnan(data.T.Scale(2).FemoralLength)
    scaleTFM(2,2,3:end) = data.S.Scale(2).FemoralLength / data.T.Scale(2).FemoralLength;
end

%% Scale
data.S.LE = transformLEM(data.T.LE, scaleTFM);

%% Skinning
switch data.ScalingLaw
    case 'ParameterDeformableFemur'
        data = skinFemurLEM(data,'ParameterBased');
    case 'LandmarkDeformableBones'
        data = skinPelvisLEM(data,'LandmarkBased');
        data = skinFemurLEM(data,'LandmarkBased');
end

%% Correct bone coordinate systems
% Bone CS may have changed due to scaling and have to be corrected
boneCS_TFM = repmat(eye(4), 1, 1, 6);
% Pelvis
boneCS_TFM(:,:,1) = createPelvisCS_TFM_LEM(data.S.LE, ...
    'definition',data.PelvicCS, 'verbose',data.Verbose);
% Femur. Should be always the right side 'R' before scaling.
boneCS_TFM(:,:,2) = createFemurCS_TFM_LEM(data.S.LE, 'R',...
    'definition','Wu2002', 'verbose',data.Verbose);

data.S.LE = transformLEM(data.S.LE, boneCS_TFM);

end