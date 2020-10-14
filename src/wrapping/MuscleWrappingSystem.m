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

classdef MuscleWrappingSystem
   
    properties
        
        % Origin and insertion points
        O;
        I;
        
        % Geodesic parameters
        q;
        
        % Path error
        eps;
        
        globalPathErrorNorm;
        
        localPathErrorNorms;
        
        % Natural geodesic variations
        Dxi;
        
        % Path error Jacobian (d xi / d eps)
        J;
        
        % Wrapping surfaces
        wrappingObstacles;
        
        % Geodesic segments
        geodesics;
        
        % Straight-line segments
        straightLineSegments;
        
        % Total path length and rate of length change
        pathLength;
        pathLengthChange;
      
    end
    
    
    methods
        
        function [obj] = MuscleWrappingSystem(O, I)
            
           obj.O = O;
           obj.I = I;
           
           obj.q = [];
           
           obj.eps = [];
           
           obj.globalPathErrorNorm = [];
           
           obj.localPathErrorNorms = [];
           
           obj.Dxi = [];
           
           obj.J = [];
           
           obj.wrappingObstacles = {};
           
           obj.geodesics = {};
           
           obj.straightLineSegments = {};
           
           obj.pathLength = [];
           
           obj.pathLengthChange = [];
                
        end
        
        
        function [obj] = addWrappingObstacle(obj, wrappingObstacle, geodesicInitialConditions)

            n = length(obj.wrappingObstacles);
            
            obj.wrappingObstacles{n+1} = wrappingObstacle;
           
            obj.q((5*(n+1)-4):(5*(n+1)), 1) = geodesicInitialConditions;
            
            obj = obj.update();
            
        end
        
        
        function [obj] = update(obj)
            
            obj = obj.computeGeodesics();
            
            obj = obj.computeStraightLineSegments();
            
            obj = obj.computePathError();
            
            obj = obj.computePathErrorJacobian();
            
            obj = obj.computeNaturalGeodesicCorrections();
            
            obj = obj.computePathLength();
            
            obj = obj.computePathLengthChange();
            
        end
        
        
        function [obj] = computeGeodesics(obj)
            
            for i=1:length(obj.wrappingObstacles)
                
                Q0(1,1:2)  = [obj.q(5*i-4,1), ...
                              obj.q(5*i-3,1)];
                
                Qd0(1,1:2) = [obj.q(5*i-2,1), ...
                              obj.q(5*i-1,1)];
                
                curveLength = obj.q(5*i,1);
                
                steps = 20;
                
                obj.geodesics{i} = obj.wrappingObstacles{i}.computeArcLengthParameterizedGeodesic(Q0, Qd0, curveLength, steps);
                
            end
            
        end
        
        
        function [obj] = computeStraightLineSegments(obj)
            
            n = length(obj.wrappingObstacles);
            
            if (n > 0)
                
                for i=1:n+1
                
                    if (i == 1)
                        startPoint = obj.O;
                        endPoint   = obj.geodesics{i}.r + obj.geodesics{i}.R * obj.geodesics{i}.KP.x;
                    end 
                    
                    if (i > 1 && i < n+1)
                        startPoint = obj.geodesics{i-1}.r + obj.geodesics{i-1}.R * obj.geodesics{i-1}.KQ.x;
                        endPoint   = obj.geodesics{i  }.r + obj.geodesics{i  }.R * obj.geodesics{i  }.KP.x;
                    end
                    
                    if (i == n+1)
                        startPoint = obj.geodesics{i-1}.r + obj.geodesics{i-1}.R * obj.geodesics{i-1}.KQ.x;
                        endPoint   = obj.I;
                    end
                       
                    obj.straightLineSegments{i} = StraightLineSegment(startPoint, endPoint);
                    
                end
               
            else
                
                obj.straightLineSegments{1} = StraightLineSegment(obj.O, obj.I);
                
            end
            
        end
        
        
        function [obj] = computePathLength(obj)
            
            n = length(obj.wrappingObstacles);
            
            if (n > 0)
                
                obj.pathLength = 0;
            
                for i=1:n
                    obj.pathLength = obj.pathLength + obj.straightLineSegments{i}.l + obj.geodesics{i}.l;
                end
            
                obj.pathLength = obj.pathLength + obj.straightLineSegments{i+1}.l;
                
            elseif (n == 0)
                
               obj.pathLength = obj.straightLineSegments{1}.l;
                
            end
            
        end
        
        
        function [obj] = computePathLengthChange(obj)
            
            
            
        end
        
        
        function [obj] = computePathError(obj)
            
            n = length(obj.wrappingObstacles);
            
            if n > 0
                
                obj.eps = zeros(4*n,1);
                obj.localPathErrorNorms = zeros(n,1);
            
                for i=1:n
                
                    eP = obj.straightLineSegments{i  }.e;
                    eQ = obj.straightLineSegments{i+1}.e;
                   
                    NP = obj.geodesics{i}.R * obj.geodesics{i}.KP.N;
                    BP = obj.geodesics{i}.R * obj.geodesics{i}.KP.B;
                    
                    NQ = obj.geodesics{i}.R * obj.geodesics{i}.KQ.N;
                    BQ = obj.geodesics{i}.R * obj.geodesics{i}.KQ.B;
                    
                    obj.eps(4*i-3,1) = dot(eP, NP);
                    obj.eps(4*i-2,1) = dot(eP, BP);
                    
                    obj.eps(4*i-1,1) = dot(eQ, NQ);
                    obj.eps(4*i  ,1) = dot(eQ, BQ);
                    
                    obj.localPathErrorNorms(i) = norm(obj.eps((4*i-3):(4*i),1));
                   
                end
                
            else
                
                obj.eps = 0;
            
            end
            
            obj.globalPathErrorNorm = norm(obj.eps);
            
        end
        
        
        function [obj] = computePathErrorJacobian(obj)
           
            n = length(obj.wrappingObstacles);
            
            obj.J = zeros(4*n, 4*n);
            
            if (n > 0)
               
                for i=1:n
                    
                    % Darboux frame vectors in absolute coordinates
                    R = obj.geodesics{i}.R;
                    
                    tP = R * obj.geodesics{i}.KP.t;
                    NP = R * obj.geodesics{i}.KP.N;
                    BP = R * obj.geodesics{i}.KP.B;
                    
                    tQ = R * obj.geodesics{i}.KQ.t;
                    NQ = R * obj.geodesics{i}.KQ.N;
                    BQ = R * obj.geodesics{i}.KQ.B;
                    
                    % Unit vectors along straight-line segments in absolute
                    % coordinates
                    eP = obj.straightLineSegments{i  }.e;
                    eQ = obj.straightLineSegments{i+1}.e;
                    
                    lP = obj.straightLineSegments{i  }.l;
                    lQ = obj.straightLineSegments{i+1}.l; 
                    
                    % Normal curvature in tangential and binormal direction 
                    kappaNP_tan = obj.geodesics{i}.kappaNP_tan;
                    kappaNP_bin = obj.geodesics{i}.kappaNP_bin;
                    
                    kappaNQ_tan = obj.geodesics{i}.kappaNQ_tan;
                    kappaNQ_bin = obj.geodesics{i}.kappaNQ_bin;
                    
                    % Geodesic torsion in tangential and binormal
                    % direction
                    tauP_tan = obj.geodesics{i}.tauP_tan;
                    tauP_bin = obj.geodesics{i}.tauP_bin;
                    
                    tauQ_tan = obj.geodesics{i}.tauQ_tan;
                    tauQ_bin = obj.geodesics{i}.tauQ_bin;
                    
                    % Jacobi fields
                    aQ  = obj.geodesics{i}.aQ;
                    adQ = obj.geodesics{i}.adQ;
                    
                    rQ  = obj.geodesics{i}.rQ;
                    rdQ = obj.geodesics{i}.rdQ;
                    
                    % Derivatives of Darboux-frame vectors
                    % ------------------------------------
                    
                    % dKP / dsP
                    dNPdsP = -kappaNP_tan*tP - tauP_tan*BP;
                    dBPdsP =  tauP_tan*NP;
                    
                    % dKQ / dsP
                    dNQdsP = -kappaNQ_tan*tQ - tauQ_tan*BQ;
                    dBQdsP =  tauQ_tan*NQ;
   
                    % dKP / dbetaP
                    dNPdbetaP =  tauP_bin*tP - kappaNP_bin*BP;
                    dBPdbetaP =  kappaNP_bin*NP;
                    
                    % dKQ / dbetaP
                    dNQdbetaP = -aQ*tauQ_tan*tQ - aQ*kappaNQ_bin*BQ;
                    dBQdbetaP = -adQ*tQ + aQ*kappaNQ_bin*NQ;
                    
                    % dKP / dtheta
                    dBPdtheta = -tP;
                    
                    % dKQ / dtheta
                    dNQdtheta = -rQ*tauQ_tan*tQ - rQ*kappaNQ_bin*BQ;
                    dBQdtheta = -rdQ*tQ + rQ*kappaNQ_bin*NQ;
                    
                    % dKQ / dl
                    dNQdl = dNQdsP;
                    dBQdl = dBQdsP;
                    
                    % Derivatives of the straight-line unit vectors
                    % ---------------------------------------------
                    
                    % Left unit vector
                    dePdsP    = (tP - dot(eP, tP)*eP) / lP;
                    dePdbetaP = (BP - dot(eP, BP)*eP) / lP;
                    
                    % Right unit vector
                    deQdsQ    = (dot(eQ, tQ)*eQ - tQ) / lQ;
                    deQdbetaQ = (dot(eQ, BQ)*eQ - BQ) / lQ;
                    
                    deQdsP = deQdsQ;
                    deQdl  = deQdsQ;
                    
                    deQdbetaP = deQdbetaQ*aQ;
                    deQdtheta = deQdbetaQ*rQ;
                    
                    % Local path-error Jacobian
                    % ---------------------------------------------
                   
                    m = 4*i;
                    
                    % First row: eps1 = dot(e, NP)
                    obj.J(m-3, m-3) = dot(dePdsP,    NP) + dot(eP, dNPdsP); 
                    obj.J(m-3, m-2) = dot(dePdbetaP, NP) + dot(eP, dNPdbetaP);
                    
                    % Second row: eps2 = dot(e, BP)
                    obj.J(m-2, m-3) = dot(dePdsP,    BP) + dot(eP, dBPdsP);
                    obj.J(m-2, m-2) = dot(dePdbetaP, BP) + dot(eP, dBPdbetaP);
                    obj.J(m-2, m-1) =                      dot(eP, dBPdtheta);
                    
                    % Third row: eps3 = dot(e_, NQ)
                    obj.J(m-1, m-3) = dot(deQdsP,    NQ) + dot(eQ, dNQdsP); 
                    obj.J(m-1, m-2) = dot(deQdbetaP, NQ) + dot(eQ, dNQdbetaP); 
                    obj.J(m-1, m-1) = dot(deQdtheta, NQ) + dot(eQ, dNQdtheta);
                    obj.J(m-1, m  ) = dot(deQdl,     NQ) + dot(eQ, dNQdl);
                    
                    % Fourth row: eps4 = dot(e_, BQ)
                    obj.J(m  , m-3) = dot(deQdsP,    BQ) + dot(eQ, dBQdsP); 
                    obj.J(m  , m-2) = dot(deQdbetaP, BQ) + dot(eQ, dBQdbetaP); 
                    obj.J(m  , m-1) = dot(deQdtheta, BQ) + dot(eQ, dBQdtheta);
                    obj.J(m  , m  ) = dot(deQdl,     BQ) + dot(eQ, dBQdl);
                   
                    % Left coupling term (dependencies of the local path 
                    % error with respect to parameters of the left surface)
                    % -----------------------------------------------------
                    if (i > 1)
                       
                        aQ_left = obj.geodesics{i-1}.aQ;
                        rQ_left = obj.geodesics{i-1}.rQ;
                        
                        tQ_left = obj.geodesics{i-1}.R * obj.geodesics{i-1}.KQ.t;
                        BQ_left = obj.geodesics{i-1}.R * obj.geodesics{i-1}.KQ.B;
                        
                        dePdsQ_left    = (dot(eP, tQ_left)*eP - tQ_left) / lP;
                        dePdbetaQ_left = (dot(eP, BQ_left)*eP - BQ_left) / lP;
                        
                        dePdsP_left    = dePdsQ_left;
                        dePdbetaP_left = dePdbetaQ_left * aQ_left;
                        dePdtheta_left = dePdbetaQ_left * rQ_left;
                        dePdl_left     = dePdsQ_left;
                      
                        % First row
                        obj.J(m-3, m-7) = dot(dePdsP_left,    NP);
                        obj.J(m-3, m-6) = dot(dePdbetaP_left, NP);
                        obj.J(m-3, m-5) = dot(dePdtheta_left, NP);
                        obj.J(m-3, m-4) = dot(dePdl_left,     NP);
                        
                        % Second row
                        obj.J(m-2, m-7) = dot(dePdsP_left,    BP);
                        obj.J(m-2, m-6) = dot(dePdbetaP_left, BP);
                        obj.J(m-2, m-5) = dot(dePdtheta_left, BP);
                        obj.J(m-2, m-4) = dot(dePdl_left,     BP);
                        
                    end
                    
                    % Right coupling term (dependencies of the local path
                    % error with respect to parameters of the right surface)
                    % -----------------------------------------------------
                    if (i < n)
                       
                       tP_right = obj.geodesics{i+1}.R * obj.geodesics{i+1}.KP.t;
                       BP_right = obj.geodesics{i+1}.R * obj.geodesics{i+1}.KP.B;
                       
                       deQdsP_right    = (tP_right - dot(eQ, tP_right)*eQ) / lQ;
                       deQdbetaP_right = (BP_right - dot(eQ, BP_right)*eQ) / lQ;
                      
                       %  Third row
                       obj.J(m-1, m+1) = dot(NQ, deQdsP_right);
                       obj.J(m-1, m+2) = dot(NQ, deQdbetaP_right);
                       
                       % Fourth row
                       obj.J(m  , m+1) = dot(BQ, deQdsP_right);
                       obj.J(m  , m+2) = dot(BQ, deQdbetaP_right);
                       
                    end
                    
                end
                
            end
            
        end
        
        
        % This method is used to verify the explicit computation of J using
        % forward differences. Note that this method does not care about
        % the many zeros in the Jacobian and therefore is slow. 
        function [obj] = computePathErrorJacobianNumerically(obj)
            
            n = length(obj.wrappingObstacles);
           
            if (n > 0)
                
                % For numerical differentiation
                delta = 1e-6;
                
                % Evaluate initial path error
                obj = obj.computeGeodesics();
                obj = obj.computeStraightLineSegments();
                obj = obj.computePathError();
                
                % Save current "state"
                qSave   = obj.q;
                epsSave = obj.eps;
                
                obj.J = zeros(4*n,4*n);
            
                for i=1:(4*n)
                
                    % Reset geodesic parameters and path
                    obj.q = qSave;
                   
                    obj = obj.computeGeodesics();
                    obj = obj.computeStraightLineSegments();
                   
                    % Perturb parameter
                    obj.Dxi = zeros(4*n,1);
                    obj.Dxi(i,1) = delta;
                    
                    % Update system corresponding to perturbation
                    obj = obj.computeNewGeodesicParameters();
                    obj = obj.computeGeodesics();
                    obj = obj.computeStraightLineSegments();
                    obj = obj.computePathError();
                    
                    % Evaluate i-th column of J numerically
                    obj.J(:,i) = (obj.eps - epsSave) / delta;
                    
                end
                
                % Recover current "state"
                obj.q = qSave;
                
                obj = obj.computeGeodesics();
                obj = obj.computeStraightLineSegments();
                obj = obj.computePathError();
                
            end
           
        end
            
       
        function [obj] = computeNaturalGeodesicCorrections(obj)
            
            obj.Dxi = -obj.J \ obj.eps;
            
        end
        
        
        function [obj] = computeNewGeodesicParameters(obj)
            
            n = length(obj.wrappingObstacles);
            
            if (n > 0)
                
                for i=1:n
                   
                    % Updating start-point coordinates
                    % --------------------------------
                    
                    DsP    = obj.Dxi(4*i-3, 1);
                    DbetaP = obj.Dxi(4*i-2, 1);
                    
                    QP_old = [ obj.q(5*i-4,1) ; ...
                               obj.q(5*i-3,1) ];
                    
                    obj.wrappingObstacles{i}.surface = obj.wrappingObstacles{i}.surface.evaluateSurface(QP_old);
                    
                    tP = obj.geodesics{i}.KP.t;
                    BP = obj.geodesics{i}.KP.B;
                    
                    xuP = obj.wrappingObstacles{i}.surface.surfaceData.xu;
                    xvP = obj.wrappingObstacles{i}.surface.surfaceData.xv;
                    
                    NP = obj.wrappingObstacles{i}.surface.surfaceData.N;
                    
                    xuP_perp = cross(xuP, NP);
                    xvP_perp = cross(xvP, NP);
                    
                    % Coordinate transformation d(u,v)/d(s,beta)
                    T = [ dot(xvP_perp, tP)/dot(xvP_perp, xuP), dot(xvP_perp, BP)/dot(xvP_perp, xuP) ;
                          dot(xuP_perp, tP)/dot(xuP_perp, xvP), dot(xuP_perp, BP)/dot(xuP_perp, xvP) ];
                      
                    QP_new = QP_old + T*[DsP; DbetaP];
                    
                    obj.q(5*i-4,1) = QP_new(1);
                    obj.q(5*i-3,1) = QP_new(2);
                    
                    % Updating start-direction
                    % ------------------------
                    Dtheta = obj.Dxi(4*i-1,1);
                    
                    % Rotate tangent vector
                    t_rot = tP*cos(Dtheta) + BP*sin(Dtheta);
                    
                    [QdP_new, ~] = obj.wrappingObstacles{i}.projectVectorOntoTangentPlaneAndNormalize(QP_new, t_rot);
                    
                    obj.q(5*i-2,1) = QdP_new(1);
                    obj.q(5*i-1,1) = QdP_new(2);
                    
                    % Updating length
                    % ---------------
                    obj.q(5*i,1) = obj.q(5*i,1) + obj.Dxi(4*i,1);
                      
                end
                
            end
                        
        end
        
        
        function [obj] = doNewtonStep(obj)
           
            obj = obj.computeNaturalGeodesicCorrections();
            
            obj = obj.computeNewGeodesicParameters();
            
            obj = obj.update();
            
        end
        
        
        
        function [] = plotWrappingSystem(obj, ... 
                                         surfaceColor, ...
                                         straightLineSegmentStyle, ...
                                         geodesicSegmentStyle, ...
                                         pathLineWidth, ... 
                                         surfaceScale)
            
            n = length(obj.wrappingObstacles);
            
            if n > 0
            
                for i=1:n
                    
                    % Surfaces
                    edgeColor = 'default';
                    obj.wrappingObstacles{i}.surface.plotSurface(surfaceColor, edgeColor, surfaceScale);
                
                    % Geodesics
                    obj.geodesics{i}.plotGeodesicSegment(geodesicSegmentStyle, pathLineWidth);
                    
                    obj.geodesics{i}.KP.plotBoundaryPointFrame();
                    obj.geodesics{i}.KQ.plotBoundaryPointFrame()
                    
                    % Straight-line segments
                    obj.straightLineSegments{i}.plotStraightLineSegment(straightLineSegmentStyle, pathLineWidth);
                    
                end
                
                obj.straightLineSegments{i+1}.plotStraightLineSegment(straightLineSegmentStyle, pathLineWidth);
           
            else
                
                obj.straightLineSegments{1}.plotStraightLineSegment(straightLineSegmentStyle, pathLineWidth);
                
            end
            
            % Origin and insertion
            plot3(obj.O(1,1), obj.O(2,1), obj.O(3,1), 'og');
            plot3(obj.I(1,1), obj.I(2,1), obj.I(3,1), 'or');
           
        end
      
    end
 
end

