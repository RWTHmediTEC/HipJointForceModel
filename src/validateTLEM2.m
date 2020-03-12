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
        
        % The HJF of the OrthoLoad subjects is given in the OrthLoad CS 
        % [Bergmann 2016]. Use definition 'ASR' instead of 'RAS'.
        OL(s).HJF_Bergmann2016 = transformVector3d(meanPFP.HJF_pBW,...
            anatomicalOrientationTFM('RAS','ASR'));
        % Transform OrthoLoad HJF into the Wu2002 CS
        switch OL(s).Subject(end)
            case 'L'
                % OrthoLoad HJF is presented for the right side for all 
                % subjects. Left sides were mirrored. Hence, for left sides
                % the OrthoLoad HJF has to be mirrored back for the 
                % transformation into the Wu2002 CS.
                meanPFP.HJF_pBW(1)=-meanPFP.HJF_pBW(1); % Right to left in 'RAS' 
                OL(s).HJF_Wu2002 = transformVector3d(...
                    meanPFP.HJF_pBW, OL(s).Wu2002TFM); % Transform to Wu2002 in 'ASR'
                OL(s).HJF_Wu2002(3)=-OL(s).HJF_Wu2002(3); % Left to right in 'ASR'
            case 'R'
                OL(s).HJF_Wu2002 = transformVector3d(meanPFP.HJF_pBW, OL(s).Wu2002TFM);
            otherwise
                error('Invalid side identifier!')
        end
        
        data.S.Side                    = OL(s).Subject(end);
        data.S.BodyWeight              = OL(s).BodyWeight;
        data.S.BodyHeight              = OL(s).BodyHeight;
        data.S.PelvicTilt              = 0; % Not available for OrthoLoad subjects
        data.S.Scale(1).HipJointWidth  = OL(s).HipJointWidth;
        data.S.Scale(1).PelvicWidth    = OL(s).PelvicWidth;
        data.S.Scale(1).PelvicHeight   = OL(s).PelvicHeight;
        data.S.Scale(1).PelvicDepth    = OL(s).PelvicDepth;
        data.S.Scale(2).FemoralLength  = OL(s).FemoralLength;
        data.S.Scale(2).FemoralWidth   = OL(s).FemoralWidth;
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
            'Surfaces',gui.Home.Settings.Checkbox_ShowWrappingSurfaces.Value);
        gui.IsUpdated = true;
        gui = updateSide(data, gui);
        gui = updateParameters(data, gui);
        gui = updateResults(data, gui);
        drawnow
        
        HJF_Wu2002 = data.HJF.Femur.Wu2002.R; % In 'ASR'
        % Use the simulated HJF in the OrthoLoad CS [Bergmann 2016] for the 
        % comparison. Use the orientation 'ASR' instead of 'RAS'.
        HJF_Bergmann2016 = transformVector3d(data.HJF.Femur.Bergmann2016.R, ...
            anatomicalOrientationTFM('RAS','ASR'));
        
        % OrthoLoad HJF is presented for the right side for all subjects.
        % Left sides were mirrored. Hence, for left sides the simulated HJF
        % is also mirrored.
        switch data.S.Side
            case 'L'
                HJF_Bergmann2016(3)=-HJF_Bergmann2016(3);
                HJF_Wu2002(3)=-HJF_Wu2002(3);
            case 'R'
            otherwise
                error('Invalid side identifier!')
        end
        
        Results(s).HJF_Wu2002          = HJF_Wu2002;
        Results(s).OL_HJF_Wu2002       = OL(s).HJF_Wu2002;
        Results(s).HJF_Bergmann2016    = HJF_Bergmann2016;
        Results(s).OL_HJF_Bergmann2016 = OL(s).HJF_Bergmann2016;
    catch
        % Otherwise fill up with nan
        Results(s).HJF_Wu2002          = nan(1,3);
        Results(s).OL_HJF_Wu2002       = nan(1,3);
        Results(s).HJF_Bergmann2016    = nan(1,3);
        Results(s).OL_HJF_Bergmann2016 = nan(1,3);
        warning(['Validation with subject ' Results(s).Subject ' failed!'])
    end
    
end