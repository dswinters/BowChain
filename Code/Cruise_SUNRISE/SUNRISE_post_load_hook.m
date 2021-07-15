function [data, cfg] = SUNRISE_post_load_hook(data,cfg)

switch cfg.vessel
  case 'Aries'
    switch cfg.name
      case 'deploy_20210629'
        % This sensor had bad timestamps, weird pressure values... possibly
        % salvageable for 1st half of deployment.
        i = strcmp('60702',{cfg.sensors.sn});
        % dn_old = data{i}.dn;
        % data{i}.dn = data{i}.dn(1) + [0:length(data{i}.dn)-1]*1/16/86400;
        data = data(~i);
        cfg.sensors = cfg.sensors(~i);
    end
  case 'Walton_Smith'
    switch cfg.name
      case 'deploy_20210623_2235'
        % RBR Solo 100154 did not log
        rm = strcmp({cfg.sensors.sn},'100154');
        data = data(~rm);
        cfg.sensors = cfg.sensors(~rm);

        % RBR Solo 101168 started giving obviously bad data after 25-Jun-2021 20:14:27
        idxi = find(strcmp({cfg.sensors.sn},'101168'));
        idxt = data{idxi}.dn > datenum('25-Jun-2021 20:14:27');
        data{idxi}.t(idxt) = nan;

      case 'deploy_20210627'
        idx = find(strcmp({cfg.sensors.sn},'100154'));
        bad_time = datenum([2000 01 04 13 48 05]);
        good_time = datenum([2021 06 30 16 05 26]);
        data{idx}.dn = data{idx}.dn + (good_time-bad_time);

        % Fix start/end times
        % cfg.dn_range = [min(cellfun(@(c) c.dn(1),data)),...
        %                 max(cellfun(@(c) c.dn(end),data))];

        % RBR Solo 101168 was having issues and didn't record any data
        rm = strcmp({cfg.sensors.sn},'101168');
        data = data(~rm);
        cfg.sensors = cfg.sensors(~rm);

      case 'deploy_20210630_2045'
        % datestr(cellfun(@(c) c.dn(1),data))
        idx = find(strcmp({cfg.sensors.sn},'100154'));
        bad_time = datenum([2000 01 08 11 06 11]);
        good_time = datenum([2021 07 04 01 23 33]);
        data{idx}.dn = data{idx}.dn + (good_time-bad_time);

        % Fix start/end times
        % cfg.dn_range = [min(cellfun(@(c) c.dn(1),data)),...
        %                 max(cellfun(@(c) c.dn(end),data))];

      case 'deploy_20210704_1115'
        % FIXME only one concerto
    end
  case 'Polly'
    switch cfg.name
      case 'deploy_20210625'
        % This deployment had 1 sensor clock way out of sync. Clock on recovery
        % showed 20000102_162841 while computer UTC clock showed
        % 20210627_134659.
        idx = find(strcmp({cfg.sensors.sn},'207057'));
        bad_time = datenum([2000 01 02 16 28 41]);
        good_time = datenum([2021 06 27 13 46 59]);
        data{idx}.dn = data{idx}.dn + (good_time-bad_time);

        % RBR Solo 101179 was having issues and didn't record any data
        rm = strcmp({cfg.sensors.sn},'101179');
        data = data(~rm);
        cfg.sensors = cfg.sensors(~rm);

        % Fix start/end times temporarily
        % cfg.dn_range = [min(cellfun(@(c) c.dn(1),data)),...
        %                 max(cellfun(@(c) c.dn(end),data))];
    end

  case 'Pelican'
    switch cfg.name
      case 'deploy_20210706'
        % Concerto 60183 has some bad timestamps mid-deployment.. skip for now
        % to avoid making a time vector to year 2073
        rm = strcmp({cfg.sensors.sn},'60183');
        data = data(~rm);
        cfg.sensors = cfg.sensors(~rm);

        % Fix start/end times temporarily
        cfg.dn_range = [min(cellfun(@(c) c.dn(1),data)),...
                        max(cellfun(@(c) c.dn(end),data))];

    end

end
