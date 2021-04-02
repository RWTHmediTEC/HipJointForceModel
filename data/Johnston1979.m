function ML = Johnston1979()
%JOHNSTON1979 contains the muscle data from [Johnston 1979]
%
% Reference:
% [Johnston 1979] 1979 - Johnston - Reconstruction of the Hip
% https://pubmed.ncbi.nlm.nih.gov/457709
%
% Table I. Relative physiological cross-sectional areas of the muscles 
% studied computed by normalizing the area of each muscle with relation to 
% the area of the gluteus maximus.
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

ML( 1,:) = {'GluteusMaximus' 1.00}; ML(13,:) = {'TensorFasciaeLatae' 0.12}; 
ML( 2,:) = {'Sartorius'      0.07}; ML(14,:) = {'Piriformis'         0.10};
ML( 3,:) = {'RectusFemoris'  0.40}; ML(15,:) = {'ObturatorInternus'  0.12};
ML( 4,:) = {'Gracilis'       0.10}; ML(16,:) = {'GemellusSuperior'   0.02};
ML( 5,:) = {'Pectineus'      0.05}; ML(17,:) = {'GemellusInferior'   0.02};
ML( 6,:) = {'AdductorLongus' 0.23}; ML(18,:) = {'QuadratusFemoris'   0.12};
ML( 7,:) = {'AdductorBrevis' 0.21}; ML(19,:) = {'ObturatorExternus'  0.12};
ML( 8,:) = {'AdductorMagnus' 0.59}; ML(20,:) = {'BicepsFemoris'      0.26};
ML( 9,:) = {'GluteusMedius'  0.80}; ML(21,:) = {'Semitendinosus'     0.20};
ML(10,:) = {'GluteusMinimus' 0.34}; ML(22,:) = {'Semimembranosus'    0.40};
ML(11,:) = {'Vastus'         0.90}; ML(23,:) = {'Iliopsoas'          0.58};
ML(12,:) = {'Gastrocnemius'  0.80}; ML(24,:) = {'Soleus'             0.40};

end