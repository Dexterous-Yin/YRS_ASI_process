% first declare the datapath where "YRS\CCD\Raw" folder is located in
asipath_title = 'F:\Graduate Research\data\pric\';
% asipath_title = 'Z:\20_Beiji_Archive\'; % e.g. if you use Z:\ to map \\192.168.43.99\uap
% set the time range you want
pickrange = ['2007-11-01/03:30:00';'2007-11-01/05:00:00'];
tformat = 'yyyy-mm-dd/HH:MM:SS';
% set the waveband 427.8 or 557.7 or 630.0 (nm) and colorbar range
waveband = 557.7;
if waveband==427.8
    waveband_str = 'V';
    height_band = 100;
    caxis_min = 0;
    caxis_max = 250;
elseif waveband==557.7
    waveband_str = 'G';
    height_band = 150;
    caxis_min = 300;
    caxis_max = 2000;
elseif waveband==630.0
    waveband_str = 'R';
    height_band = 250;
    caxis_min = 0;
    caxis_max = 500;
end

% basic settings
RE = 6371; %km
yrs_lat = 78.92;
yrs_lon = 11.93;
angle_mag = 34.0347; % the angle between magnetic meridian and X axis
angle_geo = 67.2342; % the angle between geographic meridian and X axis

year = pickrange(1,1:4);
mm = pickrange(1,6:7);
dd = pickrange(1,9:10);
hh = pickrange(1,12:13);

asipath = [asipath_title,'YRS\CCD\Raw\',num2str(fix(waveband*10)),'\',year,'\',year,mm,'\N',year,mm,dd,waveband_str,'_*'];
asidir = dir([asipath,'\N',year(3:4),mm,dd,waveband_str,'*.img']);
if isempty(asidir)
    if str2double(hh)<12 % when the start time is before noon, try previous data folder
        temptime = datestr(datenum(pickrange(1,:))-1,tformat);
        tempyear = temptime(1:4);
        tempmm = temptime(6:7);
        tempdd = temptime(9:10);
        temphh = temptime(12:13);
        asipath = [asipath_title,'YRS\CCD\Raw\',num2str(fix(waveband*10)),'\',tempyear,'\',tempyear,tempmm,'\N',tempyear,tempmm,tempdd,waveband_str,'_*'];
        asidir = dir([asipath,'\N',tempyear(3:4),tempmm,tempdd,waveband_str,'*.img']);
        [Image,Date,Time,Tag,Exposure]=OpenImg2Ray([asidir(1).folder,'\',asidir(1).name]);
        tstart = [Date,'/',Time];
        [Image,Date,Time,Tag,Exposure]=OpenImg2Ray([asidir(end).folder,'\',asidir(end).name]);
        tend = [Date,'/',Time];
        if datenum(pickrange(2,:),tformat)<datenum(tstart,tformat) || datenum(pickrange(1,:),tformat)>datenum(tend,tformat)
            error('Data Missing');
        end
    else
        error('Data Missing');
    end
else
    [Image,Date,Time,Tag,Exposure]=OpenImg2Ray([asidir(1).folder,'\',asidir(1).name]);
    tstart = [Date,'/',Time];
    [Image,Date,Time,Tag,Exposure]=OpenImg2Ray([asidir(end).folder,'\',asidir(end).name]);
    tend = [Date,'/',Time];
    if datenum(pickrange(2,:),tformat)<datenum(tstart,tformat) || datenum(pickrange(1,:),tformat)>datenum(tend,tformat)
        if str2double(hh)<12
            temptime = datestr(datenum(pickrange(1,:))-1,tformat);
            tempyear = temptime(1:4);
            tempmm = temptime(6:7);
            tempdd = temptime(9:10);
            temphh = temptime(12:13);
            asipath = [asipath_title,'YRS\CCD\Raw\',num2str(fix(waveband*10)),'\',tempyear,'\',tempyear,tempmm,'\N',tempyear,tempmm,tempdd,waveband_str,'_*'];
            asidir = dir([asipath,'\N',tempyear(3:4),tempmm,tempdd,waveband_str,'*.img']);
            [Image,Date,Time,Tag,Exposure]=OpenImg2Ray([asidir(1).folder,'\',asidir(1).name]);
            tstart = [Date,'/',Time];
            [Image,Date,Time,Tag,Exposure]=OpenImg2Ray([asidir(end).folder,'\',asidir(end).name]);
            tend = [Date,'/',Time];
            if datenum(pickrange(2,:),tformat)<datenum(tstart,tformat) || datenum(pickrange(1,:),tformat)>datenum(tend,tformat)
                error('Data Missing');
            end
        else
            error('Data Missing');
        end
    end
end

% initialize the matrices of time, zenith angle, and aurora data
time_spec = zeros(1,length(asidir));
theta_spec = [-90:1:90]; % zenith angle %degrees
radiance_spec = zeros(length(theta_spec),length(asidir));

grid_x = 1:512;
grid_y = 1:512;
[X,Y] = meshgrid(grid_x,grid_y);

for tid=1:length(asidir)
    [Image,Date,Time,Tag,Exposure]=OpenImg2Ray([asidir(tid).folder,'\',asidir(tid).name]);
    time_spec(tid) = datenum([Date,'/',Time],tformat);
    disp(['Read Data ',asidir(tid).name(end-7:end-4),' - ',Date,'/',Time]);
    if datenum([Date,'/',Time],tformat)>=datenum(pickrange(1,:),tformat) && datenum([Date,'/',Time],tformat)<=datenum(pickrange(2,:),tformat) %abs(datenum([Date,'/',Time],tformat)-datenum(maxlat_time{i},tformat))<=10/60/24
        for thetai = 1:length(theta_spec)
            temp_zeith = abs(theta_spec(thetai));
            if theta_spec(thetai)>0
                pixel_r = -8.754*1e-5*temp_zeith^3+4.565*1e-3*temp_zeith^2+3.044*temp_zeith+1.238;
            else
                pixel_r = -(-8.754*1e-5*temp_zeith^3+4.565*1e-3*temp_zeith^2+3.044*temp_zeith+1.238);
            end
            center_x = 258.8622;
            center_y = 256.6155;
            pixel_x = center_x+pixel_r.*cos(-angle_mag/180*pi);
            pixel_y = center_y+pixel_r.*sin(-angle_mag/180*pi);
            tempradiance = interp2(X,Y,Image,pixel_x,pixel_y);
            radiance_spec(thetai,tid) = tempradiance;
        end
    end
    clear Image
    if datenum([Date,'/',Time],tformat)-datenum(pickrange(2,:),tformat)>1/60/24
        break
    end
end
time_spec(tid:end)=[];
radiance_spec(:,tid:end)=[];
% narrow the time range
pickid = find(time_spec>=datenum(pickrange(1,:),tformat)-1/60/24 & time_spec<=datenum(pickrange(2,:),tformat)+1/60/24);
time_spec = time_spec(pickid);
radiance_spec = radiance_spec(:,pickid);
%% plot the keogram
figure('Color',[1 1 1]);
pco = pcolor(time_spec,theta_spec,radiance_spec);
set(pco,'LineStyle','none');
colormap jet
c = colorbar;
c.Label.String = {[num2str(waveband,'%.1f'),'nm'];'Rayleigh'};
caxis([caxis_min,caxis_max]);
ttick = datenum(pickrange(1,:),tformat):10/60/24:datenum(pickrange(2,:),tformat);
set(gca,'XTick',ttick);
set(gca,'XTickLabel',datestr(ttick,'HHMM'));
xlabel(pickrange(1,1:10));
ylabel('Zenith Angle');
xlim([datenum(pickrange(1,:),tformat),datenum(pickrange(2,:),tformat)]);
set(gca,'XMinorTick','on');
set(gca,'Layer','top');
title('Keogram');