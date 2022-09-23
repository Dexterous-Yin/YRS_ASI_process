function [Image_Ray,Date,Time,Tag,Exposure]=OpenImg2Ray(filename)
% 读入CCD的图像数据，返还参数：
% Image：图像矩阵
% Data：图像日期
% Time：图像时间
% Tag ：图像标志，0，表示是常规观测，时间格式是'HH:MM:SS'
%                 1，表示是会战观测，时间偏移量格式是'*******ms'
% Exposure:图像曝光时间

%   程序说明:
%   此版本是2005年3月28日修改,版本号:   2005.03.28
%   2004-2005北极极光观测由于更改了操作程序,CCD图像数据的时间格式有所变化,
%   从2004年11月22日起,采用了"Comment"模式
%   如果有"[Comment]",则时间以"UserComment="Fri Dec 10 15:03:08 2004"为准,
%   否则以"Date="2004-12-10",Time="5795060ms""为准,
%   UserComment的起始位置从1177开始向后会有漂移,
%   ExposureTime的起始位置从523开始向后会有漂移,
%   这些取决于Time的格式,若Time格式是"HH:MM:SS",
%   则UserComment的位置固定在1177,EposureTime的位置固定在523;
%   若Time的格式是"********ms",则两参数的位置会向后漂移,但是漂移量最大不会超过10
%--------------------------------------------------------------------------
%   版本号：2006.05.15
%   修改说明：
%   D01/02文件可能虽然采取了[comment]模式，但是时间记录仍然是非[comment]模式,
%   因此插入94-114行的代码。若去掉该段代码则与2005.03.28版本程序相同
%--------------------------------------------------------------------------
% modified by Zefan Yin.
% To transform counts to Rayleigh values.
fid=fopen(filename,'r');    %   打开文件

if fid~=-1          %  fid=-1，则该文件不存在
    % 判断是否用了[comment]工作模式
    ip=1160;    % "[Comment]"标志最早出现在1165
    Point_Comment=0;    % 初始化Point_Comment
    for n=0:15
        file_point=fseek(fid,ip+n,'bof'); %   设定文件指针位置
        [Tag_Comment, Tag_count]=fread(fid,9); % 从ip+n处连续读出9个字符
        Tag_ChrComment=char(Tag_Comment');
        if (strcmp(Tag_ChrComment,'[Comment]'))
            Point_Comment=ip+n; % 获得[Commen]的首位置
            break;
        end
    end
    
    % 获取ExposureTime
    ep=510; % ExposureTime的起始指针
    Point_Exposure=0;
    for n=0:20
        file_point=fseek(fid,ep+n,'bof'); %   设定文件指针位置
        [Tag_Exposure,Exposure_count]=fread(fid,12); % ExposureTime=7s/25s 12个字符
        Tag_ChrExposure=char(Tag_Exposure');
        Point_Exposure=ep+n; % ExposureTime的位置
        if (strcmp(Tag_ChrExposure,'ExposureTime'))
            Time_1ip=Point_Exposure+13; % 曝光时间的位置 7s/25s
            for m=0:5
                file_point=fseek(fid,Time_1ip+m,'bof');
                [S,S_count]=fread(fid,1);
                S=char(S);
                if (strcmp(S,'s'))
                    Time_2ip=Time_1ip+m; % 曝光时间的结束位置, 即's'的位置
                    file_point=fseek(fid,Time_1ip,'bof'); % 指针重新调回到'7s'的开始
                    [ExposureTime,ET_count]=fread(fid,Time_2ip-Time_1ip); % Time_2ip-Time_1ip:曝光时间值的位数,个位或十位...
                    Exposure=str2num(char(ExposureTime')); % 获得曝光时间
                    break;
                end
            end
            break;
        end
    end
    
    
    
    if Point_Comment==0 % 未采用Comment的工作模式,则文件的读取采用以前的方式
        file_point=fseek(fid,84,'bof');    %   设定文件指针位置
        [A,count_A]=fread(fid,10);    %   获取文件的日期
        Date=char(A'); % get file date(yyyy-mm-dd)
        file_point=fseek(fid,102,'bof');    %   设定文件指针位置
        [B,count_B]=fread(fid,20);   %   获取文件的时间
        file_time=char(B'); %  get file time(hh:mm:ssUT)
        [tm,tn]=size(file_time);
        if (file_time(1,3)~=':')& (file_time(1,6)~=':')
            for i=2:tn-1
                if (file_time(1,i)=='m')& (file_time(1,i+1)=='s')
                    Time=file_time(1:i-1);  % 文件时间是*******ms
                    Tag=1;
                    break;
                end
            end
        else
            Time=file_time(1:8);
            Tag=0;
        end
    else    % 采用了Comment的工作模式,文件的时间在'UserComment'之后
        file_point=fseek(fid,Point_Comment+23,'bof') ; %    [Comment],UserComment="Thu Dec 16 07:02:40 2004
        [C,count_C]=fread(fid,24);
        C_Char=char(C');
        if C_Char(1)=='"'
            file_point=fseek(fid,84,'bof');    %   设定文件指针位置
            [A,count_A]=fread(fid,10);    %   获取文件的日期
            Date=char(A'); % get file date(yyyy-mm-dd)
            file_point=fseek(fid,102,'bof');    %   设定文件指针位置
            [B,count_B]=fread(fid,20);   %   获取文件的时间
            file_time=char(B'); %  get file time(hh:mm:ssUT)
            [tm,tn]=size(file_time);
            if (file_time(1,3)~=':')& (file_time(1,6)~=':')
                for i=2:tn-1
                    if (file_time(1,i)=='m')& (file_time(1,i+1)=='s')
                        Time=file_time(1:i-1);  % 文件时间是*******ms
                        Tag=1;
                        break;
                    end
                end
            else
                Time=file_time(1:8);
                Tag=0;
            end
        else
            Date_Str=strcat(C_Char(9:10),'-',C_Char(5:7),'-',C_Char(21:24));
            Date=datestr(datenum(Date_Str),29); % 将日期格式转换成'yyyy-mm-dd'
            Time=C_Char(12:19);
            Tag=0;
        end
    end
    
    %%% 读取图像数据
    file_point=fseek(fid,-512*512*2,'eof'); % 设置指针距文件结尾512*512*2 Bytes
    Image=zeros(512,512); %   定义图像阵列：512 X 512
    [I,count_I]=fread(fid,[512,512],'uint16'); % 读取矩阵数据
    fclose(fid);
    Image=I'; % get CCD Image Matrix，显示命令是：imagesc(......)
    if ~exist('ExposureTime','var')
        Exposure=7;
    end
    
    % added code to transform counts to Rayleigh
    band_RGB = filename(end-9);
    switch band_RGB
        case 'V'
            %         band='427.8nm';
            %         BAND='V';
            band='427.8nm';
            bg_noise=ones(512,512)*594;
            c_Lim=[0 2000];
            c_LimRayleigh=[0 10000];
            K=1.5280;
            
            x0=257; % center pix
            y0=255; % center pix
            r0=247; % radius
            angleNS=62.2902;  % 地理子午线与y=255轴夹角,单位：度
            
            p1=[480 140];  % 磁北的方向指针(x,y)
            p2=[498 130];
            
            p3=[31 372];   % 磁南的方向指针(x,y)
            p4=[12 382];
            
        case 'G'
            %         band='557.7nm';
            %         BAND='G';
            band='557.7nm';
            bg_noise=ones(512,512)*564;
            c_Lim=[0 5000];
            c_LimRayleigh=[0 10000];
            K=1.0909;
            
            x0=261; % center pix
            y0=257; % center pix
            r0=246; % radius
            angleNS=63.7884;  % 地理子午线与y=255轴夹角,单位：度
            
            p1=[480 140];  % 磁北的方向指针(x,y)
            p2=[498 130];
            
            p3=[31 372];   % 磁南的方向指针(x,y)
            p4=[12 382];
            
        case 'R'
            band='630.0nm';
            bg_noise=ones(512,512)*1137;
            c_Lim=[0 7000];
            c_LimRayleigh=[0 30000];
            K=0.5159;
            
            x0=256; % center pix
            y0=257; % center pix
            r0=252; % radius
            angleNS=62.7560;  % 地理子午线与y=255轴夹角,单位：度
            
            p1=[480 140];  % 磁北的方向指针(x,y)
            p2=[498 130];
            
            p3=[31 372];   % 磁南的方向指针(x,y)
            p4=[12 382];
            
    end
    switch band_RGB
        case 'V'
            GMap=(Image-bg_noise).*K;   % 去除CCD背景噪音,计算极光强度
        case 'G'
            GMap=(Image-bg_noise).*K;   % 去除CCD背景噪音,计算极光强度
        case 'R'
            GMap=(Image-bg_noise).*K;   % 去除CCD背景噪音,计算极光强度
    end
    Image_Ray = GMap;
end
