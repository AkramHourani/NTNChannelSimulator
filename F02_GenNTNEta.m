function [etaMatrix] = F02_GenNTNEta(LoSMatrix,theta,Sim,Model)
% This function generates the excess path-loss caused by the clutter
% shadowing in different urban environments
%
% Input
% LoSMatrix holds the Line-of-Sight status for each simulation cell
% theta is the elevation angle between the satellite and each simulation cell
% Sim is the simulation parameter’s structure
% Model is the model parameter’s structure
%
% Output
% etaMatrix holds the excess path loss for each simulation cell

%% Generate eta
if ( Sim.Env ~= 1 && Sim.Env ~= 2 && Sim.Env ~= 3)
    error('Environment Should be 1,2, or 3');
end

if ( Sim.Freq < 700 || Sim.Freq > 5800)
    error('This function supports frequencies between 700 and 5800 MHz]');
end

%% Interpolating for the simulation frequency
muLoS   = interp1(Model.Model_Freq,Model.LoS_mu(:,Sim.Env),Sim.Freq);
muNLoS  = interp1(Model.Model_Freq,Model.NLoS_mu(:,Sim.Env),Sim.Freq);
aLoS    = mean(Model.LoS_sigma(:,2*Sim.Env-1)); % This vector does not show clear dependency on the freq -> the mean is taken

bLoS    = Model.LoS_sigma(:,2*Sim.Env);
bLoS    = interp1(Model.Model_Freq,bLoS,Sim.Freq);

aNLoS   = interp1(Model.Model_Freq,Model.NLoS_sigma(:,2*Sim.Env-1),Sim.Freq);
bNLoS   = mean(Model.NLoS_sigma(:,2*Sim.Env)); % This vector does not show clear dependency on the freq -> the mean is taken

%% Generating eta
stdLoS  = aLoS*exp(bLoS*theta);
stdNLoS = aNLoS*exp(bNLoS*theta);

%% Apply autocorrelation filter on eta
if Sim.Corr == 1

    aKorLoS = 1/Model.LoS_dcorr;
    aKorNLoS = 1/Model.NLoS_dcorr;

    Nfilt = round(Model.LoS_dcorr*Sim.N/Sim.MapW*2); % spetial filter size
    [xKer,yKer] = meshgrid(-Nfilt/2:Nfilt/2); % spatial points
    dKer = sqrt(xKer.^2+yKer.^2); % Distance from the center of the filter
    kernelLoS =  2^(3/4) * sqrt(aKorLoS) *besselk(0, aKorLoS *abs(dKer)) / pi^(3/4); % Create the filter, refer to [3]
    kernelLoS(isinf(kernelLoS)) = 1;
    kernelLoS = kernelLoS/sqrt(sum(kernelLoS.^2,"all")); % Normalize the filter

    kernelNLoS =  2^(3/4) * sqrt(aKorNLoS) *besselk(0, aKorNLoS *abs(dKer)) / pi^(3/4);
    kernelNLoS(isinf(kernelNLoS)) = 1;
    kernelNLoS = kernelNLoS/sqrt(sum(kernelNLoS.^2,"all"));

    out = conv2(randn(size(theta)),kernelLoS,"same"); % Apply the filter
    out = out-mean(out,'all'); % Normalize the filtered shadowing
    out = out/std(out(:));
    out = out.*stdLoS; % Apply the desired standard deviation
    out = out +muLoS; % Applu the desired mean
    etaLoS =out;

    out = conv2(randn(size(theta)),kernelNLoS,"same");
    out = out-mean(out,'all');
    out = out/std(out(:));
    out = out.*stdNLoS;
    out = out +muNLoS;
    etaNLoS =out;


else
    % This is in case no correlation is needed
    etaLoS  =  randn(size(theta)) .* stdLoS  + muLoS; 
    etaNLoS  = randn(size(theta)) .* stdNLoS + muNLoS;

end
% Combine the LoS and NLoS shadowing
etaMatrix = etaLoS.*LoSMatrix + etaNLoS.*(~LoSMatrix);


