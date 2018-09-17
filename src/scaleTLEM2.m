function data = scaleTLEM2(data)
% Implementation of patient-specific scaling

% Scaling Parameters:
% HRC = Distance between the hip joint centers
% PW  = Pelvic width measured as the distance between the two ASISs along
%       Z-Axis
% PH  = Pelvic height measured as the distance between HRC and ASIS along
%       Y-Axis
% PD  = Pelvic depth measured as the distance between ASIS and PSIS along
%       X-Axis
% FL  = Femoral length measured as the distance between HRC and the 
%       midpoint between medial and lateral epicondyle along y-Axis

T.Scale = data.T.Scale;
S.Scale = data.S.Scale;
LE = data.LE;

%% Scaling Parameters
HRC = S.Scale(1).HipJointWidth / T.Scale(1).HipJointWidth;
PW  = S.Scale(1).PelvicWidth   / T.Scale(1).PelvicWidth;
PH  = S.Scale(1).PelvicHeight  / T.Scale(1).PelvicHeight;
PD  = S.Scale(1).PelvicDepth   / T.Scale(1).PelvicDepth;
FL  = S.Scale(2).FemoralLength / T.Scale(2).FemoralLength;

%% Implementation of the Scaling Matrices
scaleTFM = repmat(eye(4), 1, 1, 6);
% Pelvis / Hip bone
scaleTFM(1,1,1) = PD; scaleTFM(2,2,1) = PH; scaleTFM(3,3,1) = PW;
% Femur % !!! Add posibility to switch between scaling options !!!
scaleTFM(2,2,2) = 1;
% Scaling of patella, tibia, talus and foot by femoral length
scaleTFM(2,2,3:6) = FL;

%% Scale
LE = transformTLEM2(LE, scaleTFM);

%% Femoral Skinning
% Linear blend skinning (LBS) of femur changing femoral length (FL), offset
% (Offset), CCD angle (CCD) and antetorsion (AT)

% Load Controls
load('femurTLEM2Controls', 'Controls','LMIdx')

P=1:size(Controls,1);

if ~exist('femurTLEM2Weights.mat', 'file')
    % Compute boundary conditions
    [bVertices,bConditions] = boundary_conditions(LE(2).Mesh.vertices, LE(2).Mesh.faces, Controls, P);
    % Compute weights
    Weights = biharmonic_bounded(LE(2).Mesh.vertices, LE(2).Mesh.faces, bVertices, bConditions, 'OptType', 'quad');
    % Normalize weights
    Weights = Weights./repmat(sum(Weights,2), 1, size(Weights,2));
    
    save('data/Skinning/femurTLEM2Weights', 'Weights')
end

load('femurTLEM2Weights','Weights')

scaleFemur = eye(4);
scaleFemur(2,2) = FL;
newControls=transformPoint3d(Controls, scaleFemur);

% Construct reference line to measure antetorsion 
postConds=transformPoint3d([...
    LE(2).Mesh.vertices(LMIdx.MedialPosteriorCondyle,:); ...
    LE(2).Mesh.vertices(LMIdx.LateralPosteriorCondyle,:)], scaleFemur);
transversePlane=createPlane(newControls(3,:), newControls(2,:)-newControls(3,:));
projPostCond=projPointOnPlane(postConds,transversePlane);
% Posterior condyle line projected onto the transverse plane
projPostCondLine=createLine3d(projPostCond(1,:),projPostCond(2,:));

% Implant parameters
if isequal(S.Scale(2).FemoralLength, T.Scale(2).FemoralLength) && ...
   isequal(S.Scale(2).FemoralVersion, T.Scale(2).FemoralVersion) && ...
   isequal(S.Scale(2).CCD, T.Scale(2).CCD) && ...
   isequal(S.Scale(2).NeckLength, S.Scale(2).NeckLength)
    data.LE=LE;
    return
else
    femoralVersion=S.Scale(2).FemoralVersion;
    CCD=S.Scale(2).CCD;
    neckLength=S.Scale(2).NeckLength;
end

% Femoral Version
% Calculate the version of the TLEM2 femur
projNeckPoints = projPointOnPlane(newControls(1:2,:),transversePlane);
projNeckLine = createLine3d(projNeckPoints(1,:),projNeckPoints(2,:));
femoralVersionTLEM2 = rad2deg(vectorAngle3d(projNeckLine(4:6),projPostCondLine(4:6)));
% Change position of control point by a rotation around the straight femur axis
ROT=createRotation3dLineAngle([newControls(3,:), newControls(3,:)-newControls(2,:)], ...
    deg2rad(femoralVersion+femoralVersionTLEM2));
newControls(1,:)=transformPoint3d(newControls(1,:), ROT);
% CCD
tempCCD = rad2deg(vectorAngle3d(newControls(3,:)-newControls(2,:), newControls(1,:)-newControls(2,:)));
tempHeight = sind(tempCCD-90)*distancePoints3d(newControls(1,:),newControls(2,:));
tempOffset = cosd(tempCCD-90)*distancePoints3d(newControls(1,:),newControls(2,:));
HeightAdjust = tand(CCD-90)*tempOffset-tempHeight;
newControls(1,:)=newControls(1,:)+HeightAdjust*normalizeVector3d(newControls(2,:)-newControls(3,:));
% Neck Length
neckLengthAdjust=neckLength-distancePoints3d(newControls(1,:),newControls(2,:));
newControls(1,:)=newControls(1,:)+neckLengthAdjust*...
    normalizeVector3d(newControls(1,:)-newControls(2,:));
% Femoral Length
% !!! Move newControls(3,:) in proximal direction, along the straight femur 
%     axis to adapt the length !!!

% Check if femoral version is correct
projNeckPoints = projPointOnPlane(newControls(1:2,:),transversePlane);
projNeckLine = createLine3d(projNeckPoints(1,:),projNeckPoints(2,:));
assert(ismembertol(abs(femoralVersion),...
    rad2deg(vectorAngle3d(projNeckLine(4:6),projPostCondLine(4:6))),'DataScale',10))
% Check if CCD angle is correct
assert(ismembertol(CCD,...
    rad2deg(vectorAngle3d(newControls(3,:)-newControls(2,:), newControls(1,:)-newControls(2,:)))))
% Check if neck length is correct
assert(ismembertol(neckLength, distancePoints3d(newControls(1,:),newControls(2,:))))
% Check if femoral length is correct
% !!! Missing

% Calculate skinning transformations
[T,AX,AN,Sm,O] = skinning_transformations(Controls,P,[],newControls);

% number of handles
m = numel(P);%+size(BE,1);
% dimension (2 or 3)
dim = size(Controls,2);
% Extract scale
TR = zeros(dim,dim+1,m);
TR(1:dim,1:dim,:) = Sm;
Sm = reshape(Sm,[dim dim*m])';
TR(1:dim,dim+1,:) = permute(O-stacktimes(Sm,O),[2 3 1]);
% Perform scale as linear blend skinning, before translations and rotations
skinnedMesh=LE(2).Mesh;
[scaledVertices] = lbs(skinnedMesh.vertices,TR,Weights);
Q = axisangle2quat(AX,AN);
% quattrans2udq expect 3D translations, so pad with zeros
T = [T zeros(size(T,1),1)];
% Convert quaternions and translations into dualquaternions
DQ = quattrans2udq(Q,T);
% Dual quaternions linear blend skinning deformation
skinnedMesh.vertices = dualquatlbs(scaledVertices,DQ,Weights);

%% Update femur
% Mesh
LE(2).Mesh = skinnedMesh;
% Joints
LE(2).Joints.Hip.Pos = newControls(1,:);
% !!! Position of the knee joint and axis has to be updated, too !!!
% Muscles
Fascicles = fieldnames(LE(2).Muscle);
for f = 1:length(Fascicles)
     LE(2).Muscle.(Fascicles{f}).Pos=LE(2).Mesh.vertices(LE(2).Muscle.(Fascicles{f}).Node,:);
end

%% Save in data struct
data.LE=LE;