clearvars

addpath(genpath('..\src'))
addpath(genpath('..\data'))
addpath(genpath('src'))

cadavers = {'Fick1850','Dostal1981','TLEM2_0'};
models = {'Pauwels','Debrunner1975','Iglic','Schimmelpfennig2020'};

%% Create results
results = cell(length(cadavers), length(models));
for c = 1:length(cadavers)
    for m=1:length(models)
        display([cadavers{c} ' - ' models{m}])
        data = createDataTLEM2();
        data.Verbose = 0;
        data = createDataTLEM2(data, cadavers{c});
        
        data.ScalingLaw = 'None';
        data.MusclePathModel = 'StraightLine';
        
        data.Model = models{m};
        
        switch data.Model
            case {'Pauwels','Debrunner1975','Iglic'}
                data.MuscleRecruitmentCriterion = 'None';
            case {'Schimmelpfennig2020'}
                data.MuscleRecruitmentCriterion = 'Polynom2';
        end
        
        modelHandle = str2func(data.Model);
        gui.Home.Model.modelHandle = modelHandle();
        [postures, defaultPosture] = gui.Home.Model.modelHandle.Posture();
        for p = 1:length(postures)
            data.Posture = postures{p,2};
            
            data.activeMuscles = gui.Home.Model.modelHandle.Muscles();
            data.activeMuscles = parseActiveMusclesLEM(data.activeMuscles, data.MuscleList);
            
            results{c,m,p} = validateTLEM2(data, gui);
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
                sHJF = reshape([results{c,m,p}.HJF_Wu2002],[3,10])';
                iHJF = reshape([results{c,m,p}.OL_HJF_Wu2002],[3,10])';
                % Absolute Error in magnitude
                AE_Mag{c,m,p} = abs(vectorNorm3d(sHJF)-vectorNorm3d(iHJF));
                % Angular Error in direction
                AE_Dir{c,m,p} = rad2deg(vectorAngle3d(sHJF, iHJF));
                
                % Table
                compTab(2+c,2+(m-1)*NoE,p) = medianStats(AE_Mag{c,m,p},'format','short','test','none','alpha',alpha);
                compTab(2+c,1+m*NoE,p)     = medianStats(AE_Dir{c,m,p},'format','short','test','none','alpha',alpha);
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