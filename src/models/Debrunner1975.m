function funcHandles = Debrunner1975
%DEBRUNNER1975 The Debrunner model from 1975
%
% Reference:
% [Debrunner 1975] 1975 - Debrunner - Studien zur Biomechanik des
%   Hüftgelenkes I
% https://www.docdroid.net/nSjKceC
%
% AUTHOR: B. Eggert
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

funcHandles.Posture     = @Posture;
funcHandles.Position    = @Position;
funcHandles.Muscles     = @Muscles;
funcHandles.Calculation = @Calculation;

end

%% Postures for validation
function [postures, default] = Posture()

default = 1;
postures = {...
    'OneLeggedStance' 'OLS';
    'LevelWalking' 'LW';
    };

end

%% Calculate the joint angles for positioning of the TLEM2
function jointAngles = Position(data)

% Inputs

% Calculate the joint angles
jointAngles = {[0 0 data.S.PelvicTilt], [0 0 0], 0, 0, 0, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(~)
% User is allowed to edit the default values
enable = 'off';

% Default muscles/fascicles of the model.
% Debrunner did not specify the abductor muscles.
activeMuscles = {};

end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
g   = data.g;
LE  = data.S.LE;
KG  = data.S.BodyWeight;
HJW = data.S.Scale(1).HipJointWidth;
HJC = data.S.LE(1).Joints.Hip.Pos;

try
    GreaterTrochanter = LE(2).Mesh.vertices(LE(2).Landmarks.GreaterTrochanter.Node,:);
    AcetabularRoof    = LE(1).Mesh.vertices(LE(1).Landmarks.RightAcetabularRoof.Node,:);
    MostCranial       = LE(1).Mesh.vertices(LE(1).Landmarks.RightSuperiorIliacCrest.Node,:);
    MostMedial        = LE(1).Mesh.vertices(LE(1).Landmarks.RightMedialIlium.Node,:);
    MostLateral       = LE(1).Mesh.vertices(LE(1).Landmarks.RightIliacTubercle.Node,:);
catch
    errMessage = [...
        'At least one landmark for this model is missing. '...
        'Choose a different cadaver to use this model!'];
    msgbox(errMessage,mfilename,'error')
    error(errMessage)
end

%% Define Parameters

d6 = HJW/2; % Half distance between the hip joint centers [Debrunner 1975, Abb.5]
d5 = 1.28 * d6; % Moment arm of G5 about the hip joint center [Debrunner 1975, Eq.4]
G5 = g * 5/6 * KG; % Magnitude of the partial body weight [Debrunner 1975, Eq.3]
Z = [0, HJC(2:3)]; % Hip joint center in the frontal plane
% Width of the iliac bone along the Z-axis [Debrunner 1975, Abb.3]
bD = MostLateral(3) - MostMedial(3);
% Height of the iliac bone along the Y-axis [Debrunner 1975, Abb.3]
hD = MostCranial(2) - AcetabularRoof(2);
% Origin point of the force of the abductor muscles [Debrunner 1975, Abb.3]
A = [0, AcetabularRoof(2) + 2/3 * hD, MostLateral(3) - 2/5 * bD];
% Use the greater trochanter in the frontal plane as insertion point of
% the force of the abductor muscles [Debrunner 1975, Abb.2]
T = [0, GreaterTrochanter(2:3)];

% The moment arm of the abductors h is defined as the projection of the hip
% joint center Z on the vector connecting A and T. [Debrunner 1975, Abb.10]
h = distancePoints3d(Z, projPointOnLine3d(Z, createLine3d(A, T)));

% Unit vector of the muscle force of the abductors
M_Dir = - normalizeVector3d(T - A);
% Symbolic magnitude of the muscle force of the abductors
syms M_Mag
% Muscle force of the abductors
M = M_Dir * M_Mag;

% Moment equilibrium about the hip joint center [Debrunner 1975, Eq.1]
eqMoment = [h * M_Mag, 0, 0] - crossProduct3d([0 0 -d5], [0, G5, 0]) ;

% Symbolic resulting hip joint force
syms Rx Ry Rz
% Force equilibrium  [Debrunner 1975, Eq.2]
eqForce = [0, G5, 0] + M + [Rx Ry Rz];

% Solve the system of equations
Results = solve([eqMoment(:); eqForce(:)]);

% Magnitude of the muscle force of the abductors
M_mag = double(Results.M_Mag);
if M_mag < 0 && data.Verbose
    warning(['Unphysiological / negative value of the muscle force M (' num2str(M_mag,1) ')!'])
end

% Resulting hip joint force pointing to the pelvis
R = - [double(Results.Rx) double(Results.Ry) double(Results.Rz)];

data = convertGlobalHJF2LocalHJF(R, data);

end