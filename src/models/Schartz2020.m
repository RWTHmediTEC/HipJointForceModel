function funcHandles = SchartzSitToStand2020

funcHandles.Posture     = @Posture;
funcHandles.Position    = @Position;
funcHandles.Muscles     = @Muscles;
funcHandles.Calculation = @Calculation;

end

%% Postures for validation
function [postures, default] = Posture()

default = 1;
postures = {'StandingUp' 'SU'};

end

%% Calculate the joint angles for positioning of the TLEM2
function jointAngles = Position(~)

jointAngles = {[0 0 -44], [0 0 44], 55, 50, -15, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(~)
% User is allowed to edit the default values
enable = 'on';
% Default fascicles of the model
activeMuscles = {...
%     'BicepsFemorisCaputLongum1';
%     'BicepsFemorisCaputBreve1';
%     'BicepsFemorisCaputBreve2';
%     'BicepsFemorisCaputBreve3';
%     'GastrocnemiusLateralis1';
%     'GastrocnemiusMedialis1';
    'GluteusMaximusInferior1';
    'GluteusMaximusInferior2';
    'GluteusMaximusInferior3';
    'GluteusMaximusInferior4';
    'GluteusMaximusInferior5';
    'GluteusMaximusInferior6';
    'GluteusMaximusSuperior1';
    'GluteusMaximusSuperior2';
    'GluteusMaximusSuperior3';
    'GluteusMaximusSuperior4';
    'GluteusMaximusSuperior5';
    'GluteusMaximusSuperior6';
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
    'GluteusMinimusMid1';
    'GluteusMinimusMid2';
    'GluteusMinimusPosterior1';
    'GluteusMinimusPosterior2';
    'IliacusLateralis1';
    'IliacusLateralis2';
    'IliacusMedialis1';
    'IliacusMedialis2';
    'IliacusMid1';
    'IliacusMid2';
    'RectusFemoris1';
    'RectusFemoris2';
%     'SoleusLateralis1';
%     'SoleusLateralis2';
%     'SoleusLateralis3';
%     'SoleusMedialis1';
%     'SoleusMedialis2';
%     'SoleusMedialis3';
%     'TibialisAnterior1';
%     'TibialisAnterior2';
%     'TibialisAnterior3';
%     'VastusIntermedius1';
%     'VastusIntermedius2';
%     'VastusIntermedius3';
%     'VastusIntermedius4';
%     'VastusIntermedius5';
%     'VastusIntermedius6';
%     'VastusLateralisInferior1';
%     'VastusLateralisInferior2';
%     'VastusLateralisInferior3';
%     'VastusLateralisInferior4';
%     'VastusLateralisInferior5';
%     'VastusLateralisInferior6';
%     'VastusLateralisSuperior1';
%     'VastusLateralisSuperior2';
%     'VastusMedialisInferior1';
%     'VastusMedialisInferior2';
%     'VastusMedialisMid1';
%     'VastusMedialisMid2';
%     'VastusMedialisSuperior1';
%     'VastusMedialisSuperior2';
%     'VastusMedialisSuperior3';
%     'VastusMedialisSuperior4'};
    };
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
muscleList      = data.MuscleList;
BW              = data.S.BodyWeight;
HipJointWidth   = data.S.Scale(1).HipJointWidth;
activeMuscles   = data.activeMuscles;
Side            = data.S.Side;
MusclePaths     = data.S.MusclePaths;
MusclePathModel = data.MusclePathModel;

%% Define Parameters
g = -9.81;                         % Weight force
Wb = BW * g;                       % Resultant force of total bodyweight
Wl = 0.161 * Wb;                   % Resultant force of the supporting limb
W = [0, (Wb - 2*Wl)/2, 0];         % Resultant bodyweight force
l = HipJointWidth/2;               % Half the distance between the two hip rotation centers

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
for i = 1:length(MusclePaths)
    r(i,:) = MusclePaths(i).(MusclePathModel)(1:3);
    s(i,:) = MusclePaths(i).(MusclePathModel)(4:6);
end

% Iglic 1990 equation 2
syms f % Symbolic average muscle tension f
for m = 1:Noam % Loop not needed for latest Matlab version
    F(m,:) = A(m) * f * s(m,:);
end
% F = A .* cell2sym(repmat({'fa'}, Noam,1)) .* s;

% Moment of F around hip rotation center
momentF = cross(r, F);

switch Side
    case 'R'
        momentW = cross([0 0 -l], W); % Moment of bodyweight force around hip rotation center
    case 'L'
        momentW = cross([0 0  l], W); % Moment of bodyweight force around hip rotation center
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