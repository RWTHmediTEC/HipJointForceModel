clc
clear
close all

numberOfPathCorrections = 4;

run importDataWrappingSurfaces.m
data = createDataTLEM2();

%% Creating wrapping cylinder
% Boolean Array to see which muscle has wrapping
wrap(size(muscleList,1),1) = false;
for m = 1:size(muscleList,1)
    for s = 1:size(surfaceList,1)
        if isequal(muscleList(m,1),surfaceList(s,1))
           wrap(m,1) = true;
        end
    end
end

% Nob = 2 %size(LE, 2);
% Nows = size(surfaceList, 1);

%% Creating values for cylinder

cCenter = cell(4,1);
cAxis = cell(4,1);
cRadius = cell(4,1);
cRot = cell(4,1);

for b = 1:2
    for s  = 1:size(surfaceList, 1)
        if isequal(LE(b).Name, surfaceList{s,2})
            cCenter{s,1} = LE(b).Surface.(surfaceList{s,1}).Center;
            cAxis{s,1} = LE(b).Surface.(surfaceList{s,1}).Axis;
            cRadius{s,1} = LE(b).Surface.(surfaceList{s,1}).Radius;
            cRot{s,1} = createRotationVector3d([0 0 1], cAxis{s,1});
            temp = cell2mat(cRot(s,1));
            temp(4,:)=[];
            temp(:,4)=[];
            cRot{s,1} = num2cell(temp);
        end
    end
end

rCyl = cCenter{4,1}; % cCenter{4,1};
RCyl = cell2mat(cRot{4,1});
cyl  = Cylinder(rCyl', RCyl, [0 0 0]', [0 0 0]', cRadius{4,1}, 10*cRadius{4,1});

wrappingCyl = WrappingObstacle(cyl);
  
% -------------------------------------------------------------------------
% 3) Define a muscle wrapping system
% -------------------------------------------------------------------------

% Origin and insertion
O = LE(2).Muscle.GastrocnemiusMedialis1.Pos(1,:)';
I = LE(6).Muscle.GastrocnemiusMedialis1.Pos';
  
% Initial conditions for each wrapping obstacle
qCyl = [0.3*pi 4.5*cRadius{4,1} -1 -10 10]';    % [0.1*pi 0 70 0 20]';
% [(Radiale Richtung, 0 kürzeste strecke zu O) ...
%     (Axiale Richtung, mitte ist 0) ...
%     (radialer Anteil des Vektors) ...
%     (axialer Anteil des Vektors) ...
%     (länge des curved segment)]

% Muscle wrapping system
muscleWrappingSystem = MuscleWrappingSystem(O, I);
muscleWrappingSystem = muscleWrappingSystem.addWrappingObstacle(wrappingCyl, qCyl);

% -------------------------------------------------------------------------
% 4) Result plots
% -------------------------------------------------------------------------
figure('Position', [950 150 580 530])
hold on
axis equal
view([-120 -60])
% title('Muscle Wrapping System')
xlabel('x')
ylabel('y')
zlabel('z')

% plot3(rCyl(1), rCyl(2), rCyl(3), 'oy');
% plot3([0, -cAxis{4,1}(1)*20], [0, -cAxis{4,1}(2)*20], [0, -cAxis{4,1}(3)*20], '-m');
for i = 1:numberOfPathCorrections+1

	muscleWrappingSystem.plotWrappingSystem('white', ...
                                            '-r',    ...
                                            '-b',    ...
                                            3.0,     ...
                                            1)

    muscleWrappingSystem = muscleWrappingSystem.doNewtonStep();
                 
end