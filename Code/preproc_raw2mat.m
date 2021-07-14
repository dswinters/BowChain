function config = preproc_raw2mat(config)
% Convert raw sensor data to .mat format

disp('Converting raw data to .mat files...')

for i = 1:length(config.sensors)
    
    % Check if .mat files already exist
    [~,fname,fext] = fileparts(config.sensors(i).file_raw);
    force_reparse = isfield(config,'raw2mat') && config.raw2mat;
    if exist(config.sensors(i).file_mat) && ~force_reparse
        % Skip
        disp(['  ' fname '.mat' ' already exists'])
    else
        disp(['  ' fname fext ' --> ' fname '.mat'])

        % Parse raw sensor data
        data = feval(config.sensors(i).parse_func,...
                     config.sensors(i).file_raw);

        % Save .mat file
        data.sn = config.sensors(i).sn;
        save(config.sensors(i).file_mat,'-struct','data');
    end
end
