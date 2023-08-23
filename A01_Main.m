clc; clear; close all
% Load model parameters
Model_Param
%% Simulation parameters
Sim.Env = 2;     % 1 for rural, 2 Urban, 3 Dense Urban
Sim.N = 400;     % number of spatial samples(more points -> slower simulation
Sim.MapW = 1000; % Map width in [m]
Sim.Freq = 2400; % Frequency in [MHz]
Sim.Corr = 1;    % 1 for simulating shadowing-autocorrelation (experimental feature)
NTN.pos = [0, 0, 120];      % UAV / Satellite cartesian coordinates referened to the center of the map
NTN.EIRP = 30;   % Power in dBm
%% Generate the LoS matrix [Important]
[LoSMatrix,theta, d] = F01_GenLoS(NTN,Sim,Model); % Un-comment this line

%% Generating excess path loss
etaMatrix = F02_GenNTNEta(LoSMatrix,theta,Sim,Model);
FSPL      = 20*log10(d)+20*log10(Sim.Freq*1e6)-147.55;
PRx       = NTN.EIRP- FSPL - etaMatrix;
%% Plotting
A02_PlotResults

%% References:
% [1] A. Al-Hourani, S. Kandeepan and A. Jamalipour, 
%     "Modeling air-to-ground path loss for low altitude platforms in urban environments," 
%     2014 IEEE Global Communications Conference, Austin, TX, USA, 2014, 
%     pp. 2898-2904, doi: 10.1109/GLOCOM.2014.7037248.
% [2] A. Al-Hourani and I. Guvenc, "On Modeling Satellite-to-Ground Path-Loss in Urban Environments," 
%     in IEEE Communications Letters, vol. 25, no. 3, pp. 696-700, March 2021, 
%     doi: 10.1109/LCOMM.2020.3037351.
% [3] I. S. Mohamad Hashim, A. Al-Hourani and W. S. T. Rowe, "Machine Learning Performance for Radio Localization under Correlated Shadowing," 
%     2020 14th International Conference on Signal Processing and Communication Systems (ICSPCS), Adelaide, SA, Australia, 2020, pp. 1-7, 
%     doi: 10.1109/ICSPCS50536.2020.931000
% [4] A. Al-Hourani, "Line-of-Sight Probability and Holding Distance in Non-Terrestrial Networks", 
%     submitted to IEEE Communications Letters, 2023

