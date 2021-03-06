function TFM = createFemurCS_TFM_Wu2002(MEC, LEC, HJC, side, varargin)
%CREATEFEMURCS_TFM_WU2002 calculates the transformation to the femoral bone
% coordinate system defined by [Wu 2002]
%
% Orientation: 'ASR'
% Origin: Hip joint center (HJC) [default]
%
% Reference:
% [Wu 2002] 2002 - Wu et al. - ISB recommendation on definitions of joint 
%   coordinate systems of various joints for the reporting of human joint 
%   motion - part 1: ankle, hip, and spine
% https://doi.org/10.1016/s0021-9290(01)00222-6
%
% Femoral coordinate system - xyz [Wu 2002]:
% o: The origin coincident with the right (or left) hip center of rotation, 
%    coincident with that of the pelvic coordinate system (o) in the 
%    neutral configuration.
% y: The line joining the midpoint between the medial and lateral femoral 
%    epicondyles (FEs) and the origin, and pointing cranially.
% z: The line perpendicular to the y-axis, lying in the plane defined by 
%    the origin and the two FEs, pointing to the right.
% x: The line perpendicular to both y- and z-axis, pointing anteriorly
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

%% Parsing
p = inputParser;
isPoint3d = @(x) validateattributes(x,{'numeric'},...
    {'nonempty','nonnan','real','finite','size',[1,3]});
addRequired(p,'MEC', isPoint3d);
addRequired(p,'LEC', isPoint3d);
addRequired(p,'HJC', isPoint3d);
addRequired(p,'side',@(x) any(validatestring(upper(x(1)),{'R','L'})));
addParameter(p,'origin', HJC, isPoint3d);

parse(p, MEC, LEC, HJC, side,varargin{:});
MEC = p.Results.MEC;
LEC = p.Results.LEC;
HJC = p.Results.HJC;
side = upper(p.Results.side(1));
origin = p.Results.origin;

%% Calculation
% Midpoint between the epicondyles
MEC_LEC_midPoint=midPoint3d(MEC, LEC);
% Mechanical axis is the connection of EC midpoint and hip joint center
MechanicalAxis = createLine3d(MEC_LEC_midPoint, HJC);
% Connection of the epicondyles
EpicondyleAxis = createLine3d(MEC, LEC);

Y = normalizeVector3d(MechanicalAxis(4:6));
X = normalizeVector3d(crossProduct3d(MechanicalAxis(4:6), EpicondyleAxis(4:6)));
Z = normalizeVector3d(crossProduct3d(X, Y));

TFM = [[X;Y;Z],[0 0 0]'; [0 0 0 1]]*createTranslation3d(-origin);
switch side
    case 'L'
        TFM=createRotationOy(pi)*TFM;
    case 'R'
    otherwise
        error('Invalid side identifier!')
end

end
