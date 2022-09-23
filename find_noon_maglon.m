tformat = 'yyyy-mm-dd/HH:MM:SS';
noon_time = datenum('2007-11-01/03:00:00'):10/60/60/24:datenum('2007-11-01/06:00:00');

RE = 6371.2; % km
kext = 0;
options = [0,1,0,0,0];
sysaxes = 1; % GEO coordinates

noon_maglon = zeros(1,length(noon_time));
for i=1:length(noon_time)
    matlabd = noon_time(i);
    xSM = [1;0;0];
    xGSM = onera_desp_lib_rotate(xSM,'sm2gsm',matlabd);
    xGEO = onera_desp_lib_rotate(xGSM,'gsm2geo',matlabd);
    xMAG = onera_desp_lib_rotate(xGEO,'geo2mag',matlabd);
    noon_maglon(i) = atan2(xMAG(2),xMAG(1))./pi*180;
    disp([num2str(i),'/',num2str(length(noon_time))]);
end
save('output_example\noon_maglon.mat','noon_time','noon_maglon');