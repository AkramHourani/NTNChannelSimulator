function [LoSMatrix,theta, d] = F01_GenLoS(NTN,Sim,Model)
%% This function generated the Line-of-Sight matrix

% Input
% NTN is the holds the properties of the NTN platform (UAV, Satellite,
% etc..) including position and EIRP
% Sim is the simulation parameter’s structure
% Model is the model parameter’s structure
%
% Output
% LoSMatrix holds the Line-of-Sight status for each simulation cell
% theta is the elevation angle between the satellite and each simulation cell
% d is the distance between the satellite and each simulation cell

%% Line of sight generator
Bar=waitbar(0,'Generating LoS matrix');
deltaD = Sim.MapW/Sim.N;
[x,y]=meshgrid(linspace(-Sim.MapW/2,Sim.MapW/2,Sim.N));
x=single(x(:));
y=single(y(:));
RR = randperm(Sim.N^2); % Randomize the indicies of the points
x=x(RR);
y=y(RR);

% This vector will hold the final asigned coordinates
xa=[];
ya=[];

d = sqrt((x-NTN.pos(1)).^2+(y-NTN.pos(2)).^2 + (0-NTN.pos(3)).^2);
dg = sqrt((x-NTN.pos(1)).^2+(y-NTN.pos(2)).^2 );
theta = acosd(dg./d);

PLoSVec = exp(-Model.Beta(Sim.Env)*cotd(theta));
kappa = Model.kappa_o(Sim.Env) * tand(theta);
kappa = min(kappa,ones(size(kappa))*Sim.MapW/10); % limit the maximum kappa to 10th of the simulation map

%% Main part
ctr = 1;
UnAsgndFlt = 1:Sim.N^2; %List of all indices (unassigned points)
LoS=[];

while ~isempty(UnAsgndFlt)

    % Filter an unassigned point
    xu=x(UnAsgndFlt);
    yu=y(UnAsgndFlt);

    % Pick an unassigned point at random
    idx=randi([1 length(UnAsgndFlt)]);
    PLoS = PLoSVec(idx);
    r11 =kappa(idx)*0.6366; % Mean raduis of the LoS
    r22 = sqrt((1-PLoS)/PLoS)*r11;

    xc(ctr) = xu(idx);
    yc(ctr) = yu(idx);

    dd=sqrt((xc(ctr)-xu).^2 + (yc(ctr)-yu).^2);

    if rand()<PLoS % 1 for LoS, 0 for NLoS
        rr = exprnd(r11);
        LoS=[LoS;ones(sum(dd<rr),1)];
        % lable the outer rim as NLoS
        LoS=[LoS;zeros(sum(all([(dd<rr+deltaD),(dd>rr)],[2])),1)];


    else
        rr = exprnd(r22);
        LoS=[LoS;zeros(sum(dd<rr),1)];
        % lable the outer rim as LoS
        LoS=[LoS;ones(sum(all([(dd<rr+deltaD),(dd>rr)],[2])),1)];
    end
    xa=[xa;xu(dd<rr)];
    xa=[xa;xu(all([(dd<rr+deltaD),(dd>rr)],[2]))];

    ya=[ya;yu(dd<rr)];
    ya=[ya;yu(all([(dd<rr+deltaD),(dd>rr)],[2]))];

    UnAsgndFlt(dd<rr+deltaD)=[];
    kappa(dd<rr+deltaD)=[];
    PLoSVec(dd<rr+deltaD)=[];

    if mod(ctr,50)==0 % report the results every 50 steps
        waitbar((length(x)-length(xu))/length(x),Bar)
    end
    ctr=ctr+1;
end
%% Interpolate into a grid
F = scatteredInterpolant(double(xa),double(ya),LoS,'nearest'); % Create interpolation function
[xt, yt]= meshgrid(linspace(-Sim.MapW/2,Sim.MapW/2,Sim.N));
LoSMatrix = F(xt,yt);
close all hidden
theta = reshape(theta,size(xt));
d     = reshape(d,size(xt));
end

