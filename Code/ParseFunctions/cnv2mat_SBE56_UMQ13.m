function [SBE]=cnv2mat_SBE56_UMQ13(cnv_file,cruiseID,mooringID,NOMdepth,TmeDrift);
% function [SBE]=cnv2mat_SBE56_UMQ13(cnv_file,cruiseID,mooringID,NOMdepth,TmeDrift,Lat);
% CNV2MAT Reads the SeaBird 56 ASCII .CNV file format
%  [SBE]=cnv2mat_SBE56_UMQ13('SN1740_MC09.cnv','MC09','LR4',66.5,45,71+);
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

    %-----------------------------------
    %
    %    Read the NMEA latitude string.  This may vary with CTD setup.
    %
    %      if (strncmp(str,'* NMEA Lat',10))
    %         is=findstr(str,'=');
    %         isub=is+1:length(str);
    %         dm=sscanf(str(isub),'%f',2);
    %         if(findstr(str(isub),'N'));
    %            lat=dm(1)+dm(2)/60;
    %         else
    %            lat=-(dm(1)+dm(2)/60);
    %         end
    % %-------------------------------
    % %
    % %    Read the NMEA longitude string.  This may vary with CTD setup.
    % %
    %      elseif (strncmp(str,'* NMEA Lon',10))
    %         is=findstr(str,'=');
    %         isub=is+1:length(str);
    %         dm=sscanf(str(isub),'%f',2);
    %         if(findstr(str(isub),'E'));
    %            lon=dm(1)+dm(2)/60;
    %         else
    %            lon=-(dm(1)+dm(2)/60);
    %         end
    % %------------------------
    %
    %    Read the 'System upload time' to get the date.
    %           This may vary with CTD setup.
    %
    %    I'm reading this in to get the date, since the NMEA time string
    %    does not contain date.  Unfortunately, the system upload time is
    %    in local time (here, EST), so I need to convert to UTC by adding
    %    5 hours (5/24 days).
    %
  
     if (strncmp(str,'# interval',10))
        is=findstr(str,'=');
        interval=str(is+2:is+13);

        %get serial number info, etc.

    elseif (strncmp(str,'# sensor 0',10))
        is=findstr(str,'0560');
        Snum=str(is+4:is+7);
        
        
     elseif (strncmp(str,'# datcnv_date',13))
        is=findstr(str,'=');
        %    pick apart date string and reassemble in DATEFORM type 0 form
%         datstr=[str(is+2:is+21)];
%         yyyy=str(is+9:is+12);
%         mmm=str(is+2:is+4);
%         ddd=str(is+6:is+7);
%         hh=str(is+14:is+15);
%         mm=str(is+17:is+18);
%         ss=str(is+20:is+21);
        
        datstr=[str(is+6:is+7) '-' str(is+2:is+4) '-' str(is+9:is+12)];
        datstr=[datstr ' ' str(is+14:is+21)];
        
    
        download_time=datstr;

%         npp=datenum(datstr);
%         gtime=datevec(npp);
%         dnum=n;

        


%# interval = seconds: 12 

        %----------------------------
        %
        %    Read the NMEA TIME string.  This may vary with CTD setup.
        %
        %      replace the System upload time with the NMEA time
        %      elseif (strncmp(str,'* NMEA UTC',10))
        %         is=findstr(str,':');
        %         isub=is(1)-2:length(str);
        %         gtime([4:6])=sscanf(str(isub),'%2d:%2d:%2d');
        %------------------------------
        %
        %    Read the variable names & units into a cell array
        %
    elseif (strncmp(str,'# name',6))
        varr=sscanf(str(7:10),'%d',1);
        varr=varr+1;  % .CNV file counts from 0, Matlab counts from 1
        %      stuff variable names into cell array
        names{varr}=str;
        %------------------------------

        %# start_time = Dec 23 2007 08:00:01 get start time..
    elseif (strncmp(str,'# start_time',12))
        is=findstr(str,'=');
        %    pick apart date string and reassemble in DATEFORM type 0 form
        datstr=[str(is+6:is+7) '-' str(is+2:is+4) '-' str(is+8:is+12)];
        datstr=[datstr ' ' str(is+14:is+21)];
        start_time=datstr;
        
        n=datenum(datstr);
        gtime=datevec(n);
        start_year=str2num(str(is+8:is+12));

       




        %    Read the sensor names into a cell array
        %
    elseif (strncmp(str,'# sensor',8))
        sens=sscanf(str(10:11),'%d',1);
        sens=sens+1;  % .CNV file counts from 0, Matlab counts from 1
        %      stuff sensor names into cell array
        sensors{sens}=str;
        %
        %  pick up bad flag value
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

SBE.serial_no=['SBE56 ' Snum];
% SBE.start_time=datstr;
% SBE.start_dnum=n;
SBE.info.download_time=download_time;
SBE.start_year=start_year;
SBE.interval=interval;
SBE.start_time=start_time;
SBE.NOMdepth=NOMdepth;

SBE.temp=data(:,2);


SBE.yday=(data(:,1))-1;%subtracting 1 for convention that Jan 1 is yday 0;
SBE.flag=data(:,3);


xDdd=diff(SBE.yday);


[Iso]=find(xDdd<-360);  %finding where difference jumps a year

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

%applying time offset to yday
TmeDriftVec=linspace(0,TmeDrift,length(SBE.dtnum));


SBE.dtnum=SBE.dtnum-TmeDriftVec'./86400;
[year,~,~]=datevec(SBE.dtnum);
SBE.yday=SBE.dtnum-datenum(year,1,1);

SBE.info.processing=['time-drift of ' num2str(TmeDrift) ' seconds applied linearly (positive is drift ahead of GMT)'];


SBE.info.cal='temperature, ITS-90 [deg C]';

%cruiseID is a string identifying the cruise or deployment 'MC09' for
    %example.
%cnv_file is the name of the file (string)
%mooringID is the ID of the mooring
%NOMdepth is the nominal depth of the instrument (vector if this changed
    %during the course of the deployment (LR4 in MC09 for example)




%converting Julian date to Datenum and yday

%getting rid of bad data at end

% SBE.temp(119930:end)=[];
% SBE.dtnum(119930:end)=[];
% SBE.pr(119930:end)=[];
% SBE.flag(119930:end)=[];
% SBE.yday(119930:end)=[];


return
