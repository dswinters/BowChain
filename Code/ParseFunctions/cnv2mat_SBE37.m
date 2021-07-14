function [SBE]=cnv2mat_SBE37(cnv_file,cruiseID,mooringID,NOMdepth,TmeDrift)
% function [SBE]=cnv2mat_SBE37(cnv_file,cruiseID,mooringID,NOMdepth,TmeDrift,Lat);
% CNV2MAT Reads the SeaBird 37 ASCII .CNV file format
%  [SBE]=cnv2mat_SBE37('SN1740_MC09.cnv','MC09','LR4',66.5,45,71+);
%Inputs
%cnv_file is the name of the file (string)
%deployID is a string identifying the cruise or deployment 'NEMO12' for example.
%mooring is the ID of the mooring
%NOMdepth is the nominal depth of the instrument...vector if this changed during the course of the deployment (LR4 in MC09 for example)
%TmeDrift=time drift in seconds, with positive values instrument ahead of UTC,
%negative values behind. Correction is LINEAR over the deployment
%duration.
%Lat is degrees and decimal degrees.


%Output: Structure with lots of goodies
%
%
%  8/1/14 J. Mickett modified from Rich Signell code (rsignell@usgs.gov)
%     incorporates ideas from code by Derek Fong & Peter Brickley
%  9/18/15 M. Alberty modified from file that read SBE 56 .cnv files to one
%  that read SBE 37 .cnv files for the Arctic Mix bow chain
%

cruise_name = cruiseID;% input('Please enter the cruise ID/name: ','s')

% Open the .cnv file as read-only text
%
fid=fopen(cnv_file,'rt');
%
% Read the header.
% Start reading header lines of .CNV file,
% Stop at line that starts with '*END*'
%
% Pull out NMEA lat & lon along the way and look
% at the '# name' fields to see how many variables we have.
%

str='*START*';
while (~strncmp(str,'*END*',5));
  str=fgetl(fid);
  % Get sample interval
  if (strncmp(str,'# interval',10))
    is=findstr(str,'=');
    interval=str(is+2:is+11);
    
    % Get serial number
  elseif (strncmp(str,'* Temperature SN',16))
    is=findstr(str,'=');
    Snum=str(is+2:end);
    
    % Get download time
  elseif (strncmp(str,'# datcnv_date',13))
    is=findstr(str,'=');
    download_time=str(is+2:is+21);
    
    % Get Variables
  elseif (strncmp(str,'# name',6))
    varr=sscanf(str(7:10),'%d',1);
    varr=varr+1;  % .CNV file counts from 0, Matlab counts from 1
    %      stuff variable names into cell array
    names{varr}=str;
    
    % Get start time
  elseif (strncmp(str,'# start_time',12))
    is=findstr(str,'=');
    start_time=str(is+2:is+21);
    [start_year,~,~,~,~,~]=datevec(start_time,'mmm dd yyyy HH:MM:SS');
    
    %  Get bad flag value
  elseif (strncmp(str,'# bad_flag',10))
    isub=13:length(str);
    bad_flag=sscanf(str(isub),'%g',1);
  end
end
%==============================================
%
%  Done reading header.  Now read the data!
%
nvars=varr;  %number of variables

% Read the data into one big matrix
%
data=fscanf(fid,'%f',[nvars inf]);

fclose(fid);

%
% Flag bad values with nan
%
ind=find(data==bad_flag);
data(ind)=data(ind)*nan;

%
% Flip data around so that each variable is a column
data=data.';

% Convert cell arrays of names to character matrices
names=char(names);
%sensors=char(sensors);
% names =
% # name 0 = t090: temperature, ITS-90 [deg C]
% # name 1 = timeJ: datenum
% # name 2 = flag:  0.000e+00

SBE.projectID=cruiseID;
SBE.mooringID=mooringID;
SBE.serial_no=['SBE37 ' Snum];
SBE.info.download_time=download_time;
SBE.start_year=start_year;
SBE.interval=interval;
SBE.start_time=start_time;
SBE.NOMdepth=NOMdepth;

SBE.temp=data(:,3);
SBE.pr=data(:,5);
SBE.cond=data(:,4);
SBE.psal=data(:,7);
SBE.yday=(data(:,2))-1;%subtracting 1 for convention that Jan 1 is yday 0;
SBE.flag=data(:,8);

% Finding where difference jumps a year
xDdd=diff(SBE.yday);
[Iso]=find(xDdd<-360);
if ~isempty(Iso)
  Xddf=xDdd(Iso); %how long is this year...accounts for leap years?
  xDdd(Iso)=xDdd(Iso)+ceil(abs(Xddf)); %making this jump by just a standard interval instead,
  OPAA=cumsum(xDdd);
  OPAA(1)=xDdd(1);
  yday=SBE.yday(1)+[0;OPAA];
  SBE.yday=yday;
end

%SBE.yday=yday;
SBE.dtnum=SBE.yday+datenum(start_year,1,1);

% Applying time offset to yday
TmeDriftVec=linspace(0,TmeDrift,length(SBE.dtnum));
SBE.dtnum=SBE.dtnum-TmeDriftVec'./86400;
[year,~,~]=datevec(SBE.dtnum);
SBE.yday=SBE.dtnum-datenum(year,1,1);
SBE.info.processing=['time-drift of ' num2str(TmeDrift) ' seconds applied linearly (positive is drift ahead of GMT)'];

% Add unit info
SBE.info.cal={'temperature, ITS-90 [deg C]';'conductivity, [mS/cm]';...
  'salinity, [PSU]'; 'pressure, [dbar]'};
return
