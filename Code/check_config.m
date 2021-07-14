%% check_config(config)
% Check a BowChain configuration structure for missing settings. Throw an error
% if required settings are missing; warn about missing optional requirements.

function check_config(cruise,config,opts,type)

% Check for missing required configuration
msg = '';
n_missing = 0;
for d = 1:length(config)
    for i = 1:length(opts)
        if ~iscell(opts(i).name);
            if ~isfield(config(d),opts(i).name) || isempty(config(d).(opts(i).name))
                msg = sprintf('%s\n  %s: %s (%s)',...
                              msg,config(d).name,opts(i).name,opts(i).desc);
                n_missing = n_missing + 1;
            end
        else
            if isfield(config(d),opts(i).name{1}) && ...
                    strcmp(config(d).(opts(i).name{1}),opts(i).name{2}) && ...
                    ~isfield(config(d),opts(i).name{3})
                msg = sprintf('%s\n  %s: %s "%s" requires config field: "%s" (%s)',...
                              msg,config(d).name,opts(i).name{1},...
                              opts(i).name{2},opts(i).name{3},opts(i).desc);
                n_missing = n_missing + 1;
            end
        end                
    end
end

if n_missing > 0
    switch type
      case 'required'
        error('Missing deployment configuration for %s: %s',...
              cruise,msg);
      otherwise
        warning('Missing deployment configuration for %s: %s',...
                cruise,msg);
    end
end
