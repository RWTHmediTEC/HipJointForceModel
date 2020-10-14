% Cadaver
% - TLEM2: Review lines of action: rectusfemoris, tensorfasciaelatae
% - TLEM2: Review via points: sartorius
% - TLEM2: Move origin of the femur mesh (from the EC midpoint) to the HJC

% Scaling laws
% - Add caching for skinning weights
% - Revision of PCSAs
% 	- AnyBody adapts the PCSAs by: PCSA = MuscleVolume/OptimalFiberLength
% 	- MuscleVolume and OptimalFiberLength can be patient-specific adapted 
%     by a scaling law. The data of TLEM1 [Klein Horsman] is used:
% 		- MuscleVolume = Mass/1.056 (MuscleDensity) 
% 		- OptimalFiberLength (Lopt)

% Muscle path models
% - Improve scaling of wrapping surfaces
% - Improve inital wrapping paramters for better robustness of wrapping for
%   scaling and different postures

% HJF models
% - Implement other one-leg stance models
% - Parameter / sensitivity study of the HJF models
% - Implement models for other ADLs

% Muscle recruitment
% - Implement common muscle recruitment criteria
% - Use EMS studies (OrthoLoad) to select muscles of the models

% Validation
% - Level Walking should be split in three peak force phases
