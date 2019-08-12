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
global hht;
global psnrh1;
global psnrh2;
global ratioh1;
global ratioh2;
img=imread(S);
s=rgb2gray(img);
subplot(2,2,1);
imshow(s);title('ԭʼͼ��'); 
disp('ѹ��ǰͼ��Ĵ�С:');
double_img=double(s);
whos('double_img');

hhstart=tic;
%��ά�Ķ��С���ֽ�
[c,l]=wavedec2(s,2,'bior3.7');
%��ȡС���ֽ�ṹ���е�һ��ĵ�Ƶϵ��
cA1=appcoef2(c,l,'bior3.7',1);
%��ȡС���ֽ�ṹ���е�һ��ĸ�Ƶϵ��
cA2=appcoef2(c,l,'bior3.7',2);
%ˮƽ����
cH1=detcoef2('h',c,l,1);
%б�߷���
cD1=detcoef2('d',c,l,1);
%��ֱ����
cV1=detcoef2('v',c,l,1);

%�ع���һ��ϵ��
A1=wrcoef2('a',c,l,'bior3.7',1);
H1=wrcoef2('h',c,l,'bior3.7',1);
D1=wrcoef2('d',c,l,'bior3.7',1);
V1=wrcoef2('v',c,l,'bior3.7',1);
c1=[A1 H1 ;V1 D1];
%��ʾ��һ��Ƶ����Ϣ
subplot(2,2,2);
imshow(uint8(c1));title('�ֽ��ĵ�Ƶ�͸�Ƶ��Ϣ');

DATA=double(cA1);
size1=size(DATA);%��ȡdata��������
tu=DATA(1:size1(1),1:size1(2),1);%ȡ����ɫ��ά�������еĵ�һά����Ϊ�Ҷ�ͼ�����
xx=size1(2);%ͼ�������������
yy=size1(1);%ͼ��������������

% ͼ���Ե���ز���
addZerosX = 16 * (round(xx / 16) - xx / 16);
addZerosY = 16 * (round(yy / 16) - yy / 16);
tu = [tu ; zeros(addZerosY , xx)];
tu = [tu , zeros(yy + addZerosY, addZerosX)];
[yy,xx]=size(tu);%xxͼ�������������,yyͼ��������������
nrx=xx/8;%��ԭʼͼ�񻮷ֳ�8*8�����ؾ���
nry=yy/8;%��ԭʼͼ�񻮷ֳ�8*8�����ؾ���
ndx=xx/16;%�������򻮷ֳ�16*16�����ؾ���
ndy=yy/16;%�������򻮷ֳ�16*16�����ؾ���


DD=zeros(ndy,ndx,8,64);%���ڴ�Ŷ�����ѹ����8*8�����8�ж�Ӧ�ı任��ʽ
cund1=zeros(16,16);%���ڴ��16*16�Ķ��������ؿ�
cund2=zeros(8,8);%���ڴ����16*16�Ķ��������ؿ�ѹ�����γɵ�8*8���ؿ�
cund3=zeros(1,64);
cund33=zeros(1,64);
cund4=zeros(8,8);

RRR=zeros(nry,nrx,6);% s,o,D(y),D(x),U
cunr=zeros(1,64);
for i=1:ndy
    for j=1:ndx
            cund1=tu(1+16*(i-1):16+16*(i-1),1+16*(j-1):16+16*(j-1));
            for l=1:8
                for m=1:8
                    %����������ÿ�ٽ��ĸ����ص��ƽ��ֵ�����Խ�16*16�Ķ������ת����8*8�Ŀ�
                    cund2(l,m)=(cund1(1+2*(l-1),1+2*(m-1))+cund1(2+2*(l-1),2+2*(m-1))+cund1(2+2*(l-1),1+2*(m-1))+cund1(1+2*(l-1),2+2*(m-1)))/4;
                end;
            end;
        DD(i,j,1,1:64)=reshape(cund2,[1,64]);%��cund2�����������г�һ��
        cund4=fliplr(cund2);%��cund2�������ҷ�ת���൱�ھ���ˮƽ���߷���
        DD(i,j,2,1:64)=reshape(cund4,[1,64]);
        cund4=flipud(cund2);%��cund2�������·�ת���൱�ھ���ֱ���߷���
        DD(i,j,3,1:64)=reshape(cund4,[1,64]);
        cund4=flipud(fliplr(cund2));%���������ҷ�ת�����·�ת���൱��180����ת
        DD(i,j,4,1:64)=reshape(cund4,[1,64]);
        cund4=rot90(flipud(cund2));%�������135�ȷ���
        DD(i,j,5,1:64)=reshape(cund4,[1,64]);
        cund4=rot90(cund2);%����90����ת
        DD(i,j,6,1:64)=reshape(cund4,[1,64]);
        cund4=rot90(rot90(rot90(cund2)));%����270����ת
        DD(i,j,7,1:64)=reshape(cund4,[1,64]);
        cund4=cund2';%�������45�ȷ���
        DD(i,j,8,1:64)=reshape(cund4,[1,64]);
    end;
end;

h=waitbar(0,'��ʼ��һ�η���ѹ��');
pause(0.01);
for i=1:nry
    for j=1:nrx
        %��ֵ���8*8������ֵ�������г�һ�У��ŵ�cunr
        cunr=reshape(tu(1+8*(i-1):8+8*(i-1),1+8*(j-1):8+8*(j-1)),[1,64]);
        sumalpha=sum(cunr);   %cunrֵ����ֵ
        sumalpha2=norm(double(cunr))^2;%cunr�и�����ֵ��ƽ����������2������ƽ�������൱����ֵ������ÿ��Ԫ�ص�ƽ�������
        dx=1;%�⼸���������Ƿ��α���������������ǵĳ�ֵ�������ⶨ����¼l��ֵ
        dy=1;%��¼k��ֵ
        ut=1;%��¼m��ֵ
        minH=10^20;%��¼��С�ľ��������Rֵ
        minot=0;%����minot��¼���뵱ǰֵ����ܹ����ƥ��Ķ�������±任��������ȵ���
        minst=0;%����minst��¼���뵱ǰֵ����ܹ����ƥ��Ķ�������±任����ĶԱȶȵ���
        for k=1:ndy%����k��l��¼���뵱ǰֵ����ܹ����ƥ��Ķ����������
            for l=1:ndx%
                for m=1:8%����m��¼���뵱ǰֵ����ܹ����ƥ��Ķ�������8�ֻ������ε����
                    cund3(1:64)=DD(k,l,m,1:64);
                    sumbeta=sum(cund3);  % cund3��������ֵ
                    sumbeta2=norm(cund3)^2;%���������2�������൱�ڶ����������ÿ��Ԫ�ص�ƽ�������
                    % ����˷�������������double���;��󣬶�cunrԭʼ����Ϊuint8���;���
                    alphabeta=double(cunr)*cund3';
                    if (64*sumbeta2-sumbeta^2)~=0
                    st=(64*alphabeta-sumalpha*sumbeta)/(64*sumbeta2-sumbeta^2);%st���ǶԱȶȵ���ϵ��s
                    elseif (64*alphabeta-sumalpha*sumbeta)==0||st > 1 || st < -1
                        st=0;
                    else
                        st=10^20;
                    end;
                    ot=(sumalpha-st*sumbeta)/64;%ot��ʹ���ȵ���ϵ��
                    H=(sumalpha2+st*(st*sumbeta2-2*alphabeta+2*ot*sumbeta)+ot*(64*ot-2*sumalpha))/64;%�ڵ�ǰs��o�������µ�R
%                     H=norm(cund33*minst+ot-cunr)^2
                    if H<minH%Ѱ���������ֵ�������ƥ�䣬����¼�����ƥ��Ĳ���ֵ
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
        waitbar((i*nrx + j)/(nry * nrx) * 100,h,['��һ�η���ѹ�������' num2str((i*nrx + j)/(nry *nrx) * 100) '%']);
    end;
end;
RRR1=zeros(nry,nrx,6);
RRR1=RRR;
close(h);
huifu=ones(yy,xx);    %�ָ�ԭͼ��


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
ca1=0.5*huifu;
subplot(2,2,3),imshow(ca1);title('��һ��ѹ�����ͼ��');
disp('��һ��ѹ����ͼ��Ĵ�С��');
whos('ca1');

DATA=double(cA2);
size1=size(DATA);%��ȡdata��������
tu=DATA(1:size1(1),1:size1(2),1);%ȡ����ɫ��ά�������еĵ�һά����Ϊ�Ҷ�ͼ�����
xx=size1(2);%ͼ�������������
yy=size1(1);%ͼ��������������


addZerosX = 16 * (round(xx / 16) - xx / 16);
addZerosY = 16 * (round(yy / 16) - yy / 16);
tu = [tu ; zeros(addZerosY , xx)];
tu = [tu , zeros(yy + addZerosY, addZerosX)];
[yy,xx]=size(tu);%xxͼ�������������,yyͼ��������������
nrx=xx/8;%��ԭʼͼ�񻮷ֳ�8*8�����ؾ���
nry=yy/8;%��ԭʼͼ�񻮷ֳ�8*8�����ؾ���
ndx=xx/16;%�������򻮷ֳ�16*16�����ؾ���
ndy=yy/16;%�������򻮷ֳ�16*16�����ؾ���


DD=zeros(ndy,ndx,8,64);%���ڴ�Ŷ�����ѹ����8*8�����8�ж�Ӧ�ı任��ʽ
cund1=zeros(16,16);%���ڴ��16*16�Ķ��������ؿ�
cund2=zeros(8,8);%���ڴ����16*16�Ķ��������ؿ�ѹ�����γɵ�8*8���ؿ�
cund3=zeros(1,64);
cund33=zeros(1,64);
cund4=zeros(8,8);

RRR=zeros(nry,nrx,6);
% s,o,D(y),D(x),U
cunr=zeros(1,64);
for i=1:ndy
    for j=1:ndx
            cund1=tu(1+16*(i-1):16+16*(i-1),1+16*(j-1):16+16*(j-1));
            for l=1:8
                for m=1:8
                    %����������ÿ�ٽ��ĸ����ص��ƽ��ֵ�����Խ�16*16�Ķ������ת����8*8�Ŀ�
                    cund2(l,m)=(cund1(1+2*(l-1),1+2*(m-1))+cund1(2+2*(l-1),2+2*(m-1))+cund1(2+2*(l-1),1+2*(m-1))+cund1(1+2*(l-1),2+2*(m-1)))/4;
                end;
            end;
        DD(i,j,1,1:64)=reshape(cund2,[1,64]);%��cund2�����������г�һ��
        cund4=fliplr(cund2);%��cund2�������ҷ�ת���൱�ھ���ˮƽ���߷���
        DD(i,j,2,1:64)=reshape(cund4,[1,64]);
        cund4=flipud(cund2);%��cund2�������·�ת���൱�ھ���ֱ���߷���
        DD(i,j,3,1:64)=reshape(cund4,[1,64]);
        cund4=flipud(fliplr(cund2));%���������ҷ�ת�����·�ת���൱��180����ת
        DD(i,j,4,1:64)=reshape(cund4,[1,64]);
        cund4=rot90(flipud(cund2));%�������135�ȷ���
        DD(i,j,5,1:64)=reshape(cund4,[1,64]);
        cund4=rot90(cund2);%����90����ת
        DD(i,j,6,1:64)=reshape(cund4,[1,64]);
        cund4=rot90(rot90(rot90(cund2)));%����270����ת
        DD(i,j,7,1:64)=reshape(cund4,[1,64]);
        cund4=cund2';%�������45�ȷ���
        DD(i,j,8,1:64)=reshape(cund4,[1,64]);
    end;
end;

h=waitbar(0,'��ʼ�ڶ��η���ѹ��');
pause(0.01);
for i=1:nry
    for j=1:nrx
        %��ֵ���8*8������ֵ�������г�һ�У��ŵ�cunr
        cunr=reshape(tu(1+8*(i-1):8+8*(i-1),1+8*(j-1):8+8*(j-1)),[1,64]);
        sumalpha=sum(cunr);   %cunrֵ����ֵ
        sumalpha2=norm(double(cunr))^2;%cunr�и�����ֵ��ƽ����������2������ƽ�������൱����ֵ������ÿ��Ԫ�ص�ƽ�������
        dx=1;%�⼸���������Ƿ��α���������������ǵĳ�ֵ�������ⶨ����¼l��ֵ
        dy=1;%��¼k��ֵ
        ut=1;%��¼m��ֵ
        minH=10^20;%��¼��С�ľ��������Rֵ
        minot=0;%����minot��¼���뵱ǰֵ����ܹ����ƥ��Ķ�������±任��������ȵ���
        minst=0;%����minst��¼���뵱ǰֵ����ܹ����ƥ��Ķ�������±任����ĶԱȶȵ���
        for k=1:ndy%����k��l��¼���뵱ǰֵ����ܹ����ƥ��Ķ����������
            for l=1:ndx%
                for m=1:8%����m��¼���뵱ǰֵ����ܹ����ƥ��Ķ�������8�ֻ������ε����
                    cund3(1:64)=DD(k,l,m,1:64);
                    sumbeta=sum(cund3);  % cund3��������ֵ
                    sumbeta2=norm(cund3)^2;%���������2�������൱�ڶ����������ÿ��Ԫ�ص�ƽ�������
                    % ����˷�������������double���;��󣬶�cunrԭʼ����Ϊuint8���;���
                    alphabeta=double(cunr)*cund3';
                    if (64*sumbeta2-sumbeta^2)~=0
                    st=(64*alphabeta-sumalpha*sumbeta)/(64*sumbeta2-sumbeta^2);%st���ǶԱȶȵ���ϵ��s
                    elseif (64*alphabeta-sumalpha*sumbeta)==0||st > 1 || st < -1
                        st=0;
                    else
                        st=10^20;
                    end;
                    ot=(sumalpha-st*sumbeta)/64;%ot��ʹ���ȵ���ϵ��
                    H=(sumalpha2+st*(st*sumbeta2-2*alphabeta+2*ot*sumbeta)+ot*(64*ot-2*sumalpha))/64;%�ڵ�ǰs��o�������µ�R
                    if H<minH%Ѱ���������ֵ�������ƥ�䣬����¼�����ƥ��Ĳ���ֵ
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
        waitbar((i*nrx + j)/(nry * nrx) * 100,h,['�ڶ��η���ѹ�������' num2str((i*nrx + j)/(nry *nrx) * 100) '%']);
    end;
end;
close(h);
RRR2=zeros(nry,nrx,6);
RRR2=RRR;

huifu=ones(yy,xx);    %�ָ�ԭͼ��

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


ca2 = mat2gray(huifu);
ca2=0.5*ca2;
subplot(2,2,4);
imshow(ca2);title('�ڶ���ѹ�����ͼ��');
disp('�ڶ���ѹ�����ͼ���С��');
whos('ca2')
hht=toc(hhstart);


disp(sprintf('\n ���ѹ����ʱ���ֵΪ��%6.3f\n',hht));
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
 psnrh1=10*log10((255*255)/mse); 
disp(sprintf('\n ��һ��ѹ����psnr��ֵΪ��%6.3f\n',psnrh1));


 mse=0;     %���ֵ�����psnr
 [x2,y2]=size(ca2);
 for i=1:x2
    for j=1:y2
        a=(c1(i,j)-ca2(i,j))^2; 
        mse=mse+a; 
    end  
 end 
 mse=mse/(m*n); 
 psnrh2=10*log10((255*255)/mse); 
disp(sprintf('\n �ڶ���ѹ����psnr��ֵΪ��%6.3f\n',psnrh2));

ratioh1=imratio(double_img,RRR1);
disp(sprintf('\n ��һ��ѹ����Ϊ��%6.3f\n',ratioh1));
ratioh2=imratio(double_img,RRR2);
disp(sprintf('\n �ڶ���ѹ����Ϊ��%6.3f\n',ratioh2));




