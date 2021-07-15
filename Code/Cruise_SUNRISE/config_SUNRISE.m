%% config_SUNRISE.m
% Usage: Called from get_config('SUNRISE') in BowChain_master
% Description: Creates a basic deployment configuration structure for all
%              BowChain/Tchain deployments.
% Inputs: none
% Outputs: config structure
%
% Author: Dylan Winters (dylan.winters@oregonstate.edu)
% Created: 2021-06-20

function config = config_SUNRISE()

%% Set some global default options for deployments
defaults = struct();

% This is the simplest model for initial processing -- just assume that the
% chain is vertical and compressing like a spring. Get the depth coordinate of
% each sensor by interpolating between pressure sensors.
defaults.chain_model = 'cm_straight';

% We should do a "dunk" to calibrate sensor clocks eventually.
% defaults.time_offset_method = 'cohere';
% defaults.cohere_interval = [dunk_start_time, dunk_end_time];

% Set this to true to force re-parsing of raw data even if .mat files already
% exist. Useful in case we find mistakes in parsing functions and need to
% correct them.
defaults.raw2mat = false;

% Use the earliest and latest timestamp of all sensors if the start/end time
% aren't specified. Just in case we're missing a section_start_end_time.csv.
defaults.dn_range = [-inf inf];

% Grid-averaging settings
% defaults.bin_method = 'average';
% defaults.bin_dt = 2;
% defaults.bin_dz = 1;
% defaults.bin_zlim = [-30 0];

% Modify user_directories.m for your data location. For me this returns
% '/home/data/SUNRISE/Tchain', but everyone's local copy will probably be
% different.
dir_raw = fullfile(user_directories('SUNRISE'),'raw');

%% Create deployment-specific configurations
% This is where having a consistent file structure does 90% of the work for us!
% The expected format should look like this:
%
% └── Tchain
%     └── raw
%         └── Aries
%             └── deploy_20210618
%                 ├── 060088_20210618_2140.rsk
%                 ├── 077416_20210618_1644.rsk
%                 ├── 077561_20210618_1649.rsk
%                 ├── 077565_20210618_1647.rsk
%                 ├── 077566_20210618_2148.rsk
%                 ├── 077568_20210618_2141.rsk
%                 ├── 101179_20210618_2145.rsk
%                 ├── 101180_20210618_2136.rsk
%                 ├── instrument_depths.csv
%                 ├── README.txt
%                 └── section_start_end_time.csv

vessel_raw_folders = dir(fullfile(dir_raw));
vessel_names = setdiff({vessel_raw_folders.name},{'.','..'});

ndep = 0;
for v = 1:length(vessel_names)
    deployments = dir(fullfile(dir_raw,vessel_names{v},'deploy*'));
    for i = 1:length(deployments)
        ndep = ndep + 1;
        config(ndep).name = deployments(i).name;
        config(ndep).vessel = vessel_names{v};

        % Read the sensors.csv file for instrument deployment positions
        t = readtable(fullfile(deployments(i).folder,deployments(i).name,'instrument_depths.csv'));
        config(ndep).sensor_sn = num2cell(t.serialnum);
        config(ndep).sensor_pos = t.depth_m_;

        % Try to read start & end time
        try
            t = readtable(fullfile(deployments(i).folder,deployments(i).name,'section_start_end_time.csv'));
            config(ndep).dn_range = datenum([t.start_time t.end_time]);
        catch err
            % Default to full sensor time range if this fails
            config(ndep).dn_range = [-inf inf];
        end

        % Set raw data directory
        config(ndep).dir_raw = fullfile(deployments(i).folder,deployments(i).name);

        % Set processed data directory
        config(ndep).dir_proc = strrep(config(ndep).dir_raw,'/raw/','/processed/');
    end
end
config = fill_defaults(config,defaults);

%% We can specify any deployment- or vessel-specific settings here
% There are a bunch of possible ways to do this, below is one example:
for i = 1:length(config)
    switch config(i).vessel

      % Configure Walton Smith deployments
      case 'Walton_Smith'
        config(i).file_gps = '/home/dw/Data/SUNRISE/ws_gps.mat';
        switch config(i).name
          case 'deploy_20210621'
            config(i).zero_pressure_interval = datenum([2021 06 21 21 04 40; 2021 06 21 23 21 20]);
            % config(i).chain_model = 'cm_catenary';
          case 'deploy_20210623_2235'
            config(i).zero_pressure_interval = datenum(['23-Jun-2021 19:16:18'
                                                        '23-Jun-2021 22:25:59']);
            % config(i).chain_model = 'cm_catenary';
          case 'deploy_20210627'
            config(i).zero_pressure_interval = datenum(['27-Jun-2021 03:46:52';
                                                        '27-Jun-2021 06:30:11']);
          case 'deploy_20210630_2045'
            config(i).zero_pressure_interval = datenum(['30-Jun-2021 18:47:05';
                                                        '30-Jun-2021 20:45:08']);
          case 'deploy_20210704_1115'

            config(i).zero_pressure_interval = datenum(['04-Jul-2021 13:30:36';
                                                        '04-Jul-2021 14:22:08']);

        end

      case 'Aries'
        config(i).file_gps = '/home/dw/Data/SUNRISE/RHIB/nav/gps_Aries.mat';
        switch config(i).name
          case 'deploy_20210622_2300'
            config(i).zero_pressure_interval = datenum(['22-Jun-2021 21:34:55';
                                                        '22-Jun-2021 23:34:19']);
          case 'deploy_20210624'
            config(i).zero_pressure_interval = datenum(['24-Jun-2021 21:09:36';
                                                        '24-Jun-2021 22:26:48']);
          case 'deploy_20210629'
            config(i).zero_pressure_interval = datenum(['28-Jun-2021 02:41:26'
                                                        '29-Jun-2021 17:12:32']);
          case 'deploy_20210702'
            config(i).zero_pressure_interval = datenum(['02-Jul-2021 00:57:36';
                                                        '02-Jul-2021 14:45:16']);
          case 'deploy_20210706'
            config(i).zero_pressure_interval = datenum(['06-Jul-2021 21:24:42';
                                                        '06-Jul-2021 22:45:38']);
        end

      case 'Polly'
        config(i).file_gps = '/home/dw/Data/SUNRISE/RHIB/nav/gps_Polly.mat';
        switch(config(i).name)
          case 'deploy_20210623_2225'
            config(i).zero_pressure_interval = datenum(['23-Jun-2021 09:48:56';
                                                        '23-Jun-2021 20:39:15']);
          case 'deploy_20210625'
            config(i).zero_pressure_interval = datenum(['25-Jun-2021 22:23:25';
                                                        '26-Jun-2021 01:08:38']);
          case 'deploy_20210629'
            config(i).zero_pressure_interval = datenum(['27-Jun-2021 21:52:15';
                                                        '29-Jun-2021 06:30:58']);
          case {'deploy_20210630','deploy_20210701'}
            config(i).zero_pressure_interval = datenum(['30-Jun-2021 21:00:13';
                                                        '30-Jun-2021 21:18:09']);
          case {'deploy_20210704','deploy_20210706'};
            config(i).zero_pressure_interval = datenum(['03-Jul-2021 02:43:08';
                                                        '03-Jul-2021 22:26:32']);
        end

      case 'Pelican'
        config(i).file_gps = '/home/dw/Data/SUNRISE/PE_nav_final.mat';

      % Configure Pelican deployments
      case 'Pelican'
        switch config(i).name
          case 'deploy_name'
        end
    end
end


%% End of config_SUNRISE
% After running
%   >> tchain = BowChain_master('SUNRISE','Aries','deploy_20210618')
% you should have a file structure like this:
%
% └── Tchain
%     ├── processed
%     │   └── Aries
%     │       └── deploy_20210618
%     │           ├── 060088_20210618_2140.mat
%     │           ├── 077416_20210618_1644.mat
%     │           ├── 077561_20210618_1649.mat
%     │           ├── 077565_20210618_1647.mat
%     │           ├── 077566_20210618_2148.mat
%     │           ├── 077568_20210618_2141.mat
%     │           ├── 101179_20210618_2145.mat
%     │           └── 101180_20210618_2136.mat
%     └── raw
%         └── Aries
%             └── deploy_20210618
%                 ├── 060088_20210618_2140.rsk
%                 ├── 077416_20210618_1644.rsk
%                 ├── 077561_20210618_1649.rsk
%                 ├── 077565_20210618_1647.rsk
%                 ├── 077566_20210618_2148.rsk
%                 ├── 077568_20210618_2141.rsk
%                 ├── 101179_20210618_2145.rsk
%                 ├── 101180_20210618_2136.rsk
%                 ├── instrument_depths.csv
%                 ├── README.txt
%                 └── section_start_end_time.csv

% And the output, tchain, looks like this:
%
% >> tchain
% tchain =
%   struct with fields:
%       dn: [1x29111 double]
%        t: [8x29111 double]
%        p: [8x29111 double]
%        s: [8x29111 double]
%        x: [8x29111 double]
%        z: [8x29111 double]
%      pos: [8x1 double]
%     info: [1x1 struct]

% You can run BowChain_master('SUNRISE',vessel_name,deploy_name) like this to
% process an individual deployment, or BowChain_master('SUNRISE') to process all
% deployments.
