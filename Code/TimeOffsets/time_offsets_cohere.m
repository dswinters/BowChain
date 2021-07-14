function offsets = time_offsets_cohere(gridded,data,cfg);

offsets = zeros(size(gridded.t,1),1);
for i = 2:length(offsets)
  % Get time offset
  offsets(i) = determine_t_offset(gridded.dn',gridded.t(i-1,:)',...
                                  gridded.dn',gridded.t(i,:)',cfg.cohere_interval);
end
offsets = cumsum(offsets);
