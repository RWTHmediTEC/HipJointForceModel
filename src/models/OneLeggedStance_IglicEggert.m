function funcHandles = OneLeggedStance_IglicEggert

funcHandles.Position = @Position;
funcHandles.Muscles = @Muscles;
funcHandles.Calculation = @Calculation;

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
function [activeMuscles, enable] = Muscles()
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
end

%% Calculation of the HJF
function data = Calculation(data)

% Inputs
LE            = data.S.LE;
muscleList    = data.MuscleList;
BW            = data.S.BodyWeight;
PelvicBend    = data.S.PelvicBend;
HRC           = data.S.Scale(1).HipJointWidth;
activeMuscles = data.activeMuscles;
Side          = data.S.Side;
rView         = data.View;

%% Define Parameters
G = -9.81;                              % Weight force
Wb = BW * G;                            % Resultant force of total bodyweight
Wl = 0.161 * Wb;                        % Resultant force of the supporting limb
W = [0, Wb - Wl, 0];                    % Resultant bodyweight force
HRChalf = HRC/2;                        % Half the distance between the two hip rotation centers
ba = 0.48 * HRChalf;                    % Lever arm of the force Wl
ca = 1.01 * HRChalf;                    % Lever arm of the ground reaction force Wb's attachment point
a = (Wb * ca - Wl * ba) / (Wb - Wl);    % Lever arm of the force W's attachment point

% Implement matrices for Muscle Origin Points (MOP) and Muscle Insertion
% Points (MIP) which are equal to r and r' in Iglic 1990
% and Physiological Cross-Sectional Areas (PCSA)

% Number of active Muscles
NoaM = size(activeMuscles,1);

% Get MOPs and MIPs
[MOP, MIP] = deal(zeros(NoaM,3));
for m = 1:NoaM
    for b = 1:length(LE)
        if ~isempty(LE(b).Muscle)
            muscles = fieldnames(LE(b).Muscle);
            if any(strcmp(muscles,activeMuscles(m,1)))
                for t = 1:length(LE(b).Muscle.(activeMuscles{m,1}).Type)
                    if strcmp(LE(b).Muscle.(activeMuscles{m,1}).Type(t), 'Origin')
                        MOP(m,:) = LE(b).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    elseif strcmp(LE(b).Muscle.(activeMuscles{m,1}).Type(t), 'Via')
                        continue
                    elseif strcmp(LE(b).Muscle.(activeMuscles{m,1}).Type(t), 'Insertion')
                        MIP(m,:) = LE(b).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    end
                end
            end
        end
    end
end

PCSA = zeros(NoaM,1);
% Get PCSAs
for m = 1:NoaM
    % PCSA of each fascicle
    PCSA_Idx = strcmp(activeMuscles{m}(1:end-1), muscleList(:,1));
    PCSA(m) = muscleList{PCSA_Idx,5} / muscleList{PCSA_Idx,4};
end

% Unit vectors s in the direction of the muscles
s = normalizeVector3d(MIP - MOP);
% Iglic 1990 equation 2
syms f % Symbolic average muscle tension f
for m = 1:NoaM % loop not needed for latest Matlab version
    muscleForce(m,:) = PCSA(m) * f * s(m,:);
end
% muscleForce = PCSA .* cell2sym(repmat({'fa'}, NoaM,1)) .* s;

% Moment of muscleForce around HRC
momentF = cross(MOP, muscleForce);

if Side == 'L'
    momentW = cross([0 0 a], W);  % Moment of bodyweight force around HRC
else
    momentW = cross([0 0 -a], W); % Moment of bodyweight force around HRC
end

syms rXsym rYsym rZsym % Hip joint forces

eq1 =  sum(muscleForce(:,1)) + rXsym + W(1); % Iglic 1990 equation 4 for X-component
eq2 =  sum(muscleForce(:,2)) + rYsym + W(2); % Iglic 1990 equation 4 for Y-component
eq3 =  sum(muscleForce(:,3)) + rZsym + W(3); % Iglic 1990 equation 4 for Z-component

eq4 = sum(momentF(:,1)) + momentW(1); % Iglic 1990 equation 5 for X-component

hipJointForce = solve(eq1, eq2, eq3, eq4);

rX = double(hipJointForce.rXsym);
rY = double(hipJointForce.rYsym);
rZ = double(hipJointForce.rZsym);
%f = double(hipJointForce.f);

rMag = norm([rX rY rZ]);
rMagP = rMag / abs(Wb) * 100;
rDir = normalizeVector3d([rX rY rZ]);

if Side == 'L'
    rZ = -1 * rZ;
end

% Rotation matrices for local pelvic COS
TFMx = createRotationOx(degtorad(0.5));
TFMy = createRotationOy(0);
TFMz = createRotationOz(degtorad(PelvicBend));

if strcmp(rView, 'Femur') == 1
    rDir = -1 * rDir;
    
    ny = asin(ba/data.S.Scale(2).FemoralLength);
    
    % Rotation matrices for local femur COS
    TFMx = createRotationOx(ny);
    TFMy = createRotationOy();
    TFMz = createRotationOz();
end

[rX, rY, rZ] = transformPoint3d(rX, rY, rZ, TFMx*TFMy*TFMz);

rPhi   = atand(rZ / rY);                               % Angle in frontal plane
rTheta = atand(rX / rY);                               % Angle in sagittal plane
rAlpha = atand(rX / rZ);                               % Angle in horizontal plane

data.rMag = rMag;
data.rMagP = rMagP;
data.rPhi = rPhi;
data.rTheta = rTheta;
data.rAlpha = rAlpha;
data.rDir = rDir;
data.rX = rX;
data.rY = rY;
data.rZ = rZ;

% ny = asind(ba/data.FL);
% rYfemur = cosd(ny)*rY + sind(ny)*rZ;
% rZfemur = -sind(ny)*rY + cosd(ny)*rZ;
% rMag = norm([rX rYfemur rZfemur]);                          % Magnitude of hip joint reaction force in [N]
% rMagP = rMag / abs(Wb) * 100;                               % Magnitude of hip joint reaction force in [BW%]
% rPhi = atand(rZfemur / rYfemur);                            % Angle in frontal plane
% rTheta = atand(rX / rYfemur);                               % Angle in sagittal plane
% rAlpha = atand(rX / rZfemur);                               % Angle in horizontal plane
% rDir = normalizeVector3d([rX rYfemur rZfemur]);

end