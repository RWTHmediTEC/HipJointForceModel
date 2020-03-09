function funcHandles = Sedghi2017
% Based on the model of [Iglic 1990] using the cadaver data of 
% [Dostal 1981].  A patient-specific femoral and pelvic scaling was
% included. PCSAs were changed without further explanation. 

% References:
% [Iglic 1990] 1990 - Iglic - Mathematical analysis of Chiari Osteotomy
% [Johnston 1979] 1979 - Johnston - Reconstruction of the Hip
% [McLeish 1970] 1970 - McLeish - Abduction forces in the one-legged stance
% [Dostal 1981] 1981 - Dostal A three-dimensional biomechanical model of hip musculature
% [Winter 2009] 2009 - Winter - Biomechanics and Motor Control of Human Movement - Fourth Edition

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

% Only used for visualization
[~, Scale] = Dostal1981();
l_ref = 1/2 * Scale(1).HipJointWidth;
x0 = Scale(2).FemoralLength;
phi = 0.5;

% Calculate the joint angles
b = 0.48 * l_ref;
ny = asind(b/x0);
jointAngles = {[phi 0 0], [ny 0 0], 0, 0, -ny, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(~)
% User is not allowed to edit the default values
enable = 'off';

% Without further explanation, [Sedghi 2017] changed the PCSAs compared to 
% [Iglic 1990, S.37, Tab.1] and excluded the Piriformis muscle.
activeMuscles = {...
    'GluteusMediusAnterior1',   'fa', 3*0.2;...
    'GluteusMinimusAnterior1',  'fa', 3*0.2;...
    'TensorFasciaeLatae1',      'fa', 1;...
    'RectusFemoris1',           'fa', 1;...
    
    'GluteusMediusMid1',        'ft', 3*0.6;... 
    'GluteusMinimusMid1',       'ft', 3*0.6;...
    
    'GluteusMediusPosterior1',  'fp', 3*0.2;...
    'GluteusMinimusPosterior1', 'fp', 3*0.2;...
    %'Piriformis1',              'fp', 1;...
    };
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
BW            = data.S.BodyWeight;
hipJointWidth = data.S.Scale(1).HipJointWidth;
Side          = data.S.Side;

activeMuscles = data.activeMuscles;
MuscleList      = data.MuscleList;
MusclePathModel = data.MusclePathModel;
MusclePaths     = data.S.MusclePaths;

%% Define Parameters
g = -9.81;                         % Weight force [N/kg]
l = 1/2 * hipJointWidth;           % Half the distance between the two hip rotation centers
WB = BW * g;                       % total body weight [N]
WL = 0.161 * WB;                   % weight of the supporting limb
W = [0, WB - WL, 0];               % 'WB - WL'
b = 0.48 * l;                      % medio-lateral moment arm of the WL [Iglic 1990, S.37, Equ.7]
c = 1.01 * l;                      % medio-lateral moment arm of the ground reaction force WB  [Iglic 1990, S.37, Equ.7]
a = (WB * c - WL * b) / (WB - WL); % medio-lateral moment arm of 'WB - WL' [Iglic 1990, S.37, Equ.6]
d = 0;                             % antero-posterior moment arm of 'WB - WL' [Iglic 1990, S.37]

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

% PCAS
A = zeros(NoAM,1);
% Get physiological cross-sectional areas
for m = 1:NoAM
    % Physiological cross-sectional areas of each fascicle
    A_Idx = strcmp(MusclePaths(m).Name(1:end-1), MuscleList(:,1));
    A(m) = MuscleList{A_Idx,5} / MuscleList{A_Idx,4};
end
A=A.*cell2mat(activeMuscles(:,3));

% [Iglic 1990, S.37, Equ.2]
f = cell2sym(activeMuscles(:,2));
assume(f >= 0);
F = f.*A.*s;

% Moment of F around hip rotation center
momentF = cross(r, F);

if Side == 'L'
    momentW = cross([d 0  a], W); % Moment 'WB - WL' around hip rotation center
else
    momentW = cross([d 0 -a], W); % Moment 'WB - WL' around hip rotation center
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