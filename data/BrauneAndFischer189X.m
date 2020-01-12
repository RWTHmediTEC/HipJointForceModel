function [S, HJW, G1, G2, g1_16, g2_L_16, hjc_R_16] = BrauneAndFischer189X()
% Values from:
% [1895 Braune] 1985 - Der Gang des Menschen - I. Theil
% [1898 Fischer] 1898 - Der Gang des Menschen - II. Theil
% [1987 Braune] 1987 - Braune - The Human Gait
S = 58.7; % Body weight [1898 Fischer, S.60; 1987 Braune, S.152]
HJW = 170; % Hip joint Width. Distance between the hip joint centers [1895 Braune, S.96; 1987 Braune, S.66]
G1 = 0.6273; % %BW of the trunk, head & both arms [1989 Fischer, S.16; 1987 Braune, S.122]
G2 = 0.18635; % %BW of one leg

g1_16   = [129.38  1.59 115.65]; % Position of G1 at step 16 of Experiment 1 [1898 Fischer, S.47; 1987 Braune, S.140]
g2_L_16 = [129.61 -8.45  56.45]; % Position of the left leg at step 16 of Experiment 1 [1898 Fischer, S.48; 1987 Braune, S.141]

hjc_R_16 = [130.40 10.28  85.95]; % Position of the left HJC at step 16 of Experiment 1 [1895 Braune, S.108; 1987 Braune, S.74]

end