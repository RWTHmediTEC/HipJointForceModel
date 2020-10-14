clearvars

addpath(genpath('..\src'))
addpath(genpath('..\data'))
addpath(genpath('src'))

cadavers = {'Fick1850','Dostal1981','TLEM2_0'};
models = {'Pauwels','Debrunner1975','Iglic'};

%% Create results
results = cell(length(cadavers), length(models));
for c = 1:length(cadavers)
    for m=1:length(models)
        data = createDataTLEM2();
        data = createDataTLEM2(data, cadavers{c});
        
        data.ScalingLaw = 'None';
        data.MusclePathModel = 'StraightLine';
        
        data.Model = models{m};
        
        modelHandle = str2func(data.Model);
        gui.Home.Model.modelHandle = modelHandle();
        [postures, defaultPosture] = gui.Home.Model.modelHandle.Posture();
        data.Posture = postures{defaultPosture,2};
        
        data.activeMuscles = gui.Home.Model.modelHandle.Muscles();
        data.activeMuscles = parseActiveMuscles(data.activeMuscles, data.MuscleList);
        
        results{c,m} = validateTLEM2(data, gui);
    end
end

%% Evaluate results
compTab = cell(1+length(cadavers),1+2*length(models));
for c = 1:length(cadavers)
    compTab{1+c,1} = cadavers{c};
    for m=1:length(models)
        if mod(1,2); compTab{1,1+m*2-1} = models{m}; end
        if ~isempty(results{c,m})
            sHJF = reshape([results{c,m}.HJF_Wu2002],[3,10])';
            iHJF = reshape([results{c,m}.OL_HJF_Wu2002],[3,10])';
            compTab{1+c,1+m*2-1} = mean(abs(vectorNorm3d(sHJF)-vectorNorm3d(iHJF)));
            compTab{1+c,1+m*2}   = mean(rad2deg(vectorAngle3d(sHJF, iHJF)));
        end
    end
end