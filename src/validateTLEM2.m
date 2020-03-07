function Results = validateTLEM2(data, gui)
% Calculate validation parameters for the OrthoLoad subjects

if exist('data\OrthoLoad.mat', 'file')
    load('OrthoLoad.mat', 'OL')
else
    importDataOrthoLoad()
    load('OrthoLoad.mat', 'OL')
end

Results = repmat(struct('Subject', []), length(OL),1);

g=9.81;

for s = 1:length(OL)
    % Save results in structure Results
    Results(s).Subject = OL(s).Subject;
    Results(s).Sex     = OL(s).Sex;
    try
        % Load body weight and HJF of OrthoLoad subjects
        % !!! Add the source of the mat files !!!
        load([OL(s).Subject '_' data.Posture '.mat'],'meanPFP')
        OL(s).BodyWeight = meanPFP.Weight_N / g; % [N] to [kg]
        
        % The HJF of the OrthoLoad subjects is given in the OrthLoad CS [Bergmann 2016].
        % Use definition 'ASR' instead of 'RAS'.
        OL_rBW = transformVector3d(meanPFP.HJF_pBW,anatomicalOrientationTFM('RAS','ASR'));
        
        OL(s).R_pBW  = OL_rBW;
        OL(s).rPhi   = atand(OL_rBW(3) / OL_rBW(2));
        OL(s).rTheta = atand(OL_rBW(1) / OL_rBW(2));
        OL(s).rAlpha = atand(OL_rBW(1) / OL_rBW(3));
        
        data.S.Side                    = OL(s).Subject(end);
        data.S.BodyWeight              = OL(s).BodyWeight;
        data.S.BodyHeight              = OL(s).BodyHeight;
        data.S.PelvicTilt              = 0; % Not available for OrthoLoad subjects
        data.S.Scale(1).HipJointWidth  = OL(s).HipJointWidth;
        data.S.Scale(1).PelvicWidth    = OL(s).PelvicWidth;
        data.S.Scale(1).PelvicHeight   = OL(s).PelvicHeight;
        data.S.Scale(1).PelvicDepth    = OL(s).PelvicDepth;
        data.S.Scale(2).FemoralLength  = OL(s).FemoralLength;
        data.S.Scale(2).FemoralVersion = OL(s).FemoralVersion;
        data.S.Scale(2).NeckLength     = OL(s).NeckLength;
        data.S.Scale(2).CCD            = OL(s).CCD;
        
        % Calculate HJF
        data = scaleTLEM2(data);
        data = globalizeTLEM2(data);
        data = gui.Home.Model.modelHandle.Calculation(data);
        delete(gui.Home.Visualization.Axis_Visualization.Children);
        visualizeTLEM2(gui.Home.Visualization.Axis_Visualization, ...
            data.S.LE, data.S.Side,...
            'Muscles', data.S.MusclePaths,...
            'MuscleList', data.MuscleList,...
            'MusclePathModel',data.MusclePathModel,...
            'ShowWrapSurf',gui.Home.Settings.Checkbox_ShowWrappingSurfaces.Value);
        gui.IsUpdated = true;
        gui = updateSide(data, gui);
        gui = updateParameters(data, gui);
        gui = updateResults(data, gui);
        drawnow
        
        % Use simulated HJF in the OrthoLoad CS [Bergmann 2016] for the comparison
        % Use orientation 'ASR' instead of 'RAS'.
        R=transformVector3d(data.HJF.Femur.Bergmann2016.R, anatomicalOrientationTFM('RAS','ASR'));
        
        % OrthoLoad HJF is presented for the right side for all subjects. Left
        % sides were mirrored. Hence, for left sides the simulated HJF is also
        % mirrored.
        switch data.S.Side
            case 'L'
                R(3)=-R(3);
        end
        Results(s).R_pBW      = R;
        Results(s).rPhi       = atand(R(3)/R(2));
        Results(s).rTheta     = atand(R(1)/R(2));
        Results(s).rAlpha     = atand(R(1)/R(3));
        
        Results(s).OL_R_pBW    = OL(s).R_pBW;
        Results(s).OL_Phi      = OL(s).rPhi;
        Results(s).OL_Theta    = OL(s).rTheta;
        Results(s).OL_Alpha    = OL(s).rAlpha;
    catch
        Results(s).R_pBW      = nan(1,3);
        Results(s).rPhi       = nan;
        Results(s).rTheta     = nan;
        Results(s).rAlpha     = nan;
        
        Results(s).OL_R_pBW    = nan(1,3);
        Results(s).OL_Phi      = nan;
        Results(s).OL_Theta    = nan;
        Results(s).OL_Alpha    = nan;
    end
    
end