%% get_sensor_info.m
% Usage: [sensor_type funcname ext sn_str status] = get_sensor_info(serial)
% Description: Returns sensor information from a given serial number.
% Inputs: serial - number or string
% Outputs: sensor_type: string
%             funcname: name of parsing function (string)
%                  ext: file extension of raw sensor data
%               sn_str: formatted serial number string with leading zeros
%               status: exit status of get_sensor_info
%
% Author: Dylan Winters (dylan.winters@oregonstate.edu)
% Updated: 2021-06-19

function [sensor_type funcname ext sn_str status] = get_sensor_info(serial)

%% Convert serial to string if it's numeric
if isnumeric(serial)
    serial = sprintf('%d',serial);
    sn_str = serial;
end

%% Instrument serial numbers
serials = struct();

% SBE39
serials.sbe39 = [03253, 03134];
fmt.sbe39 = '%05s';

% SBE56
serials.sbe56 = [00280, 00281, 00285, 00291, 00292, 00295, 00296, 00299, ...
                 00303, 00304, 00305, 00309, 00311, 00315, 00316, 00319, ...
                 00320, 00324, 00326, 00328, 00331, 00332, 00372, 00381, ...
                 00392, 00406, 00407, 00411, 00416, 00418, 00421, 00422, ...
                 00423, 00442, 00445, 00446, 00448, 00449, 00451, 00453, ...
                 00455, 01548];
fmt.sbe56 = '%05s';

% RBR Solo
serials.rbr_solo = [075998, 076158, 076309, 076310, 076311, 076312, 076313, ...
                    076314, 076315, 076316, 076317, 076318, 076583, 076584, ...
                    076585, 076586, 076587, 076588, 076589, 076590, 076591, ...
                    076592, 076593, 076594, 076595, 076596, 076597, 076598, ...
                    076599, 076600, 076601, 076602, 076603, 076605, 076606, ...
                    076607, 076610, 077416, 077520, 077521, 077522, 077523, ...
                    077524, 077561, 077561, 077561, 077561, 077562, 077562, ...
                    077562, 077562, 077563, 077563, 077564, 077564, 077564, ...
                    077564, 077565, 077565, 077565, 077566, 077566, 077566, ...
                    077567, 077567, 077567, 077568, 077568, 077568, 077568, ...
                    077569, 077569, 077569, 077569, 077570, 077570, 077570, ...
                    100020, 100021, 100022, 100023, 100024, 100025, 100026, ...
                    100027, 100028, 100029, 100030, 100031, 100033, 100034, ...
                    100153, 100154, 100155, 100156, 100157, 100158, 100159, ...
                    100160, 100161, 100162, 100320, 100693, 100694, 100695, ...
                    100696, 100698, 100699, 100700, 100701, 100702, 100885, ...
                    100886, 101158, 101159, 101160, 101161, 101162, 101164, ...
                    101165, 101168, 101179, 101180, 101181, 101185, 101186, ...
                    101188, 101189, 101190, 101191, 101192, 101193, 101194, ...
                    101195, 101196, 101197, 102516, 102517, 102519, 207018, ...
                    207021, 207036, 207045, 207046, 207048, 207054, 207057, ...
                    207059, 207063, 207039, 207035, 207064, 207065, 207016, ...
                    207017, 207025, 207026, 207037, 207040, 207041, 207044, ...
                    207050, 207034, 207031, 207020, 207038, 207032, 207029, ...
                    207061, 207052, 207058, 207062, 207056, 207022, 207033, ...
                    207024, 207060, 207023, 207030, 207027, 207028];


fmt.rbr_solo = '%06s';

% RBR Concerto
serials.rbr_concerto = [060280, 060281, 060088, 060094, 060095, 060559, 060704, ...
                        060276, 060275, 060381, 060093, 060380, 060528, 060702, ...
                        060703, 060379, 060701, 060183, 060558];
fmt.rbr_concerto = '%06s';

% Duet
serials.rbr_duet = [082489, 082506];
fmt.rbr_duet = '%06s';

% GusT
serials.gust = {'G049','G050'};
fmt.gust = '%s';

%% Create regular expressions to match serial numbers
insts = fields(serials);
rx = {};
match = '';
for i = 1:length(insts)
    if isnumeric(serials.(insts{i}))
        str = sprintf('%d|',serials.(insts{i}));
    else
        str = sprintf('%s|',serials.(insts{i}){:});
    end
    rx = ['0*(' str(1:end-1) ')'];
    if regexp(serial,rx) == 1;
        match = insts{i};
        sn_str = sprintf(serial, fmt.(insts{i}));
        break
    end
end

status = 0;
switch match
  case 'sbe39'
    sensor_type = 'SBE39';
    funcname = 'parse_sbe39';
    ext = '.asc';
  case 'sbe56'
    sensor_type = 'SBE56';
    funcname = 'parse_sbe56';
    ext = '.cnv';
  case 'rbr_solo'
    sensor_type = 'RBR Solo';
    funcname = 'parse_rbr_solo';
    ext = '.rsk';
  case 'rbr_duet'
    sensor_type = 'RBR Duet';
    funcname = 'parse_rbr_duet';
    ext = '.rsk';
  case 'rbr_concerto'
    sensor_type = 'RBR Concerto';
    funcname = 'parse_rbr_concerto';
    ext = '.rsk';
  case 'gust'
    sensor_type = 'GusT';
    funcname = 'parse_GusT';
    ext = '.mat';
  otherwise
    sensor_type = '';
    funcname = '';
    ext = '';
    status = 1;
    warning('Unknown instrument type for serial %s\n',serial)
end
