% first declare the datapath where "YRS\CCD\Raw" folder is located in
asipath_title = 'F:\Graduate Research\data\pric\';
% asipath_title = 'Z:\20_Beiji_Archive\'; % e.g. if you use Z:\ to map \\192.168.43.99\uap
% set the time range you want
pickrange = ['2007-11-01/04:21:00';'2007-11-01/04:21:00'];
tformat = 'yyyy-mm-dd/HH:MM:SS';
% set if you want to output the figures as png file
output=1;
output_path = 'output_example';
% set the waveband 427.8 or 5577 or 630.0 (nm) and colorbar range
waveband = 630.0;
if waveband==427.8
    waveband_str = 'V';
    height_band = 100;
    caxis_min = 0;
    caxis_max = 250;
elseif waveband==557.7
    waveband_str = 'G';
    height_band = 150;
    caxis_min = 0;
    caxis_max = 2000;
elseif waveband==630.0
    waveband_str = 'R';
    height_band = 250;
    caxis_min = 100;
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

j=1;
while j<=length(asidir)
    [Image,Date,Time,Tag,Exposure]=OpenImg2Ray([asidir(j).folder,'\',asidir(j).name]);
    disp(['Read Data ',asidir(j).name(end-7:end-4),' - ',Date,'/',Time]);
    if datenum([Date,'/',Time],tformat)>=datenum(pickrange(1,:),tformat) && datenum([Date,'/',Time],tformat)<=datenum(pickrange(2,:),tformat)
        
        figure('Color',[1 1 1]);
        imagesc(Image);
        colormap('gray');
        asibar = colorbar;
        asibar.Label.String = 'Rayleigh';
        axis equal;
        caxis([caxis_min,caxis_max]);
        % directions
        center_x = 258.8622;
        center_y = 256.6155;
        mag_lon_x = center_x+[-256,256]*cos(angle_mag/180*pi);
        mag_lon_y = center_y-[-256,256]*sin(angle_mag/180*pi);
        hold on; plot(mag_lon_x,mag_lon_y,'w--','LineWidth',1);
        text(mag_lon_x(1),mag_lon_y(1)-8,'MS','Color','w');
        text(mag_lon_x(end),mag_lon_y(end)-8,'MN','Color','w');
        mag_lat_x = center_x+[-256,256]*sin(angle_mag/180*pi);
        mag_lat_y = center_y+[-256,256]*cos(angle_mag/180*pi);
        hold on; plot(mag_lat_x,mag_lat_y,'w--','LineWidth',1);
        text(mag_lat_x(1),mag_lat_y(1)-8,'ME','Color','w');
        text(mag_lat_x(end),mag_lat_y(end)-8,'MW','Color','w');
        % figure settings
        xlim([0,512]);
        ylim([0,512]);
        set(gca,'XTickLabel',[]);
        set(gca,'YTickLabel',[]);
        title(['YRS ',num2str(waveband,'%.1f'),'nm ',Date,'/',Time]);
        % if want to output png file, try like print(outpath,'-dpng','-r1000') 
        if output==1
            if exist(output_path,'dir')==0
                status = mkdir(output_path);
            end
            temptime = datenum([Date,'/',Time],tformat);
            print([output_path,'\',num2str(fix(waveband*10)),'_',datestr(temptime,'yyyymmdd_HHMMSS')],'-dpng','-r1000');
            close;
        end
    end
    clear Image
    if datenum([Date,'/',Time],tformat)-datenum(pickrange(1,:),tformat)<-5/60/24
        j=j+30;
    else
        j=j+1;
    end
    if datenum([Date,'/',Time],tformat)-datenum(pickrange(2,:),tformat)>1/60/24
        break
    end
end