function funcHandles = Sedghi2017
%SEDGHI2017 Iglic based model.
%
% Reference:
% [Iglic 1990] 1990 - Iglic - Mathematical Analysis of Chiari Osteotomy
% http://physics.fe.uni-lj.si/publications/pdf/acta1990.PDF
%
% AUTHOR: A. Sedghi
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
    'LevelWalking' 'LW'};

end

%% Calculate the joint angles for positioning of the TLEM2
function jointAngles = Position(data)

% Only used for visualization
[~, Scale] = Dostal1981();
l_ref = 1/2 * Scale(1).HipJointWidth;
x0 = Scale(2).FemoralLength;
phi = 0.5;

% Calculate the joint angles
b = 0.48 * l_ref;
ny = asind(b/x0);
jointAngles = {[phi 0 data.S.PelvicTilt], [ny 0 0], 0, 0, -ny, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(~)
% User is not allowed to edit the default values
enable = 'off';

% PCSAs were changed and Piriformis muscle excluded compared to [Iglic 1990, Tab.1].
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

activeMuscles = data.activeMuscles;
MuscleList      = data.MuscleList;
MusclePathModel = data.MusclePathModel;
MusclePaths     = data.S.MusclePaths;

%% Define Parameters
g = -data.g;                       % Weight force [N/kg]
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
A = A.*cell2mat(activeMuscles(:,3));

% [Iglic 1990, S.37, Equ.2]
f = cell2sym(activeMuscles(:,2));
% The assumption 'f >= 0' should be included, but then the solver
% sometimes will not find a solution.
assume(f >= 0); assume(f, 'clear');
F = f.*A.*s;

% Moment of F around hip rotation center
momentF = cross(r, F);

% Moment 'WB - WL' around hip rotation center
momentW = cross([d 0 -a], W);

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
    warning(['Unphysiological / negative value of fa (' num2str(fa,1) '), ' ...
        'ft (' num2str(ft,1) ') or fp (' num2str(fp,1) ')!'])
end

data = convertGlobalHJF2LocalHJF([rX rY rZ], data);

end