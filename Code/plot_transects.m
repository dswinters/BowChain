clear all, close all

tc = BowChain_master('SUNRISE','Walton_Smith','deploy_20210621');

clim_t = [27.3 28.5];
clim_s = [30 36];

% xl = datenum(['22-Jun-2021 00:44:45';'23-Jun-2021 18:38:03']); % full range
xl = datenum(['21-Jun-2021 21:50:19';
              '22-Jun-2021 02:54:28';
              '22-Jun-2021 07:36:29';
              '22-Jun-2021 10:08:34';
              '22-Jun-2021 14:14:39';
              '22-Jun-2021 18:06:54';
              '22-Jun-2021 23:13:49';
              '23-Jun-2021 03:30:58';
              '23-Jun-2021 07:12:09';
              '23-Jun-2021 10:42:18';
              '23-Jun-2021 13:58:37';
              '23-Jun-2021 18:18:31';
              '23-Jun-2021 21:45:53']);

figure('position',[0 0 900 600]);
for i = 1:length(xl)-1
    clf
    subplot(811)
    plot(tc.dn,tc.lat(1,:),'k-');
    ylabel('Lat (^{\circ}N)')
    xlim(xl(i:i+1))
    datetick('x','mmdd-HHMM','keeplimits')
    xticklabels([])
    grid on
    cb = colorbar; set(cb,'visible','off');

    subplot(812);
    plot(tc.dn,tc.lon(1,:),'k-');
    ylabel('Lon (^{\circ}E)')
    xlim(xl(i:i+1))
    datetick('x','mmdd-HHMM','keeplimits')
    xticklabels([])
    grid on
    cb = colorbar; set(cb,'visible','off');

    subplot(8,1,3:5)
    pcolor(tc.dn,-tc.z,tc.s); shading flat; hold on
    colormap(gca,cmocean('haline'))
    caxis(clim_s)
    cb = colorbar; cb.Label.String = 'Salinity (PSU)';
    xlim(xl(i:i+1))
    datetick('x','mmdd-HHMM','keeplimits')
    grid on
    axis ij
    ylabel('Depth (m)')

    subplot(8,1,6:8)
    pcolor(tc.dn,-tc.z,tc.t); shading flat; hold on
    colormap(gca,cmocean('thermal'))
    caxis(clim_t)
    cb = colorbar; cb.Label.String = 'Temperature (^{\circ}C)';
    xlim(xl(i:i+1))
    datetick('x','mmdd-HHMM','keeplimits')
    xlabel('Time (UTC)')
    grid on
    axis ij
    ylabel('Depth (m)')

    ht = sgtitle(sprintf('%s %s',tc.info.config.vessel,tc.info.config.name));
    set(ht,'interpreter','none','fontsize',30,'fontweight','bold');
    f_out = sprintf('~/Work/SUNRISE/bowchain_figures/ws_bc_%02d',i);
    if numel(xl)==2
        f_out = sprintf('~/Work/SUNRISE/bowchain_figures/ws_bc_00_gridded',i);
    else
        f_out = sprintf('~/Work/SUNRISE/bowchain_figures/ws_bc_%02d_gridded',i);
    end
    print('-dpng','-r300',f_out)
    disp(['Saved ' f_out])

end
