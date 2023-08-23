tiledlayout(2,2,"TileSpacing","tight")
nexttile
colormap parula
imagesc(-Sim.MapW/2:Sim.MapW/2,-Sim.MapW/2:Sim.MapW/2,LoSMatrix)
title('LoS status')
axis equal; grid on; cb=colorbar; cb.Label.String='LoS status';
xlabel('x-axis [m]'); ylabel('y-axis [m]')
%hold on
%text(NTN.pos(1),NTN.pos(2),' BS')
%plot(NTN.pos(1),NTN.pos(2),'r+','LineWidth',2)

nexttile
imagesc(-Sim.MapW/2:Sim.MapW/2,-Sim.MapW/2:Sim.MapW/2,etaMatrix)
title('Excess path loss \eta')
axis equal; grid on; cb=colorbar; cb.Label.String='\eta [dB]'; clim ([-10 40])
xlabel('x-axis [m]'); ylabel('y-axis [m]')
%hold on
%text(NTN.pos(1),NTN.pos(2),' BS')
%plot(NTN.pos(1),NTN.pos(2),'r+','LineWidth',2)

nexttile
imagesc(-Sim.MapW/2:Sim.MapW/2,-Sim.MapW/2:Sim.MapW/2,PRx)
title('Received power P_{rx}')
axis equal; grid on; cb=colorbar; cb.Label.String='P_{rx} [dBm]';
xlabel('x-axis [m]'); ylabel('y-axis [m]')
%hold on
%text(NTN.pos(1),NTN.pos(2),' BS')
%plot(NTN.pos(1),NTN.pos(2),'r+','LineWidth',2)

nexttile
histogram(etaMatrix(:),'Normalization','pdf')
title('Excess path loss histogram')
xlabel('\eta [dB]'); ylabel('pdf')
