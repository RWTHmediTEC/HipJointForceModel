function funcHandles = Schartz2020

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
    'BicepsFemorisCaputLongum';
    % 'Gastrocnemius';
    'Gluteus';
    'Iliacus';
    'RectusFemoris';
    % 'Soleus';
    % 'TibialisAnterior';
    % 'Vastus';
    };
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
muscleList      = data.MuscleList;
BW              = data.S.BodyWeight;
HipJointWidth   = data.S.Scale(1).HipJointWidth;
STjointPos      = data.S.LE(6).Joints.Subtalar.Pos;

activeMuscles   = data.activeMuscles;
MusclePaths     = data.S.MusclePaths;
MusclePathModel = data.MusclePathModel;
MRC             = data.MuscleRecruitmentCriterion;

%% Define Parameters
g = -data.g;                  % Weight force
Wb = BW * g;                  % Resultant force of total body weight
Wl = 0.161 * Wb;              % Resultant force of the supporting limb
W = [0, (Wb - 2*Wl)/2, 0];    % Resultant body weight force
zW = HipJointWidth/2;         % Half the distance between the two hip rotation centers
xW = STjointPos(1);           % Position of the foot in posteroanterior direction
lW = [xW 0 -zW];              % Lever arm of the body weight force

% Implement matrices for muscle origin points r, muscle insertion points r'
% and relative physiological cross-sectional areas A

% Number of active muscles
Noam = size(activeMuscles,1);
PCSA = zeros(Noam,1);
% Get physiological cross-sectional areas
for m = 1:Noam
    % Physiological cross-sectional areas of each fascicle
    PCSA_Idx = strcmp(activeMuscles{m}(1:end-1), muscleList(:,1));
    PCSA(m) = muscleList{PCSA_Idx,5} / muscleList{PCSA_Idx,4};
end

% r is origin of line of action
% s is normalized vector of line of action
r = zeros(length(MusclePaths),3);
s = zeros(length(MusclePaths),3);
for i = 1:length(MusclePaths)
    r(i,:) = MusclePaths(i).(MusclePathModel)(1:3);
    s(i,:) = MusclePaths(i).(MusclePathModel)(4:6);
end

syms RxSym RySym RzSym

switch MRC
    case 'None'
        % Iglic 1990 equation 2
        syms f % Symbolic average muscle tension f
        F = PCSA .* cell2sym(repmat({'f'}, Noam,1)) .* s;
        
        % Moment of F around hip rotation center
        momentF = cross(r, F);
        
        % Moment of bodyweight force around hip rotation center
        momentW = cross(lW, W);
        
        % Calculate hip joint reaction force R
        eq1 =  sum(F(:,1)) + RxSym + W(1); % Iglic 1990 equation 4 for X-component
        eq2 =  sum(F(:,2)) + RySym + W(2); % Iglic 1990 equation 4 for Y-component
        eq3 =  sum(F(:,3)) + RzSym + W(3); % Iglic 1990 equation 4 for Z-component
        
        eq4 = sum(momentF(:,1)) + momentW(1); % Iglic 1990 equation 5 for X-component
        eq5 = sum(momentF(:,2)) + momentW(2); % Iglic 1990 equation 5 for Y-component
        eq6 = sum(momentF(:,3)) + momentW(3); % Iglic 1990 equation 5 for Y-component
        
        R = solve(eq1, eq2, eq3, eq4, eq5, eq6);
        
    case {'MinMax','Polynom2','Polynom3','Polynom5','Energy'}
        [F, data] = muscleRecruitment(lW, W, r, s, PCSA, data);
        % Calculate hip joint reaction force R
        eq1 =  sum(F(1,:)) + RxSym + W(1);
        eq2 =  sum(F(2,:)) + RySym + W(2);
        eq3 =  sum(F(3,:)) + RzSym + W(3);
        
        R = solve(eq1, eq2, eq3);
end

rX = double(R.RxSym);
rY = double(R.RySym);
rZ = double(R.RzSym);

if any(isempty([rX, rY, rZ]))
    error(['No solution was found by the ' mfilename ' model!'])
end

data = convertGlobalHJF2LocalHJF([rX rY rZ], data);

end