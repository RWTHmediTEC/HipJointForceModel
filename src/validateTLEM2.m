function Results = validateTLEM2(data, gui)
% Calculate validation parameters for the OrthoLoad subjects

if exist('data\OrthoLoad.mat', 'file')
    load('OrthoLoad', 'OL')
else
    importDataOrthoLoad
end
        
Results = repmat(struct('Subject', []), length(OL),1);

for s = 1:length(OL)
    
% Load body weight and forces
load([OL(s).Subject '_' char(data.Posture) '.mat'])
OL(s).BodyWeight = meanPFP.Weight_N / 9.81;

OL(s).rMagP = norm(meanPFP.HJF_pBW);

load(['femur' data.TLEMversion 'Controls.mat'], 'fwTFM2AFCS')
HJFtrans = transpose(fwTFM2AFCS(1:3,1:3)) * transpose(meanPFP.HJF_pBW);

OL(s).rPhi   = atand(HJFtrans(3) / HJFtrans(2));
OL(s).rTheta = atand(HJFtrans(1) / HJFtrans(2));
OL(s).rAlpha = atand(HJFtrans(1) / HJFtrans(3));
            
data.S.Side                    = OL(s).Subject(end);
data.S.BodyWeight              = OL(s).BodyWeight;
data.S.BodyHeight              = OL(s).BodyHeight;
data.S.PelvicBend              = 0; % !!! No data available
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
Results(s).rX         = data.rX;
Results(s).rY         = data.rY;
Results(s).rZ         = data.rZ;
Results(s).rMag       = data.rMag;
Results(s).rMagP      = data.rMagP;
Results(s).OrrMagP    = OL(s).rMagP;
Results(s).errP       = abs((data.rMagP - OL(s).rMagP) / OL(s).rMagP * 100);
Results(s).rPhi       = data.rPhi;          
Results(s).OrPhi      = OL(s).rPhi;
Results(s).errPhi     = abs(abs(data.rPhi) - abs(OL(s).rPhi));
Results(s).rTheta     = data.rTheta;
Results(s).OrTheta    = OL(s).rTheta;
Results(s).errTheta   = abs(data.rTheta - OL(s).rTheta);
Results(s).rAlpha     = data.rAlpha;
Results(s).OrAlpha    = OL(s).rAlpha;
Results(s).errAlpha   = abs(data.rAlpha - OL(s).rAlpha);
end
        
end