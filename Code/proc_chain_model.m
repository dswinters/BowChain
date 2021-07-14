function gridded = proc_chain_model(gridded,cfg)
gridded = feval(cfg.chain_model,gridded,cfg);
