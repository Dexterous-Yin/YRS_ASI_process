function [mag_lat,mag_lon,mag_mlt] = geo2mag_aacgm(geo_lat,geo_lon,geo_height,geo_time)
% inputs: the latitude(degree), longitude(degree) and height(km) at GEO
% coordinates. geo_time at MATLAB format.
% outputs: latitude(degree) and longitude (degree) at AACGM
RE = 6371.2; % km
kext = 0;
options = [0,1,0,0,0];
sysaxes = 1; % GEO coordinates
if ischar(geo_time)
    matlabd = datenum(geo_time);
else
    matlabd = geo_time;
end
x1 = (RE+geo_height)./RE.*cos(geo_lat./180*pi).*cos(geo_lon./180*pi);
x2 = (RE+geo_height)./RE.*cos(geo_lat./180*pi).*sin(geo_lon./180*pi);
x3 = (RE+geo_height)./RE.*sin(geo_lat./180*pi);
maginput = zeros(1,25);
mag_lat = zeros(size(x1));
mag_lon = zeros(size(x1));
mag_mlt = zeros(size(x1));
[m,n] = size(x1);
for i=1:m
    for j=1:n
        [~,xGEO] = onera_desp_lib_find_magequator(kext,options,sysaxes,matlabd,x1(i,j),x2(i,j),x3(i,j),maginput);
        tempL = sqrt(xGEO(1)^2+xGEO(2)^2+xGEO(3)^2);
        mag_lat(i,j) = acos(sqrt((1/tempL)))./pi*180;
        xMAG = onera_desp_lib_rotate(xGEO,'geo2mag',matlabd);
        mag_lon(i,j) = atan2(xMAG(2),xMAG(1))./pi*180;
        xSM = onera_desp_lib_rotate(xGEO,'geo2sm',matlabd);
        mag_mlt(i,j) = atan2(xSM(2),xSM(1))./pi*12+12;
    end
    disp(['GEO2AACGM Transformation: ',num2str(i),'/',num2str(m)]);
end
end

