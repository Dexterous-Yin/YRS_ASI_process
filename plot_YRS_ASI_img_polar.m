% first declare the datapath where "YRS\CCD\Raw" folder is located in
asipath_title = 'F:\Graduate Research\data\pric\';
% asipath_title = 'Z:\20_Beiji_Archive\'; % e.g. if you use Z:\ to map \\192.168.43.99\
% set the time range you want
pickrange = ['2007-11-01/04:21:30';'2007-11-01/04:21:30'];
tformat = 'yyyy-mm-dd/HH:MM:SS';
% set if you want to output the figures as png file
output=0;
output_path = 'output_example';
% set the waveband 427.8 or 557.7 or 630.0 (nm) and colorbar range
waveband = 630.0;
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
    caxis_min = 100;
    caxis_max = 500;
end

% load AACGM latitude and longitude
grid_x = 1:512;
grid_y = 1:512;
[X,Y] = meshgrid(grid_x,grid_y);
load(['output_example\pixel_lat_lon_',num2str(height_band),'_2007040000.mat']);
% NOTE: the magnetic field line trace could lead to some error, so sometimes it is necessary to delete the bad data.


% load noon maglon
load(['output_example\noon_maglon.mat']);

% load ASI data
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

% circles
cphi = 0:pi/100:2*pi;
cx = [10;25;40].*cos(cphi);
cy = [10;25;40].*sin(cphi);

% MLT lines
MLT_x = 40*cos([-pi:pi/6:5/6*pi]);
MLT_y = 40*sin([-pi:pi/6:5/6*pi]);


j=1;
while j<=length(asidir)
    [Image,Date,Time,Tag,Exposure]=OpenImg2Ray([asidir(j).folder,'\',asidir(j).name]);
    disp(['Read Data ',asidir(j).name(end-7:end-4),' - ',Date,'/',Time]);
    if datenum([Date,'/',Time],tformat)>=datenum(pickrange(1,:),tformat) && datenum([Date,'/',Time],tformat)<=datenum(pickrange(2,:),tformat)
        
        del_lat_id = find(isnan(lat_pixel_cgm));
        Image(del_lat_id) = nan;
        del_lon_id = find(isnan(lon_pixel_cgm));
        Image(del_lon_id) = nan;
        del_locallat_id = find(local_lat_pixel<80);
        Image(del_locallat_id) = nan;
        
        now_time = datenum([Date,'/',Time]);
        now_noon_maglon = interp1(noon_time,noon_maglon,now_time);
        asi_mlt = (lon_pixel_cgm-now_noon_maglon)./180*12+12;
        asi_lon_plot = (asi_mlt-12)./12*pi;
        asi_lat_plot = lat_pixel_cgm;
        
        figure('Color',[1 1 1]);
        asi_x_plot = abs(90-asi_lat_plot).*cos(asi_lon_plot);
        asi_y_plot = abs(90-asi_lat_plot).*sin(asi_lon_plot);
        asi_pco = pcolor(asi_y_plot,asi_x_plot,Image);
        set(asi_pco,'LineStyle','none');
        colormap jet
        axis equal
        asi_cbar = colorbar;
        asi_cbar.Label.String = [num2str(waveband,'%.1f'),' nm (Rayleigh)'] ;
        caxis([caxis_min,caxis_max])
        hold on;
        plot(cx',cy','k--','LineWidth',1); hold on;
        xlim([-40,40]);
        ylim([-40,40]);
        set(gca,'XDir','reverse');
        set(gca,'XTick',[-40,-25,-10,10,25,40]);
        set(gca,'XTickLabel',num2str([50;65;80;80;65;50]));
        set(gca,'YTick',[-40,-25,-10,10,25,40]);
        set(gca,'YTickLabel',[]);
        text(0,40-2,'Noon','HorizontalAlignment','left');
        text(-40,0+2,'Dawn','HorizontalAlignment','right');
        title(['YRS ',num2str(waveband,'%.1f'),'nm ',Date,'/',Time]);
        % MLT lines
        for MLT_id = 1:length(MLT_x)
            hold on; plot([0,MLT_y(MLT_id)],[0,MLT_x(MLT_id)],'--','Color','#808080');
        end
        % if want to output png file, try like print(outpath,'-dpng','-r1000') 
        if output==1
            if exist(output_path,'dir')==0
                status = mkdir(output_path);
            end
            temptime = datenum([Date,'/',Time],tformat);
            print([output_path,'\',num2str(fix(waveband*10)),'_',datestr(temptime,'yyyymmdd_HHMMSS_polar')],'-dpng','-r1000');
            close;
        end
        disp(['----------------------------- DONE ',Date,'/',Time,'-----------------------------']);
    end
    if datenum([Date,'/',Time],tformat)-datenum(pickrange(1,:),tformat)<-5/60/24
        j=j+30;
    else
        j=j+1;
    end
    if datenum([Date,'/',Time],tformat)-datenum(pickrange(2,:),tformat)>1/60/24
        break
    end
end

