function varargout = look3d(varargin)
% LOOK3D MATLAB code for look3d.fig
%      LOOK3D, by itself, creates a new LOOK3D or raises the existing
%      singleton*.
%
%      H = LOOK3D returns the handle to a new LOOK3D or the handle to
%      the existing singleton*.
%
%      LOOK3D('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOOK3D.M with the given input arguments.
%
%      LOOK3D('Property','Value',...) creates a new LOOK3D or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before look3d_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to look3d_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% 
%      Three ways to run this code:
%
%      1. LOOK3D, without any arguments;
%
%      2. LOOK3D(filename), where filename is ended with .mhd or .mha;
%
%      3. LOOK3D(V), where V is a 3-D array with column->X, row->Y, and the
%      third dimension maps to Z.
%
% 
% See also: GUIDE, GUIDATA, GUIHANDLES

% This GUI program allows you to navigate through a 3-D image with three
% orthogonal views, and display the intensity value at any voxel location.
% You can see the intensity values by moving the mouse pointer over any of
% the three views, or you can navigate through the data using following two
% methods: 
% - Use the sliders to navigate in one of the three directions; 
% - Click a point in any view to see the three orthogonal slices at that point. 

% This tool is also useful if you want to visualize or check the
% values of the deformation fields after a deformable registration. If this
% is what you are looking for, be sure to save the deformation fields in
% three separate 3-D images in a MetaImage format. 

% At the moment only MetaImage formats (.mhd and .mha) are supported. 

% The code for reading MetaImage data is taken from ReadData3D by D. Kroon,
% University of Twente, July 2010. 

% 
% Release notes: 
% 
% v1: 2010-10-18, initial release. 
% 
% v2: 2010-10-19, fixed a bug in loading empty images that have an uniform
% background intensity; added two testing data (one sheep femur CT, and one
% 3-D control grid after a deformable registration). 
% 
% v3: 2010-10-20, now the GUI can be called with one argument, which is
% either a file name of a MetaImage format, or a 3-D array that represents
% a volume (note: the code assumes that the first dimension is X, the
% second dimension is Y, and the third dimension is Z).
% 

% This program is written by R. H. Gong, School of Computing, Queen's
% University, Kingston, Canada. Email: rhgong(at)gmail(dot)com. 2010-10-18.

% Last Modified by GUIDE v2.5 18-Oct-2010 07:23:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @look3d_OpeningFcn, ...
                   'gui_OutputFcn',  @look3d_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before look3d is made visible.
function look3d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to look3d (see VARARGIN)

axes(handles.mylogo);
imshow('logo.png');

axes(handles.cframex);
imshow('xview.png');

axes(handles.cframey);
imshow('yview.png');

axes(handles.cframez);
imshow('zview.png');

% add the application variable cfgname
cfgname = 'look3d.mat';
if exist(cfgname)==0
    DataPath='';
    save(cfgname, 'DataPath')
end
handles.cfgname = cfgname;

% add the application variable volume, and load the data if applicable
if isempty(varargin)
    % LOOK3D is called without arguments
    handles.volume = [];
elseif isstruct(varargin{1})
    % LOOK3D is called with a 3-D image (in the format of a struct)
    handles.volume = varargin{1};
elseif isnumeric(varargin{1})
    % LOOK3D is called with a 3-D image (in the format of a 3-D array)
    volume = struct('PixelDimensions', [1 1 1], 'Offset', [0 0 0]);
    volume.data = varargin{1};
    handles.volume = volume;
elseif ischar(varargin{1})
    % LOOK3D is called with a 3-D image (in the format of a file name)
    handles.volume = readImage(varargin{1});
else
    % LOOK3D is called with something useless
    handles.volume = [];
end

% Choose default command line output for look3d
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

actDataLoaded(hObject, eventdata, handles);

% UIWAIT makes look3d wait for user response (see UIRESUME)
% uiwait(handles.mainwin);


% --- Outputs from this function are returned to the command line.
function varargout = look3d_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnload.
function btnload_Callback(hObject, eventdata, handles)
% hObject    handle to btnload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load(handles.cfgname,'DataPath')
if ischar(DataPath)==0
    DataPath = '';
end
[FileName,PathName,FilterIndex] = uigetfile(...
    {...
        '*.mhd;*.mha','MetaImage Files (*.mhd,*.mha)'...
    },...
    'Select a file',...
    DataPath...
);
if isequal(FileName,0)
    return
end

DataPath = PathName;
save(handles.cfgname,'DataPath','-append')

handles.volume=readImage([PathName FileName]);

guidata(hObject,handles);

actDataLoaded(hObject, eventdata, handles);


function actDataLoaded(hObject, eventdata, handles)

volume = handles.volume;
if isempty(volume), return, end

% the min and max intensities of the entire volume
minval=min(min(min(volume.data)));
maxval=max(max(max(volume.data)));
if maxval<=minval
    maxval=minval+1; % fix a bug in order to load empty images
end
handles.valrange=[minval maxval];

dims=size(volume.data);
handles.cursor=int16(dims/2);

set(handles.xslider, 'Min', 1 );
set(handles.xslider, 'Max', dims(1));
set(handles.xslider, 'Value', handles.cursor(1) );
set(handles.xslider, 'SliderStep', [1/(dims(1)-1) 10/(dims(1)-1)]);
%
set(handles.xview, 'NextPlot','Replace');
colormap(handles.xview, bone);
xslice=reshape(volume.data(handles.cursor(1),:,:), dims(2), dims(3));
image([1 dims(2)], [1 dims(3)], xslice', 'CDataMapping', 'scaled', 'Parent', handles.xview);
set(handles.xview,'XTick',[]);
set(handles.xview,'YTick',[]);
set(handles.xview,'XAxisLocation','top');
set(handles.xview, 'CLim', handles.valrange);
%
axes(handles.xview);
hline = line('XData',get(handles.xview,'XLim'), 'YData',[handles.cursor(3) handles.cursor(3)], 'EraseMode','xor', 'Tag','HCursor');
vline = line('XData',[handles.cursor(2) handles.cursor(2)], 'YData',get(handles.xview,'YLim'), 'EraseMode','xor', 'Tag','VCursor');
%
set(handles.xlabel, 'String', ['X ' num2str(dims(1)) ' : ' num2str(handles.cursor(1))]);

set(handles.yslider, 'Min', 1 );
set(handles.yslider, 'Max', dims(2));
set(handles.yslider, 'Value', handles.cursor(2) );
set(handles.yslider, 'SliderStep', [1/(dims(2)-1) 10/(dims(2)-1)]);
%
set(handles.yview, 'NextPlot','Replace');
colormap(handles.yview, bone);
yslice=reshape(volume.data(:,handles.cursor(2),:), dims(1), dims(3));
image([1 dims(3)], [1 dims(1)], yslice, 'CDataMapping', 'scaled', 'Parent', handles.yview);
set(handles.yview,'XTick',[]);
set(handles.yview,'YTick',[]);
set(handles.yview,'XAxisLocation','top');
set(handles.yview, 'CLim', handles.valrange);
%
axes(handles.yview);
hline = line('XData',get(handles.yview,'XLim'), 'YData',[handles.cursor(1) handles.cursor(1)], 'EraseMode','xor', 'Tag','HCursor');
vline = line('XData',[handles.cursor(3) handles.cursor(3)], 'YData',get(handles.yview,'YLim'), 'EraseMode','xor', 'Tag','VCursor');
%
set(handles.ylabel, 'String', ['Y ' num2str(dims(2)) ' : ' num2str(handles.cursor(2))]);

set(handles.zslider, 'Min', 1 );
set(handles.zslider, 'Max', dims(3));
set(handles.zslider, 'Value', handles.cursor(3) );
set(handles.zslider, 'SliderStep', [1/(dims(3)-1) 10/(dims(3)-1)]);
%
set(handles.zview, 'NextPlot','Replace');
colormap(handles.zview, bone);
zslice=volume.data(:,:,handles.cursor(3));
image([1 dims(1)], [1 dims(2)], zslice', 'CDataMapping', 'scaled', 'Parent', handles.zview);
set(handles.zview,'XTick',[]);
set(handles.zview,'YTick',[]);
set(handles.zview,'XAxisLocation','top');
set(handles.zview, 'CLim', handles.valrange);
%
axes(handles.zview);
hline = line('XData',get(handles.zview,'XLim'), 'YData',[handles.cursor(2) handles.cursor(2)], 'EraseMode','xor', 'Tag','HCursor');
vline = line('XData',[handles.cursor(1) handles.cursor(1)], 'YData',get(handles.zview,'YLim'), 'EraseMode','xor', 'Tag','VCursor');
%
set(handles.zlabel, 'String', ['Z ' num2str(dims(3)) ' : ' num2str(handles.cursor(3))]);

set(handles.coords, 'String', num2str(handles.cursor));
set(handles.pixvalue, 'String', num2str(handles.volume.data(handles.cursor(1),handles.cursor(2),handles.cursor(3))));

guidata(hObject,handles)


% --- Executes on slider movement.
function xslider_Callback(hObject, eventdata, handles)
% hObject    handle to xslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if isempty(handles.volume), return, end

% set(handles.xview, 'NextPlot','Replace');
% colormap(handles.xview, bone);
dims=size(handles.volume.data);
handles.cursor(1)=int16(get(hObject, 'Value'));
xslice=reshape(handles.volume.data(handles.cursor(1),:,:), dims(2), dims(3));
% image([1 dims(2)], [1 dims(3)], xslice', 'CDataMapping', 'scaled', 'Parent', handles.xview);
% set(handles.xview,'XTick',[]);
% set(handles.xview,'YTick',[]);
% set(handles.xview, 'CLim', handles.valrange);
imghandle=findobj(handles.xview, 'Type','image');
set(imghandle, 'CData',xslice');

set(handles.xlabel, 'String', ['X ' num2str(dims(1)) ' : ' num2str(handles.cursor(1))]);

guidata(hObject,handles)

doCommonUpdate(handles,'x')


% --- Executes during object creation, after setting all properties.
function xslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function yslider_Callback(hObject, eventdata, handles)
% hObject    handle to yslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if isempty(handles.volume), return, end

% set(handles.yview, 'NextPlot','Replace');
% colormap(handles.yview, bone);
dims=size(handles.volume.data);
handles.cursor(2)=int16(get(hObject, 'Value'));
yslice=reshape(handles.volume.data(:,handles.cursor(2),:), dims(1), dims(3));
% image([1 dims(3)], [1 dims(1)], yslice, 'CDataMapping', 'scaled', 'Parent', handles.yview);
% set(handles.yview,'XTick',[]);
% set(handles.yview,'YTick',[]);
% set(handles.yview, 'CLim', handles.valrange);
imghandle=findobj(handles.yview, 'Type','image');
set(imghandle, 'CData',yslice);

set(handles.ylabel, 'String', ['Y ' num2str(dims(2)) ' : ' num2str(handles.cursor(2))]);

guidata(hObject,handles)

doCommonUpdate(handles,'y')


% --- Executes during object creation, after setting all properties.
function yslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function zslider_Callback(hObject, eventdata, handles)
% hObject    handle to zslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

if isempty(handles.volume), return, end

% set(handles.zview, 'NextPlot','Replace');
% colormap(handles.zview, bone);
dims=size(handles.volume.data);
handles.cursor(3)=int16(get(hObject, 'Value'));
zslice=handles.volume.data(:,:,handles.cursor(3));
% image([1 dims(1)], [1 dims(2)], zslice', 'CDataMapping', 'scaled', 'Parent', handles.zview);
% set(handles.zview,'XTick',[]);
% set(handles.zview,'YTick',[]);
% set(handles.zview, 'CLim', handles.valrange);
imghandle=findobj(handles.zview, 'Type','image');
set(imghandle, 'CData',zslice');

set(handles.zlabel, 'String', ['Z ' num2str(dims(3)) ' : ' num2str(handles.cursor(3))]);

guidata(hObject,handles)

doCommonUpdate(handles,'z')


% --- Executes during object creation, after setting all properties.
function zslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on mouse motion over figure - except title and menu.
function mainwin_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to mainwin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'volume')==0 || isempty(handles.volume) || isfield(handles,'cursor')==0
    return
end

dims=size(handles.volume.data);

cpx=get(handles.xview,'CurrentPoint');
x=int16(cpx(1,1));
y=int16(cpx(1,2));
if x>=1 && x<=dims(2) && y>=1 && y<=dims(3)
    cursor=[handles.cursor(1), x, y];
    set(handles.coords, 'String', num2str(cursor));
    set(handles.pixvalue, 'String', num2str(handles.volume.data(cursor(1),cursor(2),cursor(3))));
    return
end

cpy=get(handles.yview,'CurrentPoint');
x=int16(cpy(1,1));
y=int16(cpy(1,2));
if x>=1 && x<=dims(3) && y>=1 && y<=dims(1)
    cursor=[y, handles.cursor(2), x];
    set(handles.coords, 'String', num2str(cursor));
    set(handles.pixvalue, 'String', num2str(handles.volume.data(cursor(1),cursor(2),cursor(3))));
    return
end

cpz=get(handles.zview,'CurrentPoint');
x=int16(cpz(1,1));
y=int16(cpz(1,2));
if x>=1 && x<=dims(1) && y>=1 && y<=dims(2)
    cursor=[x, y, handles.cursor(3)];
    set(handles.coords, 'String', num2str(cursor));
    set(handles.pixvalue, 'String', num2str(handles.volume.data(cursor(1),cursor(2),cursor(3))));
    return
end

cursor=handles.cursor;
set(handles.coords, 'String', num2str(cursor));
set(handles.pixvalue, 'String', num2str(handles.volume.data(cursor(1),cursor(2),cursor(3))));


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function mainwin_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to mainwin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'volume')==0 || isempty(handles.volume) || isfield(handles,'cursor')==0
    return
end

dims=size(handles.volume.data);

cpx=get(handles.xview,'CurrentPoint');
x=int16(cpx(1,1));
y=int16(cpx(1,2));
if x>=1 && x<=dims(2) && y>=1 && y<=dims(3)
    handles.cursor=[handles.cursor(1), x, y];
    set(handles.yslider,'Value',x)
    set(handles.zslider,'Value',y)
    yslider_Callback(handles.yslider, eventdata, handles);
    zslider_Callback(handles.zslider, eventdata, handles);
    %doCommonUpdate(handles,' ')
    %guidata(hObject,handles)
    return
end

cpy=get(handles.yview,'CurrentPoint');
x=int16(cpy(1,1));
y=int16(cpy(1,2));
if x>=1 && x<=dims(3) && y>=1 && y<=dims(1)
    handles.cursor=[y, handles.cursor(2), x];
    set(handles.xslider,'Value',y)
    set(handles.zslider,'Value',x)
    xslider_Callback(handles.xslider, eventdata, handles);
    zslider_Callback(handles.zslider, eventdata, handles);
    %doCommonUpdate(handles,' ')
    %guidata(hObject,handles)
    return
end

cpz=get(handles.zview,'CurrentPoint');
x=int16(cpz(1,1));
y=int16(cpz(1,2));
if x>=1 && x<=dims(1) && y>=1 && y<=dims(2)
    handles.cursor=[x, y, handles.cursor(3)];
    set(handles.xslider,'Value',x)
    set(handles.yslider,'Value',y)
    xslider_Callback(handles.xslider, eventdata, handles);
    yslider_Callback(handles.yslider, eventdata, handles);
    %doCommonUpdate(handles,' ')
    %guidata(hObject,handles)
    return
end



function doCommonUpdate(handles,caller)

set(handles.coords, 'String', num2str(handles.cursor));
set(handles.pixvalue, 'String', num2str(handles.volume.data(handles.cursor(1),handles.cursor(2),handles.cursor(3))));

if caller ~= 'x'
hline = findobj(handles.xview, 'Type','line','Tag','HCursor');
vline = findobj(handles.xview, 'Type','line','Tag','VCursor');
set(hline, 'XData',get(handles.xview,'XLim'), 'YData',[handles.cursor(3) handles.cursor(3)]);
set(vline, 'XData',[handles.cursor(2) handles.cursor(2)], 'YData',get(handles.xview,'YLim'));
end

if caller ~= 'y'
hline = findobj(handles.yview, 'Type','line','Tag','HCursor');
vline = findobj(handles.yview, 'Type','line','Tag','VCursor');
set(hline, 'XData',get(handles.yview,'XLim'), 'YData',[handles.cursor(1) handles.cursor(1)]);
set(vline, 'XData',[handles.cursor(3) handles.cursor(3)], 'YData',get(handles.yview,'YLim'));
end

if caller ~= 'z'
hline = findobj(handles.zview, 'Type','line','Tag','HCursor');
vline = findobj(handles.zview, 'Type','line','Tag','VCursor');
set(hline, 'XData',get(handles.zview,'XLim'), 'YData',[handles.cursor(2) handles.cursor(2)]);
set(vline, 'XData',[handles.cursor(1) handles.cursor(1)], 'YData',get(handles.zview,'YLim'));
end


% --- Executes during object creation, after setting all properties.
function mylogo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mylogo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate mylogo


% --- Executes during object creation, after setting all properties.
function cframex_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cframex (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate cframex


% --- Executes during object creation, after setting all properties.
function cframey_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cframey (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate cframey


% --- Executes during object creation, after setting all properties.
function cframez_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cframez (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate cframez


function result=readImage(fname)
[spath,sname,sext] = fileparts(fname);
if strcmp(lower(sext),'.mhd') || strcmp(lower(sext),'.mha')
    result = mhd_read_image(fname);
else
    result = [];
end
