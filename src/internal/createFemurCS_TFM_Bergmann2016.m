function TFM = createFemurCS_TFM_Bergmann2016(MPC, LPC, P1, P2, HJC, side)
%CREATEFEMURCS_TFM_BERGMANN2016 calculates the transformation to
% OrthoLoad's femoral bone coordinate system [Bergmann 2016].
%
% Orientation: 'RAS'
% Origin: hip joint center (HJC)
%
% Reference:
% [Bergmann 2016] 2016 - Bergmann - Standardized Loads Acting in Hip 
%   Implants
% https://doi.org/10.1371/journal.pone.0155612
%
% "The origin of this coordinate system is located at the centre of the
% femoral head. The +z axis points upward and is defined by the line
% connecting the two points where the curved femoral mid-line intersected
% with the neck axis (P1) and where it passes the intercondylar notch (P2).
% The +x axis points laterally and is oriented parallel to the proximal 
% contour of the condyles. The +y axis points in the anterior direction
% [Bergmann 2016]."
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

% The straight femur axis is defined by the points P1 and P2 [Bergmann2016]
% P1 is the point on the neck axis closest to the shaft axis
% P2 is the intercondylar notch
StraightFemurAxis = createLine3d(P2, P1);
% Connection of the most posterior points of the condyles
PosteriorCondyleAxis = createLine3d(MPC, LPC);
% 'RAS' orientation is used by the OrthoLoad femoral coordinate system
% Z -> [S]uperior
Z = normalizeVector3d(StraightFemurAxis(4:6));
% Y -> [A]nterior
Y = normalizeVector3d(crossProduct3d(StraightFemurAxis(4:6), PosteriorCondyleAxis(4:6)));
% X -> [R]ight
X = normalizeVector3d(crossProduct3d(Y, Z));

% Create transformation
TFM = [[X;Y;Z],[0 0 0]'; [0 0 0 1]] * createTranslation3d(-HJC);
switch side
    case 'L'
        TFM = createRotationOz(pi)*TFM;
    case 'R'
    otherwise
        error('Invalid side identifier!')
end

end