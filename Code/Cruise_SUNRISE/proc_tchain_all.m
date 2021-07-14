clear all, close all
cruise = 'SUNRISE';

%% Configure input/output directories
dir_raw = '/home/dw/Data/SUNRISE/Tchain/raw/';
dir_proc = '/home/dw/Data/SUNRISE/Tchain/processed/';
bcdir = '/home/dw/Work/BowChain/Code';

% Add BowChain code to path
addpath(bcdir);
addpath(genpath(fullfile(bcdir,'ParseFunctions')));   % instrument parsing functions
addpath(genpath(fullfile(bcdir,'ChainModels')));      % bow chain shape models
addpath(genpath(fullfile(bcdir,'TimeOffsets')));      % Sensor clock offset computation methods
addpath(genpath(fullfile(bcdir,'gsw')));              % GSW toolbox
addpath(genpath(fullfile(bcdir,'Hooks')));            % Hook functions
addpath(genpath(fullfile(bcdir,'RSKtools')));         % RSK tools
addpath(genpath(fullfile(bcdir,['Cruise_' cruise]))); % cruise-specific functions

% Get vessel names
vessel_dirs = dir(dir_raw);
vessels = setdiff({vessel_dirs.name},{'.','..'});

% Process each deployment
disp('Processing TChain Deployments')
overwrite = false;
for v = 1:length(vessels)
    deps = dir(fullfile(dir_raw,vessels{v},'deploy*'));
    for i = 1:length(deps)
        fname = sprintf('SUNRISE_2021_tchain_%s_%s.mat',vessels{v},deps(i).name);
        f_out = fullfile(dir_proc,fname);

        if ~exist(f_out,'file') | overwrite
            tc = BowChain_master('SUNRISE',vessels{v},deps(i).name);

            % Make lat & lon 1D, remove x coordinate
            tc.lat = tc.lat(1,:);
            tc.lon = tc.lon(1,:);
            tc = rmfield(tc,'x');

            disp('Continue to save .mat file')
            keyboard
            % Save output
            save(f_out,'-struct','tc');
            disp(['  Saved ' f_out])

        else
            disp(['  ' f_out ' already exists'])
        end
    end
end

disp('Continue to generate section files')
keyboard
%% Save files for each section
surveys = dir('/home/dw/Work/SUNRISE/transect_times/survey_*_sections.csv');
dir_out = '/home/dw/Data/SUNRISE/Tchain/processed/sections/';
dir_deps = '/home/dw/Data/SUNRISE/Tchain/processed';
overwrite_sections = true;
for s = 1:length(surveys)
    secs = readtable(fullfile(surveys(s).folder,surveys(s).name));
    sname = surveys(s).name(1:regexp(surveys(s).name,'_sections.csv','start')-1);
    for v = 1:length(vessels)
        % Get sub-table of vessel deployments
        vsecs = secs(find(strcmp(secs.vessel,vessels{v})),:);

        % Get time bounds of tchain deployments
        tfiles = dir(sprintf('%s/*%s*.mat',dir_deps,vessels{v}));
        tc_dnb = nan(length(tfiles),2);
        for t = 1:length(tfiles)
            tc = load(fullfile(tfiles(t).folder,tfiles(t).name),'info');
            tc_dnb(t,:) = tc.info.config.dn_range;
        end

        % For every section:
        nf_loaded = 0;
        for j = 1:height(vsecs)
            f_out = sprintf('%s/%s_%s_sec%02d_tchain.mat',dir_out,sname,vessels{v},vsecs.n(j));
            if ~exist(f_out,'file') | overwrite_sections
                nf = find(tc_dnb(:,1)<=datenum(vsecs.start_utc(j))+.5/24 & ...
                          tc_dnb(:,2)>=datenum(vsecs.end_utc(j))-.5/24);

                % Load the file containing the section
                idx = [];
                if ~isempty(nf);
                    if nf_loaded ~= nf
                        tc = load(fullfile(tfiles(nf).folder,tfiles(nf).name));
                        nf_loaded = nf;
                    end

                    % Limit the tchain data to the section time range
                    idx = tc.dn >= datenum(vsecs.start_utc(j)) & ...
                          tc.dn <= datenum(vsecs.end_utc(j));
                end

                if sum(idx) > 0
                    flds = setdiff(fields(tc),{'info','pos'});
                    tc_sec = tc;
                    for f = 1:length(flds)
                        tc_sec.(flds{f}) = tc_sec.(flds{f})(:,idx);
                    end

                    % Save a .mat file named after the vessel and section
                    save(f_out,'-struct','tc_sec');
                    fprintf('\nSaved %s', f_out);
                end
            end % if ~exist(file)

        end % loop over vessel's sections
    end % loop over vessels
end % loop over surveys
fprintf('\n')
