function [Image,Time,Exposure] = Openfits(filename)
% This fuction is used to open .fits files from YRS/ASI after 2010
% fitsinfo
%   Filename: 'N1R_2012_1114_000010.fits'
%   FileModDate: '07-四月-2014 18:27:47'
%   FileSize: 1054080
%   Contents: {'Primary'}
%   PrimaryData: [1x1 struct]
%   PrimaryData:
%       DataType: 'int32'
%       Size: [512 512]
%       DataSize: 1048576
%       MissingDataValue: []
%       Intercept: 0
%       Slope: 1
%       Offset: 2880
%       Keywords: {30x3 cell}

fits_info=fitsinfo(filename);
file_date= fits_info.PrimaryData.Keywords{29,2};                %'ACQUTIME'    '20121114000000'    [1x48 char]
file_datenum = datenum(file_date,'yyyymmddHHMMSS');
%em_gain=cell2mat(fits_info.PrimaryData.Keywords(33,2));
exposure_time=cell2mat(fits_info.PrimaryData.Keywords(13,2));   %'EXPOSURE'    [             7]    [1x48 char]
temp_data=cell2mat(fits_info.PrimaryData.Keywords(23,2));       %'COOLTEMP'    [           -60]    [1x48 char]
vflip_id=cell2mat(fits_info.PrimaryData.Keywords(28,2));        %'IMGVFLIP'    [             0]    [1x48 char]
fits_data=fitsread(filename);
if vflip_id==1  % 如果IMGVFLIP为1，则图像矩阵上下颠倒
    fits_data=flipud(fits_data);
end
Image = fits_data; % then imagesc(Image)
Time = datestr(file_datenum,'yyyy-mm-dd/HH:MM:SS');
Exposure = exposure_time;
end