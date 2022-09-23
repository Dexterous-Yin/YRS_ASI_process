% This function is to calculate the MLat and MLong of pixels in
% AACGM coordinates.

% set the time of coordinate transformation
% NOTE: the transformation is nearly unchanged during one day.
Date='2007-11-01';
Time='04:00:00';

% basic settings
RE = 6371; %km
yrs_lat = 78.92;
yrs_lon = 11.93;
% get the conjunction time
tformat = 'yyyy-mm-dd/HH:MM:SS';
waveband = 630.0;
if waveband==427.8
    waveband_str = 'V';
    height_band = 100;
elseif waveband==557.7
    waveband_str = 'G';
    height_band = 150;
elseif waveband==630.0
    waveband_str = 'R';
    height_band = 250;
end

center_x = 258.8622;
center_y = 256.6155;
angle_mag = 34.0347;
angle_geo = 67.3915;

% AACGM Mlon and Mlat to
grid_x = 1:512;
grid_y = 1:512;
[X,Y] = meshgrid(grid_x,grid_y);
r_pixel = sqrt((X-center_x).^2+(Y-center_y).^2);
theta_pixel = 2.001*1e-6*r_pixel.^3-4.766*1e-4*r_pixel.^2+0.3581*r_pixel-1.192; % zenith angle
theta_pixel(theta_pixel<0)=0;
theta_pixel(theta_pixel>90)=nan;
% local axis: +Z: earth's core to YRS; +X in the meridian of YRS
local_lat_pixel = 90-(theta_pixel-asin(RE/(RE+height_band).*sin(theta_pixel./180*pi))./pi*180); % latitude of local axis
local_lon_pixel = atan2((Y-center_y),(X-center_x))./pi*180+angle_geo+180; % longitude of local axis
% transfer to geo coordinates
[lat_pixel,lon_pixel] = trans_local2geo(local_lat_pixel,local_lon_pixel,yrs_lat,yrs_lon,height_band);
% transfer geo to AACGM coordinates
[lat_pixel_cgm,lon_pixel_cgm,mlt_pixel_cgm] = geo2mag_aacgm(lat_pixel,lon_pixel,height_band,[Date,'/',Time]);
save(['output_example\pixel_lat_lon_',num2str(height_band),'_',datestr([Date,'/',Time],'yyyyHHMMSS')],...
    'local_lat_pixel','local_lon_pixel','lat_pixel','lon_pixel','lat_pixel_cgm','lon_pixel_cgm');
