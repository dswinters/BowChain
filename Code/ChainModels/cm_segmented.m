function gridded = cm_segmented(gridded,cfg)

% Assume the chain is comprised of straight segments divided by pressure
% sensors. Interpolate/extrapolate depth to other sensors, compute lateral
% offsets based on known depths and chain positions.

disp('Computing chain shapes. This may take some time.')
nprog = 50;
disp(repmat('.',1,nprog))
NS = size(gridded.p,1);
L = cfg.sensor_pos;
for i = 1:length(gridded.dn)
    if mod(i,floor(length(gridded.dn)/nprog))==0
        fprintf('.')
    end

    % Extract pressure/position from pressure sensors
    hasP = find(~isnan(gridded.p(:,i)));
    p = gridded.p(hasP,i);
    l = L(hasP);

    % Assign depths to all sensors
    z = nan(NS,1);
    % Extrapolate first/last sensors
    if hasP(end) < NS % sensors after last pressure sensor
        z(hasP(end)+1:end) = interp1(l(end-1:end),p(end-1:end),...
                                     L(hasP(end)+1:end),'linear','extrap');
    end
    if hasP(1) > 1
        z(1:hasP(1)-1) = interp1(l(1:2),p(1:2),L(1:hasP(1)-1),'linear','extrap');
    end
    % Interpolate between sensors
    for n = 1:length(hasP)-1
        z(hasP(n)+1:hasP(n+1)-1) = interp1(l(n:n+1),p(n:n+1),L(hasP(n)+1:hasP(n+1)-1));
    end
    z(hasP) = p;
    gridded.z(:,i) = -z;

    % Assign lateral offsets to all sensors
    % Assume chain enters water at (0,z0)
    x = nan(NS,1);
    x(1) = 0;
    for n = 2:NS
        delZ = diff(z(n-1:n));
        delL = diff(L(n-1:n));
        delX = delL*sin(acos(delZ/delL));
        if ~isreal(delX); keyboard; end
        x(n) = x(n-1) - delX;
    end

    gridded.x(:,i) = x;

end
