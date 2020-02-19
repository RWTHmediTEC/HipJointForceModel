% -------------------------------------------------------------------------
%
% Author: Andreas Scholz 2015
% scholz.andreas@uni-due.de
% 
% Department of Mechanics and Robotics, University of Duisburg-Essen
% Lotharstr. 1
% 47057 Duisburg
% Germany
%
% See also:
% A. Scholz, M. Sherman, I. Stavness, S. Delp, A. Kecskeméthy. A Fast
% Multi-Obstacle Muscle Wrapping Method Using Natural Geodesic Variations.
% Multibody System Dynamics, Springer, 2015. DOI 10.1007/s11044-015-9451-1
% 
% www.uni-due.de/mechanikb/musclewrapping.php
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% 1) MATLAB settings and miscellaneous commands
% -------------------------------------------------------------------------
  clc
  clear all
  close all
  
  format short
  
  numberOfPathCorrections = 4;
  
  klickButtonToIterate = true;
  
% -------------------------------------------------------------------------
% 2) Define three wrapping objects
% -------------------------------------------------------------------------
  
% Cylinder 
  rCyl = [-5 0 0]';
  RCyl = computeRotationMatrixFromEulerAngles([0 0.4*pi 0]);
  cyl  = Cylinder(rCyl, RCyl, [0 0 0]', [0 0 0]', 1.5, 4);

% Elliposid
  rEll = [0 0 1]';
  REll = computeRotationMatrixFromEulerAngles([0 0 0]);
  ell  = Ellipsoid(rEll, REll, [0 0 0]', [0 0 0]', 2, 2.5, 3.5);
 
% Torus
  rTor = [5 0 0]';
  RTor = computeRotationMatrixFromEulerAngles([0.5*pi 0.4*pi 0]);
  tor  = Torus(rTor, RTor, [0 0 0]', [0 0 0]', 2, 1);
  
% Wrapping Obstacles
  wrappingCyl = WrappingObstacle(cyl);
  wrappingEll = WrappingObstacle(ell);
  wrappingTor = WrappingObstacle(tor);
  
% -------------------------------------------------------------------------
% 3) Define a muscle wrapping system
% -------------------------------------------------------------------------

% Origin and insertion
  O = [-10 -1  -2]';
  I = [ 10  1  -1]';
  
% Initial conditions for each wrapping obstacle
  qCyl = [0.75*pi  0         -1     -0.2     2]';
  qEll = [1.1      2          0     -1       1]';
  qTor = [0        1.25*pi    0     -1       1]';

% Muscle wrapping system
  muscleWrappingSystem = MuscleWrappingSystem(O, I);
  
  muscleWrappingSystem = muscleWrappingSystem.addWrappingObstacle(wrappingCyl, qCyl);
  muscleWrappingSystem = muscleWrappingSystem.addWrappingObstacle(wrappingEll, qEll);
  muscleWrappingSystem = muscleWrappingSystem.addWrappingObstacle(wrappingTor, qTor);
  
% -------------------------------------------------------------------------
% 4) Verify explicit Jacobian vs. numerical Jacobian
% -------------------------------------------------------------------------
  display('### Time for computing the path-error Jacobian numerically:')
  tic 
    muscleWrappingSystem = muscleWrappingSystem.computePathErrorJacobianNumerically();
    Jnum = muscleWrappingSystem.J;
  t = toc;
  display([num2str(t) ' seconds']);
  
  display('### Time for computing the path-error Jacobian analytically:')
  tic 
    muscleWrappingSystem = muscleWrappingSystem.computePathErrorJacobian();
    J = muscleWrappingSystem.J;
  t = toc;
  display([num2str(t) ' seconds']);
  
  display('### Maximum difference between analytic and numerical Jacobian:') 
  display(num2str(max(max(J - Jnum))));
  
% -------------------------------------------------------------------------
% 4) Result plots
% -------------------------------------------------------------------------
  figure(1)
  hold on
  axis equal
  view([190 30])
  title('Muscle Wrapping System')
 
  globalPathErrorNorm = zeros(numberOfPathCorrections, 1);
  cylinderError       = zeros(numberOfPathCorrections, 1);
  ellipsoidError      = zeros(numberOfPathCorrections, 1);
  torusError          = zeros(numberOfPathCorrections, 1);
 
  display('The initial path-error norm is:')
  display(num2str(muscleWrappingSystem.globalPathErrorNorm));
  
  display(['### Do ' num2str(numberOfPathCorrections) ' path iterations ...'])
  
  for i = 1:numberOfPathCorrections+1
 
    muscleWrappingSystem.plotWrappingSystem('white', ...
                                            '-r',    ...
                                            '-r',    ...
                                            1.0,     ...
                                            0.99)
                              
    globalPathErrorNorm(i,1) = muscleWrappingSystem.globalPathErrorNorm;
    cylinderError(i,1)       = muscleWrappingSystem.localPathErrorNorms(1);
    ellipsoidError(i,1)      = muscleWrappingSystem.localPathErrorNorms(2);
    torusError(i,1)          = muscleWrappingSystem.localPathErrorNorms(3);
  
    muscleWrappingSystem = muscleWrappingSystem.doNewtonStep();
  
    if (klickButtonToIterate == true)
        waitforbuttonpress();
    end
                                      
  end
  
  display('... done.')
  
  display('The final path-error norm is:')
  display(num2str(muscleWrappingSystem.globalPathErrorNorm));
  
  display('The total path length is:')
  display(num2str(muscleWrappingSystem.pathLength));
  
  figure(2)
  hold on
  grid on
  plot(0:numberOfPathCorrections, globalPathErrorNorm, '-k')
  plot(0:numberOfPathCorrections, cylinderError,       '-r')
  plot(0:numberOfPathCorrections, ellipsoidError,      '-b')
  plot(0:numberOfPathCorrections, torusError,          '-m')
  title('Path errors over iterations')
  xlabel('number of path iterations')
  ylabel('path errors')
  legend('global', 'cylinder', 'ellipsoid', 'torus')
  
  
  
 
  
  
                                      

 
                           
  
  
  
