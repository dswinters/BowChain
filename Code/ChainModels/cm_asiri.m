function gridded = cm_asiri(gridded,cfg)

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
    x = zeros(NS,1);

    z(1) = p(1) - abs(L(1) - l(1));
    z(end) = min(...
        [p(end) + abs(L(end) - l(end));
         abs(L(end) - L(1)) + z(1)]);
    z(2:end-1) = interp1(L([1 end]),z([1 end]),L(2:end-1));

    gridded.x(:,i) = x;
    gridded.z(:,i) = -z;

end
