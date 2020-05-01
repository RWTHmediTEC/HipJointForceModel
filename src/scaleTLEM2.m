function data = scaleTLEM2(data)

% Create scaling matrices
scaleTFM = repmat(eye(4), 1, 1, 6);

%% Scale factors
switch data.ScalingLaw
    case {'NonuniformEggert2018','SkinningFischer2018'}
        % Patient specific scaling of TLEM2 by pelvic width, pelvic height,
        % pelvic depth and femoral length
        PW = data.S.Scale(1).PelvicWidth   / data.T.Scale(1).PelvicWidth;
        PH = data.S.Scale(1).PelvicHeight  / data.T.Scale(1).PelvicHeight;
        PD = data.S.Scale(1).PelvicDepth   / data.T.Scale(1).PelvicDepth;
        FL = data.S.Scale(2).FemoralLength / data.T.Scale(2).FemoralLength;
        FW = 1;
    case 'NonuniformSedghi2017'
        % !!! Sedghi2017 may have used a different definition of the PelvicWidth !!!
        PW = (data.S.Scale(1).PelvicWidth - data.S.Scale(1).HipJointWidth) / ...
             (data.T.Scale(1).PelvicWidth - data.T.Scale(1).HipJointWidth);
        PH = data.S.Scale(1).PelvicHeight / data.T.Scale(1).PelvicHeight;
        PD = 1;
        FemoralLength = (0.53-0.285)*data.S.BodyHeight*10; % [cm] to [mm] [Winter 2009, S.83, Fig.4.1]
        FL = FemoralLength / data.T.Scale(2).FemoralLength;
        % !!! Sedghi2017 used a slightly different definition than the one implemented here !!!
        FW = data.S.Scale(2).FemoralWidth / data.T.Scale(2).FemoralWidth;
    otherwise
        error('Invalid scaling law!')
end

% Pelvis
scaleTFM(1,1,1) = PD; 
scaleTFM(2,2,1) = PH; 
scaleTFM(3,3,1) = PW;

% Femur
switch data.ScalingLaw
    case {'NonuniformEggert2018','NonuniformSedghi2017'}
        scaleTFM(2,2,2) = FL; 
        scaleTFM(3,3,2) = FW;
    case 'SkinningFischer2018'
    otherwise
        error('Invalid scaling law!')
end

% Scaling of patella, tibia, talus and foot by femoral length
scaleTFM(2,2,3:6) = FL;

%% Scale
data.S.LE = transformTLEM2(data.T.LE, scaleTFM);

%% Femoral skinning
if strcmp(data.ScalingLaw, 'SkinningFischer2018')
    data = skinFemurLEM(data);
end

%% Correct bone coordinate systems
% Bone CSs may have changed due to scaling and have to be corrected
boneCS_TFM = repmat(eye(4), 1, 1, 6);
% Pelvis
boneCS_TFM(:,:,1) = createPelvisCS_TFM_Wu2002_TLEM2(data.S.LE);
% Femur. Should be always the right side 'R' before scaling.
boneCS_TFM(:,:,2) = createFemurCS_TFM_Wu2002_TLEM2(data.S.LE, 'R');

data.S.LE = transformTLEM2(data.S.LE, boneCS_TFM);

end