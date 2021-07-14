function [SBE]=asc2mat_SBE37(asc_file,cruiseID,mooringID,NOMdepth,TmeDrift)
% function [SBE]=asc2mat_SBE37(asc_file,cruiseID,mooringID,NOMdepth,TmeDrift,Lat);
% ASC2MAT Reads the SeaBird 37 ASCII .ASC file format
%  [SBE]=asc2mat_SBE37('SN1740_MC09.asc','MC09','LR4',66.5,45,71+);
%Inputs
%asc_file is the name of the file (string)
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
%  9/23/15 M. Alberty modified from script that reads SBE 37 .cnv files to
%  one that reads SBE 37 .asc files for the Arctic Mix bowchain
%

cruise_name = cruiseID;% input('Please enter the cruise ID/name: ','s')

% Open the .cnv file as read-only text
%
fid=fopen(asc_file,'rt');
%
% Read the header.
% Start reading header lines of .ASC file,
% Stop at line that starts with '*END*'
%
% Pull out NMEA lat & lon along the way and look
% at the '# name' fields to see how many variables we have.
%

str='*START*';
while (~strncmp(str,'*END*',5));
  str=fgetl(fid);
  
  % Get sample interval
  if (strncmp(str,'* sample interval',17))
    is=findstr(str,'=');
    interval=str(is+2);
    
    % Get serial number
  elseif (strncmp(str,'* Temperature SN',16))
    is=findstr(str,'=');
    Snum=str(is+2:is+6);
    
    % Get download time
  elseif (strncmp(str,'* System UpLoad Time',20))
    is=findstr(str,'=');
    download_time=str(is+2:is+21);
    
%     % Get Variables
%   elseif (strncmp(str,'# name',6))
%     varr=sscanf(str(7:10),'%d',1);
%     varr=varr+1;  % .CNV file counts from 0, Matlab counts from 1
%     %      stuff variable names into cell array
%     names{varr}=str;

%     %  Get bad flag value
%   elseif (strncmp(str,'# bad_flag',10))
%     isub=13:length(str);
%     bad_flag=sscanf(str(isub),'%g',1);
  end
end
str=fgetl(fid);
% Get start time
is=findstr(str,'=');
start_time=str(is+2:is+21);
[start_year,~,~,~,~,~]=datevec(start_time,'dd mmm yyyy HH:MM:SS');

% Read last line
fgetl(fid);
%==============================================
%
%  Done reading header.  Now read the data!
%

% nvars=varr;  %number of variables
nvars=5;  %number of variables

% Read the data into one big matrix
%
data=textscan(fid,'%f, %f, %f, %d %s %d, %d:%d:%d');
fclose(fid);

SBE.projectID=cruiseID;
SBE.mooringID=mooringID;
SBE.serial_no=['SBE37 ' Snum];
SBE.info.download_time=download_time;
SBE.start_year=start_year;
SBE.interval=interval;
SBE.start_time=start_time;
SBE.NOMdepth=NOMdepth;

SBE.temp=data{1,1};
SBE.pr=data{1,3};
SBE.cond=data{1,2};

% Make yday
dd=num2str(data{1,4},'%02d');
mmm=char(data{1,5});
yyyy=num2str(data{1,6},'%04d');
HH=num2str(data{1,7},'%02d');
MM=num2str(data{1,8},'%02d');
SS=num2str(data{1,9},'%02d');
SBE.yday=datenum([dd mmm yyyy HH MM SS],'ddmmmyyyyHHMMSS')-...
  datenum(start_year,1,1);

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
  'pressure, [dbar]'};
return