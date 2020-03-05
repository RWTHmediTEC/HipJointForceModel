function funcHandles = IglicTLEM2
% The model of [Iglic 1990] using the TLEM2 cadaver data instead of
% Dostal's cadaver data. Some adaptions were necessary to solve the model
% that questions the validity of the [Iglic 1990] model. See below for 
% further information.

funcHandles.Posture     = @Posture;
funcHandles.Position    = @Position;
funcHandles.Muscles     = @Muscles;
funcHandles.Calculation = @Calculation;

end

%% Postures for validation
function [postures, default] = Posture()

default = 1;
postures = {'OneLeggedStance', 'OLS'; 'LevelWalking', 'LW'};

end

%% Calculate the joint angles for positioning of the TLEM2
function jointAngles = Position(data)

% Inputs
l = data.S.Scale(1).HipJointWidth/2;
x0 = data.S.Scale(2).FemoralLength; % Femoral length
phi = 0.5; % Pelvic bend [°]: rotation around the posterior-anterior axis

% Calculate the joint angles
b = 0.48 * l;
ny = asind(b/x0); % Femoral adduction: rotation around the posterior-anterior axis [Iglic 1990, S.37, Equ.8]
jointAngles = {[phi 0 0], [ny 0 0], 0, 0, -ny, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(~)
% User is allowed to edit the default values
enable = 'off';

% The division of the muscles in [Iglic 1990, S.37] is not compatible with
% the TLEM2. GluteusMediusMid1 is not available in TLEM2.
% The classification of the muscles into the groups fa, ft, fp was altered
% compared to [Iglic 1990, S.37, Table 1]. However, the results for fa, ft 
% and , fp are unphysiological / negative. See the warning in the command 
% window.
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
    
    'GluteusMediusPosterior1',  'fp';
    'GluteusMediusPosterior2',  'ft';
    'GluteusMediusPosterior3',  'fp';
    'GluteusMediusPosterior4',  'ft';
    'GluteusMediusPosterior5',  'fp';
    'GluteusMediusPosterior6',  'fp';
    'GluteusMinimusPosterior1', 'fp';
    'GluteusMinimusPosterior2', 'fp';
    'Piriformis1',              'fp'};

end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
BW              = data.S.BodyWeight;
hipJointWidth   = data.S.Scale(1).HipJointWidth;
MuscleList      = data.MuscleList;
activeMuscles   = data.activeMuscles;
MusclePathModel = data.MusclePathModel;
MusclePaths     = data.S.MusclePaths;
side            = data.S.Side;

%% Define Parameters
G = -9.81;                         % weight force

% Subject-specific values
l = hipJointWidth/2;               % Half the distance between the two hip rotation centers
WB = BW * G;                       % total body weight
% Generic values
WL = 0.161 * WB;                   % weight of the supporting limb
W = [0, WB - WL, 0];               % 'WB - WL'
b = 0.48 * l;                      % medio-lateral moment arm of the WL [Iglic 1990, S.37, Equ.7]
c = 1.01 * l;                      % medio-lateral moment arm of the ground reaction force WB  [Iglic 1990, S.37, Equ.7]
a = (WB * c - WL * b) / (WB - WL); % medio-lateral moment arm of 'WB - WL' [Iglic 1990, S.37, Equ.6]
d = 0;                             % !QUESTIONABLE! antero-posterior moment arm of 'WB - WL' [Iglic 1990, S.37]

% Create matrices for muscle origin points r, muscle insertion points r'
% and relative physiological cross-sectional areas A

% Number of active muscles
NoAM = length(MusclePaths);

% Get muscle origin points
r=nan(NoAM,3);
% Unit vectors s in the direction of the muscles [Iglic 1990, S.37, Equ.3]
s=nan(NoAM,3);
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

% [Iglic 1990, S.37, Equ.2]
f = cell2sym(activeMuscles(:,2));
% The assumption 'f >= 0' should be included, but then the solver will not find a solution
assume(f >= 0)
assume(f,'clear')
F = f .* A .* s;

% Moment of F around hip rotation center
momentF = cross(r, F);

if side == 'L'
    momentW = cross([d 0  a], W); % Moment of 'WB - WL' around hip rotation center
else
    momentW = cross([d 0 -a], W); % Moment of 'WB - WL' around hip rotation center
end

% Calculate hip joint reaction force R
syms RxSym RySym RzSym

eq1 =  sum(F(:,1)) + RxSym + W(1); % [Iglic 1990, S.37, Equ.4]
eq2 =  sum(F(:,2)) + RySym + W(2); % [Iglic 1990, S.37, Equ.4]
eq3 =  sum(F(:,3)) + RzSym + W(3); % [Iglic 1990, S.37, Equ.4]

eq4 = sum(momentF(:,1)) + momentW(1); % [Iglic 1990, S.37, Equ.5]
eq5 = sum(momentF(:,2)) + momentW(2); % [Iglic 1990, S.37, Equ.5]
eq6 = sum(momentF(:,3)) + momentW(3); % [Iglic 1990, S.37, Equ.5]

R = solve(eq1, eq2, eq3, eq4, eq5, eq6);

rX = double(R.RxSym);
rY = double(R.RySym);
rZ = double(R.RzSym);
fa = double(R.fa);
ft = double(R.ft);
fp = double(R.fp);
if fa < 0 || ft < 0 || fp < 0
    warning(['Unphysiolocial / negative value of fa (' num2str(fa,1) '), ' ...
        'ft (' num2str(ft,1) ') or fp (' num2str(fp,1) ')!'])
end

data = convertGlobalHJF2LocalHJF([rX rY rZ], data);

end