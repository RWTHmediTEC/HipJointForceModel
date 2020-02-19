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

classdef WrappingObstacle
   
    properties
       
        surface;
        
    end
    
    methods
        
        function [obj] = WrappingObstacle(surface)
            
           obj.surface = surface;
            
        end
        
        
        function [geodesicBoundaryPointFrame] = computeGeodesicBoundaryPointFrame(obj, Q, Qd)
            
             obj.surface = obj.surface.evaluateSurface(Q);
             
             x = obj.surface.surfaceData.x;
             
             t = obj.surface.surfaceData.xu*Qd(1) + obj.surface.surfaceData.xv*Qd(2);
             
             t = (t / norm(t));
             
             N = obj.surface.surfaceData.N;
             
             B = cross(t, N);
             
             geodesicBoundaryPointFrame = GeodesicBoundaryPointFrame(obj.surface.r, ... 
                                                                     obj.surface.R, ...
                                                                     obj.surface.v, ...
                                                                     obj.surface.w, ...
                                                                     x, t, N, B);
             
        end
        
        
        function [v, speed] = computeUnitTangentVector(obj, Q, Qd)
            
           obj.surface = obj.surface.evaluateSurface(Q);
           
           v =   obj.surface.surfaceData.xu*Qd(1,1) ...
               + obj.surface.surfaceData.xv*Qd(1,2);
                
           speed = norm(v);
           
           v = v / speed;
               
        end
        
        
        function [Qd, v] = projectVectorOntoTangentPlaneAndNormalize(obj, Q, v)
          
            % Point of projection
            obj.surface = obj.surface.evaluateSurface(Q);
            
            E = obj.surface.surfaceData.FF1(1,1);
            F = obj.surface.surfaceData.FF1(1,2);
            G = obj.surface.surfaceData.FF1(1,3);
            
            % Non-normalized components of v
            A = 1 / (E*G-F^2) * [ G -F ; ...
                                 -F  E ];
                                          
            Qd = A * [ dot(v, obj.surface.surfaceData.xu) ; ...
                       dot(v, obj.surface.surfaceData.xv) ];
                       
            % Normalized components of v
            Qd = 1 / sqrt(E*Qd(1)^2 + 2*F*Qd(1)*Qd(2) + G*Qd(2)^2) * Qd;
            
            % Normalized vector v
            v = obj.surface.surfaceData.xu*Qd(1) + ...
                obj.surface.surfaceData.xv*Qd(2);
            
        end
        
        
        
        function [Qd, v] = projectVectorOntoTangentPlaneAndNormalize2(obj, Q, v)
          
            % Point of projection
            obj.surface = obj.surface.evaluateSurface(Q);
            
            xu = obj.surface.surfaceData.xu;
            xv = obj.surface.surfaceData.xv;
            N  = obj.surface.surfaceData.N;
            
            xu_perp = cross(xu, N);
            xv_perp = cross(xv, N);
                       
            du = dot(v, xv_perp) / dot(xu, xv_perp);
            dv = dot(v, xu_perp) / dot(xv, xu_perp);
            
            v = xu*du + xv*dv;
            
            speed = norm(v);
            
            v = v / speed;
            
            Qd(1,1) = du / speed;
            Qd(1,2) = dv / speed;
            
        end
        
        
        
        function [Qd, speed] = normalizeGeodesicInitialConditions(obj, Q, Qd)
           
            [~, speed] = obj.computeUnitTangentVector(Q, Qd);
            
            Qd = Qd / speed;
            
        end
        
        
        
        function [Qd, v] = rotateTangentVector(obj, Q, Qd, angle)
            
            [t, ~] = obj.computeUnitTangentVector(Q, Qd);
            
            obj.surface = obj.surface.evaluateSurface(Q);
            
            N = obj.surface.surfaceData.N;
            
            B = cross(t, N);
            
            v = t*cos(angle) + B*sin(angle);
            
            Qd = obj.projectVectorOntoTangentPlaneAndNormalize(Q, v);
            
        end
        
        
        
        function [geodesic] = computeArcLengthParameterizedGeodesic(obj, Q0, Qd0, length, steps)
            
            Qd0 = obj.normalizeGeodesicInitialConditions(Q0, Qd0);
            
            geodesic = GeodesicSegment( obj.surface.r, ...
                                        obj.surface.R, ... 
                                        obj.surface.v, ...
                                        obj.surface.w );
                                    
            [Q, Qd, a, ad, r, rd, s] = obj.integrateGeodesicStateSpaceEquations(Q0, ...
                                                                                Qd0, ...
                                                                                geodesic.aP, ...
                                                                                geodesic.adP, ...
                                                                                geodesic.rP, ...
                                                                                geodesic.rdP, ...
                                                                                0, ...
                                                                                length, ...
                                                                                steps);
            % Shortcuts
            % 
            % tan = tangential direction
            % bin = binormal direction
            QP = Q(1,:);
            QQ = Q(end,:);
            
            QdP_tan = Qd(1,:);
            QdP_bin = obj.rotateTangentVector(QP, QdP_tan, 0.5*pi);
            
            QdQ_tan = Qd(end,:);
            QdQ_bin = obj.rotateTangentVector(QQ, QdQ_tan, 0.5*pi);
                         
            % Darboux trihedrons
            geodesic.KP = obj.computeGeodesicBoundaryPointFrame(QP, QdP_tan);
            geodesic.KQ = obj.computeGeodesicBoundaryPointFrame(QQ, QdQ_tan);
            
            % Normal curvature
            geodesic.kappaNP_tan = obj.surface.computeNormalCurvature(QP, QdP_tan);
            geodesic.kappaNP_bin = obj.surface.computeNormalCurvature(QP, QdP_bin);
            
            geodesic.kappaNQ_tan = obj.surface.computeNormalCurvature(QQ, QdQ_tan);
            geodesic.kappaNQ_bin = obj.surface.computeNormalCurvature(QQ, QdQ_bin);
            
            % Geodesic torsion
            geodesic.tauP_tan = obj.surface.computeGeodesicTorsion(QP, QdP_tan);
            geodesic.tauP_bin = obj.surface.computeGeodesicTorsion(QP, QdP_bin);
            
            geodesic.tauQ_tan = obj.surface.computeGeodesicTorsion(QQ, QdQ_tan);
            geodesic.tauQ_bin = obj.surface.computeGeodesicTorsion(QQ, QdQ_bin);
            
            % Jacobi fields
            geodesic.aQ  = a(end);
            geodesic.adQ = ad(end);
            
            geodesic.rQ  = r(end);
            geodesic.rdQ = rd(end);
            
            % Length
            geodesic.l = s(end);
            
            % Polygon for plotting
            geodesic.xLocal = zeros(3,steps+1);
            for i=1:(steps+1)
               
                obj.surface = obj.surface.evaluateSurface(Q(i,:));
                
                geodesic.xLocal(:,i) = obj.surface.surfaceData.x;
                
            end
          
        end
        
        
        
        function [Q, Qd, a, ad, r, rd, s] = integrateGeodesicStateSpaceEquations(obj, Q0, Qd0, a0, ad0, r0, rd0, tStart, tEnd, steps)
            
            tStepSize = (tEnd - tStart) / steps;
            
            [s, Z] = ode45(@obj.stateSpaceEquations, tStart:tStepSize:tEnd, [Q0(1,1), Q0(1,2), Qd0(1,1), Qd0(1,2), a0, ad0, r0, rd0]);
            
            Q  = Z(:, 1:2);
            Qd = Z(:, 3:4);
            a  = Z(:, 5);
            ad = Z(:, 6);
            r  = Z(:, 7);
            rd = Z(:, 8);
            
        end
        
        
     
        function [Zd] = stateSpaceEquations(obj, ~, Z)
            
            % Transformation
            u  = Z(1);
            v  = Z(2);
            ud = Z(3);
            vd = Z(4);
            a  = Z(5);
            ad = Z(6);
            r  = Z(7);
            rd = Z(8);
            
            % Evaluate surface at current point
            obj.surface = obj.surface.evaluateSurface([u, v]);
            
            A =  dot(obj.surface.surfaceData.xuu, ... 
                     obj.surface.surfaceData.xv);
            
            B =  dot(obj.surface.surfaceData.xu, ...
                     obj.surface.surfaceData.xvv);
                  
            C = dot(obj.surface.surfaceData.xu, ...
                    obj.surface.surfaceData.xuv);
                     
            D = dot(obj.surface.surfaceData.xuv, ...
                    obj.surface.surfaceData.xv);
            
            E = obj.surface.surfaceData.FF1(1,1);
            F = obj.surface.surfaceData.FF1(1,2);
            G = obj.surface.surfaceData.FF1(1,3);
            
            Eu = 2*dot(obj.surface.surfaceData.xu, ... 
                       obj.surface.surfaceData.xuu);
                   
            Gv = 2*dot(obj.surface.surfaceData.xv, ...
                       obj.surface.surfaceData.xvv);
            
            % Determinant of metric tensor
            detT = E*G - F^2;
            
            % Gaussian curvature
            K = obj.surface.surfaceData.K;
            
            % State space equations for the geodesic ...
            Zd(1,1) = ud;
            Zd(2,1) = vd;
            Zd(3,1) = -((0.5*Eu*G - A*F)*ud^2 + 2*(C*G - D*F)*ud*vd + (B*G - 0.5*F*Gv)*vd^2) / detT;
            Zd(4,1) =  ((0.5*Eu*F - A*E)*ud^2 + 2*(C*F - D*E)*ud*vd + (B*F - 0.5*E*Gv)*vd^2) / detT;
           
            % ... and for the Jacobi fields
            Zd(5,1) =  ad;
            Zd(6,1) = -K*a;
            Zd(7,1) =  rd;
            Zd(8,1) = -K*r;
            
        end
        
    end
        
end




