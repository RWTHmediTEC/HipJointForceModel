function TFM = createSISP_TFM(ASIS_R, ASIS_L, PSIS_R, PSIS_L,varargin)
% Construct the pelvic SISP coordinate system recommended by the ISB [Wu 2002]

p = inputParser;
isPoint3d = @(x) validateattributes(x,{'numeric'},...
    {'nonempty','nonnan','real','finite','size',[1,3]});
addOptional(p,'HJC',midPoint3d(ASIS_L, ASIS_R), isPoint3d);
parse(p,varargin{:});
origin = p.Results.HJC;

sispPatch.vertices=[ASIS_L; midPoint3d(PSIS_R, PSIS_L); ASIS_R];
sispPatch.faces = [1 2 3];
sispTrans = [[eye(3), -origin']; [0 0 0 1]];
sispRot=eye(4);
% y axis is the normal of the SISP plane
sispRot(2,1:3) = normalizeVector3d(meshFaceNormals(sispPatch));
% z axis is the connection of right and left ASIS
sispRot(3,1:3) = normalizeVector3d(ASIS_R-ASIS_L);
% x axis is orthogonal to z & y axis
sispRot(1,1:3) = normalizeVector3d(crossProduct3d(sispRot(2,1:3), sispRot(3,1:3)));
TFM=sispRot*sispTrans;

end