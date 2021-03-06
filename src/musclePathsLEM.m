function data = musclePathsLEM(data)
%MUSCLEPATHSLEM constructs the paths of the active muscles.
%
% Reference:
% [Scholz 2015] 2015 - Scholz et al. - A fast multi-obstacle muscle 
%   wrapping method using natural geodesic variations
%   https://doi.org/10.1007/s11044-015-9451-1
%
% AUTHOR: L. Schartz
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

if data.Verbose
    tStart = tic;
end
%% Create the muscle paths
LE = data.S.LE;
MuscleList = data.MuscleList;
MusclePathModel = data.MusclePathModel;
ActiveMuscles = parseActiveMusclesLEM(data.activeMuscles, MuscleList);
% Create the muscle paths variable
MusclePaths = cell2struct(ActiveMuscles(:,1)',{'Name'});
% Find the index of the active muscle in Muscle List
MuscleListIdx = nan(size(MusclePaths));
MuscleBones = cell(size(MusclePaths));
MusclePathModels = cell(size(MusclePaths));
% Extract parameters from the MuscleList for the active muscles
for i = 1:length(MusclePaths)
    mlIdx = find(strcmp(MusclePaths(i).Name(1:end-1),MuscleList(:,1)));
    if isempty(mlIdx)
        errMessage = [MusclePaths(i).Name(1:end-1) ' is not part of the ' ...
            'muscle list of the cadaver! Choose another cadaver!'];
        if data.Verbose
            msgbox(errMessage,mfilename,'error')
        end
        error(errMessage)
    else
        MuscleListIdx(i,1) = mlIdx;
    end
    MuscleBones{i,1} = MuscleList{MuscleListIdx(i),3};
    MusclePathModels{i,1} = MuscleList{MuscleListIdx(i),6};
end

% Create MusclePaths struct for StraightLine and ViaPoint model
for i = 1:length(MusclePaths)
    % Loop through the bones that are connected to the muscle
    Via = [];
    for b = MuscleBones{i,1}
        if ismember(MusclePaths(i).Name, fieldnames(LE(b).Muscle))
            oIdx = strcmp(LE(b).Muscle.(MusclePaths(i).Name).Type, 'Origin'); % get index of Origin
            if any(oIdx)
                Origin = LE(b).Muscle.(MusclePaths(i).Name).Pos(oIdx,:); % get Origin
            end
            vIdx = strcmp(LE(b).Muscle.(MusclePaths(i).Name).Type, 'Via'); % get index of Via Points
            if any(vIdx)
                Via = [Via; LE(b).Muscle.(MusclePaths(i).Name).Pos(vIdx,:)]; %#ok<AGROW> % get Via Points
            end
            iIdx = strcmp(LE(b).Muscle.(MusclePaths(i).Name).Type, 'Insertion'); % get index of Insertion
            if any(iIdx)
                Insertion = LE(b).Muscle.(MusclePaths(i).Name).Pos(iIdx,:); % get Insertion
            end
        end
    end % b changes
    MusclePaths(i).Points = [Origin; Via; Insertion];
    MusclePaths(i).Surface = {};
end

% Update MusclePaths struct for Wrapping
if strcmp(MusclePathModel,'Wrapping')
    for i = 1:length(ActiveMuscles)
        if isequal(MuscleList{MuscleListIdx(i,1),6},'WS')
            % Initialize the muscle wrapping system (MWS)
            MWS = {};
            if size(MusclePaths(i).Points,1) <= 2 % Checks if there are no Via Points
                for b = 1:2 % loop through bones with Surfaces
                    Surface = fieldnames(LE(b).Surface);
                    for s = 1:length(Surface)
                        sBol = ismember(ActiveMuscles{i}(1:end-1), LE(b).Surface.(Surface{s}).Muscles); % check if muscles wrapps arround surface
                        if any(sBol)
                            % Initialize matGeom cylinder
                            cCenter = LE(b).Surface.(Surface{s}).Center; % Center of cylinder
                            cRadius = LE(b).Surface.(Surface{s}).Radius; % Radius of cylinder
                            cAxis = LE(b).Surface.(Surface{s}).Axis; % Axis of cylinder
                            cStart = cCenter + cAxis; % Start point of cylinder
                            cEnd = cCenter - cAxis; % End point of cylinder
                            testCylinder = [cStart, cEnd, cRadius]; % Cylinder definition of matGeom
                            % Initialize matGeom line between origin and insertion
                            testLine = createLine3d(MusclePaths(i).Points(1,:), MusclePaths(i).Points(end,:));
                            % Test line cylinder intersection
                            testIntersection = intersectLineCylinder(testLine, testCylinder, 'checkBounds', false); % Intersection Points of Line and Cylinder
                            if ~isempty(testIntersection)
                                % Initialize values for wrapping
                                cRot = createRotationVector3d([0 0 1], cAxis); % Rotation matrix
                                % Cylinder inputs: center, rotation matrix, linear velocity, angular velocity, radius, heigth
                                cyl = Cylinder(cCenter', cRot(1:3,1:3), [0 0 0]', [0 0 0]', cRadius, 20*cRadius); % Cylinder initialization
                                wrappingCyl = WrappingObstacle(cyl); % Initialization for wrapping Cylinder
                                if isempty(MWS)
                                    lineOrigin = MusclePaths(i).Points(1,:); % creating new start Point
                                    lineInsertion = MusclePaths(i).Points(end,:);
                                    % initialize starting conditions for wrapping
                                    [~, theta, height, arcLength, vector] = startingPoint3d(testCylinder, lineOrigin, lineInsertion, cCenter, cAxis);
                                    % initialize wrapping system with Origin and Insertion
                                    MWS = MuscleWrappingSystem(lineOrigin', lineInsertion');
                                elseif ~isempty(MWS)
                                    % If there is more than one wrapping surface, the start point on the cylinder has to be adjusted
                                    geoLen = length(MWS.wrappingObstacles); % Numbers of geodesic elements
                                    lineOrigin = MWS.straightLineSegments{1, geoLen+1}.startPoint'; % creating new start Point
                                    % initialize starting conditions for wrapping
                                    [~, theta, height, arcLength, vector] = startingPoint3d(testCylinder, lineOrigin, lineInsertion, cCenter, cAxis);
                                end
                                % define initial conditions for wrapping, depending on muscles
                                % inputs for initial conditions
                                % angle according to cylinder coordinates, heigth according to cylinder coordinates, tangent
                                % vector defining initial direction, length of arc over the surface
                                qCyl = [theta height -abs(vector(1)) vector(2) arcLength];
                                switch data.Posture
                                    case 'SU'
                                        if contains(MusclePaths(i).Name,'Vastus')
                                            qCyl(1) = qCyl(1)-0.3;
                                            qCyl(5) = qCyl(5)*2/3;
                                        end
                                end
                                % adds the surface to the muscle wrapping system
                                MWS = MWS.addWrappingObstacle(wrappingCyl, qCyl);
                                % check if straight line is
                                % vertical to tangent vector of
                                % cylinder
                                straightVect = lineInsertion - lineOrigin;
                                wrapVect = transformVector3d(MWS.geodesics{1}.KP.t', cRot); % tangent vector
                                angleVect = rad2deg(vectorAngle3d(wrapVect,straightVect));
                                if abs(angleVect - 90) <= 15 && abs(angleVect - 90) >= -15
                                    angleCorrection = 0.3;
                                    qCyl(1) = qCyl(1)  -angleCorrection; % changing initial conditions for wrapping
                                    MWS = MuscleWrappingSystem(lineOrigin', lineInsertion');
                                    MWS = MWS.addWrappingObstacle(wrappingCyl, qCyl);
                                end
                            end
                        end
                    end
                end
            elseif size(MusclePaths(i).Points,1) > 2 % check if there are Via Points
                for b = 1:2 % loop through bones with Surfaces
                    Surface = fieldnames(LE(b).Surface);
                    for s = 1:length(Surface)
                        sBol = ismember(ActiveMuscles{i}(1:end-1), LE(b).Surface.(Surface{s}).Muscles); % check if muscles wrapps arround surface
                        if any(sBol)
                            % Initialize matGeom cylinder
                            for p = 1:size(MusclePaths(i).Points,1)-1 % loop through all the Points(Origin, Via, Insertion)
                                testLine =  createLine3d(MusclePaths(i).Points(p,:), MusclePaths(i).Points(p+1,:)); % Line between two successive points
                                cCenter = LE(b).Surface.(Surface{s}).Center; % Center of Cylinder
                                cRadius = LE(b).Surface.(Surface{s}).Radius; % Radius of Cylinder
                                cAxis = LE(b).Surface.(Surface{s}).Axis; % Axis of Cylinder
                                cStart = cCenter + cAxis; % Start point of Cylinder
                                cEnd = cCenter - cAxis; % End point of Cylinder
                                % Origin of Gastrocnemius Lateralis lays in the cylinder. Hence, the radius of
                                % the cylinder is made smaller for this muscle that origin is outside the cylinder.
                                if isequal(MusclePaths(i).Name(1:end-1),'GastrocnemiusLateralis')
                                    axisLine = createLine3d(cStart, cEnd);
                                    cRadius = distancePointLine3d(MusclePaths(i).Points(1,:), axisLine) - 0.00001;
                                end
                                testCylinder = [cStart, cEnd, cRadius]; % Cylinder definition for MatGeom
                                % Check if the line of the muscle path segment intersects the cylinder
                                testIntersection = intersectLineCylinder(testLine, testCylinder, 'checkBounds', false);
                                % Check if cylinder lies between the muscle points of the muscle path segment
                                [v1, v2] = deal(nan);
                                if ~isempty(testIntersection) 
                                    % Vector from the 1st muscle point to the 1st cylinder intersection
                                    v1 = round(normalizeVector3d(testIntersection(1,:) - MusclePaths(i).Points(p,:)),6);
                                    % Vector from the 2nd muscle point to the 2nd cylinder intersection
                                    v2 = round(normalizeVector3d(testIntersection(2,:) - MusclePaths(i).Points(p+1,:)),6);
                                end
                                % The muscle path segment intersects the cylinder if the line of the muscle 
                                % path segment intersects the cylinder and vectors v1 & v2 are antiparallel.
                                if ~isempty(testIntersection) && isequal(v1, -v2)
                                    % Initialize values for wrapping
                                    cRot = createRotationVector3d([0 0 1], cAxis); % Rotaion matrix of the cylinder
                                    % Cylinder inputs: center, rotation matrix, linear velocity, angular velocity, radius, heigth
                                    cyl = Cylinder(cCenter', cRot(1:3,1:3), [0 0 0]', [0 0 0]', cRadius, 20*cRadius); % Cylinder initialization
                                    wrappingCyl = WrappingObstacle(cyl); % Initialization for wrapping Cylinder
                                    % initialize starting conditions for wrapping
                                    [~, theta, height, arcLength, vector] = startingPoint3d(testCylinder, MusclePaths(i).Points(p,:), MusclePaths(i).Points(p+1,:), cCenter, cAxis);
                                    % initialize wrapping system with the successive points
                                    MWS = MuscleWrappingSystem(MusclePaths(i).Points(p,:)', MusclePaths(i).Points(p+1,:)');
                                    % define initial conditions for wrapping, depending on muscles
                                    % inputs for initial conditions
                                    % angle according to cylinder coordinates, heigth according to cylinder coordinates, tangent
                                    % vector defining initial direction, length of arc over the surface
                                    qCyl = [theta height -abs(vector(1)) vector(2) arcLength];
                                    % Add the surface to the muscle wrapping system
                                    MWS = MWS.addWrappingObstacle(wrappingCyl, qCyl);
                                end
                            end
                        end
                    end
                end
            end
            
            if ~isempty(MWS)
                for z = 1:4
                    % solves a root finding problem to find the shortest path over the cylinder
                    MWS = MWS.doNewtonStep();
                end
                % !!! WORKAROUND !!! - Sanity check in case Newton steps did not work
                if sum(abs(MWS.Dxi)) > 1
                    if data.Verbose
                        warning(['Wrapping did not work for ' MusclePaths(i).Name ...
                            '. Resetting to a simpler muscle path model for this fascile.'])
                    end
                else
                    % Add wrapping system to MusclePaths struct
                    MusclePaths(i).Surface = MWS;
                end
                
            end
            clearvars MWS
        end
    end
end

%% Create the points representing the muscles in case of wrapping
for m = 1:length(MusclePaths)
    if ~isempty(MusclePaths(m).Surface)
        musclePoints = [];
        MWS = MusclePaths(m).Surface;
        % Check if there are additional via points before the wrapping
        viaStartIdx = find(ismembertol(MusclePaths(m).Points, ...
            MWS.straightLineSegments{1}.startPoint', 'ByRows',1));
        if viaStartIdx ~= 1
            musclePoints = [musclePoints; MusclePaths(m).Points(1:viaStartIdx-1,:)]; %#ok<AGROW>
        end
        % Add wrapping points
        for ws = 1:length(MWS.wrappingObstacles)
            % StraightLine
            musclePoints = [musclePoints; ...
                MWS.straightLineSegments{ws}.startPoint'; MWS.straightLineSegments{ws}.endPoint']; %#ok<AGROW>
            % Wrapping
            MWS.geodesics{ws} = MWS.geodesics{ws}.computeCurveInGlobalCoordinates;
            musclePoints = [musclePoints; MWS.geodesics{ws}.xGlobal']; %#ok<AGROW>
        end
        musclePoints = [musclePoints; ...
            MWS.straightLineSegments{ws+1}.startPoint'; MWS.straightLineSegments{ws+1}.endPoint']; %#ok<AGROW>
        % Check if there are additional via points after the wrapping
        viaEndIdx = find(ismembertol(MusclePaths(m).Points, ...
            MWS.straightLineSegments{ws+1}.endPoint', 'ByRows',1));
        if viaEndIdx ~= size(MusclePaths(m).Points,1)
            musclePoints = [musclePoints; MusclePaths(m).Points(viaEndIdx+1:end,:)]; %#ok<AGROW>
        end
        MusclePaths(m).Points = musclePoints;
    end
end

%% % Create the lines of action for the muscle path models
MusclePaths = linesOfActionLEM(LE, MusclePaths);

data.S.MusclePaths = MusclePaths;
if data.Verbose
    disp(['Muscle path modeling took ' num2str(toc(tStart),'%.0f') ' seconds.'])
end

end

function [points, thetaO, heightO, length, vector] = startingPoint3d(cyl, O, I, Center, Axis)
%STARTINGPOINT3D creates starting point for geodesic element
line = createLine3d(O, I);
points = intersectLineCylinder(line, cyl, 'checkBounds', false);
rot = createRotationVector3d(Axis, [0 0 1]);
rot(1:3,4) = Center;
points(1,:) = points(1,:) - Center;
points(1,:) = transformPoint3d(points(1,:), rot(1:3,1:3));
points(2,:) = points(2,:) - Center;
points(2,:) = transformPoint3d(points(2,:), rot(1:3,1:3));
length = distancePoints3d(points(2,:),points(1,:));
[thetaO,~,heightO] = cart2cyl(points(1,:));
[thetaI,~,heightI] = cart2cyl(points(2,:));
vector = normalizeVector3d([thetaI-thetaO, heightI-heightO]);
end