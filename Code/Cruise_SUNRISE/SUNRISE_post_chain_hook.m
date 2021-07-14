function [data, cfg] = SUNRISE_post_chain_hook(data,cfg)

switch cfg.vessel
  case 'Walton_Smith'
    switch cfg.name
      case 'deploy_20210623_2235'
        % RBR Solo 101168 was bad after 25-Jun-2021 20:14:27. Interpolate from
        % neighboring sensors.
        idxi = find(strcmp({cfg.sensors.sn},'101168'));
        idxt = data.dn > datenum('25-Jun-2021 20:14:27');
        data.t(idxi,idxt) = nanmean(data.t(idxi+[-1 1],idxt),1);
    end
end
