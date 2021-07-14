function gridded = cm_straight(gridded,cfg)

% Assume the chain is completely straight. Calculate vertical positions by
% interpolating pressure vs. position.
hasP = ~all(isnan(gridded.p),2);
if sum(hasP) > 1
    gridded.z = -interp1(gridded.pos(hasP),gridded.p(hasP,:),gridded.pos,'linear','extrap');
else    
    gridded.z = nan(size(gridded.x));
end

% This model assumes no horizontal offsets
gridded.x = zeros(size(gridded.x));
