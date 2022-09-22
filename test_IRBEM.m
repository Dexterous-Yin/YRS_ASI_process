geo_lat = 78.92;
geo_lon = 11.93;
geo_height = 150;
geo_time = '2007-11-01/00:00:00';
[mag_lat,mag_lon,mag_mlt] = geo2mag_aacgm(geo_lat,geo_lon,geo_height,geo_time);
disp(['Results: MLAT ',num2str(mag_lat),' MLON ',num2str(mag_lon)]);
disp(['Reference: MLAT ',num2str(76.4811),' MLON ',num2str(109.7763)]);