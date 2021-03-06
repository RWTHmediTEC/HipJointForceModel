function funcHandles = Pauwels1965
%PAUWELS1965 The original model of Pauwels without patient-specific 
% adaption using the original data of Fick, Braune and Fischer
%
% References:
% [Pauwels 1965] 1965 - Pauwels - Gesammelte Abhandlungen zur funktionellen
%   Anatomie des Bewegungsapparates - Der Schenkelhalsbruch
%   https://doi.org/10.1007/978-3-642-86841-2_1
% or
% [Pauwels 1980] 1980 - Pauwels - Biomechanics of the Locomotor Apparatus -
%   The Fracture of the Femoral Neck. A Mechanical Problem
%   https://doi.org/10.1007/978-3-642-67138-8_1
% [Fick 1850] 1850 - Fick - Statische Betrachtung der Muskulatur des
%   Oberschenkels
%   https://babel.hathitrust.org/cgi/pt?id=mdp.39015053249606&view=1up&seq=117
% [Braune 1895] 1985 - Braune - Der Gang des Menschen - I. Theil
% [Fischer 1898] 1898 - Fischer - Der Gang des Menschen - II. Theil
% or
% [Braune 1987] 1987 - Braune - The Human Gait
%   https://doi.org/10.1007/978-3-642-70326-3
%
% AUTHOR: B. Eggert
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
    'LevelWalking' 'LW';
    };

end

%% Calculate the joint angles for positioning of the TLEM2
function jointAngles = Position(~)

% Calculate the joint angles
jointAngles = {[0 0 0], [0 0 0], 0, 0, 0, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(~)
% User is allowed to edit the default values
enable = 'off';

% Default fascicles of the model
activeMuscles = {...
    'GluteusMedius';
    'GluteusMinimus';
    'TensorFasciaeLatae';
    'RectusFemoris';
    'Sartorius'};
    % 'Piriformis' % In [Pauwels 1965, S.109] it is claimed that the
    % Piriformis is considered as part of the P.T. group. However,
    % positional data for the origin and insertion of the Piriformis muscle
    % is missing in [Fick 1850, S.105-106] and is not present in
    % [Pauwels 1965, S.110, Fig. 169].
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Define parameters
G = -data.g; % Weight force

[~, S5, abc] = derivationFromBrauneAndFischer189X;

[BO, alphaM] = derivationFromFick1850();
% BO = 40; % Moment arm of the muscle force M [Pauwels 1965, S.111]
% alphaM = 21; % Angle between the muscle force M and the vertical [Pauwels 1965, S.111]

syms M % Magnitude of the muscle force
% Calculation of the muscle force
eq1 = S5 * G * abc(1) + M * BO; % Moment equilibrium around hip joint center

syms RxSym RySym RzSym
% Calculation of the hip joint force
eq2 = RxSym;                             % Force equilibrium in the direction of X
eq3 = RySym + S5 * G - M * cosd(alphaM); % Force equilibrium in the direction of Y
eq4 = RzSym + M * sind(alphaM);          % Force equilibrium in the direction of Z

Results = solve(eq1, eq2, eq3, eq4);

rX = double(Results.RxSym);
rY = double(Results.RySym);
rZ = double(Results.RzSym);

data = convertGlobalHJF2LocalHJF([rX rY rZ], data);

end

function [S, S5, s5_l] = derivationFromBrauneAndFischer189X()
% Derivation of the moment arm of the body weight during stance phase.
% Step 16, Experiment 1, Braune and Fischer
[S, ~, G1, G2, g1_16, g2_L_16, hjc_R_16] = BrauneAndFischer189X();

% Derivation
S5 = S*(G1+G2);
assert(isequal(round(S5,2), 47.76)); % [kg] Partial body weight weighing on the hip joint [Pauwels 1965, S.112]
s5 = (g1_16*G1+g2_L_16*G2)/(G1+G2); % [Pauwels 1965, S.101]
assert(isequal(round(s5,2), [129.43 -0.71 102.09])); % [cm] Position of S5 [Pauwels 1965, S.102]

% Moment arms of S5 projected into the anatomical planes
a = hjc_R_16(2)-s5(2); % Frontal plane [Pauwels 1965, S.103]
b = hjc_R_16(1)-s5(1); % Sagittal plane [Pauwels 1965, S.103]
c = sqrt(a^2+b^2); % Transverse plane [Pauwels 1965, S.103]

s5_l = [a -b c]; % -b: [Pauwels 1965, S.105, Footnote 32]
assert(isequal(round(s5_l,1), round([+10.99 -0.97 11.04],1))); % [cm] Moment arms of S5 [Pauwels 1965, S.105]
s5_l = s5_l*10; % Conversion to [mm]
end

function [R_FP_MA, R_FP_Angle] = derivationFromFick1850(varargin)
% Switch for visualization of Fick's data and Pauwel's derivation of the
% orientation of the abducturs resulting force

% Parsing
p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'visualization', false, logParValidFunc);
parse(p,varargin{:});
visu = p.Results.visualization;

[HM, muscleList, Moments] = Fick1850('visu', 0);

HJC = HM(1).Joints.Hip.Pos;

%% P.T. Group [Pauwels 1965, S.110]
% Positional data for the origin and insertion of the Piriformis muscle is
% missing in [Fick 1850, S.105-106]
GMe1 = createLine3d(HM(1).Muscle.GluteusMedius1.Pos, HM(2).Muscle.GluteusMedius1.Pos);
GMe3 = createLine3d(HM(1).Muscle.GluteusMedius3.Pos, HM(2).Muscle.GluteusMedius3.Pos);
GMi1 = createLine3d(HM(1).Muscle.GluteusMinimus1.Pos, HM(2).Muscle.GluteusMinimus1.Pos);
GMi3 = createLine3d(HM(1).Muscle.GluteusMinimus3.Pos, HM(2).Muscle.GluteusMinimus3.Pos);

% Bisectrix
GMe_FP = bisector(GMe1([2,3,5,6]),GMe3([2,3,5,6]));
if GMe_FP(3)<0; GMe_FP(3:4)=-GMe_FP(3:4); end
GMi_FP = bisector(GMi1([2,3,5,6]),GMi3([2,3,5,6]));
if GMi_FP(3)<0; GMi_FP(3:4)=-GMi_FP(3:4); end

% Moment arms of the muscles
GMe_FP_MA = distancePoints(HJC(2:3),projPointOnLine(HJC(2:3),GMe_FP));
GMi_FP_MA = distancePoints(HJC(2:3),projPointOnLine(HJC(2:3),GMi_FP));

% Relative force of the muscle based on its volume
GMe_rF = Moments.GluteusMedius(2)/GMe_FP_MA;
GMi_rF = Moments.GluteusMinimus(2)/GMi_FP_MA;

% Calculate the P.T. group's resulting force
PT_group_Its = intersectLines(GMe_FP,GMi_FP);
PT_group_FP = [PT_group_Its GMe_FP(3:4)*GMe_rF + GMi_FP(3:4)*GMi_rF];

%% S.C. Group [Pauwels 1965, S.110]
RF1 = createLine3d(HM(1).Muscle.RectusFemoris1.Pos, HM(2).Muscle.RectusFemoris1.Pos);
RF2 = createLine3d(HM(1).Muscle.RectusFemoris2.Pos, HM(2).Muscle.RectusFemoris2.Pos);
TF1 = createLine3d(HM(1).Muscle.TensorFasciaeLatae1.Pos, HM(2).Muscle.TensorFasciaeLatae1.Pos);
TF2 = createLine3d(HM(1).Muscle.TensorFasciaeLatae2.Pos, HM(2).Muscle.TensorFasciaeLatae2.Pos);
S1 = createLine3d(HM(1).Muscle.Sartorius1.Pos, HM(2).Muscle.Sartorius1.Pos);
S2 = createLine3d(HM(1).Muscle.Sartorius2.Pos, HM(2).Muscle.Sartorius2.Pos);

% Bisectrix
RF_FP = bisector(RF1([2,3,5,6]),RF2([2,3,5,6]));
if RF_FP(3)<0; RF_FP(3:4)=-RF_FP(3:4); end
TF_FP = bisector(TF1([2,3,5,6]),TF2([2,3,5,6]));
if TF_FP(3)<0; TF_FP(3:4)=-TF_FP(3:4); end
S_FP = bisector(S1([2,3,5,6]),S2([2,3,5,6]));
if S_FP(3)<0; S_FP(3:4)=-S_FP(3:4); end

% Moment arms of the muscles
RF_FP_MA = distancePoints(HJC(2:3), projPointOnLine(HJC(2:3), RF_FP));
TF_FP_MA = distancePoints(HJC(2:3), projPointOnLine(HJC(2:3), TF_FP));
S_FP_MA = distancePoints(HJC(2:3), projPointOnLine(HJC(2:3), S_FP));

% Relative force of the muscle based on its volume
RF_rF = Moments.RectusFemoris(2)/RF_FP_MA;
TF_rF = Moments.TensorFasciaeLatae(2)/TF_FP_MA;
S_rF = Moments.Sartorius(2)/S_FP_MA;

% Calculate the S.C. group's resulting force
RF_TF_Its = intersectLines(RF_FP,TF_FP);
RF_TF_FP = [RF_TF_Its RF_FP(3:4)*RF_rF + TF_FP(3:4)*TF_rF];
SC_group_Its = intersectLines(RF_TF_FP, S_FP);
SC_group_FP = [SC_group_Its RF_TF_FP(3:4) + S_FP(3:4)*S_rF];

% R (resulting line of action)
R_Its = intersectLines(PT_group_FP,SC_group_FP);
R_FP = [R_Its PT_group_FP(3:4) + SC_group_FP(3:4)];
R_FP_MA  = distancePoints(HJC(2:3), projPointOnLine(HJC(2:3),R_FP));
R_FP_Angle = rad2deg(lineAngle(R_FP,[0 0 1 0]));

if visu
    figName = '[Pauwels 1965, S.110, Fig. 169]';
    figH = figure('Name',figName,'NumberTitle','off','Color','w');
    axH = axes(figH);
    hold(axH,'on')
    pointProps.Marker = 'o';
    pointProps.MarkerSize = 5;
    pointProps.Color = 'none';
    pointProps.MarkerEdgeColor = 'k';
    pointProps.MarkerFaceColor = 'k';
    
    drawPoint3d(axH,HJC,pointProps)
    
    MusclesPauwels = {...
        'GluteusMedius',...
        'GluteusMinimus',...
        'RectusFemoris',...
        'TensorFasciae',...
        'Sartorius'};
    
    Fascicles = fieldnames(HM(1).Muscle);
    Fascicles(~contains(Fascicles, MusclesPauwels))=[];
    pointProps.MarkerSize = 3;
    for m = 1:length(Fascicles)
        Origin = HM(1).Muscle.(Fascicles{m}).Pos;
        Insertion = HM(2).Muscle.(Fascicles{m}).Pos;
        pointProps.DisplayName = Fascicles{m};
        colorIdx = strcmp(Fascicles{m}(1:end-1), muscleList(:,1));
        pointProps.MarkerEdgeColor = muscleList{colorIdx,2};
        pointProps.MarkerFaceColor = muscleList{colorIdx,2};
        drawEdge3d(axH, Origin, Insertion, pointProps);
        drawLabels3d(axH, [Origin; Insertion], [Fascicles{m}([1,end]);Fascicles{m}([1,end])]);
    end
    
    ylim([-500 150]);zlim([-50 350])
    box = [get(axH, 'xlim') get(axH, 'ylim') get(axH, 'zlim')];
    edge = clipLine3d([...
        0 PT_group_FP(1:2), 0 PT_group_FP(3:4);...
        0 SC_group_FP(1:2), 0 SC_group_FP(3:4)], box);
    drawEdge3d(axH,edge,'Color','k','LineStyle','-.');
    edge = clipLine3d([0 R_FP(1:2), 0 R_FP(3:4)], box);
    drawEdge3d(axH,edge,'Color','k','LineStyle','-');
    
    axis(axH, 'equal');
    grid(axH, 'minor');
    xlabel(axH, 'X'); ylabel(axH, 'Y'); zlabel(axH, 'Z');
    title(axH,figName)
    anatomicalViewButtons(axH,'ASR')
end

end

