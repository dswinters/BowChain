% dylan winters (dylan.winters@oregonstate.edu)
clear all, close all


% I didn't do any binning when processing this
% tc = BowChain_master('SUNRISE','Walton_Smith','deploy_20210621');
% clim_t = [27.3 28.5];

tc = BowChain_master('SUNRISE','Aries','deploy_20210622_2300');
clim_t = [27.3 29];

clim_s = [30 36];

% I had to make the figure invisible to not crash matlab
figure('position',[0 0 1200 500],'visible','off');

dn = tc.dn .* ones(size(tc.z,1),1);
lat = tc.lat;
% z = tc.z;
z = -tc.pos .* ones(1,length(tc.dn));

% Uncomment this if you're using bin_method = 'average';
% lat = tc.lat .* ones(length(tc.z),1);;
% z = tc.z .* ones(1,length(tc.dn));


disp('creating figure...')
% This is basically pcolor but 3d... don't ask
xp = [reshape(dn(1:end-1,1:end-1), 1,[]);
      reshape(dn(1:end-1,2:end),   1,[]);
      reshape(dn(1:end-1,2:end),   1,[]);
      reshape(dn(1:end-1,1:end-1), 1,[])];
yp = [reshape(lat(1:end-1,1:end-1), 1,[]);
      reshape(lat(1:end-1,2:end),   1,[]);
      reshape(lat(1:end-1,2:end),   1,[]);
      reshape(lat(1:end-1,1:end-1), 1,[])];
zp = [reshape(z(2:end,1:end-1),   1,[]);
      reshape(z(2:end,1:end-1),   1,[]);
      reshape(z(1:end-1,1:end-1), 1,[]);
      reshape(z(1:end-1,1:end-1), 1,[])];
c = reshape(tc.t(1:end-1,1:end-1),1,[]);
hp = patch(xp,yp,zp,c); shading flat

colormap(gca,cmocean('thermal'))
caxis(clim_t)
view(3)
set(gca,'View',[12.5262 53.0448]);
grid on
set(hp,'facealpha',0.7)
cb = colorbar;
cb.Label.String = 'Temperature (^{\circ}C)';

zlabel('z (m)')
xlabel('Time (UTC)')
datetick('x','mmdd-HHMM','keeplimits')
ylabel('Lat (^{\circ}N)')
disp('done')

disp('saving...')
f_out = sprintf('~/Work/SUNRISE/bowchain_figures/%s_%s.png',tc.info.config.vessel,tc.info.config.name);
print('-dpng','-r300',f_out)
disp(['Saved ' f_out])
