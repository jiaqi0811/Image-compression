function varargout = fenxingyasuo(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fenxingyasuo_OpeningFcn, ...
                   'gui_OutputFcn',  @fenxingyasuo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function fenxingyasuo_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
function varargout = fenxingyasuo_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
global psnrf;
global ratiof;
global fbmt;
global fjmt;
global S;
img=imread(S);
s=rgb2gray(img);
subplot(1,2,1);
imshow(s);title('原始图像');
double_img = double(s);
disp('压缩前图像的大小:');
whos('double_img');


fbmstart=tic;
[DATA,map]=imread(S);%读入彩色图像
DATA=double(DATA);
size1=size(DATA);%获取data的行列数
tu=DATA(1:size1(1),1:size1(2),1);%取出彩色三维数据其中的第一维，即为灰度图像矩阵
xx=size1(2);%图像横轴像素列数
yy=size1(1);%图像纵轴像素行数
fgstart=tic;
% 图像边缘像素补充
% 图像的长宽像素数量不一定是8或16的倍数，换言之，直接相除，nrx,nry,ndx,ndy不一定是整数一种简单的方法是在图像边缘补零
addZerosX = 16 * (round(xx / 16) - xx / 16);
addZerosY = 16 * (round(yy / 16) - yy / 16);
tu = [tu ; zeros(addZerosY , xx)];
tu = [tu , zeros(yy + addZerosY, addZerosX)];
[yy,xx]=size(tu);%xx图像横轴像素列数,yy图像纵轴像素行数
nrx=xx/8;%将原始图像划分成8*8的像素矩阵
nry=yy/8;%将原始图像划分成8*8的像素矩阵
ndx=xx/16;%将定义域划分成16*16的像素矩阵
ndy=yy/16;%将定义域划分成16*16的像素矩阵


DD=zeros(ndy,ndx,8,64);%用于存放定义域压缩后8*8矩阵的8中对应的变换形式
cund1=zeros(16,16);%用于存放16*16的定义域像素块
cund2=zeros(8,8);%用于存放有16*16的定义域像素块压缩后形成的8*8像素块
cund3=zeros(1,64);% cund3存储定义域块的值
cund33=zeros(1,64);% cund33存储最佳匹配块
cund4=zeros(8,8);%变换后的cund2
cunr=zeros(1,64);%将值域块8*8的像素值重新排列成一列
RRR=zeros(nry,nrx,6);% s,o,D(y),D(x),U

for i=1:ndy
    for j=1:ndx
            %取定义域图像（原始图像）中16*16的像素矩阵
            cund1=tu(1+16*(i-1):16+16*(i-1),1+16*(j-1):16+16*(j-1));
            for l=1:8
                for m=1:8
                    %求定义域像素每临近四个像素点的平均值，借以将16*16的定义域块转换成8*8的块
                    cund2(l,m)=(cund1(1+2*(l-1),1+2*(m-1))+cund1(2+2*(l-1),2+2*(m-1))+cund1(2+2*(l-1),1+2*(m-1))+cund1(1+2*(l-1),2+2*(m-1)))/4;
                end;
            end;
        DD(i,j,1,1:64)=reshape(cund2,[1,64]);%对cund2做0度旋转，将cund2按列重新排列成一行
        cund4=fliplr(cund2);%将cund2矩阵左右翻转，相当于矩阵水平中线反射
        DD(i,j,2,1:64)=reshape(cund4,[1,64]);
        cund4=flipud(cund2);%将cund2矩阵上下翻转，相当于矩阵垂直中线反射
        DD(i,j,3,1:64)=reshape(cund4,[1,64]);
        cund4=flipud(fliplr(cund2));%将矩阵左右翻转后上下翻转，相当于180度旋转
        DD(i,j,4,1:64)=reshape(cund4,[1,64]);
        cund4=rot90(flipud(cund2));%矩阵相对135度反射
        DD(i,j,5,1:64)=reshape(cund4,[1,64]);
        cund4=rot90(cund2);%矩阵90度旋转
        DD(i,j,6,1:64)=reshape(cund4,[1,64]);
        cund4=rot90(rot90(rot90(cund2)));%矩阵270度旋转
        DD(i,j,7,1:64)=reshape(cund4,[1,64]);
        cund4=cund2';%矩阵相对45度反射
        DD(i,j,8,1:64)=reshape(cund4,[1,64]);
    end;
end;
fgt=toc(fgstart);

bmstart=tic;
h=waitbar(0,'开始分形压缩');
pause(0.01);
for i=1:nry%这两个循环（i和j）保证了对于每个值域块都找到了相应的定义域块，并且求出了该定义域块
    for j=1:nrx%得一系列变换过程
        %将值域块8*8的像素值重新排列成一列，放到cunr
        cunr=reshape(tu(1+8*(i-1):8+8*(i-1),1+8*(j-1):8+8*(j-1)),[1,64]);
        sumalpha=sum(cunr);   %cunr存储值域块的值
        sumalpha2=norm(double(cunr))^2;%cunr中各个数值的平方（即向量2范数的平方），相当于求值域块矩阵每个元素的平方再求和
        dx=1;%这几个变量就是分形编码的数据量，他们的初值可以随意定。记录l的值
        dy=1;%记录k的值
        ut=1;%记录m的值
        minH=10^20;%记录最小的均方根误差R值
        minot=0;%参数minot记录下与当前值域块能够最佳匹配的定义域块下变换所需的亮度调节
        minst=0;%参数minst记录下与当前值域块能够最佳匹配的定义域块下变换所需的对比度调节
        for k=1:ndy%参数k与l记录下与当前值域块能够最佳匹配的定义域块的序号
            for l=1:ndx
                for m=1:8%参数m记录下与当前值域块能够最佳匹配的定义域块得8种基本变形的序号
                    cund3(1:64)=DD(k,l,m,1:64);
                    sumbeta=sum(cund3);  % cund3存储定义域块的值
                    sumbeta2=norm(cund3)^2;%求出向量的2范数，相当于定义域块矩阵的每个元素的平方再求和
                    alphabeta=double(cunr)*cund3';
                    if (64*sumbeta2-sumbeta^2)~=0
                    st=(64*alphabeta-sumalpha*sumbeta)/(64*sumbeta2-sumbeta^2);%st即是对比度调节系数s
                    elseif (64*alphabeta-sumalpha*sumbeta)==0||st > 1 || st < -1
                        st=0;
                    else
                        st=10^20;
                    end;
                    ot=(sumalpha-st*sumbeta)/64;%ot即使亮度调节系数
                    H=(sumalpha2+st*(st*sumbeta2-2*alphabeta+2*ot*sumbeta)+ot*(64*ot-2*sumalpha))/64;%在当前s与o的条件下的R
%                     H=norm(cund33*minst+ot-cunr)^2
                    if H<minH%寻求定义域块与值域块的最佳匹配，并记录下最佳匹配的参数值
                        dx=l;
                        dy=k;
                        ut=m;
                        minot=ot;
                        minst=st;
                        minH=H;
                        cund33=cund3;
                    end;
                end;
            end;
        end;
        RRR(i,j,1)=minst;
        RRR(i,j,2)=minot;
        RRR(i,j,3)=dy;
        RRR(i,j,4)=dx;
        RRR(i,j,5)=ut;
        RRR(i,j,6)=minH;
        waitbar((i*nrx + j)/(nry * nrx) * 100,h,['分形压缩已完成' num2str((i*nrx + j)/(nry *nrx) * 100) '%']);
    end;
end;
bmt=toc(bmstart);
close(h);
fbmt=toc(fbmstart);

% 保存数据
outfp = fopen('分形图像压缩(特征值).txt','w');
h=waitbar(0,'开始保存记录');
pause(0.01);
for i=1:nry
    for j=1:nrx
        fprintf(outfp,'s值：%8.5f o值：%8.5f yy值：%4.0f  xx值: %4.0f k值：%2.0f\n',...
        RRR(i,j,1),RRR(i,j,2),RRR(i,j,3),RRR(i,j,4),RRR(i,j,5));
        waitbar((i*nrx + j)/(nry *nrx) * 100,h,['保存记录已完成' num2str((i*nrx + j)/(nry *nrx) * 100) '%']);
    end
end
close(h);
fclose(outfp);
disp('压缩后图像的大小:');
whos('RRR');

fjmstart=tic;
huifu=ones(yy,xx);    %恢复原图像
for iter=1:10
for i=1:nry
    for j=1:nrx
        st=RRR(i,j,1);
        ot=RRR(i,j,2);
        dy=RRR(i,j,3);
        dx=RRR(i,j,4);
        ut=RRR(i,j,5);
        cund1=huifu(1+16*(dy-1):16+16*(dy-1),1+16*(dx-1):16+16*(dx-1));
        for l=1:8
            for m=1:8
                cund2(l,m)=(cund1(1+2*(l-1),1+2*(m-1))+cund1(2+2*(l-1),2+2*(m-1))+cund1(2+2*(l-1),1+2*(m-1))+cund1(1+2*(l-1),2+2*(m-1)))/4;
            end;
        end;
        switch ut
            case 1 
                cund4=cund2;
            case 2 
                cund4=fliplr(cund2);
            case 3 
                cund4=flipud(cund2);
            case 4 
                cund4=flipud(fliplr(cund2));             
            case 5 
                cund4=rot90(flipud(cund2));               
            case 6 
                cund4=rot90(cund2);            
            case 7 
                cund4=rot90(rot90(rot90(cund2)));
            case 8 
                cund4=cund2';
        end;
        huifu(1+8*(i-1):8+8*(i-1),1+8*(j-1):8+8*(j-1))=st*cund4+ot;
    end;
end;
end;

huifu = mat2gray(huifu);
fjmt=toc(fjmstart);

subplot(1,2,1),imshow(s);title('原始图像');
subplot(1,2,2),imshow(huifu);title('压缩后的图像');
figure('Name','分形压缩');
imshow(huifu);title('分形压缩后图像'); 

disp(sprintf('\n 分形压缩编码的时间的值为：%6.3f\n',fbmt));
disp(sprintf('\n 分形压缩解码的时间的值为：%6.3f\n',fjmt));
ratiof=imratio(double_img,RRR);
disp(sprintf('\n 压缩比为：%6.3f\n',ratiof));

  mse=0;     %求峰值信噪比psnr
 [x,y]=size(double_img);
 DAT=zeros(x,y); 
 for i=1:x
     for j=1:y
         DAT(i,j)=huifu(i,j);
     end
 end
 
 for i=1:x
    for j=1:y
        a=(DATA(i,j)-DAT(i,j))^2; 
        mse=mse+a; 
    end  
 end 
 [m,n] = size(S);
 mse=mse/(m*n); 
 psnrf=10*log10((255*255)/mse); 
disp(sprintf('\n psnr的值为：%6.3f\n',psnrf));
disp(sprintf('\n 分形压缩分割图像的时间的值为：%6.3f\n',fgt));
disp(sprintf('\n 分形压缩相似性匹配的时间的值为：%6.3f\n',bmt));


