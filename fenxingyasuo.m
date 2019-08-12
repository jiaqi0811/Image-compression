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
imshow(s);title('ԭʼͼ��');
double_img = double(s);
disp('ѹ��ǰͼ��Ĵ�С:');
whos('double_img');


fbmstart=tic;
[DATA,map]=imread(S);%�����ɫͼ��
DATA=double(DATA);
size1=size(DATA);%��ȡdata��������
tu=DATA(1:size1(1),1:size1(2),1);%ȡ����ɫ��ά�������еĵ�һά����Ϊ�Ҷ�ͼ�����
xx=size1(2);%ͼ�������������
yy=size1(1);%ͼ��������������
fgstart=tic;
% ͼ���Ե���ز���
% ͼ��ĳ�������������һ����8��16�ı���������֮��ֱ�������nrx,nry,ndx,ndy��һ��������һ�ּ򵥵ķ�������ͼ���Ե����
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
cund3=zeros(1,64);% cund3�洢��������ֵ
cund33=zeros(1,64);% cund33�洢���ƥ���
cund4=zeros(8,8);%�任���cund2
cunr=zeros(1,64);%��ֵ���8*8������ֵ�������г�һ��
RRR=zeros(nry,nrx,6);% s,o,D(y),D(x),U

for i=1:ndy
    for j=1:ndx
            %ȡ������ͼ��ԭʼͼ����16*16�����ؾ���
            cund1=tu(1+16*(i-1):16+16*(i-1),1+16*(j-1):16+16*(j-1));
            for l=1:8
                for m=1:8
                    %����������ÿ�ٽ��ĸ����ص��ƽ��ֵ�����Խ�16*16�Ķ������ת����8*8�Ŀ�
                    cund2(l,m)=(cund1(1+2*(l-1),1+2*(m-1))+cund1(2+2*(l-1),2+2*(m-1))+cund1(2+2*(l-1),1+2*(m-1))+cund1(1+2*(l-1),2+2*(m-1)))/4;
                end;
            end;
        DD(i,j,1,1:64)=reshape(cund2,[1,64]);%��cund2��0����ת����cund2�����������г�һ��
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
fgt=toc(fgstart);

bmstart=tic;
h=waitbar(0,'��ʼ����ѹ��');
pause(0.01);
for i=1:nry%������ѭ����i��j����֤�˶���ÿ��ֵ��鶼�ҵ�����Ӧ�Ķ�����飬��������˸ö������
    for j=1:nrx%��һϵ�б任����
        %��ֵ���8*8������ֵ�������г�һ�У��ŵ�cunr
        cunr=reshape(tu(1+8*(i-1):8+8*(i-1),1+8*(j-1):8+8*(j-1)),[1,64]);
        sumalpha=sum(cunr);   %cunr�洢ֵ����ֵ
        sumalpha2=norm(double(cunr))^2;%cunr�и�����ֵ��ƽ����������2������ƽ�������൱����ֵ������ÿ��Ԫ�ص�ƽ�������
        dx=1;%�⼸���������Ƿ��α���������������ǵĳ�ֵ�������ⶨ����¼l��ֵ
        dy=1;%��¼k��ֵ
        ut=1;%��¼m��ֵ
        minH=10^20;%��¼��С�ľ��������Rֵ
        minot=0;%����minot��¼���뵱ǰֵ����ܹ����ƥ��Ķ�������±任��������ȵ���
        minst=0;%����minst��¼���뵱ǰֵ����ܹ����ƥ��Ķ�������±任����ĶԱȶȵ���
        for k=1:ndy%����k��l��¼���뵱ǰֵ����ܹ����ƥ��Ķ����������
            for l=1:ndx
                for m=1:8%����m��¼���뵱ǰֵ����ܹ����ƥ��Ķ�������8�ֻ������ε����
                    cund3(1:64)=DD(k,l,m,1:64);
                    sumbeta=sum(cund3);  % cund3�洢��������ֵ
                    sumbeta2=norm(cund3)^2;%���������2�������൱�ڶ����������ÿ��Ԫ�ص�ƽ�������
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
        waitbar((i*nrx + j)/(nry * nrx) * 100,h,['����ѹ�������' num2str((i*nrx + j)/(nry *nrx) * 100) '%']);
    end;
end;
bmt=toc(bmstart);
close(h);
fbmt=toc(fbmstart);

% ��������
outfp = fopen('����ͼ��ѹ��(����ֵ).txt','w');
h=waitbar(0,'��ʼ�����¼');
pause(0.01);
for i=1:nry
    for j=1:nrx
        fprintf(outfp,'sֵ��%8.5f oֵ��%8.5f yyֵ��%4.0f  xxֵ: %4.0f kֵ��%2.0f\n',...
        RRR(i,j,1),RRR(i,j,2),RRR(i,j,3),RRR(i,j,4),RRR(i,j,5));
        waitbar((i*nrx + j)/(nry *nrx) * 100,h,['�����¼�����' num2str((i*nrx + j)/(nry *nrx) * 100) '%']);
    end
end
close(h);
fclose(outfp);
disp('ѹ����ͼ��Ĵ�С:');
whos('RRR');

fjmstart=tic;
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
fjmt=toc(fjmstart);

subplot(1,2,1),imshow(s);title('ԭʼͼ��');
subplot(1,2,2),imshow(huifu);title('ѹ�����ͼ��');
figure('Name','����ѹ��');
imshow(huifu);title('����ѹ����ͼ��'); 

disp(sprintf('\n ����ѹ�������ʱ���ֵΪ��%6.3f\n',fbmt));
disp(sprintf('\n ����ѹ�������ʱ���ֵΪ��%6.3f\n',fjmt));
ratiof=imratio(double_img,RRR);
disp(sprintf('\n ѹ����Ϊ��%6.3f\n',ratiof));

  mse=0;     %���ֵ�����psnr
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
disp(sprintf('\n psnr��ֵΪ��%6.3f\n',psnrf));
disp(sprintf('\n ����ѹ���ָ�ͼ���ʱ���ֵΪ��%6.3f\n',fgt));
disp(sprintf('\n ����ѹ��������ƥ���ʱ���ֵΪ��%6.3f\n',bmt));


