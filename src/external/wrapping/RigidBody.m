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

classdef RigidBody
   
    properties
       
        % Position
        r;
        
        % Orientation
        R; 
        
        % Linear velocity
        v;
        
        % Angular velocity
        w;
     
    end
    
    methods 
        
        function [obj] = RigidBody(r, R, v, w)
            
            obj.r = r;
            obj.R = R;
            obj.v = v;
            obj.w = w;
            
        end
        
        
        function [obj] = performLinearSpatialMotion(obj, timeStep)
            
               obj.r = obj.r + obj.v*timeStep;
               
               Q = computeEulerAnglesFromRotationMatrix(obj.R);
              
               if norm(sin(Q(2))) > 0.1
                   
                    Qd = computeEulerAngleDerivativesFromAngularVelocity(obj.w);
                    
                    obj.R = computeRotationMatrixFromEulerAngles(Q+Qd*timeStep);
                    
               else
                   
                    Q = obj.computeBryantAnglesFromRotationMatrix(obj.R);
                    
                    Qd = obj.computeBryantAngleDerivativesFromAngularVelocity(obj.w);
                    
                    obj.R = obj.computeRotationMatrixFromBryantAngles(Q+Qd*timeStep);
                    
               end
    
        end
        
    end
    
end

