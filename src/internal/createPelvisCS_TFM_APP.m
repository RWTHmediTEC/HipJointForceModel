function TFM = createPelvisCS_TFM_APP(ASIS_R, ASIS_L, PS, varargin)
%CREATEPELVISCS_TFM_APP creates the transformation to the anterior pelvic 
% plane (APP) bone coordinate established in orthopedic surgery.
%
% Orientation: 'ASR'
% Origin: Midpoint between left and right ASIS [default]
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

p = inputParser;
isPoint3d = @(x) validateattributes(x,{'numeric'},...
    {'nonempty','nonnan','real','finite','size',[1,3]});
addOptional(p,'origin',midPoint3d(ASIS_L, ASIS_R), isPoint3d);
parse(p,varargin{:});
origin = p.Results.origin;

appPatch.vertices = [ASIS_R; PS; ASIS_L];
appPatch.faces = [1 2 3];
appTrans = [[eye(3), -origin']; [0 0 0 1]];
appRot = eye(4);
% x axis is the normal of the APP
appRot(1,1:3) = normalizeVector3d(meshFaceNormals(appPatch));
% z axis is the connection of right and left ASIS
appRot(3,1:3) = normalizeVector3d(ASIS_R - ASIS_L);
% y axis is orthogonal to z & x axis
appRot(2,1:3) = normalizeVector3d(crossProduct3d(appRot(3,1:3), appRot(1,1:3)));
TFM = appRot * appTrans;

end