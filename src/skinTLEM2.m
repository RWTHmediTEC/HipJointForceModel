function [ data ] = skinTLEM2( data )
% Linear blend skinning (LBS) of femur changing femoral length (FL), offset
% (Offset), CCD angle (CCD) and antetorsion (AT)

% addpath('data')
% addpath(genpath('src'))
% % addpath('D:\Biomechanics\General\Code\#public')
% % addpath(genpath('D:\Biomechanics\General\Code\#external\matGeom\matGeom'))
% % addpath(genpath('D:\Biomechanics\General\Code\#external\#Mesh\gptoolbox'))

% Load Controls
load('femurTLEM2Controls') % create in importData?

P=1:size(Controls,1);

if ~exist('femurTLEM2Weights.mat', 'file')
    % Compute boundary conditions
    [bVertices,bConditions] = boundary_conditions(femur.vertices, femur.faces, Controls, P);
    % Compute weights
    Weights = biharmonic_bounded(femur.vertices, femur.faces, bVertices, bConditions, 'OptType', 'quad');
    % Normalize weights
    Weights = Weights./repmat(sum(Weights,2), 1, size(Weights,2));
    
    save('data/femurTLEM2Weights', 'Weights') % create in importData?
end

load('femurTLEM2Weights') 


% % Scaling of the femoral length
% FL = 1.1;
% scaleTFM=eye(4);
% scaleTFM(1,1) = 1;  scaleTFM(2,2) = FL; scaleTFM(3,3) = 1; % No scaling for femoral width and depth
% 
% scaledControls=transformPoint3d(Controls, scaleTFM);

% Construct reference line to measure antetorsion 
postConds=transformPoint3d([...
    femur.vertices(LMIdx.MedialPosteriorCondyle,:); ...
    femur.vertices(LMIdx.LateralPosteriorCondyle,:)], scaleTFM);
transversePlane=createPlane(scaledControls(3,:), scaledControls(2,:)-scaledControls(3,:));
projPostCond=projPointOnPlane(postConds,transversePlane);
projPostCondLine=createLine3d(projPostCond(1,:),projPostCond(2,:));

% Implant parameters
femoralVersion = linspace(-25,25,3); % neg. = retroversion, pos. = anteversion
neckLength=linspace(40,60,3);
CCD=linspace(125,135,3);

for a=1:length(femoralVersion)
    skinnedMesh = femur;
    nC = scaledControls;
    
    % Femoral Version
    % Calculate the version of the TLEM2 femur
    projNeckPoints = projPointOnPlane(nC(1:2,:),transversePlane);
    projNeckLine = createLine3d(projNeckPoints(1,:),projNeckPoints(2,:));
    femoralVersionTLEM2 = rad2deg(vectorAngle3d(projNeckLine(4:6),projPostCondLine(4:6)));
    % Change position of control point by a rotation around the straight femur axis
    ROT=createRotation3dLineAngle([nC(3,:), nC(3,:)-nC(2,:)], ...
        deg2rad(femoralVersion(a)+femoralVersionTLEM2));
    nC(1,:)=transformPoint3d(nC(1,:), ROT);
    % CCD
    tempCCD = rad2deg(vectorAngle3d(nC(3,:)-nC(2,:), nC(1,:)-nC(2,:)));
    tempHeight = sind(tempCCD-90)*distancePoints3d(nC(1,:),nC(2,:));
    tempOffset = cosd(tempCCD-90)*distancePoints3d(nC(1,:),nC(2,:));
    HeightAdjust = tand(CCD(a)-90)*tempOffset-tempHeight;
    nC(1,:)=nC(1,:)+HeightAdjust*normalizeVector3d(nC(2,:)-nC(3,:));
    % Neck Length
    neckLengthAdjust=neckLength(a)-distancePoints3d(nC(1,:),nC(2,:));
    nC(1,:)=nC(1,:)+neckLengthAdjust*...
        normalizeVector3d(nC(1,:)-nC(2,:));
    
    % Check if femoral version is correct
    projNeckPoints = projPointOnPlane(nC(1:2,:),transversePlane);
    projNeckLine = createLine3d(projNeckPoints(1,:),projNeckPoints(2,:));
    assert(ismembertol(abs(femoralVersion(a)),...
         rad2deg(vectorAngle3d(projNeckLine(4:6),projPostCondLine(4:6))),'DataScale',10))
    % Check if CCD angle is correct
    assert(ismembertol(CCD(a),...
        rad2deg(vectorAngle3d(nC(3,:)-nC(2,:), nC(1,:)-nC(2,:)))))
    % Check if neck length is correct
    assert(ismembertol(neckLength(a), distancePoints3d(nC(1,:),nC(2,:))))
    
    % Calculate skinning transformations
    [T,AX,AN,Sm,O] = skinning_transformations(Controls,P,[],nC);
    
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
    [new_V] = lbs(V,TR,Weights);
    Q = axisangle2quat(AX,AN);
    % quattrans2udq expect 3D translations, so pad with zeros
    T = [T zeros(size(T,1),1)];
    % Convert quaternions and translations into dualquaternions
    DQ = quattrans2udq(Q,T);
    
    skinnedMesh.vertices = dualquatlbs(new_V,DQ,Weights);
    
    vIdx2rem = ismembertol(skinnedMesh.vertices, femur.vertices, 'ByRows', true, 'DataScale', 1e10);
    skinnedMesh = removeMeshVertices(skinnedMesh, vIdx2rem);
    
%     patch(skinnedMesh, patchProps)

end

end

