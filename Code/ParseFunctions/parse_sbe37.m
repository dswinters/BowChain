function data = parse_sbe37(f_in)

sbe = cnv2mat_SBE37_asiri13(f_in,'','',0,0);
data.dn = sbe.dtnum;
data.t = sbe.temp;
data.p = sbe.pr;
data.c = sbe.cond;
data.s = gsw_SP_from_C(data.c,data.t,data.p);
