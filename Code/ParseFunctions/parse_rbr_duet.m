function data = parse_rbr_duet(f_in)
    data = struct();
    [rbr,dbid] = RSKopen(f_in);
    tmp = RSKreaddata(rbr);
    data.dn = tmp.data.tstamp;
    data.t = tmp.data.values(:,1);
    data.p = tmp.data.values(:,2);
end
