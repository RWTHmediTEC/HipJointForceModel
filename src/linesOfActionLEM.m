function MusclePaths = linesOfActionLEM(LE, MusclePaths)
% Create the lines of action for the muscle path models

% Contains origin and a normalized direction vector for each model
for i = 1:length(MusclePaths)
    MusclePaths(i).StraightLine = [];
    MusclePaths(i).ViaPoint = [];
    MusclePaths(i).Wrapping = [];
    % Create line of action for StraightLine
    MusclePaths(i).StraightLine = shortestDistanceJoint2MusclePath(...
        LE(1).Joints.Hip.Pos, MusclePaths(i).Points([1 end],:));
    % Creates line of action for ViaPoint without Wrapping
    if size(MusclePaths(i).Points,1) > 2 && isempty(MusclePaths(i).Surface)
        MusclePaths(i).ViaPoint = shortestDistanceJoint2MusclePath(...
            LE(1).Joints.Hip.Pos, MusclePaths(i).Points);
    elseif ~isempty(MusclePaths(i).Surface)
        MusclePaths(i).Wrapping = shortestDistanceJoint2MusclePath(...
            LE(1).Joints.Hip.Pos, MusclePaths(i).Points);
    end
    % Creates line of action for Wrapping
    if isempty(MusclePaths(i).ViaPoint)
        MusclePaths(i).ViaPoint = MusclePaths(i).StraightLine;
    end
    if isempty(MusclePaths(i).Wrapping)
        MusclePaths(i).Wrapping = MusclePaths(i).ViaPoint;
    end
end
end

function lineOfAction = shortestDistanceJoint2MusclePath(jointCenter, musclePoints)
% Use the closest point of the muscle path to the joint center as origin
% and the associated edge as line of action

% Create edges
muscleEdges = [musclePoints(1:end-1,:) musclePoints(2:end,:)];
% Distance between the joint center and the edges
[distance, muscleEdgePosition] = distancePointEdge3d(jointCenter, muscleEdges);
% Find the minimum distance and associated edge
[~, minIdx] = min(distance);
edgeOfAction = muscleEdges(minIdx,:);
edgePosition = muscleEdgePosition(minIdx);

% Calculate line of action
lineOfAction(1:3) = edgeOfAction(1:3) + edgePosition * (edgeOfAction(4:6) - edgeOfAction(1:3));
lineOfAction(4:6) = normalizeVector3d(edgeOfAction(4:6) - edgeOfAction(1:3));
end