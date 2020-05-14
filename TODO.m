% Cadaver
% - TLEM2: Review lines of action: rectusfemoris, tensorfasciaelatae
% - TLEM2: Review via points: sartorius
% - TLEM2: Move origin of the femur mesh (from the EC midpoint) to the HJC
% - Scale cadaver to the mean male/female?

% Scaling laws
% - Add caching for skinning weights
% - Revision of PCSAs
% 	- AnyBody adapts the PCSAs by: PCSA = MuscleVolume/OptimalFiberLength
% 	- MuscleVolume and OptimalFiberLength can be patient-specific adapted 
%     by a scaling law. The data of TLEM1 [Klein Horsman] is used:
% 		- MuscleVolume = Mass/1.056 (MuscleDensity) 
% 		- OptimalFiberLength (Lopt)

% Muscle path models
% - Muscle moment arm calculation for wrapping?
% - Scaling of wrapping surfaces?

% HJF models
% - Implement other one-leg stance models
% - Parameter / sensitivity study of the HJF models
% - Implement models for other ADLs

% Muscle recruitment
% - Implement common muscle recruitment criteria
% - Use EMS studies (OrthoLoad) to select muscles of the models

% Validation
% - Source of the OrthoLoad HJF data has to be documented
% - Validation data should be the mean of on multiple trials for each
%   subject
