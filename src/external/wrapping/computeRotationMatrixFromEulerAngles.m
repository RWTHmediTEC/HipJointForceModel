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

% Compute the rotation matrix R = Rot[z,psi] * Rot[x,theta] * Rot[z,phi]
% for a given set Q = (psi, theta, phi) of Euler Angles.
function [ R ] = computeRotationMatrixFromEulerAngles( Q )

    [layers, ~] = size(Q);
            
    R = zeros(3, 3, layers);
           
    for i=1:length(Q(:,1))
                
        sinpsi   = sin(Q(i,1));
        cospsi   = cos(Q(i,1));
        sintheta = sin(Q(i,2));
        costheta = cos(Q(i,2));
        sinphi   = sin(Q(i,3));
        cosphi   = cos(Q(i,3));
               
        R(1:3, 1:3, i) = [ cospsi*cosphi-sinpsi*costheta*sinphi, -cospsi*sinphi-sinpsi*costheta*cosphi,  sinpsi*sintheta;
                           sinpsi*cosphi+cospsi*costheta*sinphi, -sinpsi*sinphi+cospsi*costheta*cosphi, -cospsi*sintheta; 
                           sintheta*sinphi,                       sintheta*cosphi,                       costheta ]; 
            
    end
    
end

