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

classdef ParametricSurfaceData
    
    properties
        
        % Surface coordinates
        u;
        v;
        
        % Radius vector x(u,v) to evaluated point
        x;
        xu;
        xv;
        
        xuu;
        xuv;
        xvv;
        
        % Normal vector N  
        N;
        
        % Coefficients of first fundamental form
        FF1;
        
        % Coefficients of second fundamental form FF2
        FF2;
        
        % Gaussian curvature
        K;
        
    end
    
    methods
        
        % Constructor
        function [obj] = ParametricSurfaceData()
            
            obj.u = 0;
            obj.v = 0;
            
            obj.x  = [0 0 0];
            obj.xu = [0 0 0];
            obj.xv = [0 0 0];
            
            obj.xuu = [0 0 0];
            obj.xuv = [0 0 0];
            obj.xvv = [0 0 0];
            
            obj.FF1 = [0 0 0];
            obj.FF2 = [0 0 0];
            
            obj.K = 0;
        
        end
          
    end
    
end

