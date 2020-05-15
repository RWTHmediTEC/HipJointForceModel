function funcHandles = Pauwels
% The model by Pauwels with patient-specific adaption using the TLEM2 
% cadaver data instead of Fick's cadaver data and the data of Braune and 
% Fischer
% 
% References:
%   [Pauwels 1965] 1965 - Pauwels - Gesammelte Abhandlungen zur 
%   funktionellen Anatomie des Bewegungsapparates - Der Schenkelhalsbruch
%   [Braune 1895] 1985 - Braune - Der Gang des Menschen - I. Theil
%   [Fischer 1898] 1898 - Fischer - Der Gang des Menschen - II. Theil
% or
%   [Braune 1987] 1987 - Braune - The Human Gait

funcHandles.Posture     = @Posture;
funcHandles.Position    = @Position;
funcHandles.Muscles     = @Muscles;
funcHandles.Calculation = @Calculation;

end

%% Postures for validation
function [postures, default] = Posture()

default = 1;
postures = {'OneLeggedStance' 'OLS';
            'LevelWalking' 'LW'};

end

%% Calculate the joint angles for positioning of the TLEM2
function jointAngles = Position(~)

jointAngles = {[0 0 0], [0 0 0], 0, 0, 0, 0};

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
S               = data.S.BodyWeight;
MuscleList      = data.MuscleList;
MusclePathModel = data.MusclePathModel;
MusclePaths     = data.S.MusclePaths;
HJC             = data.S.LE(1).Joints.Hip.Pos;
HJW             = data.S.Scale(1).HipJointWidth;
Side            = data.S.Side;

%% Define parameters
G = -data.g; % Weight force

% Partial body weight and its lever arm in percent of the full body weight
% and the hip joint width
[relPartialBW, ratioLeverArm2HJW] = derivationFromBrauneAndFischer189X();
S5=S*relPartialBW;
a=HJW*ratioLeverArm2HJW;

% Moment arm of the muscle force M
% Angle between the muscle force M and the vertical in the frontal plane
[BO, alphaM] = combineMuscleForces(MusclePaths, MusclePathModel, MuscleList, HJC);

syms M % Magnitude of the muscle force
% Calculation of the muscle force
eq1 = S5 * G * a + M * BO; % Moment equilibrium around hip joint center

syms RxSym RySym RzSym
% Calculation of the hip joint force
eq2 = RxSym;                             % Force equilibrium in the direction of X
eq3 = RySym + S5 * G - M * cosd(alphaM); % Force equilibrium in the direction of Y
switch Side
    case 'L'
        eq4 = RzSym - M * sind(alphaM); % Force equilibrium in the direction of Z
    case 'R'
        eq4 = RzSym + M * sind(alphaM); % Force equilibrium in the direction of Z
end

Results = solve(eq1, eq2, eq3, eq4);

rX = double(Results.RxSym);
rY = double(Results.RySym);
rZ = double(Results.RzSym);

data = convertGlobalHJF2LocalHJF([rX rY rZ], data);

end

function [relPartialBW, leverArm2HJW] = derivationFromBrauneAndFischer189X()
% Derivation of the lever arm of the body weight during stance phase.
% Step 16, Experiment 1, Braune and Fischer
[S, HJW, G1, G2, g1_16, g2_L_16, hjc_R_16] = BrauneAndFischer189X();

% Derivation 
S5 = S*(G1+G2);
relPartialBW=S5/S;
s5 = (g1_16*G1+g2_L_16*G2)/(G1+G2); % [Pauwels 1965, S.101]

% Lever arms of S5 projected into the anatomical planes
a = hjc_R_16(2)-s5(2); % Frontal plane [Pauwels 1965, S.103]
% Ratio between the lever arm in the frontal plane and the hip joint width
leverArm2HJW=a*10/HJW;
end

function [R_FP_MA, R_FP_Angle] = combineMuscleForces(MusclePaths, MusclePathModel, MuscleList, HJC)
% Combination of muscle forces in the frontal plane into one resulting
% muscle force as desribed by Pauwels [Pauwels 1965, S.111] 

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
muscleForces = [LoA_Origins(:,2:3) LoA_Vectors(:,2:3).*PCSAs];
% Calculate the resulting muscle force in the frontal plane
while size(muscleForces,1)>1
    muscleForces(end-1,:) = resultingOf2Forces2d(muscleForces(end-1,:), muscleForces(end,:));
    muscleForces(end,:)=[];
end

% R (resulting line of action)
% Moment arm of R
R_FP_MA  = distancePoints(HJC(2:3), projPointOnLine(HJC(2:3),muscleForces));
% Angle to vertical
R_FP_Angle = rad2deg(lineAngle(muscleForces,[0 0 -1 0]));
if R_FP_Angle>90; R_FP_Angle=360-R_FP_Angle; end

end

function r = resultingOf2Forces2d(f1, f2)
% Calculate resulting force (r) of two forces (f1, f2) in 2D
% Intersection point of the lines of action
f1_f2_Its = intersectLines(f1, f2);
% Resulting force
r = [f1_f2_Its f1(3:4)+f2(3:4)];

end