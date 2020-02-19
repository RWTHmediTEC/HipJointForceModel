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

classdef GeodesicBoundaryPointFrame < RigidBody
    
    properties
        
        x;
        t;
        N;
        B;
        
    end
    
    methods
      
        function [obj] = GeodesicBoundaryPointFrame(r, R, v, w, x, t, N, B)
            
           obj = obj@RigidBody(r, R, v, w);
            
           obj.x = x;
           obj.t = t;
           obj.N = N;
           obj.B = B;
            
        end
        
        
        function [] = plotBoundaryPointFrame(obj)
            
           xGlobal = obj.r + obj.R * obj.x;
           
           tGlobal = obj.R * obj.t;
           NGlobal = obj.R * obj.N;
           BGlobal = obj.R * obj.B;
           
           quiver3(xGlobal(1), xGlobal(2), xGlobal(3), tGlobal(1), tGlobal(2), tGlobal(3), '-r')
           quiver3(xGlobal(1), xGlobal(2), xGlobal(3), NGlobal(1), NGlobal(2), NGlobal(3), '-g')
           quiver3(xGlobal(1), xGlobal(2), xGlobal(3), BGlobal(1), BGlobal(2), BGlobal(3), '-b')
           
        end
        
        
    end
    
end

