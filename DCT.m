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
I=imread(S);  %����ԭͼ��
s=rgb2gray(I);
subplot(2,2,1);
imshow(s);title('ԭʼͼ��'); 

R=I(:,:,1);
R1=im2double(R); %��ԭͼ��תΪ˫�����������ͣ�
T=dctmtx(8);  %������άDCT�任����
L2=blkproc(R1,[8,8],'P1*x*P2',T,T');%�����άDCT
Mask=[ 1 1 1 1 0 0 0 0
       1 1 1 0 0 0 0 0
       1 1 0 0 0 0 0 0
       1 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0];%��ֵ��Ĥ������ѹ��DCTϵ����ֻ����DCTϵ�������Ͻǵ�10��
   L=blkproc(L2,[8,8],'P1.*x',Mask); %ֻ����DCT�任��10��ϵ��
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
    end    %����

 % ��ѹ����������
K(1:m,1:n)=0;
i1=1;
j1=1;
for i=3:2:length(J)%��3��ʼÿ������2ֱ��J����ȡ������������ֵ
    c1=J(i);%����num
    c2=J(i+1);%����ֵvalue
    for j=1:c1
        K(i1,j1)=c2;
        j1=j1+1;
        if j1>n
            i1=i1+1;
            j1=1;
        end
    end
end
R2= blkproc(K,[8,8],'P1*x*P2',T',T); %��DCT���ع�ͼ��


 G=I(:,:,2);
G1=im2double(G); %��ԭͼ��תΪ˫�����������ͣ�
T=dctmtx(8);  %������άDCT�任����
L2=blkproc(G1,[8 8],'P1*x*P2',T,T');  %�����άDCT������T����ת��T����DCT����P1*x*P2�Ĳ���
Mask=[ 1 1 1 1 0 0 0 0
       1 1 1 0 0 0 0 0
       1 1 0 0 0 0 0 0
       1 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0];      %��ֵ��Ĥ������ѹ��DCTϵ����ֻ����DCTϵ�������Ͻǵ�10��
      L=blkproc(L2,[8 8],'P1.*x',Mask); %ֻ����DCT�任��10��ϵ��
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

 % ��ѹ��
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
G2= blkproc(K,[8,8],'P1*x*P2',T',T); %��DCT���ع�ͼ��

DCTbmstart=tic;
B=I(:,:,3);
B1=im2double(B); %��ԭͼ��תΪ˫������������;
disp('ѹ��ǰͼ��Ĵ�С:');
whos('B1');   
T=dctmtx(8);  %������άDCT�任����
L2=blkproc(B1,[8 8],'P1*x*P2',T,T');  %�����άDCT������T����ת��T����DCT����P1*x*P2�Ĳ���
Mask=[ 1 1 1 1 0 0 0 0
       1 1 1 0 0 0 0 0
       1 1 0 0 0 0 0 0
       1 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0
       0 0 0 0 0 0 0 0];      %��ֵ��Ĥ������ѹ��DCTϵ����ֻ����DCTϵ�������Ͻǵ�10��
      L=blkproc(L2,[8 8],'P1.*x',Mask);  %ֻ����DCT�任��10��ϵ��
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
disp('ѹ����ͼ��Ĵ�С:');
whos('J');   
 DCTbmt=toc(DCTbmstart);
 DCTjmstart=tic;
 % ��ѹ��
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
B2= blkproc(K,[8,8],'P1*x*P2',T',T); %��DCT���ع�ͼ��
DCTjmt=toc(DCTjmstart);

A(:,:,1)=R2;
A(:,:,2)=G2;
A(:,:,3)=B2;

subplot(2,2,2);
imshow(R2);title('R����ѹ����ͼ��'); 
subplot(2,2,3);
imshow(G2);title('G����ѹ����ͼ��'); 
subplot(2,2,4);
imshow(B2);title('B����ѹ����ͼ��'); 
figure('Name','DCTѹ��');
a=rgb2gray(A);
imshow(a);title('DCTѹ����ͼ��'); 
figure;
subplot(1,2,1);
imshow(S);title('ԭʼͼ��');
subplot(1,2,2);
imshow(A);title('ѹ����ͼ��'); 

disp(sprintf('\n DCTѹ�������ʱ���ֵΪ��%6.3f\n',DCTbmt));
disp(sprintf('\n DCTѹ�������ʱ���ֵΪ��%6.3f\n',DCTjmt));
ratioD=imratio(B1,J);
disp(sprintf('\n ѹ����Ϊ��%6.3f\n',ratioD));
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
disp(sprintf('\n DCTѹ����psnr��ֵΪ��%6.3f\n',psnrD));
