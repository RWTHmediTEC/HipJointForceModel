function [LE, muscleList] = importDataTLEM2_0()
% IMPORTDATATLEM2_0 Import TLEM 2.0 data and save as TLEM2_0.mat in data
% including the LE (Lower Extremity) struct and muscleList


%% Import .stl files
tempFileName = 'TLEM 2.0 - Bones - Local Reference Frame - ';

% Bone Names (BN)
Bones      = {'Pelvis', 'Femur',  'Tibia',         'Patella', 'Talus', 'Foot'           };
BoneSuffix = {' Right', ' Right', '-Fibula Right', ' Right', ' Right', ' straight Right'};

NoB = size(Bones,2);

LE = repmat(struct('Name',[]),1,6);
for b = 1:NoB
    % Lower Extremity (LE)
    LE(b).Name = Bones{b};
    % Load the bone surfaces described in the local (bone) coordinate system
    TR = stlread([tempFileName Bones{b} BoneSuffix{b} '.stl']);
    LE(b).Mesh.vertices = TR.Points;
    LE(b).Mesh.faces = TR.ConnectivityList;
end


%% Import joint centers
jRaw = readcell('TLEM 2.0 - Musculoskeletal Model Dataset - Table A6 - Joint Center and Axes.xlsx');
% Delete the first 3 lines
jRaw(1:3,:) = [];
% Delete lines only containing "nan"
jRaw(sum(cellfun('isclass', jRaw, 'char'),2)==0,:) = [];
% Replace nan by ''
jRaw(~cellfun('isclass', jRaw(:,1), 'char'),1) = {''};
% Get Joint Names (JN)
jRaw(:,1) = fillmissing(jRaw(:,1), 'previous');

for b = 1:NoB
    % Find joints of the bone
    jIdx = ismember(jRaw(:,2), Bones{b});
    jIdx = find(jIdx);
    joints = jRaw(jIdx,1);
    for j = 1:length(jIdx)
        LE(b).Joints.(joints{j}) = [];
        % Joint position in the local bone CS
        LE(b).Joints.(joints{j}).Pos = cell2mat(jRaw(jIdx(j),3:5))*1000; % [m] to [mm]
        % Joint axis in the local bone CS
        if all(cellfun(@isnumeric, jRaw(jIdx(j),6:8)))
            LE(b).Joints.(joints{j}).Axis = cell2mat(jRaw(jIdx(j),6:8));
        end
        check = find(strcmp(jRaw(:,1),joints{j}));
        
        if check(1) < jIdx(j)
            LE(b).Joints.(joints{j}).Parent = 1;
        else
            LE(b).Joints.(joints{j}).Parent = 0;
        end
    end
end

% Store parent bone
for j = 1:size(jRaw,1)/2
    childIdx = find(ismember({LE.Name},jRaw(j*2,2)));
    LE(childIdx).Parent = find(ismember({LE.Name},jRaw(j*2-1,2)));
end


%% Import muscle elements including PCSA (Physiological Cross-Sectional Areas)
mRaw = readcell('TLEM 2.0 - Musculoskeletal Model Dataset - Table A3 - Muscle-tendon lines-of-action.xlsx');
lRaw = readcell('TLEM 2.0 - Musculoskeletal Model Dataset - Table 1 - Muscle list.xlsx');
aRaw = readcell('TLEM 2.0 - Musculoskeletal Model Dataset - Table A7 - Muscle-tendon architecture.xlsx');
% Change RectusFemoris for consistency
aRaw(123:124,1) = {'RectusFemoris1', 'RectusFemoris2'};
% Delete the first 2 lines
mRaw(1:2,:) = [];
aRaw(1:2,:) = [];
lRaw(1:2,:) = [];
% Replace nan by ''
mRaw(~cellfun('isclass', mRaw(:,1), 'char'),1) = {''};
mRaw(~cellfun('isclass', mRaw(:,2), 'char'),2) = {''};
% Erase spaces
mRaw(:,1:2) = erase(mRaw(:,1:2),' ');
muscleList = mRaw(:,1);
lRaw(:,1) = erase(lRaw(:,1),' ');
% Fill missing names
mRaw(:,1:2) = fillmissing(mRaw(:,1:2),'previous');
% Special case: PsoasMajor starts with a Via point and not with Origin
emptyIdx = find(cellfun('isclass', mRaw(:,5), 'char'));
% Replace 'Via' by 'Origin'
mRaw(emptyIdx+1,3) = {'Origin'};
% Delete empty Origins
mRaw(emptyIdx,:) = [];
% Convert coordinates
mRaw(:,5) = num2cell(1000 * cell2mat(mRaw(:,5:7)),2); % [m] to [mm]
mRaw(:,6:7) = [];

% Muscles list
muscleList(cellfun(@isempty, muscleList)) = [];
% Create colormap
cmap = round(rand(length(muscleList),3),4);
muscleList(:,2) = num2cell(cmap,2);

% Muscle bones
for m = 1:length(muscleList)
    mBIdx = ismember(mRaw(:,1), muscleList{m,1});
    muscleData = mRaw(mBIdx,:);
    muscleList{m,3} = find(ismember(Bones, unique(muscleData(:,4),'stable')));
    % Number of fascicles of the muscle
    muscleList{m,4} = max(str2double(strrep(muscleData(:,2), muscleList{m,1}, '')));
    % Check if each fascicle of one muscle has the same number of connection points
    NoC = size(muscleData,1) / muscleList{m,4};
    if ~isequal(repmat(muscleData(1:NoC,4), muscleList{m,4},1), muscleData(:,4))
        warning(['Fascicles of ' muscleList{m,1} ' are inconsistent!'])
    end
    % Add PCSA for the muscle
    tempRaw = cellfun(@(x) regexp(x,'\D+','match'), aRaw(:,1));
    mBIdx = ismember(tempRaw, muscleList{m,1});
    muscleData = aRaw(mBIdx,:);
    % Check if PCSA value is the same for each fascicle of the muscle
    musclePCSA = unique(cell2mat(muscleData(:,5)));
    assert(length(musclePCSA)==1)
    muscleList{m,5} = muscleList{m,4} * musclePCSA * 100; % [cm²] to [mm²]
    if isequal(lRaw(m,1), muscleList(m,1))
        % add lines of action
        muscleList(m,6) = lRaw(m,3);
        % Add mass
        muscleList(m,7) = lRaw(m,6);
    end
end

% Fascicle list
fascicleList = mRaw(:,2);
for b = 1:NoB
    LE(b).Muscle = [];
    % Get the muscles that are connected to the bone
    mIdx = find(ismember(string(mRaw(:,4)), Bones{1,b}));
    Fascicles = fascicleList(mIdx);
    for m = 1:length(mIdx)
        if ~isfield(LE(b).Muscle, Fascicles{m})
            % Create muscle field if it does not exist
            LE(b).Muscle.(Fascicles{m}).Type = mRaw(mIdx(m),3);
            LE(b).Muscle.(Fascicles{m}).Pos = mRaw{mIdx(m),5};
        else
            % Append the muscle point to the muscle
            LE(b).Muscle.(Fascicles{m}).Type = ...
                [LE(b).Muscle.(Fascicles{m}).Type; mRaw(mIdx(m),3)];
            LE(b).Muscle.(Fascicles{m}).Pos = ...
                [LE(b).Muscle.(Fascicles{m}).Pos; mRaw{mIdx(m),5}];
        end
    end
end

% Save node closest to muscle origins, insertions and via points
for b = 1:NoB
    if ~isempty(LE(b).Muscle)
        Fascicles = fieldnames(LE(b).Muscle);
        for m = 1:length(Fascicles)
            LE(b).Muscle.(Fascicles{m}).Node = knnsearch(LE(b).Mesh.vertices, LE(b).Muscle.(Fascicles{m}).Pos);
        end
    end
end

%% Import wrapping surfaces
sRaw = readcell('TLEM 2.0 - Musculoskeletal Model Dataset - Table A5 - Wrapping Surfaces.xlsx');
% Delete 3 first rows
sRaw(1:3,:) = [];
% Erase spaces
sRaw(:,1) = erase(sRaw(:,1),' ');

% Add surface data (center, axis and radius of the cylinder) to data struct
for s = 1:size(sRaw,1)
    for b = 1:size(LE,2)
        if isequal(sRaw{s,2},LE(b).Name)
            LE(b).Surface.(sRaw{s,1}).Center = cell2mat(sRaw(s,3:5))*1000;
            LE(b).Surface.(sRaw{s,1}).Axis = cell2mat(sRaw(s,6:8));
            LE(b).Surface.(sRaw{s,1}).Radius = cell2mat(sRaw(s,9))*1000;
        end
    end
end
% Add muscles to surface they wrap over !!! Where does this info come from? !!!
LE(1).Surface.GluteusMaximus.Muscles = {...
    'GluteusMaximusInferior'; ...
    'GluteusMaximusSuperior'};
LE(2).Surface.Iliopsoas.Muscles = {...
    'IliacusLateralis'; ...
    'IliacusMedialis'; ...
    'IliacusMid'; ...
    'RectusFemoris'; ...
    'PsoasMajor'};
LE(2).Surface.QuadricepsFemoris.Muscles = {...
    'VastusIntermedius'; ...
    'VastusLateralisInferior'; ...
    'VastusLateralisSuperior'; ...
    'VastusMedialisInferior'; ...
    'VastusMedialisMid'; ...
    'VastusMedialisSuperior'; ...
    'RectusFemoris'};
LE(2).Surface.Gastrocnemius.Muscles = {...
    'GastrocnemiusLateralis'; ...
    'GastrocnemiusMedialis'; ...
    'Plantaris'};


%% Import bony landmarks
lmRaw = readcell('TLEM 2.0 - Musculoskeletal Model Dataset - Table A2 - Bony landmarks.xlsx');

for b = 1:NoB
    LE(b).Landmarks = [];
end

% Indices of required landmarks (line1) and indices of related bones (line2)
REQ = [5:11, 14:17];
REQ(2,1:7)  = deal(1);
REQ(2,8:11) = deal(2); % More landmarks can be added here

% Erase spaces
lmRaw(REQ(1,1:length(REQ))) = erase(lmRaw(REQ(1,1:length(REQ))),' ');

% Create landmark fields including coordinates
for r = 1:length(REQ)
    LE(REQ(2,r)).Landmarks.(lmRaw{REQ(1,r)}).Pos = cell2mat(lmRaw(REQ(1,r),2:4))*1000; % [m] to [mm]
end

% Save node closest to landmark
for b = 1:NoB
    if ~isempty(LE(b).Landmarks)
        Landmarks = fieldnames(LE(b).Landmarks);
        for lm = 1:length(Landmarks)
            [LE(b).Landmarks.(Landmarks{lm}).Node, tempDist] = ...
                knnsearch(LE(b).Mesh.vertices, LE(b).Landmarks.(Landmarks{lm}).Pos);
            if tempDist > 3 % [mm]
                warning(['The landmark ' Landmarks{lm} ' was more than 3 mm away' ...
                    ' from the nearest vertex. Therefore no node was saved!'])
                LE(b).Landmarks.(Landmarks{lm})=...
                    rmfield(LE(b).Landmarks.(Landmarks{lm}), 'Node');
            end
        end
    end
end

%% Add additional landmarks
load('TLEM 2.0 - Additional bony landmarks.mat','TLEM2_0_Landmarks')
% Pelvis
addLMpelvis = {...
    'AcetabularRoof_R';...
    'InferiorIschialTuberosity_R';...
    'PosteriorIschialTuberosity_R';...
    'RightIschialSpine';...
    'PosteriorInferiorIliacSpine_R';...
    'RightPosteriorSuperiorIliacSpine';...
    'SuperiorIliacCrest_R';...
    'IliacTubercle_R';...
    'RightAnteriorSuperiorIliacSpine';...
    'RightAnteriorInferiorIliacSpine';...
    'RightPubicTubercle';...
    'MedialPubis_R';...
    'MedialIlium_R';...
    };
for lm = 1:size(addLMpelvis,1)
    LE(1).Landmarks.(addLMpelvis{lm,1}).Pos  = TLEM2_0_Landmarks(1).Landmarks.(addLMpelvis{lm,1}).Pos;
    if isfield(TLEM2_0_Landmarks(1).Landmarks.(addLMpelvis{lm,1}), 'Node')
        LE(1).Landmarks.(addLMpelvis{lm,1}).Node = TLEM2_0_Landmarks(1).Landmarks.(addLMpelvis{lm,1}).Node;
    end
end
% Construction of the Pubic Symphysis
LE(1).Landmarks.PubicSymphysis.Pos = [...
    LE(1).Landmarks.RightPubicTubercle.Pos(1:2), ...
    LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(3) - ...
    1/2 * (LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(3) - ...
    LE(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos(3))];

% Femur
addLMfemur = {...
    'SuperiorGreaterTrochanter';...
    'P1';...
    'P2';...
    'MedialPosteriorCondyle';...
    'LateralPosteriorCondyle';...
    };
for lm = 1:size(addLMfemur,1)
    LE(2).Landmarks.(addLMfemur{lm,1}).Pos  = TLEM2_0_Landmarks(2).Landmarks.(addLMfemur{lm,1}).Pos;
    if isfield(TLEM2_0_Landmarks(2).Landmarks.(addLMfemur{lm,1}), 'Node')
        LE(2).Landmarks.(addLMfemur{lm,1}).Node = TLEM2_0_Landmarks(2).Landmarks.(addLMfemur{lm,1}).Node;
    end
end


%% Save data
cachePath = strrep(mfilename('fullpath'), ['data\' mfilename], 'cache');
save(fullfile(cachePath, 'cache_TLEM2_0.mat'), 'LE', 'muscleList')

end