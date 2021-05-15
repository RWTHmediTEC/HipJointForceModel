function funcHandles = mediTEC2021
% Based on the Iglic.m model but using all muscles connected to the pelvis.

% AUTHOR: F. Schimmelpfennig
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
l = data.S.Scale(1).HipJointWidth/2;
x0 = data.S.Scale(2).FemoralLength; % Femoral length

phi = 0.5; % Pelvic bend [°]: rotation around the posteroanterior axis

% Calculate the joint angles
b = 0.48 * l;
ny = asind(b/x0); % Femoral adduction: rotation around the posteroanterior axis [Iglic 1990, S.37, Equ.8]
jointAngles = {[phi 0 data.S.PelvicTilt], [ny 0 0], 0, 0, -ny, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(~)
% User is allowed to edit the default values
enable = 'off';

% Default fascicles of the model
activeMuscles = {...
    'AdductorBrevis';...
    'AdductorLongus';...
    'AdductorMagnus';...
    'BicepsFemoris';...
    'Gemellus';...
    'GluteusMaximus';...
    'GluteusMedius';...
    'GluteusMinimus';...
    'Gracilis';...
    'Iliacus';...
    'Iliopsoas';...
    'Obturator';...
    'Pectineus';...
    'Piriformis';...
    'PsoasMajor';...
    'QuadratusFemoris';...
    'RectusFemoris';...
    'Sartorius';...
    'Semimembranosus';...
    'Semitendinosus';...
    'TensorFasciaeLatae';...
    };
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
g               = data.g;
BW              = data.S.BodyWeight;
hipJointWidth   = data.S.Scale(1).HipJointWidth;
muscleList      = data.MuscleList;
musclePathModel = data.MusclePathModel;
musclePaths     = data.S.MusclePaths;
MRC             = data.MuscleRecruitmentCriterion;

%% Define Parameters

% Subject-specific values
l = hipJointWidth/2;               % Half distance between the two hip joint centers
WB = -g * BW;                      % Total body weight [N]
% Generic values
WL = 0.161 * WB;                   % Weight of the supporting limb
W = [0, WB - WL, 0];               % Partial body weight (WB - WL)
b = 0.48 * l;                      % Mediolateral moment arm of the WL [Iglic 1990, S.37, Equ.7]
c = 1.01 * l;                      % Mediolateral moment arm of the ground reaction force WB  [Iglic 1990, S.37, Equ.7]
a = (WB * c - WL * b) / (WB - WL); % Mediolateral moment arm of  (WB - WL) [Iglic 1990, S.37, Equ.6]
d = 0;                             % Posteroanterior moment arm of (WB - WL) [Iglic 1990, S.37]
lW = [d 0 -a];                     % Moment arm of the partial body weight W

% Number of active muscles
NoAM = length(musclePaths);

% Get muscle origin points
r=nan(NoAM,3);
% Unit vectors s in the direction of the muscles [Iglic 1990, S.37, Equ.3]
s=nan(NoAM,3);

for i = 1:NoAM
    r(i,:) = musclePaths(i).(musclePathModel)(1:3);
    s(i,:) = musclePaths(i).(musclePathModel)(4:6);
end

PCSA = zeros(NoAM,1);
% Get physiological cross-sectional areas and masses
for m = 1:NoAM
    % Physiological cross-sectional areas of each fascicle
    A_Idx = strcmp(musclePaths(m).Name(1:end-1), muscleList(:,1));
    PCSA(m) = muscleList{A_Idx,5} / muscleList{A_Idx,4};
end

syms Rx Ry Rz

switch MRC
    case 'None'
        errMessage = 'Please select a muscle recruitment criterion!';
        msgbox(errMessage,mfilename,'error')
        error(errMessage)
    case {'Polynom1','Polynom2','Polynom3','Polynom5','MinMax','Energy'}
        [F, data] = muscleRecruitment(lW, W, r, s, PCSA, data);
        % Calculate hip joint reaction force R
        eq1 =  sum(F(1,:)) + Rx + W(1);
        eq2 =  sum(F(2,:)) + Ry + W(2);
        eq3 =  sum(F(3,:)) + Rz + W(3);
        
        Results = solve(eq1, eq2, eq3);
        
        % Resulting hip joint force pointing to the pelvis
        R = [double(Results.Rx) double(Results.Ry) double(Results.Rz)];
        
        data = convertGlobalHJF2LocalHJF(R, data);
end

end