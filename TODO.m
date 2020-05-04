% Cadaver
% - TLEM2: Review lines of action: rectusfemoris, tensorfasciaelatae
% - TLEM2: Review via points: sartorius
% - TLEM2: Move origin of the femur mesh (from the EC midpoint) to the HJC 

% Muscle model
% - Revision of PCSAs
% 	- Vergleich mit AnyBody; AnyBody passt die PCSAs anhand eines "Scaling Laws" an
% 	- PCSA = MuscleVolume/OptimalFiberLength
% 	- Sowohl MuscleVolume als auch OptimalFiberLength k�nnen patienten-spezifisch �ber ein Skalierungsgesetz angepasst werden
% 	- Hier werden die Daten vom TLEM1 (Klein Horsman) verwendet:
% 		- MuscleVolume = Mass/1.056 (MuscleDensity) 
% 		- OptimalFiberLength (Lopt)

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
% - Verify LBS for OrthoLoad subjects
% - Add caching for skinning weights

%% GUI
% Validation
% - Source of the OrthoLoad force data should be documented
