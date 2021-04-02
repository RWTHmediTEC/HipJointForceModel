function TFM = createPelvisCS_TFM_Wu2002(ASIS_R, ASIS_L, PSIS_R, PSIS_L,varargin)
%CREATEPELVISCS_TFM_WU2002 calculates the transformation to the pelvic bone
% coordinate system defined by [Wu 2002]
%
% Orientation: 'ASR'
% Origin: Midpoint between left and right ASIS [default]
%
% Also called superior iliac spine plane (SISP) coordinate system.
%
% Reference:
% [Wu 2002] 2002 - Wu et al. - ISB recommendation on definitions of joint 
%   coordinate systems of various joints for the reporting of human joint 
%   motion - part 1: ankle, hip, and spine
% https://doi.org/10.1016/s0021-9290(01)00222-6
%
% Pelvic coordinate system - XYZ [Wu 2002]:
% O: The origin coincident with the right (or left) hip center of rotation.
% Z: The line parallel to a line connecting the right and left ASISs, and 
%    pointing to the right.
% X: The line parallel to a line lying in the plane defined by the two 
%    ASISs and the midpoint of the two PSISs, orthogonal to the Z-axis, and
%    pointing anteriorly.
% Y: The line perpendicular to both X and Z, pointing cranially.
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

sispPatch.vertices = [ASIS_L; midPoint3d(PSIS_R, PSIS_L); ASIS_R];
sispPatch.faces = [1 2 3];
sispTrans = [[eye(3), -origin']; [0 0 0 1]];
sispRot = eye(4);
% y axis is the normal of the SISP
sispRot(2,1:3) = normalizeVector3d(meshFaceNormals(sispPatch));
% z axis is the connection of right and left ASIS
sispRot(3,1:3) = normalizeVector3d(ASIS_R - ASIS_L);
% x axis is orthogonal to y & z axis
sispRot(1,1:3) = normalizeVector3d(crossProduct3d(sispRot(2,1:3), sispRot(3,1:3)));
TFM = sispRot * sispTrans;

end