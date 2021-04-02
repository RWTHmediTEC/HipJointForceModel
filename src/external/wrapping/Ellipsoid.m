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

classdef Ellipsoid < ParametricSurface

    properties 
        
        a;
        b;
        c;
        
    end
    
    
    methods
        
        function [obj] = Ellipsoid(r, R, v, w, a, b, c)
            
            obj = obj@ParametricSurface(r, R, v, w);
            
            obj.a = a;
            obj.b = b;
            obj.c = c;
            
            obj = obj.computeSurfaceMeshInLocalCoordinates();
            
            obj = obj.computeSurfaceMeshInGlobalCoordinates();
            
        end
        
      
        function [obj] = computeSurfaceMeshInLocalCoordinates(obj)
            
            u = pi*[0.0:0.1:2.0];
            v = pi*[0:0.1:1];
            
            obj.xSurfMeshLocalCoordinates = zeros(length(v), length(u));
            obj.ySurfMeshLocalCoordinates = zeros(length(v), length(u));
            obj.zSurfMeshLocalCoordinates = zeros(length(v), length(u));
            
            for i=1:length(v)
                
                for j=1:length(u)
                    
                    sinu = sin(u(j));
                    
                    obj.xSurfMeshLocalCoordinates(i,j) =  obj.a * sinu * cos(v(i));
                    obj.ySurfMeshLocalCoordinates(i,j) =  obj.b * sinu * sin(v(i));
                    obj.zSurfMeshLocalCoordinates(i,j) =  obj.c * cos(u(j));
                    
                end
                
            end
            
        end
      
       
        function [obj] = evaluateSurface(obj, Q)
                     
                sinu = sin(Q(1));
                cosu = cos(Q(1));
                sinv = sin(Q(2));
                cosv = cos(Q(2));
                
                obj.surfaceData.u = Q(1);
                
                obj.surfaceData.v = Q(2);
                
                obj.surfaceData.x   = [  obj.a * sinu * cosv ; ...
                                         obj.b * sinu * sinv ; ...
                                         obj.c * cosu        ];
               
                obj.surfaceData.xu  = [  obj.a * cosu * cosv ; ...
                                         obj.b * cosu * sinv ; ...
                                        -obj.c * sinu        ];
                          
                obj.surfaceData.xv  = [ -obj.a * sinu * sinv ; ...
                                         obj.b * sinu * cosv ; ...
                                         0.0                 ];
                           
                obj.surfaceData.xuu = [ -obj.a * sinu * cosv ; ...
                                        -obj.b * sinu * sinv ; ...
                                        -obj.c * cosu        ];
                           
                obj.surfaceData.xuv = [ -obj.a * cosu * sinv ; ...
                                         obj.b * cosu * cosv ; ...
                                         0.0                 ];
                         
                obj.surfaceData.xvv = [ -obj.a * sinu * cosv ; ...
                                        -obj.b * sinu * sinv ; ...
                                         0.0                 ];
                        
                N = cross(obj.surfaceData.xu, obj.surfaceData.xv);
                
                obj.surfaceData.N = N / norm(N);
                
                obj = obj.evaluateFirstFundamentalForm();
                obj = obj.evaluateSecondFundamentalForm();
                obj = obj.evaluateGaussianCurvature();
                      
        end
  
    end         
    
end

