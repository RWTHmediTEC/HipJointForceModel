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

classdef GeodesicSegment < RigidBody
  
    properties
        
        % Boundary-point frames
        KP;
        KQ;
        
        % Points of the curve
        xLocal;
        xGlobal;
        
        % Arc length
        l;
        
        % Jacobi fields
        % a(s) : binormal displacement
        % r(s) : rotation of initial direction 
        aP;
        adP;
        
        aQ;
        adQ;
        
        rP;
        rdP;
        
        rQ;
        rdQ;
        
        % Geodesic torsion
        tauP_tan;
        tauP_bin;
        
        tauQ_tan;
        tauQ_bin;
        
        % Normal curvature
        kappaNP_tan;
        kappaNP_bin;
        
        kappaNQ_tan;
        kappaNQ_bin;
        
        % Geodesic curvature (only in binormal direction at Q)
        kappaQ_alpha;   % For binormal displacement of start point P
        kappaQ_rho;     % For rotation of initial direction at P
        
    end
    
    methods
        
        function [obj] = GeodesicSegment(r, R, v, w)
            
            obj = obj@RigidBody(r, R, v, w);
            
            obj.KP = GeodesicBoundaryPointFrame(r, R, v, w, [], [], [], []);
            obj.KQ = GeodesicBoundaryPointFrame(r, R, v, w, [], [], [], []);
            
            obj.xLocal  = [];
            obj.xGlobal = [];
            
            obj.l  = [];
            
            obj.aP  = 1;
            obj.adP = 0;
            
            obj.aQ  = [];
            obj.adQ = [];
            
            obj.rP  = 0;
            obj.rdP = 1;
            
            obj.rQ  = [];
            obj.rdQ = [];
            
            obj.tauP_tan = [];
            obj.tauP_bin = [];
            
            obj.tauQ_tan = [];
            obj.tauQ_bin = [];
            
            obj.kappaNP_tan = [];
            obj.kappaNP_bin = []; 
        
            obj.kappaNQ_tan = []; 
            obj.kappaNQ_bin = [];
            
            obj.kappaQ_alpha = [];
            obj.kappaQ_rho = [];    
            
        end
        
        
        function [obj] = plotGeodesicSegment(obj, lineStyle, lineWidth)
            
           obj = obj.computeCurveInGlobalCoordinates();
           
           plot3(obj.xGlobal(1,:), ...
                 obj.xGlobal(2,:), ...
                 obj.xGlobal(3,:), ...
                 lineStyle, ... 
                 'linewidth', lineWidth);        
             
        end
        
        
        
        function [obj] = computeCurveInGlobalCoordinates(obj)
            
            [~, cols] = size(obj.xLocal);
            
            obj.xGlobal = zeros(3, cols);
            
            for i=1:cols
               
                obj.xGlobal(:,i) = obj.r + obj.R * obj.xLocal(:,i);
                
            end
            
        end
        
    end
       
end

