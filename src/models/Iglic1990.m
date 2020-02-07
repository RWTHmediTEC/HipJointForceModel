function funcHandles = Iglic1990
% The original model of Iglic with data from Johnston, Dostal, McLeish and 
% Clauser. Data was copied from the Iglic paper.

% References:
% [Iglic 1990] 1990 - Iglic - Mathematical analysis of Chiari Osteotomy
% [Johnston 1979] 1979 - Johnston - Reconstruction of the Hip
% [McLeish 1970] 1970 - McLeish - Abduction forces in the one-legged stance
% [Clauser 1969] 1969 - Clauser - Weight, volume and centre of mass of segments of the human body

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
[x0, l_ref]=Dostal1981_Iglic1990_Table2('visu',0);
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
View          = data.View;

%% Define Parameters
G = -9.81;                         % Weight force
[x0, l_ref, HM]=Dostal1981_Iglic1990_Table2('visu',0); 
WB = BW * G;                       % total body weight
WL = 0.161 * WB;                   % weight of the supporting limb
d = 0;                             % !QUESTIONABLE! antero-posterior moment arm of 'WB - WL' [Iglic 1990, S.37]
W = [0, WB - WL, 0];               % 'WB - WL'
b = 0.48 * l_ref;                  % medio-lateral moment arm of the WL [Iglic 1990, S.37, Equ.7]
c = 1.01 * l_ref;                  % medio-lateral moment arm of the ground reaction force WB  [Iglic 1990, S.37, Equ.7]
a = (WB * c - WL * b) / (WB - WL); % medio-lateral moment arm of 'WB - WL' [Iglic 1990, S.37, Equ.6]

phi = 0.5;                         % Pelvic bend [0]: rotation around the posterior-anterior axis
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
for b=1:length(HM)
    muscles = fieldnames(HM(b).Muscle);
    for m = 1:length(muscles)
        HM(b).Muscle.(muscles{m}).Pos =...
            transformPoint3d(HM(b).Muscle.(muscles{m}).Pos, TFM(:,:,b));
    end
end


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
F = cell2sym(activeMuscles(:,2)).*A.*s;

% Moment of F around hip rotation center
momentF = cross(r, F);

if side == 'L'
    momentW = cross([d 0  a], W);  % Moment of bodyweight force around hip rotation center
else
    momentW = cross([d 0 -a], W); % Moment of bodyweight force around hip rotation center
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

rMag = vectorNorm3d([rX rY rZ]);      % Magnitude of R
rMagP = rMag / abs(WB) * 100;         % Magnitude of R in percentage body weight
rDir = normalizeVector3d([rX rY rZ]); % Direction of R

if side == 'L'
    rZ = -1 * rZ;
end

% Rotation matrices for local pelvic COS
TFMx = createRotationOx(deg2rad(phi));
TFMy = createRotationOy(0);
TFMz = createRotationOz(0);

if strcmp(View, 'Femur') == 1
    rDir = -1 * rDir;
    
    % Rotation matrices for local femur COS
    TFMx = createRotationOx(deg2rad(ny));
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

function varargout = Dostal1981_Iglic1990_Table2(varargin)

% Parsing
p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'visualization',false,logParValidFunc);
parse(p,varargin{:});
visu = p.Results.visualization;

HJC = [0 0 0];

% Data from [Dostal 1981] as presented in [Iglic 1990, S.37, Table 2]
x0=42.3;
l_ref= 8.45;

% Gluteus Medius Anterior
% Origin
HM(1).Muscle.GluteusMediusAnterior1.Type={'Origin'};
HM(1).Muscle.GluteusMediusAnterior1.Pos = [-10.2 -2.7 -6.2];
% Insertion
HM(2).Muscle.GluteusMediusAnterior1.Type={'Insertion'};
HM(2).Muscle.GluteusMediusAnterior1.Pos = [  2.6  1.8 -7.3];

% Gluteus Minimus Anterior
% Origin
HM(1).Muscle.GluteusMinimusAnterior1.Type={'Origin'};
HM(1).Muscle.GluteusMinimusAnterior1.Pos = [- 7.3 -2.9 -4.1];
% Insertion
HM(2).Muscle.GluteusMinimusAnterior1.Type={'Insertion'};
HM(2).Muscle.GluteusMinimusAnterior1.Pos = [  2.7 -0.4 -6.9];

% Tensor Fasciae Latae
% Origin
HM(1).Muscle.TensorFasciaeLatae1.Type={'Origin'};
HM(1).Muscle.TensorFasciaeLatae1.Pos = [-7.8 -4.5 -5.6];
% Insertion
HM(2).Muscle.TensorFasciaeLatae1.Type={'Insertion'};
HM(2).Muscle.TensorFasciaeLatae1.Pos = [43.6 -2.2 -3.3];

% Rectus Femoris
% Origin
HM(1).Muscle.RectusFemoris1.Type={'Origin'};
HM(1).Muscle.RectusFemoris1.Pos = [-3.7 -4.3 -2.6];
% Insertion
HM(2).Muscle.RectusFemoris1.Type={'Insertion'};
HM(2).Muscle.RectusFemoris1.Pos = [41.5 -4.3 -0.2];

% Gluteus Medius Mid
% Origin
HM(1).Muscle.GluteusMediusMid1.Type={'Origin'};
HM(1).Muscle.GluteusMediusMid1.Pos = [-13.2 0.2 -1.8];
% Insertion
HM(2).Muscle.GluteusMediusMid1.Type={'Insertion'};
HM(2).Muscle.GluteusMediusMid1.Pos = [  2.6  1.8 -7.3];

% Gluteus Minimus Mid
% Origin
HM(1).Muscle.GluteusMinimusMid1.Type={'Origin'};
HM(1).Muscle.GluteusMinimusMid1.Pos = [- 8.8 0.4 -2.0];
% Insertion
HM(2).Muscle.GluteusMinimusMid1.Type={'Insertion'};
HM(2).Muscle.GluteusMinimusMid1.Pos = [  2.7 -0.4 -6.9];

% Gluteus Medius Posterior
% Origin
HM(1).Muscle.GluteusMediusPosterior1.Type={'Origin'};
HM(1).Muscle.GluteusMediusPosterior1.Pos = [-9.7 4.8  1.5];
% Insertion
HM(2).Muscle.GluteusMediusPosterior1.Type={'Insertion'};
HM(2).Muscle.GluteusMediusPosterior1.Pos = [ 2.6 1.8 -7.3];

% Gluteus Minimus Posterior
% Origin
HM(1).Muscle.GluteusMinimusPosterior1.Type={'Origin'};
HM(1).Muscle.GluteusMinimusPosterior1.Pos = [-7.1 2.6 0.0];
% Insertion
HM(2).Muscle.GluteusMinimusPosterior1.Type={'Insertion'};
HM(2).Muscle.GluteusMinimusPosterior1.Pos = [2.7 -0.4 -6.9];

% Piriformis
% Origin
HM(1).Muscle.Piriformis1.Type={'Origin'};
HM(1).Muscle.Piriformis1.Pos = [-5.5 7.8 4.7];
% Insertion
HM(2).Muscle.Piriformis1.Type={'Insertion'};
HM(2).Muscle.Piriformis1.Pos = [0.1 0.1 -5.5];


% Transform from 'IPL' to 'ASR' coordinate system
TFM=createRotationOx(deg2rad(180))*createRotationOz(deg2rad(90));
for b=1:length(HM)
    muscles = fieldnames(HM(b).Muscle);
    for m = 1:length(muscles)
        HM(b).Muscle.(muscles{m}).Pos =...
            transformPoint3d(HM(b).Muscle.(muscles{m}).Pos, TFM);
    end
end

varargout{1}=x0;
varargout{2}=l_ref;
varargout{3}=HM;
varargout{4}=NaN;

if visu
    % ColorMap
    cmap = hsv(length(fieldnames(HM(1).Muscle)));
    
    figH=figure('Color','w');
    axH=axes(figH);
    hold(axH,'on')
    lineProps.Marker = 'o';
    lineProps.MarkerSize = 5;
    lineProps.Color = 'k';
    lineProps.MarkerEdgeColor = lineProps.Color;
    lineProps.MarkerFaceColor = lineProps.Color;
    drawPoint3d(axH,HJC,lineProps)
    lineProps.MarkerSize = 2;

    % Loop over bones with muscles
    BwM = find(~arrayfun(@(x) isempty(x.Muscle), HM));
    for b = BwM
        Muscles = fieldnames(HM(b).Muscle);
        % Loop over the muscles of the bone
        for m = 1:length(Muscles)
            % Check if the muscle originates from this bone
            oIdx = strcmp(HM(b).Muscle.(Muscles{m}).Type, 'Origin');
                Origin = HM(b).Muscle.(Muscles{m}).Pos(oIdx,:);
                % Loop over the other bones exept the bone of Origin
                for bb = BwM(BwM~=b)
                    matchingMuscle = fieldnames(HM(bb).Muscle);
                    if any(strcmp(Muscles(m), matchingMuscle))
                        % Check if it is the bone of insertion
                        iIdx = strcmp(HM(bb).Muscle.(Muscles{m}).Type, 'Insertion');
                        if any(iIdx)
                            Insertion = HM(bb).Muscle.(Muscles{m}).Pos(iIdx,:);
                        end
                    end
                end
                
                % Combine Origin, Via points & Insertion
                mPoints = [Origin; Insertion];
                lineProps.DisplayName = Muscles{m};
                lineProps.Color = cmap(m,:);
                lineProps.MarkerEdgeColor = lineProps.Color;
                lineProps.MarkerFaceColor = lineProps.Color;
                drawPoint3d(axH, mPoints, lineProps);
                drawLabels3d(axH, mPoints, [Muscles{m}([1,end]);Muscles{m}([1,end])], lineProps);
        end
    end
    axis(axH, 'equal', 'tight'); 
    grid(axH, 'minor');
    xlabel(axH, 'X'); ylabel(axH, 'Y'); zlabel(axH, 'Z');
    title('Data from [Dostal 1981] as presented in [Iglic 1990, S.37, Table 2]')
    medicalViewButtons(axH,'ASR')
    varargout{4}=axH;
end

end
