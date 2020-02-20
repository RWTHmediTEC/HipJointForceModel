function data = musclePathsTLEM2(data)
%MUSCLEPATHSTLEM2 Turns data from the muscles (Origin, Via Points,
%Insertion) and the surfaces to a struct

%% create the muscle paths
tic;
LE = data.S.LE;
MuscleList = data.MuscleList;
ActiveMuscles = data.activeMuscles;
% Find the Index of the active muscle in Muscle List
for i = 1:size(ActiveMuscles,1)
    tmpMuscles{i,1} = ActiveMuscles{i,1}(1:end-1);
end
mIdx = find(contains(MuscleList(:,1), tmpMuscles(:,1)));
% Initalizing variables
mPoints = {};
Via = {};
% check which Muscle Path is used
switch data.MusclePath
    case 'StraightLine'
        for i = 1:length(ActiveMuscles)
            for m = 1:length(mIdx) % loop through indexes of active muscles in muscle list
                if isequal(ActiveMuscles{i}(1:end-1),MuscleList{mIdx(m),1})
                    createMusclePoints;
                end
            end
        end
    case 'ViaPoint'
        for i = 1:length(ActiveMuscles)
            for m = 1:length(mIdx) % loop through indexes of active muscles in muscle list
                if isequal(ActiveMuscles{i}(1:end-1),MuscleList{mIdx(m),1})
                    createMusclePoints;
                end
            end
        end
    case 'Wrapping'
        for i = 1:length(ActiveMuscles)
            muscleWrappingSystem = {};
            for m = 1:length(mIdx) % loop through indexes of active muscles in muscle list
                if isequal(ActiveMuscles{i}(1:end-1),MuscleList{mIdx(m),1})
                    Origin = createMusclePoints;
                    if size(MusclePaths(i).Points,1) <= 2 % Checks if there are no Via Points
                        for b = 1:2 % loop through bones with Surfaces
                            Surface = fieldnames(LE(b).Surface);
                            for s = 1:length(Surface)
                                sBol = ismember(ActiveMuscles{i}(1:end-1), LE(b).Surface.(Surface{s}).Muscles); % check if muscles wrapps arround surface
                                if any(sBol)
                                    % Initialize values for MatGeom (see Documentation of MatGeom3D)
                                    testIntersection = {};
                                    cCenter = LE(b).Surface.(Surface{s}).Center; % Center of Cylinder
                                    cRadius = LE(b).Surface.(Surface{s}).Radius; % Radius of Cylinder
                                    cAxis = LE(b).Surface.(Surface{s}).Axis; % Axis of Cylinder
                                    cStart = cCenter + cAxis; % Start point of cylinder
                                    cEnd = cCenter - cAxis; % End point of cylinder
                                    testCylinder = [cStart, cEnd, cRadius]; % Cylinder definition for MatGeom
                                    testLine = createLine3d(MusclePaths(i).Points(1,:), MusclePaths(i).Points(end,:)); % Line for MatGeom between Origin and Insertion
                                    testIntersection = intersectLineCylinder(testLine, testCylinder, 'checkBounds', false); % Intersection Points of Line and Cylinder
                                    if ~isempty(testIntersection)
                                        % Initialize values for wrapping
                                        cRot = createRotationVector3d([0 0 1], cAxis); % Rotation matrix
                                        % inputs for Cylinder:
                                        % Center of Cylinder, matrix of
                                        % rotation, linear velocity,
                                        % angular velocity, radius, heigth
                                        % of cylinder
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
                                        switch data.Model
                                            case 'SchartzSitToStand2020'
                                                if contains(MusclePaths(i).Name{1},{'GluteusMaximus', 'PsoasMajor'})
                                                    qCyl = [theta height -vector(1) vector(2) arcLength];
                                                elseif contains(MusclePaths(i).Name{1},'Vastus')
                                                    qCyl = [theta-0.2 height -abs(vector(1)) vector(2) arcLength];
                                                else
                                                    qCyl = [theta height vector(1) vector(2) arcLength];
                                                end
                                            case {'SchartzOneLeggedStance2020', 'Debrunner1975', 'Eggert2018', 'Iglic1990', 'Pauwels1965'}
                                                if contains(MusclePaths(i).Name{1},'GluteusMaximus')
                                                    qCyl = [theta height vector(1) vector(2) arcLength];
                                                else
                                                    qCyl = [theta height -vector(1) vector(2) arcLength];
                                                end
                                        end
                                        % adds the surface to the muscle wrapping system
                                        muscleWrappingSystem = muscleWrappingSystem.addWrappingObstacle(wrappingCyl, qCyl);
                                        % check if straight line is
                                        % vertical to tangent vector of
                                        % cylinder
                                        straightVect = lineInsertion - lineOrigin;
                                        wrapVect = transformVector3d(muscleWrappingSystem.geodesics{1}.KP.t', cRot); % tangent vector
                                        angleVect = vectorAngle3d(straightVect, wrapVect)*180/pi;
                                        if abs(angleVect - 90) <= 15 && abs(angleVect - 90) >= -15
                                        	qCyl = [theta-0.3 height -vector(1) vector(2) arcLength]; % changing initial conditions for wrapping
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
                                    % Initialize values for MatGeom (see Documentation of MatGeom3D)
                                    % This loop finds the two points between which the muscle wraps
                                    for p = 1:size(MusclePaths(i).Points,1)-1 % loop through all the Points(Origin, Via, Insertion)
                                        testLine =  createLine3d(MusclePaths(i).Points(p,:), MusclePaths(i).Points(p+1,:)); % Line between two successive points
                                        cCenter = LE(b).Surface.(Surface{s}).Center; % Center of Cylinder
                                        cRadius = LE(b).Surface.(Surface{s}).Radius; % Radius of Cylinder
                                        cAxis = LE(b).Surface.(Surface{s}).Axis; % Axis of Cylinder
                                        cStart = cCenter + cAxis; % Start point of Cylinder
                                        cEnd = cCenter - cAxis; % End point of Cylinder
                                        % Origin of Gastrocnemius Lateralis lays in the cylinder. So radius of
                                        % cylinder is made smaller for that muscle so that origin is on cylinder.
                                        % Furthermore point can't lay on cylinder, therefore radius is made
                                        % smaller by 0.00001
                                        if isequal(MusclePaths(i).Name{:}(1:end-1),'GastrocnemiusLateralis')
                                            axisLine = createLine3d(cStart, cEnd);
                                            cRadius = distancePointLine3d(Origin, axisLine) - 0.00001;
                                        end
                                        testCylinder = [cStart, cEnd, cRadius]; % Cylinder definition for MatGeom
                                        testIntersection = intersectLineCylinder(testLine, testCylinder, 'checkBounds', false); % Intersection Points of Line and Cylinder
                                        % initalize 2 vectors with diffrent direction
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
                                            % inputs for Cylinder:
                                            % Center of Cylinder, matrix of
                                            % rotation, linear velocity,
                                            % angular velocity, radius, heigth
                                            % of cylinder
                                            cyl = Cylinder(cCenter', cRot(1:3,1:3), [0 0 0]', [0 0 0]', cRadius, 20*cRadius); % Cylinder initialization
                                            wrappingCyl = WrappingObstacle(cyl); % Initialization for wrapping Cylinder
                                            % initialize starting conditions for wrapping
                                            [~, theta, height, arcLength, vector] = startingPoint3d(testCylinder, MusclePaths(i).Points(p,:), MusclePaths(i).Points(p+1,:), cCenter, cAxis);
                                            % initialize wrapping system with the sucessive points
                                            muscleWrappingSystem = MuscleWrappingSystem(MusclePaths(i).Points(p,:)', MusclePaths(i).Points(p+1,:)');
                                            % define initial conditions for wrapping, depending on muscles
                                            % inputs for initial conditions
                                            % angle according to cylinder coordinates, heigth according to cylinder coordinates, tangent
                                            % vector defining initial direction, length of arc over the surface
                                            switch data.Model
                                                case 'SchartzSitToStand2020'
                                                    if contains(MusclePaths(i).Name{1},['GluteusMaximus', 'PsoasMajor'])
                                                        qCyl = [theta height -vector(1) vector(2) arcLength];
                                                    elseif contains(MusclePaths(i).Name{1},'Vastus')
                                                        qCyl = [theta+0.2 height -abs(vector(1)) vector(2) arcLength];
                                                    else
                                                        qCyl = [theta height vector(1) vector(2) arcLength];
                                                    end
                                                case 'SchartzOneLeggedStance2020'
                                                    if contains(MusclePaths(i).Name{1},'GluteusMaximus')
                                                        qCyl = [theta height vector(1) vector(2) arcLength];
                                                    else
                                                        qCyl = [theta height -vector(1) vector(2) arcLength];
                                                    end
                                            end
                                            % adds the surface to the muscle wrapping system
                                            muscleWrappingSystem = muscleWrappingSystem.addWrappingObstacle(wrappingCyl, qCyl);
                                        end
                                        
                                    end % p changes
                                end
                            end % s changes
                        end % b changes
                    end
                    mPoints = {};
                end
                % check if the muscle wrapps around the cylinder
                if isequal(MuscleList{mIdx(m),6},'WS') && ~isempty(muscleWrappingSystem)
                    for z = 1:4
                        % solves a root finding problem to find the shortest path over the cylinder
                        muscleWrappingSystem = muscleWrappingSystem.doNewtonStep();
                    end
                    % adds wrapping systen to muscle definition struct
                    MusclePaths(i).Surface = muscleWrappingSystem;
                end
            end % m change

        end % i changes
end

%% create the line of actions for Straight Line, Via Point and muscle wrapping
% StraightAction, ViaAction and WrapAction contains normalized vector and
% Starting Point for the Vector
for i = 1:length(MusclePaths)
    MusclePaths(i).StraightAction = [];
    MusclePaths(i).ViaAction = [];
    MusclePaths(i).WrapAction = [];
    % creates normalized vector for straight Line an Line of action for
    % straight line
    NormStraight = normalizeVector3d(MusclePaths(i).Points(end,:) - MusclePaths(i).Points(1,:));
    MusclePaths(i).StraightAction = [NormStraight; MusclePaths(i).Points(1,:)];
    % creates normalized vector for via Line and Line of action for via
    % points
    if size(MusclePaths(i).Points,1) > 2 && isempty(MusclePaths(i).Surface)
        if MusclePaths(i).idxFemur && MusclePaths(i).idxPelvis % checks if muscle is located on femur and pelvis
            NormVia = normalizeVector3d( ...
                        LE(2).Muscle.(MusclePaths(i).Name{:}).Pos(MusclePaths(i).idxFemur,:) - ...
                        LE(1).Muscle.(MusclePaths(i).Name{:}).Pos(MusclePaths(i).idxPelvis,:));
        else 
            NormVia = normalizeVector3d(MusclePaths(i).Points(2,:) - MusclePaths(i).Points(1,:));
        end
        MusclePaths(i).ViaAction = [NormVia; MusclePaths(i).Points(1,:)];
    % creates normalized vector for wrapping w/o via points and Line of
    % action
    elseif size(MusclePaths(i).Points,1) == 2 && ~isempty(MusclePaths(i).Surface)
        NormWrap = MusclePaths(i).Surface.straightLineSegments{1}.e'; 
        MusclePaths(i).WrapAction = [NormWrap; MusclePaths(i).Surface.straightLineSegments{1}.startPoint'];
    % creates normalized vector for wrapping with via points and Line of 
    % action. Checks if wrapping occurs between first two points of muscle
    % or not
    elseif size(MusclePaths(i).Points,1) > 2 && ~isempty(MusclePaths(i).Surface)
        % checks if muscle starts with wrapping
        if ~isequal(MusclePaths(i).Points(1,:), MusclePaths(i).Surface.straightLineSegments{1}.startPoint')
            if MusclePaths(i).idxFemur && MusclePaths(i).idxPelvis % checks if muscle is located on femur and pelvis
                NormWrap = normalizeVector3d( ...
                            LE(2).Muscle.(MusclePaths(i).Name{:}).Pos(MusclePaths(i).idxFemur,:) - ...
                            LE(1).Muscle.(MusclePaths(i).Name{:}).Pos(MusclePaths(i).idxPelvis,:));
            else
                NormWrap = normalizeVector3d(MusclePaths(i).Points(2,:) - MusclePaths(i).Points(1,:));
            end
            MusclePaths(i).WrapAction = [NormWrap; MusclePaths(i).Surface.straightLineSegments{1}.startPoint'];
        % checks if muscle starts with straight line from via points
        else
            NormWrap = MusclePaths(i).Surface.straightLineSegments{1}.e'; 
            MusclePaths(i).WrapAction = [NormWrap; MusclePaths(i).Surface.straightLineSegments{1}.startPoint'];
        end
    end
    if isempty(MusclePaths(i).ViaAction)
        MusclePaths(i).ViaAction = MusclePaths(i).StraightAction;
    end
    if isempty(MusclePaths(i).WrapAction)
        MusclePaths(i).WrapAction = MusclePaths(i).ViaAction;
    end
end
MusclePaths = rmfield(MusclePaths, 'idxPelvis');
MusclePaths = rmfield(MusclePaths, 'idxFemur');

data.S.MusclePaths = MusclePaths;
toc;

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
        vector = [thetaI-thetaO, heightI-heightO];
    end
	
	function Origin = createMusclePoints
        Via = [];
        for b = MuscleList{mIdx(m),3} % loop through bones with muscles associated to it
            if ismember(ActiveMuscles(i), fieldnames(LE(b).Muscle))
                oIdx = strcmp(LE(b).Muscle.(ActiveMuscles{i}).Type, 'Origin'); % get index of Origin
                if any(oIdx)
                    Origin = LE(b).Muscle.(ActiveMuscles{i}).Pos(oIdx,:); % get Origin
                end
                vIdx = strcmp(LE(b).Muscle.(ActiveMuscles{i}).Type, 'Via'); % get index of Via Points
                if any(vIdx)
                    Via = [Via; LE(b).Muscle.(ActiveMuscles{i}).Pos(vIdx,:)]; % get Via Points
                end
                iIdx = strcmp(LE(b).Muscle.(ActiveMuscles{i}).Type, 'Insertion'); % get index of Insertion
                if any(iIdx)
                    Insertion = LE(b).Muscle.(ActiveMuscles{i}).Pos(iIdx,:); % get Insertion
                end
                % Find most distal via point of pelvis an most
                % proximal point for femur. If muscle isn't
                % located on pelvis and/or femur, returns 0
                if b == 1
                    [~, idxPelvis] = min(LE(1).Muscle.(ActiveMuscles{i}).Pos(:,2));
                elseif b == 2
                    [~, idxFemur] = max(LE(2).Muscle.(ActiveMuscles{i}).Pos(:,2));
                elseif b ~= 1 || b ~= 2
                    idxPelvis = 0;
                    idxFemur = 0;
                end
            end
        end % b changes
        mPoints = [Origin; Via; Insertion];
        MusclePaths(i).Name = ActiveMuscles(i);
        MusclePaths(i).Points = mPoints;
        MusclePaths(i).Surface = {};
        MusclePaths(i).idxPelvis = idxPelvis;
        MusclePaths(i).idxFemur = idxFemur;
	end

end