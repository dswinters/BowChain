function RBR = RSKtoMATstruct(rskfile,startt,endt)
%
% read in rsk file and output RBR structure similar to what you get
%    when you convert to mat in Ruskin
%
% need to input the rsk database you get from using RSKopen
% and start/end times you can get from RSKplotthumbnail
%
% if no start/end it reads in whole dataset
%
% OUTPUT: RBR structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rsk = RSKopen(rskfile);

%addpath ./RSKtools/
%addpath ./RSKtools/mksqlite-1.12-src/

if nargin < 2
    startt = rsk.thumbnailData.tstamp(1);
    endt   = rsk.thumbnailData.tstamp(end);
    tmp = RSKreaddata(rsk, startt, endt);
else
    tmp = RSKreaddata(rsk, startt, endt);
end

RBR.datasetfilename = tmp.datasets.name;

% make cell array of times
RBR.sampletimes = datestr(tmp.data.tstamp,'dd/mm/yyyy HH:MM:SS.FFF AM');
RBR.sampletimes = cellstr(RBR.sampletimes);

% make data matrix
for i=1:length(tmp.channels)
    RBR.data(:,i) = tmp.data.values(:,i);
    RBR.channelnames(i) = cellstr(tmp.channels(i).longName);
    RBR.channelunits(i) = cellstr(tmp.channels(i).units);
end

fname = RBR.datasetfilename(1:end-4);

% save
savedir = '../../reelCTD/conversion_test/';
save([savedir,fname,'.mat'],'RBR');
