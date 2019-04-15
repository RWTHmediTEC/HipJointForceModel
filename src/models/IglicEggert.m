function funcHandles = IglicEggert

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
function jointAngles = Position(data)

% Inputs
l = data.S.Scale(1).HipJointWidth/2;
x0 = data.S.Scale(2).FemoralLength;
phi = 0.5;

% Calculate the joint angles
b = 0.48 * l;
ny = asind(b/x0);
jointAngles = {[phi 0 data.S.PelvicBend], [ny 0 0], 0, 0, -ny, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(gui)
% User is allowed to edit the default values
enable = 'on';

% Default fascicles of the model
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
set(gui.Home.Settings.RadioButton_ObstacleSet, 'enable', 'off');
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
LE            = data.S.LE;
muscleList    = data.MuscleList;
BW            = data.S.BodyWeight;
PelvicBend    = data.S.PelvicBend;
HipJointWidth = data.S.Scale(1).HipJointWidth;
FemoralLength = data.S.Scale(2).FemoralLength;
activeMuscles = data.activeMuscles;
Side          = data.S.Side;
View          = data.View;

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

% Get muscle origin points and muscle insertion points
via(Noam,1) = false;
[r, rApostrophe] = deal(zeros(Noam,3));
for m = 1:Noam
    for n = 1:length(LE)
        if ~isempty(LE(n).Muscle)
            muscles = fieldnames(LE(n).Muscle);
            if any(strcmp(muscles,activeMuscles(m,1)))
                for t = 1:length(LE(n).Muscle.(activeMuscles{m,1}).Type)
                    if strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Origin')
                        r(m,:) = LE(n).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    elseif strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Via')
                        if strcmp(data.MusclePath, 'ViaPoint')
                            via(m) = true;
                        else
                            continue;
                        end
                    elseif strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Insertion')
                        rApostrophe(m,:) = LE(n).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    end
                end
            end
        end
    end
end

A = zeros(Noam,1);
% Get physiological cross-sectional areas
for m = 1:Noam
    % Physiological cross-sectional areas of each fascicle
    A_Idx = strcmp(activeMuscles{m}(1:end-1), muscleList(:,1));
    A(m) = muscleList{A_Idx,5} / muscleList{A_Idx,4};
end

% Unit vectors s in the direction of the muscles
for m = 1:Noam
    if via(m) == true
        % Find most distal via point of pelvis
        [~, idxPelvis] = min(LE(1).Muscle.(activeMuscles{m,1}).Pos(:,2));
        r(m,:) = LE(1).Muscle.(activeMuscles{m,1}).Pos(idxPelvis,:);
        % Find most proximal via point of femur
        [~, idxFemur] = max(LE(2).Muscle.(activeMuscles{m,1}).Pos(:,2));
        rApostrophe(m,:) = LE(2).Muscle.(activeMuscles{m,1}).Pos(idxFemur,:);
    end
end
s = normalizeVector3d(rApostrophe - r);

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

rMag = norm([rX rY rZ]);              % Magnitude of R
rMagP = rMag / abs(Wb) * 100;         % Magnitude of R in percentage body weight
rDir = normalizeVector3d([rX rY rZ]); % Direction of R

if Side == 'L'
    rZ = -1 * rZ;
end

% Rotation matrices for local pelvic COS
TFMx = createRotationOx(degtorad(phi));
TFMy = createRotationOy(0);
TFMz = createRotationOz(degtorad(PelvicBend));

if strcmp(View, 'Femur') == 1
    rDir = -1 * rDir;
    
    ny = asin(b/x0);
    
    % Rotation matrices for local femur COS
    TFMx = createRotationOx(ny);
    TFMy = createRotationOy();
    TFMz = createRotationOz();
end

[rX, rY, rZ] = transformPoint3d(rX, rY, rZ, TFMx*TFMy*TFMz);

rPhi   = atand(rZ / rY); % Angle in frontal plane
rTheta = atand(rX / rY); % Angle in sagittal plane
rAlpha = atand(rX / rZ); % Angle in horizontal plane

% Save results in data
data.rX     = rX;
data.rY     = rY;
data.rZ     = rZ;
data.rDir   = rDir;
data.rMag   = rMag;
data.rMagP  = rMagP;
data.rPhi   = rPhi;
data.rTheta = rTheta;
data.rAlpha = rAlpha;

end