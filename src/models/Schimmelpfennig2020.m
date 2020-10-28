function funcHandles = Schimmelpfennig2020
% Based on model of [Eggert2018] but using all muscles which are connected
% to the pelvis.

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
enable = 'off';

% Default fascicles of the model
activeMuscles = {...
    'AdductorBrevisMid';...
    'AdductorBrevisProximal';...
    'AdductorLongus';...
    'AdductorMagnusDistal';...
    'AdductorMagnusMid';...
    'AdductorMagnusProximal';...
    'BicepsFemorisCaputLongum';...
    'GemellusInferior';...
    'GemellusSuperior';...
    'GluteusMaximusInferior';...
    'GluteusMaximusSuperior';...
    'GluteusMediusAnterior';...
    'GluteusMediusPosterior';...
    'GluteusMinimusAnterior';...
    'GluteusMinimusMid';...
    'GluteusMinimusPosterior';...
    'Gracilis';...
    'IliacusLateralis';...
    'IliacusMedialis';...
    'IliacusMid';...
    'ObturatorExternusInferior';...
    'ObturatorExternusSuperior';...
    'ObturatorInternus';...
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
BW_kg           = data.S.BodyWeight;
hipJointWidth   = data.S.Scale(1).HipJointWidth;
muscleList      = data.MuscleList;
musclePathModel = data.MusclePathModel;
musclePaths     = data.S.MusclePaths;
MRC             = data.MuscleRecruitmentCriterion;

%% Define Parameters
g = -data.g;                       % weight force

% Subject-specific values
l = hipJointWidth/2;               % Half the distance between the two hip rotation centers
Wb = BW_kg * g;                    % total body weight [N]
% Generic values
Wl = 0.161 * Wb;                   % weight of the supporting limb
W = [0, Wb - Wl, 0];               % 'WB - WL'

b = 0.48 * l;                      % mediolateral moment arm of the WL [Iglic 1990, S.37, Equ.7]
c = 1.01 * l;                      % mediolateral moment arm of the ground reaction force WB  [Iglic 1990, S.37, Equ.7]
a = (Wb * c - Wl * b) / (Wb - Wl); % mediolateral moment arm of 'WB - WL' [Iglic 1990, S.37, Equ.6]
lW = [0 0 -a];                     % lever arm of the body weight W

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

syms RxSym RySym RzSym

switch MRC
    case 'None'
        errMessage = 'Please select a muscle recruitment criterion!';
        msgbox(errMessage,mfilename,'error')
        error(errMessage)
    case {'MinMax','Polynom2','Polynom3','Polynom5','Energy'}
        [F, data] = muscleRecruitment(lW, W, r, s, PCSA, data);
        % Calculate hip joint reaction force R
        eq1 =  sum(F(1,:)) + RxSym + W(1);
        eq2 =  sum(F(2,:)) + RySym + W(2);
        eq3 =  sum(F(3,:)) + RzSym + W(3);
        
        R = solve(eq1, eq2, eq3);
        
        rX = double(R.RxSym);
        rY = double(R.RySym);
        rZ = double(R.RzSym);
        
        data = convertGlobalHJF2LocalHJF([rX rY rZ], data);
end

end