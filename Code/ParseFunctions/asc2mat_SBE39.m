function [SBE]=asc2mat_SBE39(asc_file,deployID,mooringID,NOMdepth,TmeDrift);
% function [SBE]=asc2mat_SBE39(asc_file,deployID,mooringID,NOMdepth,PRsens,TmeDrift,Lat);
% ASC2MAT Reads the SeaBird 39 ASCII .CNV file format
%  
%[SBE]=asc2mat_SBE39(asc_file,deployID,mooringID,NOMdepth,PRsens,TmeDrift,Lat);
%[SBE39]=asc2mat_SBE39('SN1740_MC09.asc','MC09','LR4',66.5,'Y',15,36.6);
%Inputs
%deployID is a string identifying the cruise or deployment 'NEMO12' for example.
%cnv_file is the name of the file (string)
%mooring is the ID of the mooring
%NOMdepth is the nominal depth of the instrument...vector if this changed during the course of the deployment (LR4 in MC09 for example)
%PRsens is 'Y' or 'N', indicating if the SBE39 is equipped with one or not.
%TmeDrift=time drift in seconds, with positive values ahead of UTC,
%negative values behind. Correction is LINEAR over the deployment
%duration.
%Lat is degrees and decimal degrees.
%want to input directory, mooring, plannned depth, deployment.


%Output: Structure with lots of goodies
%
%
%  3/13 J. Mickett modified from Rich Signell code (rsignell@usgs.gov)
%     incorporates ideas from code by Derek Fong & Peter Brickley
%



% Open the .cnv file as read-only text
%
fid=fopen(asc_file,'rt');
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
    if (strncmp(str,'* System UpLoad',15))
        is=findstr(str,'=');
        %    pick apart date string and reassemble in DATEFORM type 0 form
        datstr=[str(is+6:is+7) '-' str(is+2:is+4) '-' str(is+8:is+12)];
        datstr=[datstr ' ' str(is+14:is+21)];
        SBE.info.download_time=datstr;
        
        n=datenum(datstr);
        gtime=datevec(n);
        dnum=n;
        
        
        %get serial number info, etc.
        
    elseif (strncmp(str,'* SBE 39',8)) & ~isempty(findstr(str,'NO.'));
        is=findstr(str,'NO.');
        Snum=str(is+4:is+7);
        iss=findstr(str,' V ');
        Fvers=str(iss+3:iss+6);
        SBE.info.firmware=Fvers;
        
    elseif (strncmp(str,'* sample interval',17));
        is=findstr(str,' = ');
        Sint=str(is+3:is+6);
        SBE.info.sampleInterval=Sint;
        
    elseif (strncmp(str,'* SBE 39 configuration',22));
        is=findstr(str,'temperature');
        ist=findstr(str,'pressure');
        
        if ~isempty(is);
            varS(1)={'temperature'};
            units(1)={'deg. C, ITS-90'};
        end
        
        if ~isempty(ist);
            varS(2)={'pressure'};
            units(2)={'decibars'};
            
        end
        
        SBE.info.varS=varS;
        SBE.info.units=units;
        
    elseif (strncmp(str,'* temperature:',14));
        is=findstr(str,'e:');
        TCalDate=str(is+3:is+12);
        
        
        SBE.info.TCalDate=TCalDate;
        
        
        
    elseif (strncmp(str,'* pressure',10));
        is=findstr(str,'psia:');
        PCalDate=str(is+6:is+14);
        
        SBE.info.PCalDate=PCalDate;
        
        
        
        
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
        %     elseif (strncmp(str,'* name',6))
        %         varr=sscanf(str(7:10),'%d',1);
        %         varr=varr+1;  % .CNV file counts from 0, Matlab counts from 1
        %         %      stuff variable names into cell array
        %         names{varr}=str;
        %------------------------------
        
        %# start_time = Dec 23 2007 08:00:01 get start time..
        
        %     elseif (strncmp(str,'# start_time',12))
        %         is=findstr(str,'=');
        %         %    pick apart date string and reassemble in DATEFORM type 0 form
        %         datstr=[str(is+6:is+7) '-' str(is+2:is+4) '-' str(is+8:is+12)];
        %         datstr=[datstr ' ' str(is+14:is+21)];
        %         n=datenum(datstr);
        %         gtime=datevec(n);
        %         start_year=str2num(str(is+8:is+12));
        
        
        
        
        
        
        %    Read the sensor names into a cell array
        %         %
        %     elseif (strncmp(str,'# sensor',8))
        %         sens=sscanf(str(10:11),'%d',1);
        %         sens=sens+1;  % .CNV file counts from 0, Matlab counts from 1
        %         %      stuff sensor names into cell array
        %         sensors{sens}=str;
        %         %
        %         %  pick up bad flag value
        %     elseif (strncmp(str,'# bad_flag',10))
        %         isub=13:length(str);
        %         bad_flag=sscanf(str(isub),'%g',1);
    end
end

% Get through the last three lines in the header
fgetl(fid);
fgetl(fid);
fgetl(fid);

SBE.info.deployID=deployID;
SBE.info.serial_no=['SBE39 ' Snum];
SBE.info.mooringID=mooringID;
SBE.NOMdepth=NOMdepth;
%==============================================
%
%  Done reading header.  Now read the data!
%
nvars=length(varS)+2;  %number of variables + time


% Read the data into one big matrix
%
if nvars<4
data=textscan(fid,'%7n%11c%8c','delimiter',',');
%data=fscanf(fid,'%c',[34 inf]);

SBE.dtnum=datenum([data{2} data{3}],'dd mmm yyyyHH:MM:SS');


else
data=textscan(fid,'%7n%7n%11c%8c','delimiter',',');
SBE.dtnum=datenum([data{3} data{4}],'dd mmm yyyyHH:MM:SS');
SBE.pr=data{2};
end


fclose(fid);

SBE.temp=data{1};

%
% Flag bad values with nan
%
% ind=find(data==bad_flag);
% data(ind)=data(ind)*nan;

%
% Flip data around so that each variable is a column
%data=data.';

% Convert cell arrays of names to character matrices
%names=char(names);
%sensors=char(sensors);
% names =
% # name 0 = t090: temperature, ITS-90 [deg C]
% # name 1 = c0S/m: conductivity [S/m]
% # name 2 = pr: pressure [db]
% # name 3 = sal00: salinity, PSS-78 [PSU]
% # name 4 = timeJ: datenum
% # name 5 = flag:  0.000e+00

%getting rid of bad times

Iobad=find(SBE.dtnum>nanmean(SBE.dtnum(1:100))+730); %can't have longer than 2-yr deploy

SBE.temp(Iobad)=[];
SBE.dtnum(Iobad)=[];
if isfield(SBE,'pr');
    SBE.pr(Iobad)=[];
end


%ORDERING info fields
% SBE.info
% ans = 
%      download_time: '19-Jan- 2013 00:00:48'
%           firmware: '1.1a'
%     sampleInterval: '60 s'
%                varS: {'temperature'}
%              units: {'deg. C, ITS-90'}
%           TCalDate: ' 01-feb-12'
%           cruiseID: 'NEMO12'
%          serial_no: 'SBE39 4966'
%          mooringID: 'ChaBa'
%         start_time: '25-May-2012 03:20:21'


SBE.info.start_time=datestr(SBE.dtnum(1));
SBE.info.processing=['time-drift of ' num2str(TmeDrift) ' seconds applied linearly (positive is drift ahead of GMT)'];



if ~isfield(SBE,'pr');
SBE.info = orderfields(SBE.info,[7 9 8 10 3 4 5 1 2 6 11]);
else  %we have a pressure calibration field
SBE.info = orderfields(SBE.info,[8 10 9 11 3 4 5 1 2 6 7 12]);
end



% 
% xDdd=diff(SBE.yday);
% 
% 
% [Iso]=find(xDdd<-360);  %finding where difference jumps a year
% 
% if ~isempty(Iso)
%     Xddf=xDdd(Iso); %how long is this year...accounts for leap years?
%     xDdd(Iso)=xDdd(Iso)+ceil(abs(Xddf)); %making this jump by just a standard interval instead,
%     OPAA=cumsum(xDdd);
%     OPAA(1)=xDdd(1);
%     yday=SBE.yday(1)+[0;OPAA];
%     SBE.yday=yday;
% end


%applying time offset to yday
TmeDriftVec=linspace(0,TmeDrift,length(SBE.dtnum));


SBE.dtnum=SBE.dtnum-TmeDriftVec'./86400;
% [yday,year]=datenum2yday(SBE.dtnum);
% SBE.yday=yday; 
[year,~,~]=datevec(SBE.dtnum);
SBE.yday=SBE.dtnum-datenum(year,1,1);

%SBE.start_year=start_year;



%SBE.info='temperature, ITS-90 [deg C] and pressure (if available) [db]';

%cruiseID is a string identifying the cruise or deployment 'MC09' for
%example.
%cnv_file is the name of the file (string)
%mooringID is the ID of the mooring
%NOMdepth is the nominal depth of the instrument (vector if this changed
%during the course of the deployment (LR4 in MC09 for example)

%converting Julian date to Datenum and yday

%getting rid of bad data at end and beginning

% bdvale=133513-bdvals;
%
%  SBE.temp(bdvale:end)=[];
%  SBE.dtnum(bdvale:end)=[];
%  if isfield(SBE,'pr');
%  SBE.pr(bdvale:end)=[];
%  end
%
%  SBE.flag(bdvale:end)=[];
%  SBE.yday(bdvale:end)=[];


%
%
%
% bdvals=156;
% %
%  SBE.temp(1:bdvals)=[];
%  SBE.dtnum(1:bdvals)=[];
%  if isfield(SBE,'pr');
%  SBE.pr(1:bdvals)=[];
%  end
%
%  SBE.flag(1:bdvals)=[];
%  SBE.yday(1:bdvals)=[];
% % %
% % % %
%return
pp=1;

if pp==1;
    
    for ii=1:2;
        
        Xstd=nanstd(SBE.temp);
        
        FGG=4.*Xstd+1;  %outside 4 standard deviations with 1 for good measure
        
        Ibadda=find(SBE.temp<-3 | SBE.temp>35);
        
        
        Ibaddb=find(SBE.temp<(nanmedian(SBE.temp)-FGG) | SBE.temp>(nanmedian(SBE.temp)+FGG));
        
        
        
        Ibadd=union(Ibadda,Ibaddb);
        
        
        SBE.temp(Ibadd)=[];
        if isfield(SBE,'pr');
            SBE.pr(Ibadd)=[];
        end
        
        SBE.yday(Ibadd)=[];
        SBE.dtnum(Ibadd)=[];
       
        %and one more sample before this because last sample may be bad if it
        %happened on the way up.
        
        clear Ibadd
    end
    
end
% 
% SBE.temp(end)=[];
% if isfield(SBE,'pr');
%     SBE.pr(end)=[];
% end
% 
% SBE.yday(end)=[];
% SBE.dtnum(end)=[];
% %SBE.flag(end)=[];



