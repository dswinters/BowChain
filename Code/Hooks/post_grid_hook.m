function gridded = post_grid_hook(gridded, cfg)

func = [cfg.cruise '_post_grid_hook'];
if exist(func) == 2
    gridded = feval(func,gridded,cfg);
end
