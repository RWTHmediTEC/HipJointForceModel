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

classdef ParametricSurface < RigidBody
   
    properties
       
        surfaceData;
        
        % This needs to becomputed only one time when the surface is 
        % constructed
        xSurfMeshLocalCoordinates;
        ySurfMeshLocalCoordinates;
        zSurfMeshLocalCoordinates;
        
        % These are frequently updated according to the spatial pose 
        % of the surface
        xSurfMeshGlobalCoordinates;
        ySurfMeshGlobalCoordinates;
        zSurfMeshGlobalCoordinates;
        
    end
    
    methods (Abstract)
        
        [obj] = computeSurfaceMeshInLocalCoordinates(obj);
        
        [obj] = evaluateSurface(obj, Q);
        
    end
    
    methods
        
        function [obj] = ParametricSurface(r, R, v, w)
            
            obj = obj@RigidBody(r, R, v, w);
            
            obj.surfaceData = ParametricSurfaceData();
            
        end
        
        
        function [obj] = computeSurfaceMeshInGlobalCoordinates(obj)
            
           [rows, cols] = size(obj.xSurfMeshLocalCoordinates);
            
            obj.xSurfMeshGlobalCoordinates = zeros(rows, cols);
            obj.ySurfMeshGlobalCoordinates = zeros(rows, cols);
            obj.zSurfMeshGlobalCoordinates = zeros(rows, cols);
            
            for i=1:rows
                
                for j=1:cols
                    
                    r_local = [ obj.xSurfMeshLocalCoordinates(i,j) ; ... 
                                obj.ySurfMeshLocalCoordinates(i,j) ; ...
                                obj.zSurfMeshLocalCoordinates(i,j) ];
                    
                    obj.xSurfMeshGlobalCoordinates(i,j) = obj.r(1,1) + obj.R(1,:) * r_local;
                    obj.ySurfMeshGlobalCoordinates(i,j) = obj.r(2,1) + obj.R(2,:) * r_local;
                    obj.zSurfMeshGlobalCoordinates(i,j) = obj.r(3,1) + obj.R(3,:) * r_local;
                    
                end
                
            end
            
        end
        
        
        function [obj] = evaluateFirstFundamentalForm(obj)
            
           obj.surfaceData.FF1(1,1) = dot(obj.surfaceData.xu, obj.surfaceData.xu);
           obj.surfaceData.FF1(1,2) = dot(obj.surfaceData.xu, obj.surfaceData.xv);
           obj.surfaceData.FF1(1,3) = dot(obj.surfaceData.xv, obj.surfaceData.xv);
           
        end
        
        
        function [obj] = evaluateSecondFundamentalForm(obj)
            
           obj.surfaceData.FF2(1,1) = dot(obj.surfaceData.N, obj.surfaceData.xuu);
           obj.surfaceData.FF2(1,2) = dot(obj.surfaceData.N, obj.surfaceData.xuv);
           obj.surfaceData.FF2(1,3) = dot(obj.surfaceData.N, obj.surfaceData.xvv);
            
        end
        
        
        % Normal curvature 
        function [kn] = computeNormalCurvature(obj, Q, Qd)
            
            obj = obj.evaluateSurface(Q);
            
            du = Qd(1);
            dv = Qd(2);
            
            E = obj.surfaceData.FF1(1,1);
            F = obj.surfaceData.FF1(1,2);
            G = obj.surfaceData.FF1(1,3);
            
            L = obj.surfaceData.FF2(1,1);
            M = obj.surfaceData.FF2(1,2);
            N = obj.surfaceData.FF2(1,3);
            
            kn = (L*du^2 + 2*M*du*dv + N*dv^2)  ... 
                 /                              ...
                 (E*du^2 + 2*F*du*dv + G*dv^2);
                   
        end
        
      
        % Geodesic torsion
        % Read more: http://www.solitaryroad.com/c335.html
        function [tau] = computeGeodesicTorsion(obj, Q, Qd)
            
           obj = obj.evaluateSurface(Q);
            
           du = Qd(1);
           dv = Qd(2);
            
           E = obj.surfaceData.FF1(1,1);
           F = obj.surfaceData.FF1(1,2);
           G = obj.surfaceData.FF1(1,3);
            
           L = obj.surfaceData.FF2(1,1);
           M = obj.surfaceData.FF2(1,2);
           N = obj.surfaceData.FF2(1,3);
           
           tau = -((E*M-F*L)*du^2 + (E*N-G*L)*du*dv + (F*N-G*M)*dv^2) ...
                  /                                                   ...
                  (sqrt(E*G-F^2) * (E*du^2 + 2*F*du*dv + G*dv^2));
            
        end
        
        
        % Gaussian curvature
        function [obj] = evaluateGaussianCurvature(obj)
            
           E = obj.surfaceData.FF1(1,1);
           F = obj.surfaceData.FF1(1,2);
           G = obj.surfaceData.FF1(1,3);
            
           L = obj.surfaceData.FF2(1,1);
           M = obj.surfaceData.FF2(1,2);
           N = obj.surfaceData.FF2(1,3); 
            
           obj.surfaceData.K = (L*N - M^2) ...
                               /           ...
                               (E*G - F^2);
            
        end
        
        
        function [] = plotSurface(obj, FaceColor, EdgeColor, scale)
            
            surf(scale*obj.xSurfMeshGlobalCoordinates, ... 
                 scale*obj.ySurfMeshGlobalCoordinates, ...
                 scale*obj.zSurfMeshGlobalCoordinates, ...
                 'FaceColor', FaceColor, ... 
                 'EdgeColor', EdgeColor)
            
        end
        
        
    end
    
end

