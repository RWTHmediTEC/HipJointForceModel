
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

% Muscle path models
% - Improve scaling of wrapping surfaces
% - Include sanity check for wrapping based on the length of the muscle
%   path. If length is not physological, use StraightLine model.
% - Improve inital wrapping parameters for better robustness of wrapping 
%   for scaling and different postures

% Muscle recruitment
% - Use EMS studies (OrthoLoad) to select muscles of the models

% HJF models
% - Implement other one-leg stance models
% - Implement models for other ADLs
% - Schartz2020 move upper body weight W anterior

% Validation
% - Level Walking could be split in three peak force phases

% GUI
% - Move postures selection to validation tab
% - Enable pelvic tilt depending on the HJF model
% - Add verbose option