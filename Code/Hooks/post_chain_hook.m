function gridded = post_chain_hook(gridded, cfg)

func = [cfg.cruise '_post_chain_hook'];
if exist(func) == 2
    gridded = feval(func,gridded,cfg);
end
