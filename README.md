# 黄河站全天空成像仪图像处理代码示例
## 0. 配置IRBEM函数库
图像数据处理代码中利用IRBEM函数库进行磁力线投影以及坐标系转换等，IRBEM的下载地址见<https://github.com/PRBEM/IRBEM/tree/main>，函数说明见<https://prbem.github.io/IRBEM/>，示例代码中包含了IRBEM的基础文件以及所需要的64-bit dll文件，按以下步骤配置即可。

+ 64-bit MATLAB配置  
把`IRBEM\matlab`和`IRBEM\data`文件夹添加到MATLAB路径下（主页-设置路径）
+ 函数库测试  
运行`test_IRBEM.m`，得到以下结果说明配置成功  
> Results: MLAT 76.4811 MLON 109.7763  
> Reference: MLAT 76.4811 MLON 109.7763  
## 1. 代码说明  
### 1.1 img格式ASI数据初步处理
2010年之前的YRS ASI的数据格式为img，存储在`\YRS\CCD\Raw\`路径格式下，这里给出得到全天空照片以及磁子午线上keogram的代码示例  
> 运行函数前请修改程序开始部分的数据路径变量`asipath_title`，将其指引到`\YRS\CCD\Raw\`的上级目录。例如已经将`Z`盘映射到`\\192.168.43.99\uap`，将路径变量设置为`asipath_title = 'Z:\20_Beiji_Archive\'`即可。  
+ plot_YRS_ASI_img.m  
用于输出ASI图像数据，输出示例见`output_example\6300_20071101_042100.png`。所调用函数`OpenImg2Ray.m`将img文件读取并转化成极光强度数组，具体信息见函数内说明。。**注意：1. 图中的磁经纬度线仅为示意，更精确的AACGM网格见1.2节；2. 这里背景暗电流简单减去了一个设定好的值，更准确的暗电流值需要对所关注的时间范围前后进行平均得到。**
+ plot_YRS_ASI_img_keogram.m  
用于输出某一波段的ASI图像中磁子午线对应的keogram，输出示例见`output_example\keogram_5577_20071101_0330_0500.png`。  
+ plot_YRS_ASI_img_keogram_multiband.m  
用于输出全波段的ASI图像中磁子午线对应的keogram，输出示例见`output_example\keogram_multiband_20070103_0400_1000.png`。  
### 1.2 img格式ASI数据结合AACGM的处理
在配置好IRBEM函数库之后，我们可以通过追踪磁力线来得到视场内每一个像素点对应的GEO坐标和AACGM坐标，同时也可以将全天空图像投影到MLT-MLAT的格式内，方法如下： 
+ 运行`YRS_pixel_lat_lon_aacgm.m`得到全天空图像内像素点对应的GEO坐标和AACGM坐标。该程序利用天顶角和成像半径关系，首先得到每个像素点的GEO坐标，然后利用IGRF模型将GEO坐标转换到AACGM上。  
使用时需修改时间和波段，2007年11月1日630.0nm对应的示例结果见`output_example\pixel_lat_lon_250_2007040000.mat`。**注意磁力线追踪利用的IGRF模型对时间尺度为天的变化不敏感，会在更长时间尺度上发生变化，因而得到的坐标矩阵可以用于相近时间段的分析。**  
+ 运行`find_noon_maglon.m`得到不同的UT时下太阳日下点所对应的磁经度值，同样需自行修改时间范围，2007年11月1日03:00-06:00的示例结果见`output_example\noon_maglon.mat`。  
+ 运行`plot_YRS_ASI_img_polar.m`得到某一段时间内全天空图像在MLT-MLAT格式下的投影。程序通过以上两步所计算得到的全天空图像在AACGM下的磁经纬度以及不同时刻12MLT对应的磁经度值来进行投影，输出示例见`output_example\6300_20071101_042130_polar.png`。需自行修改时间范围和波段。
#### 其他函数
+ plot_YRS_ASI_img_AACGM_grid.m  
生成全天空图像内磁经纬度线的分布，参考结果见`output_example\6300_AACGM_grid_reference.png`
### 1.3 fits格式ASI数据初步处理  
2010年之后YRS ASI的数据格式为fits，存储在`YRS\CCD\Andor\`路径格式下，这里给出得到全天空照片的代码示例。**因10年之后的图像需要重新标定，准确的磁经纬度值暂时没有，可大致利用1.2节中的结果简单分析，待重新标定后得到更准确的结果。**
+ plot_YRS_ASI_fits.m 
用于输出ASI图像数据，输出示例见`output_example\5577_20151221_213000.png`。所调用函数`Openfits.m`将fits文件读取为计数矩阵，具体信息见函数内说明。
