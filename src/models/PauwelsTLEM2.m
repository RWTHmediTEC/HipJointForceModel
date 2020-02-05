function funcHandles = PauwelsTLEM2
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

% Inputs

% Calculate the joint angles
jointAngles = {[0 0 0], [0 0 0], 0, 0, 0, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(gui)
% User is allowed to edit the default values
enable = 'off';

% Default fascicles of the model
activeMuscles = {...
    'GluteusMediusAnterior1';
    'GluteusMediusAnterior2';
    'GluteusMediusAnterior3';
    'GluteusMediusAnterior4';
    'GluteusMediusAnterior5';
    'GluteusMediusAnterior6';
    'GluteusMediusPosterior1';
    'GluteusMediusPosterior2';
    'GluteusMediusPosterior3';
    'GluteusMediusPosterior4';
    'GluteusMediusPosterior5';
    'GluteusMediusPosterior6';
    'GluteusMinimusAnterior1';
    'GluteusMinimusAnterior2';
    'TensorFasciaeLatae1';
    'TensorFasciaeLatae2';
    'RectusFemoris1';
    'RectusFemoris2';
    'GluteusMinimusMid1';
    'GluteusMinimusMid2';
    'GluteusMinimusPosterior1';
    'GluteusMinimusPosterior2';
    'Piriformis1'
    'Sartorius1'};

% Disable muscle path models which are not supported
set(gui.Home.Settings.RadioButton_ViaPoint, 'enable', 'on');
set(gui.Home.Settings.RadioButton_ObstacleSet, 'enable', 'off');
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
LE            = data.S.LE;
muscleList    = data.MuscleList;
S             = data.S.BodyWeight;
activeMuscles = data.activeMuscles;
musclePath    = data.MusclePath;
HJC           = data.S.LE(1).Joints.Hip.Pos;
HJW           = data.S.Scale(1).HipJointWidth;
Side          = data.S.Side;
View          = data.View;

%% Define parameters
G = -9.81; % Weight force

% Partial body weight and its lever arm in percent of the full body weight
% and the hip joint width
[relPartialBW, ratioLeverArm2HJW] = derivationFromBrauneAndFischer189X();
S5=S*relPartialBW;
a=HJW*ratioLeverArm2HJW;

% Moment arm of the muscle force M
% Angle between the muscle force M and the vertical in the frontal plane
[BO, alphaM] = combineMuscleForces(LE, muscleList, musclePath, HJC, activeMuscles);

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

rMag = norm([rX rY rZ]);              % Magnitude of R
rMagP = rMag / abs(S*G) * 100;        % Magnitude of R in percentage body weight
rDir = normalizeVector3d([rX rY rZ]); % Direction of R

if Side == 'L'
    rZ = -1 * rZ;
end

% Rotation matrices for local pelvic CS
TFMx = createRotationOx(0);
TFMy = createRotationOy(0);
TFMz = createRotationOz(0);

if strcmp(View, 'Femur') == 1
    rDir = -1 * rDir;
    
    % Rotation matrices for local femur CS
    TFMx = createRotationOx();
    TFMy = createRotationOy();
    TFMz = createRotationOz();
end

[rX, rY, rZ] = transformPoint3d(rX, rY, rZ, TFMx*TFMy*TFMz);

rPhi   = atand(rZ / rY); % Angle in frontal plane
rTheta = atand(rX / rY); % Angle in sagittal plane
rAlpha = atand(rX / rZ); % Angle in horizontal plane

% Save results in data
data.rX     = rX;
data.rY     = rY;
data.rZ     = rZ;
data.rDir   = rDir;
data.rMag   = rMag;
data.rMagP  = rMagP;
data.rPhi   = rPhi;
data.rTheta = rTheta;
data.rAlpha = rAlpha;

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

function [R_FP_MA, R_FP_Angle] = combineMuscleForces(LE, muscleList, musclePath, HJC, activeMuscles)
% Combination of muscle forces in the frontal plane into one resulting
% muscle force as desribed by Pauwels [Pauwels 1965, S.111] 

% Number of active muscles
NoAM = size(activeMuscles,1);

% Get muscle origin points and muscle insertion points
via(NoAM,1) = false;
[origins, insertions] = deal(zeros(NoAM,3));
for m = 1:NoAM
    for n = 1:length(LE)
        if ~isempty(LE(n).Muscle)
            muscles = fieldnames(LE(n).Muscle);
            if any(strcmp(muscles,activeMuscles(m,1)))
                for t = 1:length(LE(n).Muscle.(activeMuscles{m,1}).Type)
                    if strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Origin')
                        origins(m,:) = LE(n).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    elseif strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Via')
                        if strcmp(musclePath, 'ViaPoint')
                            via(m) = true;
                        else
                            continue;
                        end
                    elseif strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Insertion')
                        insertions(m,:) = LE(n).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    end
                end
            end
        end
    end
end

PCSAs = zeros(NoAM,1);
% Get physiological cross-sectional areas (PCSA)
for m = 1:NoAM
    % Physiological cross-sectional areas of each fascicle
    tempIdx = strcmp(activeMuscles{m}(1:end-1), muscleList(:,1));
    PCSAs(m) = muscleList{tempIdx,5} / muscleList{tempIdx,4};
end

% Unit vectors in the directions of the muscles
for m = 1:NoAM
    if via(m)
        % Find most distal via point of pelvis
        [~, idxPelvis] = min(LE(1).Muscle.(activeMuscles{m,1}).Pos(:,2));
        origins(m,:) = LE(1).Muscle.(activeMuscles{m,1}).Pos(idxPelvis,:);
        % Find most proximal via point of femur
        [~, idxFemur] = max(LE(2).Muscle.(activeMuscles{m,1}).Pos(:,2));
        insertions(m,:) = LE(2).Muscle.(activeMuscles{m,1}).Pos(idxFemur,:);
    end
end
muscleVectors = normalizeVector3d(insertions - origins);

% Multiplicate the muscle unit vectors with the PCSAs and project them on
% the frontal plane
muscleForces = [origins(:,2:3) muscleVectors(:,2:3).*PCSAs];
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

