function data = scaleTLEM2(data)
% Patient specific scaling of TLEM2 by pelvic width, pelvic height,
% pelvic depth and femoral length

%% Scaling parameters
PW  = data.S.Scale(1).PelvicWidth   / data.T.Scale(1).PelvicWidth;
PH  = data.S.Scale(1).PelvicHeight  / data.T.Scale(1).PelvicHeight;
PD  = data.S.Scale(1).PelvicDepth   / data.T.Scale(1).PelvicDepth;
FL  = data.S.Scale(2).FemoralLength / data.T.Scale(2).FemoralLength;

%% Implementation of scaling matrices
scaleTFM = repmat(eye(4), 1, 1, 6);

% Pelvis
scaleTFM(1,1,1) = PD; scaleTFM(2,2,1) = PH; scaleTFM(3,3,1) = PW;

% Femur
if strcmp(data.FemoralTransformation, 'Scaling')
    scaleTFM(2,2,2) = FL;
end

% Scaling of patella, tibia, talus and foot by femoral length
scaleTFM(2,2,3:6) = FL;

%% Scale
data.S.LE = transformTLEM2(data.T.LE, scaleTFM);

%% Femoral skinning
if strcmp(data.FemoralTransformation, 'Skinning')
    data = skinFemur(data);
end

%% Correct bone coordinate systems
% Bone CSs may have changed due to scaling and have to be corrected
boneCS_TFM = repmat(eye(4), 1, 1, 6);
% Pelvis
boneCS_TFM(:,:,1) = createPelvisCS_TFM_Wu2002(...
    data.S.LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos,...
    data.S.LE(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos,...
    data.S.LE(1).Landmarks.RightPosteriorSuperiorIliacSpine.Pos,...
    data.S.LE(1).Landmarks.LeftPosteriorSuperiorIliacSpine.Pos,...
    data.S.LE(1).Joints.Hip.Pos);
% Femur
boneCS_TFM(:,:,2) = createFemurCS_TFM_Wu2002(...
    data.S.LE(2).Landmarks.MedialEpicondyle.Pos,...
    data.S.LE(2).Landmarks.LateralEpicondyle.Pos,...
    data.S.LE(2).Joints.Hip.Pos);

data.S.LE = transformTLEM2(data.S.LE, boneCS_TFM);
end