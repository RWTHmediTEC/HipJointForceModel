
% Cadaver
% - Include additonal cadavers from https://github.com/anmuller/CusToM

% Scaling laws
% - Revision of PCSAs
% 	- AnyBody adapts the PCSAs by: PCSA = MuscleVolume/OptimalFiberLength
% 	- MuscleVolume and OptimalFiberLength can be patient-specific adapted 
%     by a scaling law. The data of TLEM1 [Klein Horsman] is used:
% 		- MuscleVolume = Mass/1.056 (MuscleDensity) 
% 		- OptimalFiberLength (Lopt)

% Muscle path models
% - Improve scaling of wrapping surfaces
% - Improve inital wrapping parameters for better robustness of wrapping 
%   for scaling and different postures

% HJF models
% - Implement other one-leg stance models
% - Implement models for other ADLs
% - Schartz2020 move upper body weight W anterior?

% GUI
% - Move postures selection to validation tab
% - Left radio button not working for the LandmarkDeformableBones. See
%   skinPelvisLEM.m lines 89 to 93.