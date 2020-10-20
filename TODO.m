% Cadaver
% - TLEM2: Move origin of the femur mesh (from the EC midpoint) to the HJC
% - Include additonal cadaver from https://github.com/anmuller/CusToM

% Scaling laws
% - Add caching for skinning weights
% - Revision of PCSAs
% 	- AnyBody adapts the PCSAs by: PCSA = MuscleVolume/OptimalFiberLength
% 	- MuscleVolume and OptimalFiberLength can be patient-specific adapted 
%     by a scaling law. The data of TLEM1 [Klein Horsman] is used:
% 		- MuscleVolume = Mass/1.056 (MuscleDensity) 
% 		- OptimalFiberLength (Lopt)
% Revise scaling law of Sedghi2017

% Muscle path models
% - Improve scaling of wrapping surfaces
% - Improve inital wrapping paramters for better robustness of wrapping for
%   scaling and different postures

% Muscle recruitment
% - Implement common muscle recruitment criteria
% - Use EMS studies (OrthoLoad) to select muscles of the models

% HJF models
% - Implement other one-leg stance models
% - Implement models for other ADLs

% Validation
% - Level Walking could be split in three peak force phases
% - Move postures selection to validation tab