%% config = get_config(cruise,varargin)
%
% Run the cruise's configuration file, fill with default values where necessary,
% and scan for missing configuration options

function config = get_config(cruise,varargin)

%% Setup
% Get cruise configuration
cruise_file = fullfile(['Cruise_' cruise],['config_' cruise]);
if exist(cruise_file) == 2
    config = feval(['config_' cruise]);
else
    error('Cannot find file: %s.m',cruise_file)
end
flds = fields(config);

% Fill default options
defaults = config_default();
config = fill_defaults(config,config_default());

% Notify about options that were filled
newflds = setdiff(fields(config),flds);
for i = 1:length(newflds)
    if isnumeric(defaults.(newflds{i}));
        fldfmt = '%.2f';
    else
        fldfmt = '%s';
    end
    msgfmt = ['Field "%s" not specified. Using default value: ' fldfmt];
    disp(sprintf(msgfmt,newflds{i},defaults.(newflds{i})));
end

% Limit to vessel(s), if specified
if nargin > 1
    if ~iscell(varargin{1})
        varargin{1} = {varargin{1}};
    end
    config = config(ismember({config.vessel},varargin{1}));
end

% Limit to deployment(s), if specified
if nargin > 2
    if ~iscell(varargin{2})
        varargin{2} = {varargin{2}};
    end
    config = config(ismember({config.name},varargin{2}));
end

%% Check for missing configuration settings

% Missing optional settings
opts_optional = struct();
opts_optional(1).name = 'zero_pressure_interval';
opts_optional(2).name = 'file_gps';
%
opts_optional(1).desc = 'Time interval to calibrate pressure (datenum)';
opts_optional(2).desc = 'Location of GPS file';
%
check_config(cruise,config,opts_optional,'optional')

% Missing required settings
opts = struct();
opts(1).name = 'name';
opts(2).name = 'freq_base';
opts(3).name = 'dir_raw';
opts(4).name = 'dir_proc';
opts(5).name = 'dn_range';
opts(6).name = 'sensor_sn';
opts(7).name = 'sensor_pos';
% Requried additional fields for certain options
%   {option, value, required option}
% e.g. if config.time_offset_method is 'cohere', then config.cohere_interval
% must be set.
opts(8).name = {'time_offset_method','cohere','cohere_interval'};
opts(9).name = {'time_offset_method','known_drift','time_synched'};
opts(10).name = {'time_offset_method','known_drift','drift'};
opts(11).name = {'bin_method','time','binned_period'};
opts(12).name = {'bin_method','average','bin_dt'};
opts(13).name = {'bin_method','average','bin_dz'};
opts(14).name = {'bin_method','average','bin_zlim'};
%
opts(1).desc = 'deployment name';
opts(2).desc = 'desired frequency for gridded data';
opts(3).desc = 'path to deployment''s raw data directory';
opts(4).desc = 'path to deployment''s processed data directory';
opts(5).desc = 'desired datenum range for gridded data';
opts(6).desc = 'cell array of sensor serial numbers (as strings)';
opts(7).desc = 'vector of sensor positions (m)';
opts(8).desc = 'datenum range for determining time offsets';
opts(9).desc = 'time that clocks were synched (datenum)';
opts(10).desc = 'measured clock drifts (seconds)';
opts(11).desc = 'period for time-binned output (s)';
opts(12).desc = 'time bin size (s)';
opts(13).desc = 'depth bin size (m)';
opts(14).desc = 'depth bin range (m)';
%
check_config(cruise,config,opts,'required')

%% Misc config structure processing
for d = 1:length(config)
    % Ensure the right shape for sensor_sn
    config(d).sensor_sn = reshape(config(d).sensor_sn,1,[]);
    % Add the cruise name to the config structure
    config(d).cruise = cruise;
end
