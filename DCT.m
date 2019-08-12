function varargout = DCT(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DCT_OpeningFcn, ...
                   'gui_OutputFcn',  @DCT_OutputFcn, ...
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
function DCT_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
function varargout = DCT_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
global DCTbmt;
global DCTjmt;
global ratioD;
global psnrD;
global S;
I=imread(S);  %读入原图像
s=rgb2gray(I);
subplot(2,2,1);
imshow(s);title('原始图像'); 

R=I(:,:,1);
R1=im2double(R); %将原图像转为双精度数据类型；
T=dctmtx(8);  %产生二维DCT变换矩阵
L2=blkproc(R1,[8,8],'P1*x*P2',T,T');%计算二维DCT
Mask=[ 1 1 1 1 0 0 0 0
       1 1 1 0 0 0 0 0
       1 1 0 0 0 0 0 0
       1 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0];%二值掩膜，用来压缩DCT系数，只留下DCT系数中左上角的10个
   L=blkproc(L2,[8,8],'P1.*x',Mask); %只保留DCT变换的10个系数
    [m n]=size(L);
     J=[m n];
    for i=1:m
    value=L(i,1);
    num=1;
    for j=2:n
        if L(i,j)==value
            num=num+1;
        else
            J=[J num value];
            num=1;
            value=L(i,j);
        end
    end
    J=[J num value ];    
    end    %量化

 % 解压缩，反量化
K(1:m,1:n)=0;
i1=1;
j1=1;
for i=3:2:length(J)%从3开始每次增加2直到J长即取出个数和像素值
    c1=J(i);%个数num
    c2=J(i+1);%像素值value
    for j=1:c1
        K(i1,j1)=c2;
        j1=j1+1;
        if j1>n
            i1=i1+1;
            j1=1;
        end
    end
end
R2= blkproc(K,[8,8],'P1*x*P2',T',T); %逆DCT，重构图像


 G=I(:,:,2);
G1=im2double(G); %将原图像转为双精度数据类型；
T=dctmtx(8);  %产生二维DCT变换矩阵
L2=blkproc(G1,[8 8],'P1*x*P2',T,T');  %计算二维DCT，矩阵T及其转置T’是DCT函数P1*x*P2的参数
Mask=[ 1 1 1 1 0 0 0 0
       1 1 1 0 0 0 0 0
       1 1 0 0 0 0 0 0
       1 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0];      %二值掩膜，用来压缩DCT系数，只留下DCT系数中左上角的10个
      L=blkproc(L2,[8 8],'P1.*x',Mask); %只保留DCT变换的10个系数
      [m n]=size(L);
     J=[m n];
    for i=1:m
    value=L(i,1);
    num=1;
    for j=2:n
        if L(i,j)==value
            num=num+1;
        else
            J=[J num value];
            num=1;
            value=L(i,j);
        end
end
J=[J num value ];    
    end

 % 解压缩
K(1:m,1:n)=0;
i1=1;
j1=1;
for i=3:2:length(J)
    c1=J(i);
    c2=J(i+1);
    for j=1:c1
        K(i1,j1)=c2;
        j1=j1+1;
        if j1>n
            i1=i1+1;
            j1=1;
        end
    end
end
G2= blkproc(K,[8,8],'P1*x*P2',T',T); %逆DCT，重构图像

DCTbmstart=tic;
B=I(:,:,3);
B1=im2double(B); %将原图像转为双精度数据类型;
disp('压缩前图像的大小:');
whos('B1');   
T=dctmtx(8);  %产生二维DCT变换矩阵
L2=blkproc(B1,[8 8],'P1*x*P2',T,T');  %计算二维DCT，矩阵T及其转置T’是DCT函数P1*x*P2的参数
Mask=[ 1 1 1 1 0 0 0 0
       1 1 1 0 0 0 0 0
       1 1 0 0 0 0 0 0
       1 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0];      %二值掩膜，用来压缩DCT系数，只留下DCT系数中左上角的10个
      L=blkproc(L2,[8 8],'P1.*x',Mask);  %只保留DCT变换的10个系数
      [m n]=size(L);
     J=[m n];
    for i=1:m
    value=L(i,1);
    num=1;
    for j=2:n
        if L(i,j)==value
            num=num+1;
        else
            J=[J num value];
            num=1;
            value=L(i,j);
        end
    end
    J=[J num value ];    
    end
disp('压缩后图像的大小:');
whos('J');   
 DCTbmt=toc(DCTbmstart);
 DCTjmstart=tic;
 % 解压缩
K(1:m,1:n)=0;
i1=1;
j1=1;
for i=3:2:length(J)
    c1=J(i);
    c2=J(i+1);
    for j=1:c1
        K(i1,j1)=c2;
        j1=j1+1;
        if j1>n
            i1=i1+1;
            j1=1;
        end
    end
end
B2= blkproc(K,[8,8],'P1*x*P2',T',T); %逆DCT，重构图像
DCTjmt=toc(DCTjmstart);

A(:,:,1)=R2;
A(:,:,2)=G2;
A(:,:,3)=B2;

subplot(2,2,2);
imshow(R2);title('R分量压缩后图像'); 
subplot(2,2,3);
imshow(G2);title('G分量压缩后图像'); 
subplot(2,2,4);
imshow(B2);title('B分量压缩后图像'); 
figure('Name','DCT压缩');
a=rgb2gray(A);
imshow(a);title('DCT压缩后图像'); 
figure;
subplot(1,2,1);
imshow(S);title('原始图像');
subplot(1,2,2);
imshow(A);title('压缩后图像'); 

disp(sprintf('\n DCT压缩编码的时间的值为：%6.3f\n',DCTbmt));
disp(sprintf('\n DCT压缩解码的时间的值为：%6.3f\n',DCTjmt));
ratioD=imratio(B1,J);
disp(sprintf('\n 压缩比为：%6.3f\n',ratioD));
 mse=0;    
 [m,n]=size(B1);
 for i=1:m
    for j=1:n
        b=(B1(i,j)-B2(i,j))^2; 
        mse=mse+b; 
    end  
 end 
 mse=mse/(m*n); 
 psnrD=10*log10((255*255)/mse); 
disp(sprintf('\n DCT压缩的psnr的值为：%6.3f\n',psnrD));
