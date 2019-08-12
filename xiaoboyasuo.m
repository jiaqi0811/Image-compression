function varargout = untitled(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @untitled_OpeningFcn, ...
                   'gui_OutputFcn',  @untitled_OutputFcn, ...
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

function untitled_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

guidata(hObject, handles);

function varargout = untitled_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
global S;
global xbt;
global psnrx1;
global psnrx2;
global ratiox1;
global ratiox2;
img=imread(S);
s=rgb2gray(img);
subplot(2,2,1);
imshow(s);title('ԭʼͼ��'); 
disp('ѹ��ǰͼ��Ĵ�С:');
double_img=double(s);
whos('double_img');

xbstart=tic;
%��ά�Ķ��С���ֽ�
[c,l]=wavedec2(s,2,'bior3.7');
%��ȡС���ֽ�ṹ���е�һ��ĵ�Ƶϵ��
cA1=appcoef2(c,l,'bior3.7',1);
%��ȡС���ֽ�ṹ���е�һ��ĸ�Ƶϵ��
%ˮƽ����
cH1=detcoef2('h',c,l,1);
%б�߷���
cD1=detcoef2('d',c,l,1);
%��ֱ����
cV1=detcoef2('v',c,l,1);

%�ֱ��ع���һ��ϵ��
A1=wrcoef2('a',c,l,'bior3.7',1);
H1=wrcoef2('h',c,l,'bior3.7',1);
D1=wrcoef2('d',c,l,'bior3.7',1);
V1=wrcoef2('v',c,l,'bior3.7',1);
c1=[A1 H1 ;V1 D1];


%��ͼ�����ѹ��:������һ���Ƶ��Ϣ�����������������
ca1=wcodemat(cA1,440,'mat',0);

%ѹ��ͼ�񣺱����ڶ����Ƶ��Ϣ�����������������
cA2=appcoef2(c,l,'bior3.7',2);
ca2=wcodemat(cA2,440,'mat',0);
xbt=toc(xbstart);

%��ʾ��һ��Ƶ����Ϣ
subplot(2,2,2);
imshow(uint8(c1));title('�ֽ��ĵ�Ƶ�͸�Ƶ��Ϣ');
%�ı�ͼ��߶Ȳ���ʾ
ca1=0.5*ca1;
subplot(2,2,3);
imshow(uint8(ca1));title('��һ��ѹ�����ͼ��');
disp('��һ��ѹ����ͼ��Ĵ�С��');
whos('ca1');
ca2=0.5*ca2;
subplot(2,2,4);
imshow(uint8(ca2));title('�ڶ���ѹ�����ͼ��');
disp('�ڶ���ѹ�����ͼ���С��');
whos('ca2')
figure;
imshow(uint8(c1));title('�ֽ��ĵ�Ƶ�͸�Ƶ��Ϣ');

disp(sprintf('\n С��ѹ����ʱ���ֵΪ��%6.3f\n',xbt));

 [m,n] = size(S);
 mse=0;     %���ֵ�����psnr
 [x1,y1]=size(ca1);
 for i=1:x1
    for j=1:y1
        a=(c1(i,j)-ca1(i,j))^2; 
        mse=mse+a; 
    end  
 end 
 mse=mse/(m*n); 
 psnrx1=10*log10((255*255)/mse); 
disp(sprintf('\n ��һ��ѹ����psnr��ֵΪ��%6.3f\n',psnrx1));


 mse=0;     %���ֵ�����psnr
 [x2,y2]=size(ca2);
 for i=1:x2
    for j=1:y2
        a=(c1(i,j)-ca2(i,j))^2; 
        mse=mse+a; 
    end  
 end 
 mse=mse/(m*n); 
 psnrx2=10*log10((255*255)/mse); 
disp(sprintf('\n �ڶ���ѹ����psnr��ֵΪ��%6.3f\n',psnrx2));

ratiox1=imratio(double_img,ca1);
disp(sprintf('\n ��һ��ѹ����Ϊ��%6.3f\n',ratiox1));
ratiox2=imratio(double_img,ca2);
disp(sprintf('\n �ڶ���ѹ����Ϊ��%6.3f\n',ratiox2));



