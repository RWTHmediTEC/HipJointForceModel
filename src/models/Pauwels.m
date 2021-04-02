function funcHandles = Pauwels
% A Pauwels based model with subject-specific adaption using the the data
% of Braune and Fischer
%
% References:
% [Pauwels 1965] 1965 - Pauwels - Gesammelte Abhandlungen zur funktionellen 
%   Anatomie des Bewegungsapparates - Der Schenkelhalsbruch
%   https://doi.org/10.1007/978-3-642-86841-2_1
% or
% [Pauwels 1980] 1980 - Pauwels - Biomechanics of the Locomotor Apparatus -
%   The Fracture of the Femoral Neck. A Mechanical Problem
%   https://doi.org/10.1007/978-3-642-67138-8_1
% [Braune 1895] 1985 - Braune - Der Gang des Menschen - I. Theil
% [Fischer 1898] 1898 - Fischer - Der Gang des Menschen - II. Theil
% or
% [Braune 1987] 1987 - Braune - The Human Gait
%   https://doi.org/10.1007/978-3-642-70326-3
%
% AUTHOR: M.C.M. Fischer
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

jointAngles = {[0 0 data.S.PelvicTilt], [0 0 0], 0, 0, 0, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(~)
% User is allowed to edit the default values
enable = 'on';

% Default fascicles of the model
activeMuscles = {...
    'GluteusMedius';
    'GluteusMinimus';
    'TensorFasciaeLatae';
    'RectusFemoris';
    'GluteusMinimus';
    'Piriformis'
    'Sartorius'};

end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
g               = data.g;
S               = data.S.BodyWeight;
MuscleList      = data.MuscleList;
MusclePathModel = data.MusclePathModel;
MusclePaths     = data.S.MusclePaths;
HJC             = data.S.LE(1).Joints.Hip.Pos;
HJW             = data.S.Scale(1).HipJointWidth;
if isnan(HJW)
    error('Please specifiy the hip joint width (HJW)!')
end

%% Define parameters

% Partial body weight and its moment arm in relation to the body weight and
% the hip joint width
[ratio_S52S, ratio_a2HJW] = derivationFromBrauneAndFischer189X();
S5 = ratio_S52S * S;
% Force of the partial body weight
K = -g * S5;
% Moment arm of the partial body weight about the hip joint center
a = ratio_a2HJW*HJW;

% Line of action of the muscle force of the abductors in the frontal plane
M_LoA = combineMuscleForces(MusclePaths, MusclePathModel, MuscleList);

% Unit vector of the muscle force of the abductors
M_Dir = normalizeVector3d(M_LoA(4:6));
% Moment arm of the muscle force of the abductors
BO = distancePoints3d(HJC, projPointOnLine3d(HJC, M_LoA));

% Symbolic magnitude of the muscle force of the abductors
syms M_Mag
% Moment equilibrium about the hip joint center
eqMoment = K * a + M_Mag * BO;

% Symbolic resulting hip joint force
syms Rx Ry Rz
% Force equilibrium
eqForce = M_Dir*M_Mag + [Rx Ry Rz] + [0 K 0];

% Solve the system of equations
Results = solve([eqMoment(:); eqForce(:)]);

% Resulting hip joint force pointing to the pelvis
R = [double(Results.Rx) double(Results.Ry) double(Results.Rz)];

data = convertGlobalHJF2LocalHJF(R, data);

end

function [ratio_S52S, ratio_a2HJW, a] = derivationFromBrauneAndFischer189X()
% Derivation of the lever arm of the body weight during stance phase.
% Step 16, Experiment 1, Braune and Fischer
[S, HJW, G1, G2, g1_16, g2_L_16, hjc_R_16] = BrauneAndFischer189X();

% Partial body weight
S5 = S*(G1+G2);
% Ratio between the partial body weight and the body weight
ratio_S52S = S5/S;
s5 = (g1_16*G1+g2_L_16*G2)/(G1+G2); % [Pauwels 1965, p.101; Pauwels 1980, p.80]

% Moment arm of S5 projected to the anatomical planes
a = hjc_R_16(2) - s5(2); % Frontal plane [Pauwels 1965, p.103; Pauwels 1980, p.82]
% Ratio between the moment arm in the frontal plane and the hip joint width
ratio_a2HJW = a/HJW;
end

function M_FP = combineMuscleForces(MusclePaths, MusclePathModel, MuscleList)
% Combination of muscle forces in the frontal plane (FP) into one resulting
% muscle force as desribed by Pauwels [Pauwels 1965, p.111; Pauwels 1980, p.85]

% Number of active muscles
NoAM = length(MusclePaths);

PCSAs = zeros(NoAM,1);
% Get physiological cross-sectional areas (PCSA)
for m = 1:NoAM
    % Physiological cross-sectional areas of each fascicle
    tempIdx = strcmp(MusclePaths(m).Name(1:end-1), MuscleList(:,1));
    PCSAs(m) = MuscleList{tempIdx,5} / MuscleList{tempIdx,4};
end

% Lines of action (LoA)
LoA_Origins = zeros(length(MusclePaths),3);
LoA_Vectors = zeros(length(MusclePaths),3);
for i = 1:NoAM
    LoA_Origins(i,:) = MusclePaths(i).(MusclePathModel)(1:3);
    LoA_Vectors(i,:) = MusclePaths(i).(MusclePathModel)(4:6);
end

% Multiplicate the muscle unit vectors with the PCSAs and project them on
% the frontal plane
M_FP = [LoA_Origins(:,2:3) LoA_Vectors(:,2:3).*PCSAs];
% Calculate the resulting muscle force in the frontal plane
while size(M_FP,1)>1
    M_FP(end-1,:) = resultingOf2Forces2d(M_FP(end-1,:), M_FP(end,:));
    M_FP(end,:)=[];
end

% Back to 3D
M_FP = [0 M_FP(1:2) 0 M_FP(3:4)];

end

function r = resultingOf2Forces2d(f1, f2)
% Calculate resulting force (r) of two forces (f1, f2) in 2D
% Intersection point of the lines of action
f1_f2_Its = intersectLines(f1, f2);
% Resulting force
r = [f1_f2_Its f1(3:4)+f2(3:4)];

end