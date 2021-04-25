clearvars

addpath(genpath('..\src'))
addpath(genpath('..\data'))
addpath(genpath('src'))

% Cadaver templates
cadavers = {'Fick1850','Dostal1981','TLEM2_0'};
% Static models
models = {'Pauwels','Debrunner','Iglic','mediTEC2020'};

%% Validate the static models using the various cadaver templates
results = cell(length(cadavers), length(models));
for c = 1:length(cadavers)
    for m=1:length(models)
        display([cadavers{c} ' - ' models{m}])
        data = createLEM();
        data.Verbose = 0;
        data = createLEM(data, cadavers{c});
        % Scaling Law
        data.ScalingLaw = 'None';
        % Static model
        data.Model = models{m};
        % Muscle path model
        switch cadavers{c}
            case {'Fick1850','Dostal1981'}
                 data.MusclePathModel = 'StraightLine';
            case {'TLEM2_0'}
                 data.MusclePathModel = 'Wrapping';
        end
        % Muscle recruitment
        switch data.Model
            case {'Pauwels','Debrunner1975','Iglic'}
                data.MuscleRecruitmentCriterion = 'None';
            case {'mediTEC2020'}
                data.MuscleRecruitmentCriterion = 'Polynom2';
        end
        % Get the model specifications
        modelHandle = str2func(data.Model);
        gui.Home.Model.modelHandle = modelHandle();
        postures = gui.Home.Model.modelHandle.Posture();
        for p = 1:size(postures,1)
            data.Posture = postures{p,2};
            data.activeMuscles = gui.Home.Model.modelHandle.Muscles();
            data.activeMuscles = parseActiveMusclesLEM(data.activeMuscles, data.MuscleList);
            % Validate model
            results{c,m,p} = validateLEM(data, gui);
        end
    end
end

%% Evaluate results
alpha = 0.01;

[AE_Mag, AE_Dir, APE_Mag] = deal(cell(length(cadavers), length(models), length(postures)));
compTab = cell(2+length(cadavers),1+2*length(models));
errorNames = {'MAE Mag.','MAE Dir.'};
NoE = length(errorNames);
for p = 1:length(postures)
    for c = 1:length(cadavers)
        compTab{2+c,1,p} = cadavers{c};
        for m=1:length(models)
            compTab{1,2+(m-1)*NoE,p} = models{m};
            compTab(2,2+(m-1)*NoE:1+m*NoE,p) = errorNames;
            if ~isempty(results{c,m})
                pHJF = reshape([results{c,m,p}.HJF_Wu2002],[3,10])';
                iHJF = reshape([results{c,m,p}.OL_HJF_Wu2002],[3,10])';
                % Absolute Error in magnitude
                AE_Mag{c,m,p} = abs(vectorNorm3d(pHJF)-vectorNorm3d(iHJF));
                % Angular Error in direction
                AE_Dir{c,m,p} = rad2deg(vectorAngle3d(pHJF, iHJF));
                
                % Table
                compTab(2+c,2+(m-1)*NoE,p) = ...
                    medianStats(AE_Mag{c,m,p},'format','short','test','none','alpha',alpha);
                compTab(2+c,1+m*NoE,p)     = ...
                    medianStats(AE_Dir{c,m,p},'format','short','test','none','alpha',alpha);
            end
        end
    end
    writecell(compTab(:,:,p),'compareCadavers.xlsx','Sheet',postures{p,2},'Range','B2')
end

% Check for significant differences between the cadavers for each model
for p = 1:length(postures)
    for m=1:length(models)
        % Remove failed simulations
        cadaverIdx = ~cellfun(@(x) any(isnan(x)), AE_Mag(:,m,p));
        [pValue,tbl,stats] = friedman(reshape(cell2mat(AE_Mag(cadaverIdx,m,p)),10,[]),1,'off');
        disp([postures{p} ' - ' models{m} ': ' num2str(pValue)])
    end
end