function config = preproc_setup(config);

disp('Identifying sensors and finding data...')
conig.sensors = struct();

setup_override_fname = ['setup_override_' config.cruise];
if exist(setup_override_fname) == 2
    fprintf('  Overriding default setup with %s.\n',setup_override_fname)
    config = feval(setup_override_fname,config);
    return
end

pos_ind = 0; % position index

sensor_dir_func = ['sensor_dirs_' config.cruise];

for i = 1:length(config.sensor_sn)
    % Associate a parsing function and file extension with a serialnum
    [sensor_type, parse_func, ext, sn, status] = get_sensor_info(config.sensor_sn{i});
    if status==0 % found parsing func and file ext for serial
        if exist(sensor_dir_func,'file')
            [fpath_raw, fpath_proc] = feval(sensor_dir_func,config,sn);
        else
            fpath_raw = config.dir_raw;
            fpath_proc = config.dir_proc;
        end
        if ~exist(config.dir_proc,'dir')
            mkdir(config.dir_proc);
        end

        file_raw = dir(fullfile(fpath_raw,['*' sn '*' ext]));
        if length(file_raw) == 1
            pos_ind = pos_ind + 1;
            fn_raw = file_raw.name;
            [~,fname,fext] = fileparts(fn_raw);
            fn_mat = [fname, '.mat'];
            config.sensors(pos_ind) = struct(...
                'sn'          , sn                          ,...
                'file_raw'    , fullfile(fpath_raw,fn_raw)  ,...
                'file_mat'    , fullfile(fpath_proc,fn_mat) ,...
                'sensor_type' , sensor_type                 ,...
                'parse_func'  , parse_func                  ,...
                'pos'         , config.sensor_pos(i)        ,...
                'pos_ind'     , pos_ind);
            msg = '  %s [%s]';
            disp(sprintf(msg,sensor_type,sn));
        else
            msg = '%s [%s]: %d raw file(s), skipped!';
            disp(sprintf(msg,sensor_type,sn,length(file_raw)));
        end
    else
        disp(sprintf('  No sensor information found for [%s]',sn))
    end
end
