function [force, data] = muscleRecruitment(lBW, BW, LoA_PoA, LoA_Dir, PCSA, data)
% lBW = lever arm of the bodyweight force;
% BW = bodyweight force;
% LoA_PoA = point of application (origin) of the fascicle's line of action;
% LoA_Dir = unit vector in the direction of the fascicle's line of action;
% PCSA = physiological cross sectional area of fascicles [mm²]

tStart = tic;
%% Inputs
muscleList    = data.MuscleList;
musclePaths   = data.S.MusclePaths;
MRC           = data.MuscleRecruitmentCriterion;
HJC           = data.S.LE(1).Joints.Hip.Pos;

%% Parameters
% Muscle Tension [N/mm²] 0.9 in Anybody, 0.5 in CusToM
SIGMA = 0.9;
% Maximal fascicle strength [N]
fMax = SIGMA*PCSA;
% Weighting factor in Minmax and Polynomial criteria (fMax or PCSA)
n = 'Fmax';
switch n
    case 'Fmax'
        N = fMax;
    case 'PCSA'
        N = PCSA;
end

%% Optimization of fascicle forces
% Number of active fascicles
NoAF = length(musclePaths);

% Initial value of optimization
F_0 = zeros(NoAF,1);
% Minimum fasicle strength [N]
F_MIN = zeros(size(F_0));
% Project the HJC onto the line of action
HJConLineOfAction = projPointOnLine3d(HJC,[LoA_PoA LoA_Dir]);
% Get lever arms of the fascicles around HJC
leverArm = HJConLineOfAction-HJC;
% Moment of the fascicle forces around HJC
aeq = crossProduct3d(leverArm, LoA_Dir)';
% Moment of the bodyweight force around hip joint center [Nmm]
momentW = crossProduct3d(lBW, BW);
% Negative moment of external forces around hip joint center
beq = -momentW';

% Optimization options
opts = optimoptions(@fmincon,...
    'Algorithm','sqp',...
    'Display','off',...
    'GradObj','off',...
    'GradConstr','off',...
    'TolFun',1e-9,...
    'MaxFunctionEvaluations',1000000,...
    'TolX',1e-9,...
    'StepTolerance',1e-15,...
    'FunctionTolerance',1e-10,...
    'MaxIterations',5000);
switch MRC
    case 'MinMax'
        % MinMax muscle recruitment criteria
        fascicleForce = muscleRecruitmentMinMax(F_0,F_MIN,fMax,aeq,beq,N,opts);
    case {'Polynom2', 'Polynom3', 'Polynom5'}
        % Polynomial muscle recruitment criteria with power = 2, 3 or 5
        DP = str2double(MRC(end));
        fascicleForce = muscleRecruitmentPoly(DP,F_0,F_MIN,fMax,aeq,beq,N,opts);
    case 'Energy'
        % Energy muscle recruitment criteria
        if size(muscleList,2) >= 7
            % Get mass of each fascicle
            fascicleMass = zeros(NoAF,1);
            for m = 1:NoAF
                PCSA_Idx = strcmp(musclePaths(m).Name(1:end-1), muscleList(:,1));
                fascicleMass(m) = muscleList{PCSA_Idx,7} / muscleList{PCSA_Idx,4};
            end
        else
            errMessage = ['No muscle mass available for the selected cadaver. '...
                'Choose another cadaver to use this muscle recruitment criterion!'];
            msgbox(errMessage,mfilename,'error')
            error(errMessage)
        end
        % Weighting factor in Energy criteria [~]
        C1 = .5;
        fascicleForce = muscleRecruitmentEnergy(C1,F_0,F_MIN,fMax,aeq,beq,PCSA,opts,fascicleMass);
end

% Get the fascicle forces by multiplying the unit force direction vector
% with the magnitdue of the fascicle forces
force = (LoA_Dir.*fascicleForce)';

% Check if optimization was succesful
momentF = (aeq*fascicleForce)';
% Check whether moments are equal
if any(~ismembertol(momentF,momentW,1e-8,'ByRows',1))
    uiwait(msgbox({'Unphysiological!';'Imbalance of moments!';...
        [num2str(sum(momentF)),' = ',num2str(sum(momentW))]},'Warning','warn','modal'));
end

disp(['Muscle recruitment took ' num2str(toc(tStart),'%.0f') ' seconds.'])


%% Activation
% Get Fmax of each muscle
[nbFas,fMaxM] = deal(zeros(NoAF,1));
activeMuscles = '';
for m = 1:NoAF
    % Find Index of active fascicle
    tempIdx = strcmp(musclePaths(m).Name(1:end-1),muscleList(:,1));
    activeMuscles{m} = cellstr(muscleList(tempIdx,1));
    nbFas(m) = muscleList{tempIdx,4};
    fMaxM(m) = muscleList{tempIdx,5}*SIGMA;
end
% Delete values of all fascicles except one per muscle
[~,idx] = unique(fMaxM,'first');
% Number of fascicles of each muscle
nbFas = nbFas(sort(idx),:);
% Names of active muscles
activeMuscles = string(activeMuscles(:,sort(idx)));
% Fmax of each muscle [N]
fMaxM = fMaxM(sort(idx),:);

% Get force of active muscles
muscleForce = zeros(length(fMaxM),1);
% Calculation of the sum of all fascicle forces of each muscle
for i = 1:length(fMaxM)
    if i == 1
        muscleForce(i) = sum(fascicleForce(1:nbFas(i)));
    else
        j = 1+sum(nbFas(1:(i-1)));
        k = sum(nbFas(1:i));
        muscleForce(i) = sum(fascicleForce(j:k));
    end
end

% Activation of each fascicle
fascicleActivation = table(fascicleForce./fMax,'VariableNames',{'Activation'},'RowNames',{musclePaths.Name});
data.Activation.Fascicles = fascicleActivation;
% Activation of each muscle
muscleActivation = table(muscleForce./fMaxM,'VariableNames',{'Activation'},'RowNames',activeMuscles);
data.Activation.Muscles = muscleActivation;

end