function varargout = tuxiangyasuo(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tuxiangyasuo_OpeningFcn, ...
                   'gui_OutputFcn',  @tuxiangyasuo_OutputFcn, ...
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
function tuxiangyasuo_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

guidata(hObject, handles);
function varargout = tuxiangyasuo_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
% --------------------------------------------------------------------
function open_Callback(hObject, eventdata, handles)

[filename,pathname]=uigetfile({'*.jpg';'*.bmp';'*.tif';'*.*'},'����ͼ��');
if (isequal(filename,0)|isequal(pathname,0))
    errordlg('û��ѡ���ļ�','����ͼƬʧ��');
    return;
else
file=[pathname,filename];
   global S;
    S=file;
    x=imread(file);
    set(handles.axes1,'HandleVisibility','ON');
    axes(handles.axes1);
    s=rgb2gray(x);
    imshow(s);
    set(handles.axes1,'HandleVisibility','OFF');
    handles.img=s;
    guidata(hObject,handles);
end

% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
close();
% --------------------------------------------------------------------
function xiaobo_Callback(hObject, eventdata, handles)
figure(xiaoboyasuo);
function fenxing_Callback(hObject, eventdata, handles)
figure(fenxingyasuo);
function hunhe_Callback(hObject, eventdata, handles)
figure(hunheyasuo);
function DCT_Callback(hObject, eventdata, handles)
figure(DCT);
% --------------------------------------------------------------------
function contrast_Callback(hObject, eventdata, handles)
global DCTbmt;
global DCTjmt;
global ratioD;
global psnrD;

global fbmt;
global fjmt;
global ratiof;
global psnrf;

global hht;
global psnrh1;
global psnrh2;
global ratioh1;
global ratioh2;

global xbt;
global psnrx1;
global psnrx2;
global ratiox1;
global ratiox2;

f=figure('Name','�������');
data1=[DCTbmt, DCTjmt,DCTbmt+DCTjmt, ratioD, psnrD ;fbmt ,fjmt, fbmt+fjmt,ratiof, psnrf];
c1names = {'����ʱ��/s', '����ʱ��/s','����ʱ/s', 'ѹ����','��ֵ�����psnr/dB'};
r1names={'DCTѹ��' ,'����ѹ��'};
t1 = uitable('Parent',f,'Data',data1,'ColumnName',c1names,... 
            'RowName',r1names,'Position',[10 300 550 80]);
        
data2=[xbt,psnrx1, psnrx2, ratiox1, ratiox2 ;hht,psnrh1 ,psnrh2, ratioh1, ratioh2];
c2names = {'����ʱ/s','��һ��ѹ����psnr/dB', '�ڶ���ѹ����psnr/dB', '��һ��ѹ����','�ڶ���ѹ����'};
r2names={'С��ѹ��' ,'���ѹ��'};
t2 = uitable('Parent',f,'Data',data2,'ColumnName',c2names,... 
            'RowName',r2names,'Position',[10 150 550 90]);