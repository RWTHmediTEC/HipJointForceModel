function data = createDataTLEM2()
% Build structure which contains default data

if exist('data\TLEM2.mat', 'file')
    load('TLEM2', 'LE', 'muscleList')
else
    importDataTLEM2
end

data = struct(...
    'Side', 'R',...             % Side of the regarded hip joint, R:Right, L:Left
    'BW', 45,...                % Patient's body weight [kg]
    'PB', 0);                   % Pelvic Bend [°]
                  
data.LE = LE;
data.MuscleList = muscleList;
end