function funcHandles = Iglic2021
% A Iglic based model with adapted muscle grouping to be compatible with
% other cadaver templates. See below for further information.
%
% Reference:
% [Iglic 1990] 1990 - Iglic - Mathematical Analysis of Chiari Osteotomy
% http://physics.fe.uni-lj.si/publications/pdf/acta1990.PDF
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
    'OneLeggedStance', 'OLS';
    'LevelWalking', 'LW';
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

% The division of the muscles/fascicles into muscle groups [Iglic 1990, p.37]
% is not compatible with the every cadaver template, e.g. GluteusMediusMid1
% is not available in TLEM2. The division into the groups fa, ft, fp was
% altered compared to [Iglic 1990, S.37, Table 1]. However, the results for
% fa, ft and fp can be unphysiological (negative) depending on the cadaver
% template. See the warning in the command window.
activeMuscles = {...
    'GluteusMediusAnterior1',   'ft';
    'GluteusMediusAnterior2',   'ft';
    'GluteusMediusAnterior3',   'fa';
    'GluteusMediusAnterior4',   'fa';
    'GluteusMediusAnterior5',   'fa';
    'GluteusMediusAnterior6',   'fa';
    'GluteusMinimusAnterior1',  'fa';
    'GluteusMinimusAnterior2',  'fa';
    'TensorFasciaeLatae1',      'fa';
    'TensorFasciaeLatae2',      'fa';
    'RectusFemoris1',           'fa';
    'RectusFemoris2',           'fa';
    
    'GluteusMinimusMid1',       'ft';
    'GluteusMinimusMid2',       'ft';
    % 'GluteusMediusMid1'         'ft';
    
    'GluteusMediusPosterior1',  'fp';
    'GluteusMediusPosterior2',  'ft';
    'GluteusMediusPosterior3',  'fp';
    'GluteusMediusPosterior4',  'ft';
    'GluteusMediusPosterior5',  'fp';
    'GluteusMediusPosterior6',  'fp';
    'GluteusMinimusPosterior1', 'fp';
    'GluteusMinimusPosterior2', 'fp';
    'Piriformis1',              'fp';
    };
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
g               = data.g;
BW              = data.S.BodyWeight;
hipJointWidth   = data.S.Scale(1).HipJointWidth;
MuscleList      = data.MuscleList;
activeMuscles   = data.activeMuscles;
MusclePathModel = data.MusclePathModel;
MusclePaths     = data.S.MusclePaths;

%% Define Parameters

% Subject-specific values
l = hipJointWidth/2;               % Half distance between the two hip joint centers
WB = -g * BW;                      % Total body weight
% Generic values
WL = 0.161 * WB;                   % Weight of the supporting limb
W = [0, WB - WL, 0];               % Partial body weight (WB - WL)
b = 0.48 * l;                      % Mediolateral moment arm of the WL [Iglic 1990, S.37, Equ.7]
c = 1.01 * l;                      % Mediolateral moment arm of the ground reaction force WB  [Iglic 1990, S.37, Equ.7]
a = (WB * c - WL * b) / (WB - WL); % Mediolateral moment arm of (WB - WL) [Iglic 1990, S.37, Equ.6]
d = 0;                             % Posteroanterior moment arm of (WB - WL) [Iglic 1990, S.37]
lW = [d 0 -a];                     % Moment arm of the partial body weight W

% Number of active muscles
NoAM = length(MusclePaths);

% Moment arms of the muscles
r = nan(NoAM,3);
% Unit vectors s in the direction of the muscles [Iglic 1990, S.37, Equ.3]
s = nan(NoAM,3);
for i = 1:NoAM
    r(i,:) = MusclePaths(i).(MusclePathModel)(1:3);
    s(i,:) = MusclePaths(i).(MusclePathModel)(4:6);
end

A = zeros(NoAM,1);
% Get physiological cross-sectional areas
for m = 1:NoAM
    % Physiological cross-sectional areas of each fascicle
    A_Idx = strcmp(MusclePaths(m).Name(1:end-1), MuscleList(:,1));
    A(m) = MuscleList{A_Idx,5} / MuscleList{A_Idx,4};
end

% Symbolic resulting hip joint force
syms Rx Ry Rz
% Symbolic avarage muscle tension
f = cell2sym(activeMuscles(:,2));
% The assumption 'f >= 0' should be included, but then the solver might not find a solution
assume(f >= 0); assume(f,'clear')
F = f .* A .* s; % [Iglic 1990, S.37, Equ.2]

% Moment of F about the hip joint center
momentF = cross(r, F);

% Moment of 'WB - WL' about the hip joint center
momentW = cross(lW, W);

% Force equilibrium
eq1 =  sum(F(:,1)) + Rx + W(1); % [Iglic 1990, S.37, Equ.4]
eq2 =  sum(F(:,2)) + Ry + W(2); % [Iglic 1990, S.37, Equ.4]
eq3 =  sum(F(:,3)) + Rz + W(3); % [Iglic 1990, S.37, Equ.4]
% Moment equilibrium
eq4 = sum(momentF(:,1)) + momentW(1); % [Iglic 1990, S.37, Equ.5]
eq5 = sum(momentF(:,2)) + momentW(2); % [Iglic 1990, S.37, Equ.5]
eq6 = sum(momentF(:,3)) + momentW(3); % [Iglic 1990, S.37, Equ.5]

% Solve the system of equations
Results = solve(eq1, eq2, eq3, eq4, eq5, eq6);

fa = double(Results.fa); ft = double(Results.ft); fp = double(Results.fp);
if (fa < 0 || ft < 0 || fp < 0) && data.Verbose
    warning(['Unphysiological / negative value of fa (' num2str(fa,1) '), ' ...
        'ft (' num2str(ft,1) ') or fp (' num2str(fp,1) ')!'])
end

% Resulting hip joint force pointing to the pelvis
R = [double(Results.Rx) double(Results.Ry) double(Results.Rz)];

data = convertGlobalHJF2LocalHJF(R, data);

end