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

classdef Torus < ParametricSurface

    properties
        
        Rds;
        rds;
       
    end
   
    
    methods
        
        function [obj] = Torus(r, v, R, w, Rds, rds)
            
            obj = obj@ParametricSurface(r, v, R, w);
            
            obj.Rds    = Rds;
            obj.rds    = rds;
            
            obj = obj.computeSurfaceMeshInLocalCoordinates();
         
            obj = obj.computeSurfaceMeshInGlobalCoordinates();
                       
        end
        
       
        function [obj] =  computeSurfaceMeshInLocalCoordinates(obj)
            
            u = 2*pi*[0:0.05:1];
            v = 2*pi*[0:0.05:1];
            
            obj.xSurfMeshLocalCoordinates = zeros(length(v), length(u));
            obj.ySurfMeshLocalCoordinates = zeros(length(v), length(u));
            obj.zSurfMeshLocalCoordinates = zeros(length(v), length(u));
            
            for i=1:length(v)
                
                for j=1:length(u)
                    
                    sinu = sin(u(j));
                    cosu = cos(u(j));
                    sinv = sin(v(i));
                    cosv = cos(v(i));
                    
                    obj.xSurfMeshLocalCoordinates(i,j) = (obj.Rds + obj.rds*cosv)*cosu;
                    obj.ySurfMeshLocalCoordinates(i,j) = (obj.Rds + obj.rds*cosv)*sinu;
                    obj.zSurfMeshLocalCoordinates(i,j) =  obj.rds*sinv;
                    
                end
                
            end
            
        end
      
      
        function [obj] = evaluateSurface(obj, Q)
            
                sinu = sin(Q(1));
                cosu = cos(Q(1));
                sinv = sin(Q(2));
                cosv = cos(Q(2));
                
                A = (obj.Rds + obj.rds*cosv);
                
                obj.surfaceData.u = Q(1);
                
                obj.surfaceData.v = Q(2);
                
                obj.surfaceData.x   = [  A * cosu        ; ...
                                         A * sinu        ; ...
                                         obj.rds * sinv ];
               
                obj.surfaceData.xu  = [ -A * sinu ; ...
                                         A * cosu ; ...
                                         0.0      ];
                          
                obj.surfaceData.xv  = [ -obj.rds * cosu * sinv ; ...
                                        -obj.rds * sinu * sinv ; ...
                                         obj.rds * cosv        ];
                           
                obj.surfaceData.xuu = [ -A * cosu ; ...
                                        -A * sinu ; ...
                                         0.0      ];
                                     
                obj.surfaceData.xuv = [  obj.rds * sinu * sinv ; ...
                                        -obj.rds * cosu * sinv ; ...
                                         0.0                   ];
                           
                obj.surfaceData.xvv = [ -obj.rds * cosu * cosv ; ...
                                        -obj.rds * sinu * cosv ; ...
                                        -obj.rds * sinv        ];
                          
                N = cross(obj.surfaceData.xu, obj.surfaceData.xv);
                
                obj.surfaceData.N = N / norm(N);
                
                obj = obj.evaluateFirstFundamentalForm();
                obj = obj.evaluateSecondFundamentalForm();
                obj = obj.evaluateGaussianCurvature();
                  
        end
                  
    end
  
end

