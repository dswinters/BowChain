%% proc_gps(gridded,cfg)
% Compute locations of samples by applying positional offsets to GPS data.
% cfg.file_gps must point to a .mat file containing the following variables:
%  - dn: datenum vector
%  - lat: latitude vector (deg E)
%  - lon: longitude vector (deg N)
%  - heading: heading vector (deg T)

function gridded = proc_gps(gridded,cfg)

if isfield(cfg,'file_gps')
    % Load gps data
    gps = load(cfg.file_gps);
    [~,iu] = unique(gps.dn);

    % Interpolate GPS data to sensor time
    hi = cosd(gps.heading) + 1i*sind(gps.heading);
    h = mod(180/pi*angle(interp1(gps.dn(iu),hi(iu),gridded.dn)),360);
    lat = interp1(gps.dn(iu),gps.lat(iu),gridded.dn);
    lon = interp1(gps.dn(iu),gps.lon(iu),gridded.dn);

    % Make lat/lon/heading the same size as gridded data
    nsens = length(gridded.pos);
    h = repmat(h,nsens,1);
    lat = repmat(lat,nsens,1);
    lon = repmat(lon,nsens,1);

    % Apply positional offsets in the direction of ship motion
    arc = distdim(gridded.x,'meters','degrees','earth'); % convert m to arclength
    [gridded.lat, gridded.lon] = reckon(lat,lon,gridded.x,h); % apply arclength offset
end
