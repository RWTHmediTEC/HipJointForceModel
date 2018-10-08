function data = skinFemur(data)
% Linear blend skinning (LBS) of femur changing femoral length, femoral version,
% CCD angle and neck length

LE      = data.T.LE;
T.Scale = data.T.Scale;
S.Scale = data.S.Scale;

% Implant parameters
if isequal(S.Scale(2).FemoralLength,  T.Scale(2).FemoralLength) &&...
   isequal(S.Scale(2).FemoralVersion, T.Scale(2).FemoralVersion) &&...
   isequal(S.Scale(2).CCD,            T.Scale(2).CCD) &&...
   isequal(S.Scale(2).NeckLength,     T.Scale(2).NeckLength)
    return
else
    femoralVersion = S.Scale(2).FemoralVersion;
    CCD            = S.Scale(2).CCD;
    neckLength     = S.Scale(2).NeckLength;
end

% Load TLEMversion controls
load(['femur' data.TLEMversion 'Controls'], 'Controls', 'LMIdx')

P = 1:size(Controls,1);

% Create TLEMversion weights
if ~exist(['femur' data.TLEMversion 'Weights.mat'], 'file')
    % Compute boundary conditions
    [bVertices,bConditions] = boundary_conditions(LE(2).Mesh.vertices, LE(2).Mesh.faces, Controls, P);
    % Compute weights
    Weights = biharmonic_bounded(LE(2).Mesh.vertices, LE(2).Mesh.faces, bVertices, bConditions, 'OptType', 'quad');
    % Normalize weights
    Weights = Weights./repmat(sum(Weights,2), 1, size(Weights,2));
    
    save(['data/Skinning/femur' data.TLEMversion 'Weights'], 'Weights')
end
load(['femur' data.TLEMversion 'Weights'], 'Weights')

scaleFemur = eye(4);
scaleFemur(2,2) = S.Scale(2).FemoralLength / T.Scale(2).FemoralLength;
newControls = transformPoint3d(Controls, scaleFemur);

% Femoral version
% Change position of control point by a rotation around the straight femur axis
ROT = createRotation3dLineAngle([newControls(3,:), newControls(3,:) - newControls(2,:)],...
    deg2rad(femoralVersion + T.Scale(2).FemoralVersion));
newControls(1,:) = transformPoint3d(newControls(1,:), ROT);

% CCD
tempCCD = rad2deg(vectorAngle3d(newControls(3,:) - newControls(2,:), newControls(1,:) - newControls(2,:)));
tempHeight = sind(tempCCD - 90) * distancePoints3d(newControls(1,:), newControls(2,:));
tempOffset = cosd(tempCCD - 90) * distancePoints3d(newControls(1,:), newControls(2,:));
HeightAdjust = tand(CCD - 90) * tempOffset - tempHeight;
newControls(1,:) = newControls(1,:) + HeightAdjust * normalizeVector3d(newControls(2,:) - newControls(3,:));

% Neck Length
neckLengthAdjust = neckLength - distancePoints3d(newControls(1,:), newControls(2,:));
newControls(1,:) = newControls(1,:) + neckLengthAdjust *...
    normalizeVector3d(newControls(1,:) - newControls(2,:));

% Femoral Length
% !!! Move newControls(3,:) in proximal direction, along the straight femur 
%     axis to adapt the length !!!

% Construct reference lines to measure femoral version 
postConds = transformPoint3d([...
    LE(2).Mesh.vertices(LMIdx.MedialPosteriorCondyle,:);...
    LE(2).Mesh.vertices(LMIdx.LateralPosteriorCondyle,:)], scaleFemur);
transversePlane = createPlane(newControls(3,:), newControls(2,:) - newControls(3,:));
projPostCond = projPointOnPlane(postConds, transversePlane);
% Posterior condyle line projected onto the transverse plane
projPostCondLine = createLine3d(projPostCond(1,:), projPostCond(2,:));
projNeckPoints = projPointOnPlane(newControls(1:2,:), transversePlane);
projNeckLine = createLine3d(projNeckPoints(1,:), projNeckPoints(2,:));

% % Check if femoral version is correct
% assert(ismembertol(abs(femoralVersion),...
%     rad2deg(vectorAngle3d(projNeckLine(4:6), projPostCondLine(4:6))), 'DataScale', 10)) % !!! Set tolerance
% % Check if CCD angle is correct
% assert(ismembertol(CCD,...
%     rad2deg(vectorAngle3d(newControls(3,:) - newControls(2,:), newControls(1,:) - newControls(2,:)))))
% % Check if neck length is correct
% assert(ismembertol(neckLength, distancePoints3d(newControls(1,:), newControls(2,:))))
% % Check if femoral length is correct
% assert(ismembertol(S.Scale(2).FemoralLength, distancePoints3d(newControls(1,:), newControls(3,:))))

% Calculate skinning transformations
[T, AX, AN, Sm, O] = skinning_transformations(Controls, P, [], newControls);

% Number of handles
m = numel(P); % + size(BE,1);
% Dimension (2 or 3)
dim = size(Controls,2);
% Extract scale
TR = zeros(dim,dim+1,m);
TR(1:dim,1:dim,:) = Sm;
Sm = reshape(Sm,[dim dim*m])';
TR(1:dim,dim+1,:) = permute(O-stacktimes(Sm,O),[2 3 1]);
% Perform scale as linear blend skinning, before translations and rotations
skinnedMesh = LE(2).Mesh;
[scaledVertices] = lbs(skinnedMesh.vertices, TR, Weights);
Q = axisangle2quat(AX,AN);
% quattrans2udq expect 3D translations, so pad with zeros
T = [T zeros(size(T,1),1)];
% Convert quaternions and translations into dualquaternions
DQ = quattrans2udq(Q,T);
% Dual quaternions linear blend skinning deformation
skinnedMesh.vertices = dualquatlbs(scaledVertices, DQ, Weights);

%% Update struct LE of femur
% Mesh
LE(2).Mesh = skinnedMesh;
% Joints
LE(2).Joints.Hip.Pos = newControls(1,:);
% !!! Positions of the knee joint and axis have to be updated, too !!!
% Muscles
    muscles = fieldnames(LE(2).Muscle);
    for m = 1:length(muscles)
        for n = 1:length(LE(2).Muscle.(muscles{m}).Type)
            
            trans = LE(2).Mesh.vertices(LE(2).Muscle.(muscles{m}).Node(n),:) - data.T.LE(2).Mesh.vertices(LE(2).Muscle.(muscles{m}).Node(n),:);
            LE(2).Muscle.(muscles{m}).Pos(n,:) = LE(2).Muscle.(muscles{m}).Pos(n,:) + trans;
        end
    end
    
data.S.LE(2) = LE(2);

end