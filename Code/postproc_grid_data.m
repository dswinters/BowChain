function out = postproc_grid_data(gridded,cfg)

out = gridded;
%% Check for bin method
if ~isfield(cfg,'bin_method')
    warning('No bin method specified. Returning point cloud!')
end

%% Check for valid GPS data
if isfield(cfg,'file_gps') % Make sure we have a GPS file specified
    gps = load(cfg.file_gps);
    % Check for missing fields
    flds = fields(gps);
    req_flds = {'dn','lat','lon'};
    missing_flds = setdiff(req_flds,flds);
    if length(missing_flds) > 1
        warning('GPS file is missing fields: %s. Returning point cloud!',...
                strjoin(missing_flds,', '))
        return
    end
end

%% Define bin edges for time/lateral space dimension
switch cfg.bin_method
  case 'average'
    %% Bin-average with specified dt & dz
    fprintf('Bin-averaging with dt=%.1fs, dz=%.1fm...',cfg.bin_dt,cfg.bin_dz);

    tg = cfg.dn_range(1):cfg.bin_dt/86400:cfg.dn_range(end); % time grid
    zg = min(cfg.bin_zlim):abs(cfg.bin_dz):max(cfg.bin_zlim); % z grid
    zbn = discretize(gridded.z,zg); % z bin number
    tbn = discretize(gridded.dn,tg).*ones(length(cfg.sensors),1); % time bin number
    kp = ~isnan(zbn.*tbn); % indices to keep (non-nan time and depth bin numbers)

    % Do the bin-averaging
    flds = {'t','p','s','lat','lon'};
    for i = 1:length(flds)
        gridded.(flds{i}) = accumarray([zbn(kp), tbn(kp)], ...      % bin indices
                                       gridded.(flds{i})(kp),...    % values
                                       [length(zg), length(tg)],... % output size
                                       @nanmean, NaN);              % function to apply & fill value
    end

    % Make lat & lon 1D
    gridded.lat = nanmean(gridded.lat,1);
    gridded.lon = nanmean(gridded.lon,1);

    % Remove 'pos' field (no longer makes sense)
    gridded = rmfield(gridded,'pos');

    % Replace time and z fields
    gridded.z = zg(:);
    gridded.dn = tg;
    out = gridded;
    fprintf(' Done!\n')

  case 'time'
    %%% Project sensor measurements onto slice beneath ship and bin in time

    %% Compute ship speed from GPs data
    % remove non-unique timestamps
    [~,idx] = unique(gps.dn);
    dn = gps.dn(idx);
    lt = gps.lat(idx);
    ln = gps.lon(idx);
    % remove NaNs
    idx = ~isnan(dn.*lt.*ln);
    dn = dn(idx);
    lt = lt(idx);
    ln = ln(idx);
    % compute velocity
    wgs84 = referenceEllipsoid('wgs84','m');
    lt0 = nanmean(lt);
    ln0 = nanmean(ln);
    lt2y = distance('rh',lt0-0.5,ln0,lt0+0.5,ln0,wgs84); % meters N/S per deg N
    ln2x = distance('rh',lt0,ln0-0.5,lt0,ln0+0.5,wgs84); % meters E/W per deg W at lat lt0
    y  =  lt2y * (lt-lt0) ; % meters N/S
    x  =  ln2x * (ln-ln0) ; % meters E/W
    dt = diff(dn)*86400;
    t  = dn(1:end-1) + diff(dn)/2;
    vx = interp1(t, diff(x)./dt, gridded.dn);
    vy = interp1(t, diff(y)./dt, gridded.dn);
    spd = sqrt(vx.^2 + vy.^2);

    %% Apply speed-dependent sensor time offsets
    spd2 = ones(length(gridded.pos),1)*spd;
    dn_base = ones(length(gridded.pos),1)*gridded.dn;
    dn_offset = dn_base - (gridded.x ./ spd2);

    %% Bin the data
    % define bin edges and output time vector
    dt = cfg.binned_period/86400; % convert binned period to days (datenum)
    tbin = gridded.dn(1):dt:gridded.dn(end); % bin edges
    out.dn = tbin(1:end-1) + dt/2; % use bin centers for output time vector
    % assign time bin numbers to each measurement
    [n,~,tbin] = histcounts(dn_offset,tbin);
    % we also need depth bin numbers - just use sensor index
    dbin = [1:length(gridded.pos)]'*ones(1,length(gridded.dn));
    % use accumarray to average all data within each bin
    flds = {'t','p','s','z'};
    for i = 1:length(flds)
        out.(flds{i}) = accumarray([dbin(:),tbin(:)],gridded.(flds{i})(:),[],@nanmean);
    end

    out.lat = interp1(gps.dn,gps.lat,out.dn);
    out.lon = interp1(gps.dn,gps.lon,out.dn);
    if isfield(cfg,'include_config') && cfg.include_config
        out.config = cfg;
    end

  case 'space'
    % Assign a lat/lon to each measurement and then bin spatially
    warning('''Space'' bin method not yet implemented. Returning point cloud!');
    return
end
