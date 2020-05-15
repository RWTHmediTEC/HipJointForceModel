function data = musclePathsTLEM2(data)
%MUSCLEPATHSTLEM2 constructs the lines of action of the active muscles

%% create the muscle paths
tStart = tic;
LE = data.S.LE;
MuscleList = data.MuscleList;
MusclePathModel = data.MusclePathModel;
ActiveMuscles = data.activeMuscles;
MusclePaths = cell2struct(ActiveMuscles(:,1)',{'Name'});
% Switch sign for right and left side
switch data.S.Side; case 'R'; side = 1; case 'L'; side = -1; end
% Find the Index of the active muscle in Muscle List
MuscleListIdx=nan(size(MusclePaths));
MuscleBones=cell(size(MusclePaths));
MusclePathModels=cell(size(MusclePaths));
% Extract parameters from the MuscleList for the active muscles
for i = 1:length(MusclePaths)
    mlIdx = find(strcmp(MusclePaths(i).Name(1:end-1),MuscleList(:,1)));
    if isempty(mlIdx)
        error('Muscle is not part of the muscle list of the cadaver! Choose another cadaver!')
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
            % Find most distal via point of pelvis an most
            % proximal point for femur. If muscle isn't
            % located on pelvis and/or femur, returns 0
            if b == 1
                [~, idxPelvis] = min(LE(1).Muscle.(MusclePaths(i).Name).Pos(:,2));
            elseif b == 2
                [~, idxFemur] = max(LE(2).Muscle.(MusclePaths(i).Name).Pos(:,2));
            elseif b ~= 1 || b ~= 2
                idxPelvis = 0;
                idxFemur = 0;
            end
        end
    end % b changes
    MusclePaths(i).Points = [Origin; Via; Insertion];
    MusclePaths(i).Surface = {};
    MusclePaths(i).idxPelvis = idxPelvis;
    MusclePaths(i).idxFemur = idxFemur;
end

% Update MusclePaths struct for Wrapping model
if strcmp(MusclePathModel,'Wrapping')
    for i = 1:length(ActiveMuscles)
        if isequal(MuscleList{MuscleListIdx(i,1),6},'WS')
            muscleWrappingSystem = {};
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
                                if ~isempty(muscleWrappingSystem)
                                    % If there is more than one wrapping surface, the start point on the cylinder has to be adjusted
                                    geoLen = length(muscleWrappingSystem.wrappingObstacles); % Numbers of geodesic elements
                                    lineOrigin = muscleWrappingSystem.straightLineSegments{1, geoLen+1}.startPoint'; % creating new start Point
                                    % initialize starting conditions for wrapping
                                    [~, theta, height, arcLength, vector] = startingPoint3d(testCylinder, lineOrigin, lineInsertion, cCenter, cAxis);
                                elseif isempty(muscleWrappingSystem)
                                    lineOrigin = MusclePaths(i).Points(1,:); % creating new start Point
                                    lineInsertion = MusclePaths(i).Points(end,:);
                                    % initialize starting conditions for wrapping
                                    [~, theta, height, arcLength, vector] = startingPoint3d(testCylinder, lineOrigin, lineInsertion, cCenter, cAxis);
                                    % initialize wrapping system with Origin and Insertion
                                    muscleWrappingSystem = MuscleWrappingSystem(lineOrigin', lineInsertion');
                                end
                                % define initial conditions for wrapping, depending on muscles
                                % inputs for initial conditions
                                % angle according to cylinder coordinates, heigth according to cylinder coordinates, tangent
                                % vector defining initial direction, length of arc over the surface
                                qCyl = [theta height -side*abs(vector(1)) vector(2) arcLength];
                                switch data.Posture
                                    case 'SU'
                                        if contains(MusclePaths(i).Name,'Vastus')
                                            qCyl(1) = qCyl(1)-side*0.3;
                                            qCyl(5) = qCyl(5)*2/3;
                                        end
                                end
                                % adds the surface to the muscle wrapping system
                                muscleWrappingSystem = muscleWrappingSystem.addWrappingObstacle(wrappingCyl, qCyl);
                                % check if straight line is
                                % vertical to tangent vector of
                                % cylinder
                                straightVect = lineInsertion - lineOrigin;
                                wrapVect = transformVector3d(muscleWrappingSystem.geodesics{1}.KP.t', cRot); % tangent vector
                                angleVect = rad2deg(vectorAngle3d(wrapVect,straightVect));
                                if abs(angleVect - 90) <= 15 && abs(angleVect - 90) >= -15
                                    angleCorrection = 0.3;
                                    qCyl(1) = qCyl(1)  -side*angleCorrection; % changing initial conditions for wrapping
                                    muscleWrappingSystem = MuscleWrappingSystem(lineOrigin', lineInsertion');
                                    muscleWrappingSystem = muscleWrappingSystem.addWrappingObstacle(wrappingCyl, qCyl);
                                end
                            end
                        end
                    end % s changes
                end % b changes
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
                                testIntersection = intersectLineCylinder(testLine, testCylinder, 'checkBounds', false); % Intersection Points of Line and Cylinder
                                % initalize 2 vectors with diffrent directions
                                v1 = [1 0 0];
                                v2 = [0 1 0];
                                % vectors from first muscle point to cylinder intersection and from second muscle point to cylinder intersection
                                if ~isempty(testIntersection) % checks if muscle passes through cylinder
                                    v1 = round(normalizeVector3d(testIntersection(1,:) - MusclePaths(i).Points(p,:)),6);
                                    v2 = round(normalizeVector3d(testIntersection(2,:) - MusclePaths(i).Points(p+1,:)),6);
                                end
                                % checks if muscle passes through cylinder and if vectors have opposing directions
                                % if vectors have opposing directions the cylinder lies between the two sucessive points
                                if ~isempty(testIntersection) && isequal(v1, -v2)
                                    % Initialize values for wrapping
                                    cRot = createRotationVector3d([0 0 1], cAxis); % Rotaion matrix of the cylinder
                                    % Cylinder inputs: center, rotation matrix, linear velocity, angular velocity, radius, heigth
                                    cyl = Cylinder(cCenter', cRot(1:3,1:3), [0 0 0]', [0 0 0]', cRadius, 20*cRadius); % Cylinder initialization
                                    wrappingCyl = WrappingObstacle(cyl); % Initialization for wrapping Cylinder
                                    % initialize starting conditions for wrapping
                                    [~, theta, height, arcLength, vector] = startingPoint3d(testCylinder, MusclePaths(i).Points(p,:), MusclePaths(i).Points(p+1,:), cCenter, cAxis);
                                    % initialize wrapping system with the successive points
                                    muscleWrappingSystem = MuscleWrappingSystem(MusclePaths(i).Points(p,:)', MusclePaths(i).Points(p+1,:)');
                                    % define initial conditions for wrapping, depending on muscles
                                    % inputs for initial conditions
                                    % angle according to cylinder coordinates, heigth according to cylinder coordinates, tangent
                                    % vector defining initial direction, length of arc over the surface
                                    qCyl = [theta height -side*abs(vector(1)) vector(2) arcLength];
                                    % adds the surface to the muscle wrapping system
                                    muscleWrappingSystem = muscleWrappingSystem.addWrappingObstacle(wrappingCyl, qCyl);
                                end
                                
                            end % p changes
                        end
                    end % s changes
                end % b changes
            end

            if ~isempty(muscleWrappingSystem)
                for z = 1:4
                    % solves a root finding problem to find the shortest path over the cylinder
                    muscleWrappingSystem = muscleWrappingSystem.doNewtonStep();
                end
                % adds wrapping system to MusclePaths struct
                MusclePaths(i).Surface = muscleWrappingSystem;
            end
        end
    end % i changes
end

%% Create the lines of action for the muscle path models
% Contains origin and direction vector for each model
for i = 1:length(MusclePaths)
    MusclePaths(i).StraightLine = [];
    MusclePaths(i).ViaPoint = [];
    MusclePaths(i).Wrapping = [];
    % creates normalized vector for straight Line an Line of action for
    % straight line
    NormStraight = normalizeVector3d(MusclePaths(i).Points(end,:) - MusclePaths(i).Points(1,:));
    MusclePaths(i).StraightLine = [MusclePaths(i).Points(1,:) NormStraight];
    % creates normalized vector for via Line and Line of action for via
    % points
    if size(MusclePaths(i).Points,1) > 2 && isempty(MusclePaths(i).Surface)
        if MusclePaths(i).idxFemur && MusclePaths(i).idxPelvis % checks if muscle is located on femur and pelvis
            NormVia = normalizeVector3d( ...
                LE(2).Muscle.(MusclePaths(i).Name).Pos(MusclePaths(i).idxFemur,:) - ...
                LE(1).Muscle.(MusclePaths(i).Name).Pos(MusclePaths(i).idxPelvis,:));
        else
            NormVia = normalizeVector3d(MusclePaths(i).Points(2,:) - MusclePaths(i).Points(1,:));
        end
        MusclePaths(i).ViaPoint = [MusclePaths(i).Points(1,:) NormVia];
        % creates normalized vector for wrapping w/o via points and Line of
        % action
    elseif size(MusclePaths(i).Points,1) == 2 && ~isempty(MusclePaths(i).Surface)
        NormWrap = MusclePaths(i).Surface.straightLineSegments{1}.e';
        MusclePaths(i).Wrapping = [MusclePaths(i).Surface.straightLineSegments{1}.startPoint' NormWrap];
        % creates normalized vector for wrapping with via points and Line of
        % action. Checks if wrapping occurs between first two points of muscle
        % or not
    elseif size(MusclePaths(i).Points,1) > 2 && ~isempty(MusclePaths(i).Surface)
        % checks if muscle starts with wrapping
        if ~isequal(MusclePaths(i).Points(1,:), MusclePaths(i).Surface.straightLineSegments{1}.startPoint')
            if MusclePaths(i).idxFemur && MusclePaths(i).idxPelvis % checks if muscle is located on femur and pelvis
                NormWrap = normalizeVector3d( ...
                    LE(2).Muscle.(MusclePaths(i).Name).Pos(MusclePaths(i).idxFemur,:) - ...
                    LE(1).Muscle.(MusclePaths(i).Name).Pos(MusclePaths(i).idxPelvis,:));
            else
                NormWrap = normalizeVector3d(MusclePaths(i).Points(2,:) - MusclePaths(i).Points(1,:));
            end
            MusclePaths(i).Wrapping = [MusclePaths(i).Surface.straightLineSegments{1}.startPoint' NormWrap];
            % checks if muscle starts with straight line from via points
        else
            NormWrap = MusclePaths(i).Surface.straightLineSegments{1}.e';
            MusclePaths(i).Wrapping = [MusclePaths(i).Surface.straightLineSegments{1}.startPoint' NormWrap];
        end
    end
    if isempty(MusclePaths(i).ViaPoint)
        MusclePaths(i).ViaPoint = MusclePaths(i).StraightLine;
    end
    if isempty(MusclePaths(i).Wrapping)
        MusclePaths(i).Wrapping = MusclePaths(i).ViaPoint;
    end
end
MusclePaths = rmfield(MusclePaths, 'idxPelvis');
MusclePaths = rmfield(MusclePaths, 'idxFemur');

data.S.MusclePaths = MusclePaths;
mpTime = toc(tStart);
disp(['Muscle path modeling took ' num2str(mpTime,1) ' seconds.'])

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