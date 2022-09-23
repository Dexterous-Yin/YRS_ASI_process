% first declare the datapath where "YRS\CCD\Raw" folder is located in
asipath_title = 'F:\Graduate Research\data\pric\';
% asipath_title = 'Z:\20_Beiji_Archive\'; % e.g. if you use Z:\ to map \\192.168.43.99\uap
% set the time range you want
pickrange = ['2007-01-03/04:00:00';'2007-01-03/10:00:00']; % trajectory time range
tformat = 'yyyy-mm-dd/HH:MM:SS';
year = pickrange(1,1:4);
mm = pickrange(1,6:7);
dd = pickrange(1,9:10);
hh = pickrange(1,12:13);
% set the string for each waveband 427.8 or 557.7 or 630.0 (nm)
if waveband==427.8
    waveband_str = 'V';
elseif waveband==557.7
    waveband_str = 'G';
elseif waveband==630.0
    waveband_str = 'R';
end

% basic settings
center_x = 258.8622; %260;
center_y = 256.6155; %256;
angle_mag = 34.0347;
angle_geo = 67.2342; %67.3915;
RE = 6371; %km
yrs_lat = 78.92;
yrs_lon = 11.93;

% initialize cells for three wavebands
time_spec = cell(3,1);
radiance_spec = cell(3,1);
waveband_set = [427.8;557.7;630.0];
% initialize the zenith angle
theta_spec = [-90:1:90]; % degrees

for bandi = 1:length(waveband_set)
    
    waveband = waveband_set(bandi);
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
            if isempty(asidir)
                time_spec{bandi} = datenum(pickrange,tformat)';
                radiance_spec{bandi} = zeros(length(theta_spec),length(time_spec{bandi}))+nan;
                continue
            end
            [~,Date,Time,Tag,Exposure]=OpenImg2Ray([asidir(1).folder,'\',asidir(1).name]);
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
    
    % initialize the matrices of time and aurora data
    time_spec{bandi} = zeros(1,length(asidir))+nan;
    radiance_spec{bandi} = zeros(length(theta_spec),length(asidir))+nan;
    
    grid_x = 1:512;
    grid_y = 1:512;
    [X,Y] = meshgrid(grid_x,grid_y);
    
    for tid=1:length(asidir)
        [Image,Date,Time,Tag,Exposure]=OpenImg2Ray([asidir(tid).folder,'\',asidir(tid).name]);
        time_spec{bandi}(tid) = datenum([Date,'/',Time],tformat);
        if datenum([Date,'/',Time],tformat)>=datenum(pickrange(1,:),tformat) && datenum([Date,'/',Time],tformat)<=datenum(pickrange(2,:),tformat)
            for thetai = 1:length(theta_spec)
                temp_zeith = abs(theta_spec(thetai));
                if theta_spec(thetai)>0
                    pixel_r = -8.754*1e-5*temp_zeith^3+4.565*1e-3*temp_zeith^2+3.044*temp_zeith+1.238;
                else
                    pixel_r = -(-8.754*1e-5*temp_zeith^3+4.565*1e-3*temp_zeith^2+3.044*temp_zeith+1.238);
                end
                pixel_x = center_x+pixel_r.*cos(-angle_mag/180*pi);
                pixel_y = center_y+pixel_r.*sin(-angle_mag/180*pi);
                tempradiance = interp2(X,Y,Image,pixel_x,pixel_y);
                radiance_spec{bandi}(thetai,tid) = tempradiance;
            end
        end
        clear Image
        disp([num2str(bandi),':',Date,'/',Time]);
    end
    % narrow the time range
    pickid = find(time_spec{bandi}>=datenum(pickrange(1,:),tformat)-1/60/24 & time_spec{bandi}<=datenum(pickrange(2,:),tformat)+1/60/24);
    time_spec{bandi} = time_spec{bandi}(pickid);
    radiance_spec{bandi} = radiance_spec{bandi}(:,pickid);
end

%% plot the keogram
% set the colorbar range and reference height for 427.8 or 557.7 or 630.0 (nm)
caxis_min = [100,100,100];
caxis_max = [1000,2000,2000];
height_band = [100,150,250];
figure('Color',[1 1 1]);
for bandi= 1:length(waveband_set)
    lat_spec = yrs_lat_mag+theta_spec-asin(RE/(RE+height_band(bandi))*sin(theta_spec./180*pi))./pi*180;
    subplot(3,1,bandi);
    pco = pcolor(time_spec{bandi},theta_spec,radiance_spec{bandi});
    set(pco,'LineStyle','none');
    colormap jet
    c = colorbar;
    c.Label.String = {'Rayleigh'};
    caxis([caxis_min(bandi) caxis_max(bandi)]);
    ttick = datenum(pickrange(1,:),tformat)-1/24:30/60/24:datenum(pickrange(2,:),tformat)+1/24;
    set(gca,'XTick',ttick);
    set(gca,'XTickLabel',datestr(ttick,'HHMM'));
    xlabel(pickrange(1,1:10));
    ylabel({[num2str(waveband_set(bandi),'%.1f'),'nm'];'Zenith Angle'});
    xlim([datenum(pickrange(1,:),tformat),datenum(pickrange(2,:),tformat)]);
    set(gca,'XMinorTick','on');
    set(gca,'YMinorTick','on');
    set(gca,'Layer','top');
    ylim([-90,90]);
    if bandi==1
        title('Keogram');
    end
end

