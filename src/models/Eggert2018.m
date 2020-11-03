function funcHandles = Eggert2018
% Based on the model of [Iglic 1990] but using the TLEM2 cadaver data
% instead of Dostal's cadaver data. Grouping of the muscles was removed to
% avoid unphysiological / negative muscle forces.

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
enable = 'on';

% Default fascicles of the model
activeMuscles = {...
    'GluteusMedius';
    'GluteusMinimus';
    'TensorFasciaeLatae';
    'RectusFemoris';
    'Piriformis'
    };

end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
BW              = data.S.BodyWeight;
hipJointWidth   = data.S.Scale(1).HipJointWidth;

MuscleList      = data.MuscleList;
MusclePathModel = data.MusclePathModel;
MusclePaths     = data.S.MusclePaths;
MRC             = data.MuscleRecruitmentCriterion;

%% Define Parameters
g = -data.g;                       % weight force

% Subject-specific values
l = hipJointWidth/2;               % Half the distance between the two hip rotation centers
WB = BW * g;                       % total body weight [N]
% Generic values
WL = 0.161 * WB;                   % weight of the supporting limb
W = [0, WB - WL, 0];               % 'WB - WL'

b = 0.48 * l;                      % mediolateral moment arm of the WL [Iglic 1990, S.37, Equ.7]
c = 1.01 * l;                      % mediolateral moment arm of the ground reaction force WB  [Iglic 1990, S.37, Equ.7]
a = (WB * c - WL * b) / (WB - WL); % mediolateral moment arm of 'WB - WL' [Iglic 1990, S.37, Equ.6]
lBW = [0 0 -a];                    % lever arm of the body weight BW

% Number of active muscles
NoAM = length(MusclePaths);
% Names of active fascicles
NoAF = '';

% Get muscle origin points
r=nan(NoAM,3);
% Unit vectors s in the direction of the muscles [Iglic 1990, S.37, Equ.3]
s=nan(NoAM,3);
for i = 1:NoAM
    r(i,:) = MusclePaths(i).(MusclePathModel)(1:3);
    s(i,:) = MusclePaths(i).(MusclePathModel)(4:6);
    NoAF{i} = MusclePaths(i).Name;
end

PCSA = zeros(NoAM,1);
% Get physiological cross-sectional areas
for m = 1:NoAM
    % Physiological cross-sectional areas of each fascicle
    PCSA_Idx = strcmp(MusclePaths(m).Name(1:end-1), MuscleList(:,1));
    PCSA(m) = MuscleList{PCSA_Idx,5} / MuscleList{PCSA_Idx,4};
end

syms RxSym RySym RzSym

switch MRC
    case 'None'
        % [Iglic 1990, S.37, Equ.2]
        f = cell2sym(repmat({'f'}, NoAM,1));
        assume(f >= 0);
        F = f .* PCSA .* s;
        
        % Moment of F around hip rotation center
        momentF = cross(r, F);

        % Moment of bodyweight force around hip rotation center
        momentW = cross(lBW, W);
        
        % Calculate hip joint force R
        eq1 =  sum(F(:,1)) + RxSym + W(1); % [Iglic 1990, S.37, Equ.4]
        eq2 =  sum(F(:,2)) + RySym + W(2); % [Iglic 1990, S.37, Equ.4]
        eq3 =  sum(F(:,3)) + RzSym + W(3); % [Iglic 1990, S.37, Equ.4]
        
        eq4 = sum(momentF(:,1)) + momentW(1); % [Iglic 1990, S.37, Equ.5]
        
        R = solve(eq1, eq2, eq3, eq4);
        
        % Clear assumptions
        assume(f, 'clear');
    case {'Polynom1','Polynom2','Polynom3','Polynom5','MinMax','Energy'}
        
        [F, data] = muscleRecruitment(lBW, W, r, s, PCSA, data);
        
        % Calculate hip joint reaction force R
        eq1 =  sum(F(1,:)) + RxSym + W(1);
        eq2 =  sum(F(2,:)) + RySym + W(2);
        eq3 =  sum(F(3,:)) + RzSym + W(3);
        
        R = solve(eq1, eq2, eq3);
end

rX = double(R.RxSym);
rY = double(R.RySym);
rZ = double(R.RzSym);

data = convertGlobalHJF2LocalHJF([rX rY rZ], data);

end