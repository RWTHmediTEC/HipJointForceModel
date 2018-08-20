function data = createDataTLEM2()
% Build structure which contains default data

if ~exist('data\TLEM2.mat', 'file')
    importDataTLEM2
end
load('TLEM2', 'LE', 'muscleList')

data = struct(...
    'Dataset', 1,...            % Choosen dataset, 1:TLEM 2, 2:TLEM 2.1
    'View', 1,...               % View of the HJF, 1:Pelvis, 2:Femur
    'Side', 'R',...             % Side of the regarded hip joint, R:Right, L:Left
    'BW', 45,...                % Patient's body weight [kg]
    'PB', 0,...                 % Pelvic Bend [°]
    'FL', 0,...
    'Offset', 0,...
    'CCD', 0,...
    'AT', 0);
                  
data.originalLE = LE;
data.MuscleList = muscleList;

end