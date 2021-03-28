function [S, HJW, G1, G2, g1_16, g2_L_16, hjc_R_16] = BrauneAndFischer189X()
%BRAUNEANDFISCHER198X contains values from the publications of Braune & Fischer
%
% References:
% [Braune 1895] 1985 - Der Gang des Menschen - I. Theil
% [Fischer 1898] 1898 - Der Gang des Menschen - II. Theil
% [Braune 1987] 1987 - Braune - The Human Gait
% https://doi.org/10.1007/978-3-642-70326-3

S = 58.7; % Body weight [Fischer 1898, S.60; Braune 1987, S.152]
HJW = 17; % Hip joint Width. Distance between the hip joint centers [Braune 1895 , S.96; Braune 1987, S.66]
G1 = 0.6273; % %BW of the trunk, head & both arms [1989 Fischer, S.16; Braune 1987, S.122]
G2 = 0.18635; % %BW of one leg

g1_16   = [129.38  1.59 115.65]; % Position of G1 at step 16 of Experiment 1 [Fischer 1898, S.47; Braune 1987, S.140]
g2_L_16 = [129.61 -8.45  56.45]; % Position of the left leg at step 16 of Experiment 1 [Fischer 1898, S.48; Braune 1987, S.141]

hjc_R_16 = [130.40 10.28  85.95]; % Position of the left HJC at step 16 of Experiment 1 [Braune 1895 , S.108; Braune 1987, S.74]

end