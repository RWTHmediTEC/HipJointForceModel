clearvars; close all;
% This script tries to replicate Fig. 2 in 2001 - Rasmussen et al. - Muscle
% recruitment by the min/max criterion - a comparative numerical study that
% compares different muscle recruitment criteria.
% The differences between the results of the script and Fig. 2 for higher
% polynomial degrees (>3) might be caused by numerical difficulties of the
% polynomial criterion [Rasmussen 2001]. Global optimization can be used to
% reduce the differences.

% AUTHOR: Fabian Schimmelpfennig
% COPYRIGHT (C) 2021
% LICENSE: EUPL v1.2

addpath(genpath('..\src'))

%% Settings
% Option to get better results when using higher polynomial degrees.
globalSearchOn = 0; %#ok<*UNRCH> % true requires the Global Optimization Toolbox

%% Model
% Simple model of the dumbbell curl [Rasmussen 2001]
MuscleList = ['1' '2' '3']; % Muscle names
Fmax = [1450;1200;1000]; % Maximum force of each muscle
beq(3,:) = 0:10:230; % Moments around the ellbow
dP = [2;3;5;10;100]; % Degrees of the polynomial criterion
nMuscles = length(MuscleList); % Number of muscles
aeq = zeros(3,nMuscles);
aeq(3,:) = [.1 .05 .02]; % Moment arms of muscles around the ellbow


%% Parameters
[Fmin,F0,F0_pol] = deal(zeros(3,1));
nMoments = length(beq); % Number of moments around the ellbow
nPower = length(dP);
[F_mm,A_mm] = deal(zeros(nMuscles,nMoments));
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

%% Calculation
tic
% Muscle Recruitment
for i = 1:nMoments
    for j = 1:nPower
        disp(['Power' num2str(dP(j)) ' - Moment ' num2str(beq(3,i))])
        if globalSearchOn
            % Calculation with GlobalSearch function (much slower)
            % Set initiation point for solver of polynomial criteria with polynom 100
            if j == 5 && i == 1
                F0_pol = F0;
            elseif j == 5
                F0_pol = F_pol.(['Power' num2str(dP(j))])(:,i-1);
            end
            % Use of GlobalSearch function. Requires the Global Optimization Toolbox.
            problem_pol_max = createOptimProblem(...
                'fmincon','x0',F0_pol,'objective',@(F) sum((F./Fmax).^(dP(j))),...
                'Aeq',aeq,'beq',beq(:,i),'lb',Fmin,'ub',Fmax,'options',opts);
            F_pol.(['Power' num2str(dP(j))])(:,i) = run(GlobalSearch,problem_pol_max);
        else
            F_pol.(['Power' num2str(dP(j))])(:,i) = ...
                muscleRecruitmentPoly(dP(j),F0,Fmin,Fmax,aeq,beq(:,i),Fmax,opts);
        end
        A_pol.(['Power' num2str(dP(j))])(:,i) = F_pol.(['Power' num2str(dP(j))])(:,i)./Fmax;
    end
    
    % Min/Max [Rasmussen et al. 2001, Olhoff 1989]
    disp(['Min/Max - Moment ' num2str(beq(3,i))])
    F_mm(:,i) = muscleRecruitmentMinMax(F0,Fmin,Fmax,aeq,beq(:,i),Fmax,opts);
    A_mm(:,i) = F_mm(:,i)./Fmax;
end
toc

%% Plots
xTicks = 0:50:250;
yTicks_F = 0:200:1600;
yTicks_A = 0:.2:1.2;

% Plot Force
figure('color','w','Position',[0,0,750,830],'NumberTitle','off','Name',...
    'Simulated muscle load distributions in the dumbbell curl model using different criteria.')
tiledlayout(3,2);
for j = 1:nPower
    F_tmp = F_pol.(['Power' num2str(dP(j))]);
    ax = nexttile;
    plot(ax, beq(3,:),F_tmp(1,:),'g--',beq(3,:),F_tmp(2,:),'b--',beq(3,:),F_tmp(3,:),'r--')
    title(ax, ['Power ' num2str(dP(j))])
    xlabel(ax, 'Moment [Nm]')
    ylabel(ax, 'Muscle forces [N]')
    set(ax,'xtick',xTicks,'ytick',yTicks_F,'xlim',[0,250],'ylim',[0,1600])
    grid(ax, 'on')
    if j == 1
        legend(ax, {'f^{(M)}_1','f^{(M)}_2','f^{(M)}_3'},'Location','northwest')
    end
end

ax = nexttile;
F_tmp = F_pol.('Power100');
lineH = plot(ax, ...
    beq(3,:),F_tmp(1,:),'g--',beq(3,:),F_tmp(2,:),'b--',beq(3,:),F_tmp(3,:),'r--',...
    beq(3,:),F_mm(1,:),'g-',beq(3,:),F_mm(2,:),'b-',beq(3,:),F_mm(3,:),'r-');
title(ax, 'Min/Max')
xlabel(ax, 'Moment [Nm]')
ylabel(ax, 'Muscle forces [N]')
legend(ax, lineH([1,4]),{'f^{(M)}_1 Power 100','f^{(M)}_1 Min/Max'},'Location','northwest')
set(ax, 'xtick',xTicks,'ytick',yTicks_F,'xlim',[0,250],'ylim',[0,1600])
grid(ax, 'on')

% Plot Activation
figure('color','w','Position',[751,0,750,830],'NumberTitle','off','Name',...
    'Simulated muscle activation in the dumbbell curl model using different criteria.')
tiledlayout(3,2);
for j = 1:nPower
    A_tmp = A_pol.(['Power' num2str(dP(j))]);
    ax = nexttile;
    plot(ax, beq(3,:),A_tmp(1,:),'g--',beq(3,:),A_tmp(2,:),'b--',beq(3,:),A_tmp(3,:),'r--')
    title(ax, ['Power ' num2str(dP(j))])
    xlabel(ax, 'Moment [Nm]')
    ylabel(ax, 'Activation')
    set(ax,'xtick',xTicks,'ytick',yTicks_A,'xlim',[0,250],'ylim',[0,1.1])
    grid(ax, 'on')
    if j == 1
        legend(ax, {'a^{(M)}_1','a^{(M)}_2','a^{(M)}_3'},'Location','northwest')
    end
end

ax = nexttile;
A_tmp = A_pol.('Power100');
lineH = plot(ax, ...
    beq(3,:),A_tmp(1,:),'g--',beq(3,:),A_tmp(2,:),'b--',beq(3,:),A_tmp(3,:),'r--',...
    beq(3,:),A_mm(1,:),'g-',beq(3,:),A_mm(2,:),'b-',beq(3,:),A_mm(3,:),'r-');
title(ax, 'Min/Max')
xlabel(ax, 'Moment [Nm]')
ylabel(ax, 'Activation')
legend(ax, lineH([3,6]),{'a^{(M)}_1 Power 100','a^{(M)}_1 Min/Max'},'Location','northwest')
set(ax, 'xtick',xTicks,'ytick',yTicks_A,'xlim',[0,250],'ylim',[0,1.1])
grid(ax, 'on')