function [HM, Scale] = Dostal1981()
% Reference:
% [Dostal 1981] 1981 - Dostal A three-dimensional biomechanical model of 
%   hip musculature
% All values in [cm]!

% Segment names
HM(1).Name='Pelvis';
HM(2).Name='Femur';

% Joints
HM(1).Joints.Hip.Pos = [0 0 0];
HM(1).Joints.Hip.Parent = 0;
HM(2).Joints.Hip.Pos = [0 0 0];
HM(2).Joints.Hip.Parent = 1;

% Parent segment
HM(1).Parent=[];
HM(2).Parent=1;

%% Muscles (Table 1)
% 1 Iliopsoas
HM(1).Muscle.Iliopsoas1.Pos = [ 2.8  2.4 0.5]; % Origin
HM(2).Muscle.Iliopsoas1.Pos = [-0.2 -6.1 1.5]; % Insertion

% 2 Pectineus
HM(1).Muscle.Pectineus1.Pos = [ 4.4  -0.3 -3.8]; % Origin
HM(2).Muscle.Pectineus1.Pos = [-0.4 -11.4  3.5]; % Insertion

% 3 Sartorius
HM(1).Muscle.Sartorius1.Pos = [ 5.1   6.8  5.0]; % Origin
HM(2).Muscle.Sartorius1.Pos = [-0.8 -43.5 -4.2]; % Insertion

% 4 Rectus Femoris
HM(1).Muscle.RectusFemoris1.Pos = [4.3   3.7 2.6]; % Origin
HM(2).Muscle.RectusFemoris1.Pos = [4.3 -41.5 0.2]; % Insertion

% 5 Adductor Longus
HM(1).Muscle.AdductorLongus1.Pos = [4.1  -3.1 -6.5]; % Origin
HM(2).Muscle.AdductorLongus1.Pos = [0.5 -20.4  2.6]; % Insertion

% 6 Adductor Brevis
HM(1).Muscle.AdductorBrevis1.Pos = [ 2.1  -4.5 -6.7]; % Origin
HM(2).Muscle.AdductorBrevis1.Pos = [-0.2 -13.1  3.8]; % Insertion

% 7 Adductor Minimus
HM(1).Muscle.AdductorMinimus1.Pos = [ 0.7  -4.9 -6.1]; % Origin
HM(2).Muscle.AdductorMinimus1.Pos = [-0.4 -12.4  4.0]; % Insertion

% 8 Adductor Magnus Mid
HM(1).Muscle.AdductorMagnusMid1.Pos = [-3.1  -6.1 -4.4]; % Origin
HM(2).Muscle.AdductorMagnusMid1.Pos = [ 0.5 -22.8  2.7]; % Insertion

% 9 Adductor Magnus Posterior
HM(1).Muscle.AdductorMagnusPosterior1.Pos = [-4.8  -5.9 -3.4]; % Origin
HM(2).Muscle.AdductorMagnusPosterior1.Pos = [ 0.1 -40.4 -3.1]; % Insertion

% 10 Gracilis
HM(1).Muscle.Gracilis1.Pos = [ 1.0  -4.9 -6.8]; % Origin
HM(2).Muscle.Gracilis1.Pos = [-1.4 -43.4 -4.1]; % Insertion

% 11 Gluteus Maximus
HM(1).Muscle.GluteusMaximus1.Pos = [-8.7   6.8 -4.4]; % Origin
HM(2).Muscle.GluteusMaximus1.Pos = [-0.9 -10.3  4.7]; % Insertion

% 12 Gluteus Medius Anterior
HM(1).Muscle.GluteusMediusAnterior1.Pos = [ 2.7 10.2 6.2]; % Origin
HM(2).Muscle.GluteusMediusAnterior1.Pos = [-1.8 -2.6 7.3]; % Insertion

% 13 Gluteus Medius Mid
HM(1).Muscle.GluteusMediusMid1.Pos = [-0.2 13.2 1.8]; % Origin
HM(2).Muscle.GluteusMediusMid1.Pos = [-1.8 -2.6 7.3]; % Insertion

% 14 Gluteus Medius Posterior
HM(1).Muscle.GluteusMediusPosterior1.Pos = [-4.8  9.7 -1.5]; % Origin
HM(2).Muscle.GluteusMediusPosterior1.Pos = [-1.8 -2.6  7.3]; % Insertion

% 15 Gluteus Minimus Anterior
HM(1).Muscle.GluteusMinimusAnterior1.Pos = [2.9  7.3 4.1]; % Origin
HM(2).Muscle.GluteusMinimusAnterior1.Pos = [0.4 -2.7 6.9]; % Insertion

% 16 Gluteus Minimus Mid
HM(1).Muscle.GluteusMinimusMid1.Pos = [-0.4  8.8 2.0]; % Origin
HM(2).Muscle.GluteusMinimusMid1.Pos = [ 0.4 -2.7 6.9]; % Insertion

% 17 Gluteus Minimus Posterior
HM(1).Muscle.GluteusMinimusPosterior1.Pos = [-2.6  7.1 0.0]; % Origin
HM(2).Muscle.GluteusMinimusPosterior1.Pos = [ 0.4 -2.7 6.9]; % Insertion

% 18 Tensor Fasciae Latae
HM(1).Muscle.TensorFasciaeLatae1.Pos = [4.5   7.8 5.6]; % Origin
HM(2).Muscle.TensorFasciaeLatae1.Pos = [2.2 -43.6 3.3]; % Insertion

% 19 Piriformis
HM(1).Muscle.Piriformis1.Pos = [-7.8  5.5 -4.7]; % Origin
HM(2).Muscle.Piriformis1.Pos = [-0.1 -0.1  5.5]; % Insertion

% 20 Obturator Internus
HM(1).Muscle.ObturatorInternus1.Pos = [-5.3 -1.1 -1.8]; % Origin
HM(2).Muscle.ObturatorInternus1.Pos = [-0.6 -0.5  4.7]; % Insertion

% 21 Gemellus Superior
HM(1).Muscle.GemellusSuperior1.Pos = [-5.5  0.5 -2.8]; % Origin
HM(2).Muscle.GemellusSuperior1.Pos = [-0.6 -0.5  4.7]; % Insertion

% 22 Gemellus Inferior
HM(1).Muscle.GemellusInferior1.Pos = [-4.9 -1.2 -0.9]; % Origin
HM(2).Muscle.GemellusInferior1.Pos = [-0.6 -0.5  4.7]; % Insertion

% 23 Quadratus Femoris
HM(1).Muscle.QuadratusFemoris1.Pos = [-3.6 -4.6 -1.5]; % Origin
HM(2).Muscle.QuadratusFemoris1.Pos = [-2.9 -4.0  4.7]; % Insertion

% 24 Obturator Externus
HM(1).Muscle.ObturatorExternus1.Pos = [ 0.9 -3.5 -4.9]; % Origin
HM(2).Muscle.ObturatorExternus1.Pos = [-1.7 -1.6  5.0]; % Insertion

% 25 Biceps Femoris
HM(1).Muscle.BicepsFemoris1.Pos = [-5.3  -3.6 -1.3]; % Origin
HM(2).Muscle.BicepsFemoris1.Pos = [-2.3 -44.1  3.9]; % Insertion

% 26 Semitendinosus
HM(1).Muscle.Semitendinosus1.Pos = [-5.3  -3.6 -1.3]; % Origin
HM(2).Muscle.Semitendinosus1.Pos = [-2.2 -43.3 -4.0]; % Insertion

% 27 Semimembranosus
HM(1).Muscle.Semimembranosus1.Pos = [-4.4  -3.1 -0.8]; % Origin
HM(2).Muscle.Semimembranosus1.Pos = [-2.9 -42.8 -3.4]; % Insertion

% Add types
HM(1).Muscle=structfun(@(x) setfield(x,'Type',{'Origin'}), HM(1).Muscle, 'uni',0);
HM(2).Muscle=structfun(@(x) setfield(x,'Type',{'Insertion'}), HM(2).Muscle, 'uni',0);

%% Landmarks
% Pelvis
HM(1).Landmarks.RightHipJointCenter.Pos=[0.0 0.0 0.0];
HM(1).Landmarks.LeftHipJointCenter.Pos=[0.3 -0.4 -16.9];
HM(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos=[5.9 8.3 5.1];
HM(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos=[5.9 8.3 -20.9];
HM(1).Landmarks.RightPubicTubercle.Pos=[5.9 -1.8 -4.9];
HM(1).Landmarks.LeftPubicTubercle.Pos=[5.7 -1.9 -10.6];
HM(1).Landmarks.RightPosteriorSuperiorIliacSpine.Pos=nan(1,3);
HM(1).Landmarks.LeftPosteriorSuperiorIliacSpine.Pos=nan(1,3);
% Femur
HM(2).Landmarks.MedialEpicondyle.Pos=[0.1 -42.3 -4.4];
HM(2).Landmarks.LateralEpicondyle.Pos=[-0.2 -42.3 4.4];
HM(2).Landmarks.PosteriorMedialCondyle.Pos=[-2.8 -43.4 -2.8];
HM(2).Landmarks.PosteriorLateralCondyle.Pos=[-2.8 -43.4 2.9];

%% Transform from [cm] to [mm]
scaleTFM = repmat(10*eye(4), 1, 1, 2);
HM = transformTLEM2(HM, scaleTFM);

%% Scaling parameters
Scale(1).HipJointWidth = abs(...
    HM(1).Landmarks.RightHipJointCenter.Pos(3)-...
    HM(1).Landmarks.LeftHipJointCenter.Pos(3));
Scale(1).ASISWidth  = abs(... % 28.6; % Table 3
    HM(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(3)-...
    HM(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos(3));
Scale(1).PelvicHeight = abs(... % mean([23.0 23.4]); % Table 3
    HM(1).Landmarks.RightHipJointCenter.Pos(2)-...
    HM(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(2));
Scale(1).PelvicDepth =  mean([16.5 16.3]*10); % Table 3 [cm] to [mm]
Scale(2).FemoralLength = abs(HM(2).Landmarks.MedialEpicondyle.Pos(2));

end