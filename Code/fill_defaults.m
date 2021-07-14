function deps = fill_defaults(deps,defaults)

depflds = fields(deps);
defflds = fields(defaults);

for d = 1:length(deps)
    for i = 1:length(defflds)
        if ~isfield(deps(d),defflds{i}) || isempty(deps(d).(defflds{i}))
            deps(d).(defflds{i}) = defaults.(defflds{i});
        else
            if isstruct(deps(d).(defflds{i}))
                deps(d).(defflds{i}) = fill_defaults(deps(d).(defflds{i}),defaults.(defflds{i}));
            end
        end
    end
end
