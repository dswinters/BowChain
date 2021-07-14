function [data, config] = proc_load_mat(config)
data = {};

disp('Loading raw data from .mat files...')
for i = 1:length(config.sensors)
    data{i} = load(config.sensors(i).file_mat);
    msg = '  Loaded data from %s [%s]';
    disp(sprintf(msg,config.sensors(i).sensor_type,config.sensors(i).sn))
end

% Set time limits to the min & max of sensor values if they're inf
if isinf(config.dn_range(1))
    config.dn_range(1) = min(cellfun(@(c) c.dn(1), data));
end

if isinf(config.dn_range(end))
    config.dn_range(end) = max(cellfun(@(c) c.dn(end), data));
end
