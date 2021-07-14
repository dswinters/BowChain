function [data, cfg] = post_load_hook(data, cfg)

func = [cfg.cruise '_post_load_hook'];
if exist(func) == 2
    [data, cfg] = feval(func,data,cfg);
end
