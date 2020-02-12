function funcHandles = Iglic1990
% The original model of Iglic with data from Johnston, Dostal, McLeish and 
% Clauser. Data was copied from the Iglic paper.

% References:
% [Iglic 1990] 1990 - Iglic - Mathematical analysis of Chiari Osteotomy
% [Johnston 1979] 1979 - Johnston - Reconstruction of the Hip
% [McLeish 1970] 1970 - McLeish - Abduction forces in the one-legged stance
% [Clauser 1969] 1969 - Clauser - Weight, volume and centre of mass of segments of the human body
% [Dostal 1981] 1981 - Dostal A three-dimensional biomechanical model of hip musculature

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
[~, Scale] = Dostal1981('visu',0);
l_ref = 1/2 * Scale(1).HipJointWidth;
x0 = Scale(2).FemoralLength;
phi = 0.5;

% Calculate the joint angles
b = 0.48 * l_ref;
ny = asind(b/x0);
jointAngles = {[phi 0 0], [ny 0 0], 0, 0, -ny, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(gui)
% User is not allowed to edit the default values
enable = 'off';

% The division of the muscles in [Iglic 1990, S.37] is not compatible with
% the TLEM2. Hence, GluteusMediusMid1 is not visualized. However, it is
% used for calculation as described in [Iglic 1990, S.37].

% Data from [Johnston 1979] as presented in [Iglic 1990, S.37, Table 1]
% The devision into the groups fa (anterior), ft (middle) and 
% fp (posterior) is !QUESTIONABLE!
activeMuscles = {...
    'GluteusMediusAnterior1',   'fa', 0.266;...
    'GluteusMinimusAnterior1',  'fa', 0.113;...
    'TensorFasciaeLatae1',      'fa', 0.120;...
    'RectusFemoris1',           'fa', 0.400;...
    
    'GluteusMediusMid1',        'ft', 0.266;... 
    'GluteusMinimusMid1',       'ft', 0.113;...
    
    'GluteusMediusPosterior1',  'fp', 0.266;...
    'GluteusMinimusPosterior1', 'fp', 0.113;...
    'Piriformis1',              'fp', 0.100;...
    };

% Disable muscle path models which are not supported
set(gui.Home.Settings.RadioButton_ViaPoint, 'enable', 'off');
set(gui.Home.Settings.RadioButton_ObstacleSet, 'enable', 'off');
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
BW            = data.S.BodyWeight;
activeMuscles = data.activeMuscles;
side          = data.S.Side;
view          = data.View;

%% Define Parameters
G = -9.81;                         % Weight force
[HM, Scale] = Dostal1981('visu',0);
l_ref = 1/2 * Scale(1).HipJointWidth;
x0 = Scale(2).FemoralLength;
WB = BW * G;                       % total body weight
WL = 0.161 * WB;                   % weight of the supporting limb
W = [0, WB - WL, 0];               % 'WB - WL'
b = 0.48 * l_ref;                  % medio-lateral moment arm of the WL [Iglic 1990, S.37, Equ.7]
c = 1.01 * l_ref;                  % medio-lateral moment arm of the ground reaction force WB  [Iglic 1990, S.37, Equ.7]
a = (WB * c - WL * b) / (WB - WL); % medio-lateral moment arm of 'WB - WL' [Iglic 1990, S.37, Equ.6]
d = 0;                             % !QUESTIONABLE! antero-posterior moment arm of 'WB - WL' [Iglic 1990, S.37]
phi = 0.5;                         % Pelvic bend [°]: rotation around the posterior-anterior axis
ny = asind(b/x0);                  % Femoral adduction: rotation around the posterior-anterior axis [Iglic 1990, S.37, Equ.8]

% Rotate muscle attachments [Iglic 1990, S.37]
TFM(:,:,1)=createRotationOx(deg2rad(phi));
TFM(:,:,2)=createRotationOx(deg2rad(ny));
switch side
    case 'L'
        lTFM=[1 0 0 0; 0 1 0 0; 0 0 -1 0; 0 0 0 1];
        TFM(:,:,1)=lTFM*TFM(:,:,1);
        TFM(:,:,2)=lTFM*TFM(:,:,2);
end
HM = transformTLEM2(HM, TFM);


% Get muscle origin points and muscle insertion points
NoAM = size(activeMuscles,1); % Number of active muscles
[r, r_] = deal(nan(NoAM,3));
for m = 1:NoAM
    for b = 1:length(HM)
        muscles = fieldnames(HM(b).Muscle);
        if any(strcmp(muscles,activeMuscles(m,1)))
            for t = 1:length(HM(b).Muscle.(activeMuscles{m,1}).Type)
                if strcmp(HM(b).Muscle.(activeMuscles{m,1}).Type(t), 'Origin')
                    r(m,:)  = HM(b).Muscle.(activeMuscles{m,1}).Pos(t,:);
                elseif strcmp(HM(b).Muscle.(activeMuscles{m,1}).Type(t), 'Insertion')
                    r_(m,:) = HM(b).Muscle.(activeMuscles{m,1}).Pos(t,:);
                end
            end
        end
    end
end

% PCAS
A = cell2mat(activeMuscles(:,3));

% Unit vectors s in the direction of the muscles
% [Iglic 1990, S.37, Equ.3]
s = normalizeVector3d(r_ - r);

% [Iglic 1990, S.37, Equ.2]
f = cell2sym(activeMuscles(:,2));
assume(f >= 0) % Muscles can only pull
F = f.*A.*s;

% Moment of F around hip rotation center
momentF = cross(r, F);

if side == 'L'
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