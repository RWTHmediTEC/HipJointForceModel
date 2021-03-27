function importDataTLEM2_1(LE, muscleList)
% !!! Update of muscleList needed? !!!

% Update TLEM 2.0 to TLEM 2.1
% Hardcoding of changes made in the AnyBody model due to the reviewed TLEM

%% Update joint centers

scaleFactor = 1000; % [m] in [mm]

% Joint centers
AnyBodyHipJointTLEM2_0 = [-0.0338      -0.0807      0.0843    ] .* scaleFactor;
AnyBodyHipJointTLEM2_1 = [-0.03697295  -0.07767031  0.08159202] .* scaleFactor;
% In AnyBody instead of the HJC a different origin is used: 
%   0.5*(ASIS_R + ASIS_L)
% The difference is used to reconstruct the translation of the joint center
LE(1).Joints.Hip.       Pos = AnyBodyHipJointTLEM2_1 - AnyBodyHipJointTLEM2_0;
LE(2).Joints.Hip.       Pos = [-0.004290743    0.3616561    -0.0006287179] .* scaleFactor;
LE(2).Joints.Knee.      Pos = [-0.009683742   -0.006310877   0.001295266 ] .* scaleFactor;
LE(2).Joints.Patella.   Pos = [ 0.001859503    0.01200243   -0.004400671 ] .* scaleFactor;
LE(3).Joints.Knee.      Pos = [-0.006538604    0.3561071    -0.004329047 ] .* scaleFactor;
LE(3).Joints.Talocrural.Pos = [ 0.01337003    -0.01126083    0.0007477404] .* scaleFactor;
LE(4).Joints.Patella.   Pos = [-0.04425682    -0.001883169   0           ] .* scaleFactor;
LE(5).Joints.Talocrural.Pos = [ 0.0003584674  -0.005524157   0           ] .* scaleFactor;
LE(5).Joints.Subtalar.  Pos = [-0.006535063   -0.02434153    0.005824743 ] .* scaleFactor;
LE(6).Joints.Subtalar.  Pos = [ 0              0             0           ] .* scaleFactor;

% Joint axes
LE(2).Joints.Knee.      Axis = normalizeVector3d([0.09091897   0.06445389    0.9937703]) * -1;
LE(2).Joints.Patella.   Axis = normalizeVector3d([0.09663987  -0.009576934   0.9952733]) * -1;
LE(3).Joints.Knee.      Axis = normalizeVector3d([0.02081402   0.1209213     0.9924439]) * -1;
LE(3).Joints.Talocrural.Axis = normalizeVector3d([0.362799     0.1304906    -0.9226858]);
LE(4).Joints.Patella.   Axis = normalizeVector3d([0.09663987  -0.009576935   0.9952733]) * -1;
LE(5).Joints.Talocrural.Axis = normalizeVector3d([0.362799     0.1304906    -0.9226858]);
LE(5).Joints.Subtalar.  Axis = normalizeVector3d([0.8784254    0.4637787     0.1152306]);
LE(6).Joints.Subtalar.  Axis = normalizeVector3d([0.8784254    0.4637787     0.1152306]);

%% Update muscle elements
% Pelvic muscle elements
LE(1).Muscle.GluteusMaximusInferior1.Pos = [-0.08467, 0.04858, -0.04897] * scaleFactor;
LE(1).Muscle.GluteusMaximusInferior2.Pos = [-0.08405, 0.03945, -0.05900] * scaleFactor;
LE(1).Muscle.GluteusMaximusInferior3.Pos = [-0.08492, 0.01396, -0.05762] * scaleFactor;
LE(1).Muscle.GluteusMaximusInferior4.Pos = [-0.08948, 0.01379, -0.07041] * scaleFactor;
LE(1).Muscle.GluteusMaximusInferior5.Pos = [-0.08267, -0.00586,-0.06855] * scaleFactor;
LE(1).Muscle.GluteusMaximusInferior6.Pos = [-0.07987, -0.01008,-0.07769] * scaleFactor;
LE(1).Muscle.GluteusMaximusSuperior1.Pos = [-0.07811, 0.12125, -0.01815] * scaleFactor;
LE(1).Muscle.GluteusMaximusSuperior2.Pos = [-0.082885, 0.10457,-0.02771] * scaleFactor;
LE(1).Muscle.GluteusMaximusSuperior3.Pos = [-0.08766, 0.08989, -0.03227] * scaleFactor;
LE(1).Muscle.GluteusMaximusSuperior4.Pos = [-0.07993, 0.07367, -0.03044] * scaleFactor;
LE(1).Muscle.GluteusMaximusSuperior5.Pos = [-0.07993, 0.06667, -0.03844] * scaleFactor;
LE(1).Muscle.GluteusMaximusSuperior6.Pos = [-0.08466, 0.05289, -0.03927] * scaleFactor;
LE(1).Muscle.GluteusMediusAnterior1.Pos = [-0.0237,  0.11888,  0.03977] * scaleFactor;
LE(1).Muscle.GluteusMediusAnterior2.Pos = [-0.01813, 0.113175, 0.04818] * scaleFactor;
LE(1).Muscle.GluteusMediusAnterior3.Pos = [-0.00856, 0.10680,  0.05059] * scaleFactor;
LE(1).Muscle.GluteusMediusAnterior4.Pos = [0.002285, 0.101335, 0.04859] * scaleFactor;
LE(1).Muscle.GluteusMediusAnterior5.Pos = [0.01513,   0.0956,  0.04659] * scaleFactor;
LE(1).Muscle.GluteusMediusAnterior6.Pos = [0.02373,   0.0846,  0.04051] * scaleFactor;
LE(1).Muscle.GluteusMediusPosterior1.Pos = [-0.03122, 0.12208, 0.03577] * scaleFactor;
LE(1).Muscle.GluteusMediusPosterior2.Pos = [-0.03916,  0.12701, 0.0246] * scaleFactor;
LE(1).Muscle.GluteusMediusPosterior3.Pos = [-0.05385, 0.13065, 0.00905] * scaleFactor;
LE(1).Muscle.GluteusMediusPosterior4.Pos = [-0.06054, 0.12789, -0.0075] * scaleFactor;
LE(1).Muscle.GluteusMediusPosterior5.Pos = [-0.06482, 0.1139, -0.01827] * scaleFactor;
LE(1).Muscle.GluteusMediusPosterior6.Pos = [-0.05382, 0.05809,-0.01627] * scaleFactor;
LE(1).Muscle.GluteusMinimusAnterior1.Pos = [0.01976,  0.08933, 0.04217] * scaleFactor;
% LE(1).Muscle.GluteusMinimusAnterior2.Pos = [] * ScaleFactor; % missing
LE(1).Muscle.GluteusMinimusMid1.Pos = [-0.012625, 0.09145, 0.025825] * scaleFactor;
% LE(1).Muscle.GluteusMinimusMid2.Pos = [] * ScaleFactor; % missing
LE(1).Muscle.GluteusMinimusPosterior1.Pos = [-0.03774,0.05215,-0.00660] * scaleFactor;
% LE(1).Muscle.GluteusMinimusPosterior2.Pos = [] * ScaleFactor; % missing
LE(1).Muscle.Piriformis1.Pos = [-0.07157,0.05790,-0.05668] * scaleFactor;
LE(1).Muscle.RectusFemoris1.Pos = [0.02073, 0.04280,0.01613] * scaleFactor;
LE(1).Muscle.RectusFemoris2.Pos = [-0.00784,0.03433,0.01127] * scaleFactor;
LE(1).Muscle.Sartorius1.Pos = [0.03195,0.07861,0.03261] * scaleFactor;
LE(1).Muscle.TensorFasciaeLatae1.Pos = [0.02942,0.08614,0.04266] * scaleFactor;
LE(1).Muscle.TensorFasciaeLatae2.Pos = [0.02249,0.09155,0.04677] * scaleFactor;

% Femoral muscle elements
LE(2).Muscle.GluteusMaximusInferior1.Pos = [-0.0117,  0.28838,  0.045480] * scaleFactor;
LE(2).Muscle.GluteusMaximusInferior2.Pos = [-0.00933, 0.27438,  0.043026] * scaleFactor;
LE(2).Muscle.GluteusMaximusInferior3.Pos = [-0.00696, 0.26038,  0.040572] * scaleFactor;
LE(2).Muscle.GluteusMaximusInferior4.Pos = [-0.00459, 0.24638,  0.038118] * scaleFactor;
LE(2).Muscle.GluteusMaximusInferior5.Pos = [-0.00222, 0.23238,  0.035664] * scaleFactor;
LE(2).Muscle.GluteusMaximusInferior6.Pos = [0.00015,  0.21838,  0.033210] * scaleFactor;
LE(2).Muscle.GluteusMaximusSuperior1.Pos = [-0.01389, 0.365117, 0.067731] * scaleFactor;
LE(2).Muscle.GluteusMaximusSuperior2.Pos = [-0.01979, 0.355234, 0.065461] * scaleFactor;
LE(2).Muscle.GluteusMaximusSuperior3.Pos = [-0.02568, 0.345352, 0.063192] * scaleFactor;
LE(2).Muscle.GluteusMaximusSuperior4.Pos = [-0.02502, 0.330528, 0.059788] * scaleFactor;
LE(2).Muscle.GluteusMaximusSuperior5.Pos = [-0.0217,  0.315704, 0.056384] * scaleFactor;
LE(2).Muscle.GluteusMaximusSuperior6.Pos = [-0.0167,  0.30088,  0.052980] * scaleFactor;
LE(2).Muscle.GluteusMediusAnterior1.Pos = [-0.00379, 0.34932,0.06574] * scaleFactor;
LE(2).Muscle.GluteusMediusAnterior2.Pos = [0.00213, 0.34856, 0.06489] * scaleFactor;
LE(2).Muscle.GluteusMediusAnterior3.Pos = [0.000480, 0.3539, 0.06414] * scaleFactor;
LE(2).Muscle.GluteusMediusAnterior4.Pos = [0.00879, 0.35158, 0.06124] * scaleFactor;
LE(2).Muscle.GluteusMediusAnterior5.Pos = [0.00838, 0.35579, 0.05972] * scaleFactor;
LE(2).Muscle.GluteusMediusAnterior6.Pos = [0.01537, 0.35358, 0.05599] * scaleFactor;
LE(2).Muscle.GluteusMediusPosterior1.Pos = [-0.00718,0.35174,0.06344] * scaleFactor;
LE(2).Muscle.GluteusMediusPosterior2.Pos = [-0.01142,0.35907,0.05855] * scaleFactor;
LE(2).Muscle.GluteusMediusPosterior3.Pos = [-0.01014,0.34942,0.06367] * scaleFactor;
LE(2).Muscle.GluteusMediusPosterior4.Pos = [-0.01664,0.36185,0.05178] * scaleFactor;
LE(2).Muscle.GluteusMediusPosterior5.Pos = [-0.01579,0.35539,0.05894] * scaleFactor;
LE(2).Muscle.GluteusMediusPosterior6.Pos = [-0.01977,0.35915,0.05206] * scaleFactor;
LE(2).Muscle.GluteusMinimusAnterior1.Pos = [0.01523, 0.34569,0.05730] * scaleFactor;
LE(2).Muscle.GluteusMinimusAnterior1.Type(2,1) = {'Via'}; % via point added
LE(2).Muscle.GluteusMinimusAnterior1.Pos(2,1:3) = [0.01523,0.34569,0.05730] * scaleFactor;
% LE(2).Muscle.GluteusMinimusAnterior2.Pos = [] * ScaleFactor; % missing
LE(2).Muscle.GluteusMinimusMid1.Pos = [0.01635,0.33517,0.05715] * scaleFactor;
LE(2).Muscle.GluteusMinimusMid1.Type(2,1) = {'Via'}; % via point added
LE(2).Muscle.GluteusMinimusMid1.Pos(2,1:3) = [0.01635,0.33517,0.05715] * scaleFactor;
% LE(2).Muscle.GluteusMinimusMid2.Pos = [] * ScaleFactor; % missing
LE(2).Muscle.GluteusMinimusPosterior1.Pos = [0.01656,0.32615,0.05660] * scaleFactor;
LE(2).Muscle.GluteusMinimusPosterior1.Type(2,1) = {'Via'}; % via point added
LE(2).Muscle.GluteusMinimusPosterior1.Pos(2,1:3) = [0.01656,0.32615,0.05660] * scaleFactor;
% LE(2).Muscle.GluteusMinimusPosterior2.Pos = [] * ScaleFactor; % missing
LE(2).Muscle.Piriformis1.Pos = [0.00153,0.36326,0.05249] * scaleFactor;
% LE(2).Muscle.Sartorius1.Pos = [] * ScaleFactor; % Review needed

% Tibial muscle elements
LE(3).Muscle.TensorFasciaeLatae1.Pos = [0.01568,0.32738,0.03194] * scaleFactor;
% LE(3).Muscle.TensorFasciaeLatae2.Pos = [] * ScaleFactor; % Same as node 1
% LE(3).Muscle.Sartorius1.Pos = [0.01796,0.29020,-0.01085] * ScaleFactor; % Review needed

% Patellar muscle elements
LE(4).Muscle.RectusFemoris1.Pos = [0.00290,0.01391,- 0.00732] * scaleFactor;
LE(4).Muscle.RectusFemoris2.Pos = [0.00397,0.01249, 0.00462] * scaleFactor;

%% Update nearest node to femoral muscle origins, insertions and via points

femurNS = createns(LE(2).Mesh.vertices);
Fascicles = fieldnames(LE(2).Muscle);
for m = 1:length(Fascicles)
    LE(2).Muscle.(Fascicles{m}).Node = knnsearch(femurNS, LE(2).Muscle.(Fascicles{m}).Pos);
end

%% Save data
cachePath = strrep(mfilename('fullpath'), ['data\' mfilename], 'cache');
save(fullfile(cachePath, 'cache_TLEM2_1.mat'), 'LE', 'muscleList')

end