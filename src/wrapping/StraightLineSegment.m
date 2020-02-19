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

classdef StraightLineSegment
    
    properties
        
        startPoint;
        
        endPoint;
        
        e;
        
        l;
        
    end
    
    methods
        
        function [obj] = StraightLineSegment(startPoint, endPoint)
            
           obj = obj.update(startPoint, endPoint);
           
        end
        
        
        function [obj] = update(obj, startPoint, endPoint)
            
            obj.startPoint = startPoint;
           
            obj.endPoint = endPoint;
            
            obj.l = norm(obj.endPoint - obj.startPoint);
            
            obj.e = (obj.endPoint - obj.startPoint) / obj.l;
            
        end
        
        
        
        function [] = plotStraightLineSegment(obj, lineProps, axH)
            
            plot3(axH, ...
                  [obj.startPoint(1,1), obj.endPoint(1,1)], ... 
                  [obj.startPoint(2,1), obj.endPoint(2,1)], ... 
                  [obj.startPoint(3,1), obj.endPoint(3,1)], ...
                  'Color', lineProps.Color);
            
        end
        
    end
    
end

