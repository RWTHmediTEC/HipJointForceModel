function funcHandles = SchartzOneLeggedStance2020

funcHandles.Posture     = @Posture;
funcHandles.Position    = @Position;
funcHandles.Muscles     = @Muscles;
funcHandles.Calculation = @Calculation;

end

%% Postures for validation
function [postures, default] = Posture()

default = 1;
postures = {'OneLeggedStance' 'OLS';
            'LevelWalking' 'LW'
            'StandingUp' 'SU'};
end

%% Calculate the joint angles for positioning of the TLEM2
function jointAngles = Position(data)

% Inputs
l = data.S.Scale(1).HipJointWidth/2;
x0 = data.S.Scale(2).FemoralLength;
phi = 0.5;

% Calculate the joint angles
b = 0.48 * l;
ny = asind(b/x0);
jointAngles = {[phi 0 data.S.PelvicTilt], [ny 0 0], 0, 0, -ny, 0};
end

%% Active muscles
function [activeMuscles, enable] = Muscles(gui)
% User is allowed to edit the default values
enable = 'on';

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
    'Piriformis1'};

% Disable muscle path models which are not supported
set(gui.Home.Settings.RadioButton_ViaPoint, 'enable', 'on');
set(gui.Home.Settings.RadioButton_Wrapping, 'enable', 'on');
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
LE            = data.S.LE;
muscleList    = data.MuscleList;
BW            = data.S.BodyWeight;
PelvicTilt    = data.S.PelvicTilt;
HipJointWidth = data.S.Scale(1).HipJointWidth;
FemoralLength = data.S.Scale(2).FemoralLength;
activeMuscles = data.activeMuscles;
Side          = data.S.Side;
View          = data.View;
MusclePaths   = data.S.MusclePaths;
MusclePath    = data.MusclePath;

%% Define Parameters
G = -9.81;                         % Weight force
Wb = BW * G;                       % Resultant force of total bodyweight
Wl = 0.161 * Wb;                   % Resultant force of the supporting limb
W = [0, Wb - Wl, 0];               % Resultant bodyweight force
l = HipJointWidth/2;               % Half the distance between the two hip rotation centers
x0 = FemoralLength;                % Femoral length
b = 0.48 * l;                      % Lever arm of the force Wl
c = 1.01 * l;                      % Lever arm of the ground reaction force Wb's attachment point
a = (Wb * c - Wl * b) / (Wb - Wl); % Lever arm of the force W's attachment point
phi = 0.5;                         % Rotation of the pelvis around the Y axis

% Implement matrices for muscle origin points r, muscle insertion points r'
% and relative physiological cross-sectional areas A

% Number of active muscles
Noam = size(activeMuscles,1);

A = zeros(Noam,1);
% Get physiological cross-sectional areas
for m = 1:Noam
    % Physiological cross-sectional areas of each fascicle
    A_Idx = strcmp(activeMuscles{m}(1:end-1), muscleList(:,1));
    A(m) = muscleList{A_Idx,5} / muscleList{A_Idx,4};
end

% r is origin of line of action
% s is normalized vector of line of action

r = zeros(length(MusclePaths),3);
s = zeros(length(MusclePaths),3);
switch MusclePath
    case 'StraightLine'
        for i = 1:length(MusclePaths)
            s(i,:) = MusclePaths(i).StraightAction(1,:);
            r(i,:) = MusclePaths(i).StraightAction(2,:);
        end
    case 'ViaPoint'
        for i = 1:length(MusclePaths)
            s(i,:) = MusclePaths(i).ViaAction(1,:);
            r(i,:) = MusclePaths(i).ViaAction(2,:);
        end
    case 'Wrapping'
        for i = 1:length(MusclePaths)
            s(i,:) = MusclePaths(i).WrapAction(1,:);
            r(i,:) = MusclePaths(i).WrapAction(2,:);
        end
end

% Iglic 1990 equation 2
syms f % Symbolic average muscle tension f
for m = 1:Noam % Loop not needed for latest Matlab version
    F(m,:) = A(m) * f * s(m,:);
end
% F = A .* cell2sym(repmat({'fa'}, Noam,1)) .* s;

% Moment of F around hip rotation center
momentF = cross(r, F);

if Side == 'L'
    momentW = cross([0 0 a], W);  % Moment of bodyweight force around hip rotation center
else
    momentW = cross([0 0 -a], W); % Moment of bodyweight force around hip rotation center
end

% Calculate hip joint reaction force R
syms RxSym RySym RzSym

eq1 =  sum(F(:,1)) + RxSym + W(1); % Iglic 1990 equation 4 for X-component
eq2 =  sum(F(:,2)) + RySym + W(2); % Iglic 1990 equation 4 for Y-component
eq3 =  sum(F(:,3)) + RzSym + W(3); % Iglic 1990 equation 4 for Z-component

eq4 = sum(momentF(:,1)) + momentW(1); % Iglic 1990 equation 5 for X-component

R = solve(eq1, eq2, eq3, eq4);

rX = double(R.RxSym);
rY = double(R.RySym);
rZ = double(R.RzSym);
% f = double(R.f);

data = convertGlobalHJF2LocalHJF([rX rY rZ], data);

end