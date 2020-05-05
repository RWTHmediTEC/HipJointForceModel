% Cadaver
% - TLEM2: Review lines of action: rectusfemoris, tensorfasciaelatae
% - TLEM2: Review via points: sartorius
% - TLEM2: Move origin of the femur mesh (from the EC midpoint) to the HJC 

% HJF models
% - Implement other one-leg stance models
% - Parameter / sensitivity study of the HJF models
% - Implement models for other ADLs

% Muscle path models
% - Muscle moment arm calculation for wrapping?
% - Scaling of wrapping surfaces?

% Muscle recruitment
% - Implement common muscle recruitment criteria
% - Use EMS studies (OrthoLoad) to select muscles of the models

% Scaling laws
% - Add caching for skinning weights
% - Revision of PCSAs
% 	- AnyBody adapts the PCSAs by: PCSA = MuscleVolume/OptimalFiberLength
% 	- MuscleVolume and OptimalFiberLength can be patient-specific adapted 
%     by a scaling law. The data of TLEM1 [Klein Horsman] is used:
% 		- MuscleVolume = Mass/1.056 (MuscleDensity) 
% 		- OptimalFiberLength (Lopt)

% Validation
% - Source of the OrthoLoad HJF data has to be documented
