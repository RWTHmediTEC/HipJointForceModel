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
    
% Load body weight and HJF of OrthoLoad subjects
% !!! Add the source of the mat files !!!
load([OL(s).Subject '_' char(data.Posture) '.mat'],'meanPFP')
OL(s).BodyWeight = meanPFP.Weight_N/g; % [N] to [kg]

% The HJF of the OrthoLoad subjects is given in the OrthLoad coordinate system (CS) [Bergmann 2016].
OL_rBW = transformPoint3d(meanPFP.HJF_pBW,medicalCoordinateSystemTFM('RAS','ASR'));

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
            
data = scaleTLEM2(data);
data = globalizeTLEM2(data);
data = gui.Home.Model.modelHandle.Calculation(data);

% Save results in structure Results
Results(s).Subject = OL(s).Subject;
Results(s).Sex     = OL(s).Sex;
            
% Scaling and skinning parameters
Results(s).BodyWeight     = OL(s).BodyWeight;
Results(s).HipJointWidth  = OL(s).HipJointWidth;
Results(s).PelvicWidth    = OL(s).PelvicWidth;
Results(s).PelvicHeight   = OL(s).PelvicHeight;
Results(s).PelvicDepth    = OL(s).PelvicDepth;
Results(s).FemoralLength  = OL(s).FemoralLength;
Results(s).FemoralVersion = OL(s).FemoralVersion;
Results(s).NeckLength     = OL(s).NeckLength;
Results(s).CCD            = OL(s).CCD;
            
% Force parameters
% OrthoLoad HJF is presented for the right side for all subjects. Left
% sides were mirrored. Hence, for left sides the simulated HJF is also
% mirrored.
% !!! Simulated HJF has to be transformed into the OrthoLoad CS for comparison !!!
switch data.S.Side
    case 'R'
        R=[data.rX data.rY data.rZ];
    case 'L'
        R=[data.rX data.rY -data.rZ];
end
Results(s).R_pBW      = R;
Results(s).rPhi       = atand(R(3)/R(2));
Results(s).rTheta     = atand(R(1)/R(2));
Results(s).rAlpha     = atand(R(1)/R(3));

Results(s).OL_R_pBW    = OL(s).R_pBW;
Results(s).OL_Phi      = OL(s).rPhi;
Results(s).OL_Theta    = OL(s).rTheta;
Results(s).OL_Alpha    = OL(s).rAlpha;
end
        
end