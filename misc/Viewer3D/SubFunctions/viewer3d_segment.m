function varargout = viewer3d_segment(varargin)
% VIEWER3D_SEGMENT MATLAB code for viewer3d_segment.fig
%      VIEWER3D_SEGMENT, by itself, creates a new VIEWER3D_SEGMENT or raises the existing
%      singleton*.
%
%      H = VIEWER3D_SEGMENT returns the handle to a new VIEWER3D_SEGMENT or the handle to
%      the existing singleton*.
%
%      VIEWER3D_SEGMENT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWER3D_SEGMENT.M with the given input arguments.
%
%      VIEWER3D_SEGMENT('Property','Value',...) creates a new VIEWER3D_SEGMENT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewer3d_segment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewer3d_segment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewer3d_segment

% Last Modified by GUIDE v2.5 25-Jan-2011 16:41:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewer3d_segment_OpeningFcn, ...
                   'gui_OutputFcn',  @viewer3d_segment_OutputFcn, ...
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


% --- Executes just before viewer3d_segment is made visible.
function viewer3d_segment_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewer3d_segment (see VARARGIN)

% Choose default command line output for viewer3d_segment
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes viewer3d_segment wait for user response (see UIRESUME)
% uiwait(handles.figure1);

data=getMyData(); if(isempty(data)), return, end

Options=struct('Verbose',false,'nPoints',100,'Wline',0.04,'Wedge',2,'Wterm',0.01,'Sigma1',1,'Sigma2',1,'Alpha',0.2,'Beta',0.2,'Delta',0.1,'Gamma',1,'Kappa',2,'Iterations',100,'GIterations',0,'Mu',0.2,'Sigma3',1);

% Initalize Snake Parameters
n=structfind(data.substorage,'name','viewer3d_segment');
if(isempty(n))
   n=length(data.substorage)+1;
   data.substorage(n).name='viewer3d_segment';
   data.substorage(n).data.Options=Options;
end
setMyData(data);

fn=fields(data.substorage(n).data.Options);
set(handles.listbox2,'String',fn);
listbox2_Callback(hObject, eventdata, handles);



% --- Outputs from this function are returned to the command line.
function varargout = viewer3d_segment_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end


% ID's to volume struct location
dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));
id=data.subwindow(data.axes_select).volume_id_select;
editable=false(1,length(id));
dv2=zeros(1,length(id));
for i=1:length(id)    
    dv2(i)=structfind(data.volumes,'id',id(i));
    editable(i)=data.volumes(dv2(i)).Editable;
end
[editable,i]=sort(editable);
dv2=dv2(i);
dvs2=dv2(1);

n=structfind(data.volumes(dvs).MeasureList,'type','s');
if(isempty(n)), return; end
n=n(end);
vm=data.volumes(dvs).MeasureList(n);
SliceSelected=data.subwindow(data.axes_select).SliceSelected(uint8(data.subwindow(data.axes_select).render_type(6))-119);
switch(vm.RenderSelected)
    case {'x'}
        I=data.volumes(dvs2).volume_original(SliceSelected,:,:);
        y=vm.z; x=vm.y;
    case {'y'}
        I=data.volumes(dvs2).volume_original(:,SliceSelected,:);
        y=vm.z; x=vm.x;
    case {'z'}
        I=data.volumes(dvs2).volume_original(:,:,SliceSelected);
        y=vm.y; x=vm.x;
end

I=double(I);
I=I-min(I(:));
I=I./max(I(:));


% Make an array with the clicked coordinates
P=[x(:) y(:)];
    
% Start Snake Process
n=structfind(data.substorage,'name','viewer3d_segment');
Options=data.substorage(n).data.Options;

O=Snake2D(I,P,Options);
figure(data.handles.figure1);
x=O(:,1); y=O(:,2);
[x,y]=interpcontour(x,y,zeros(size(x)),2);
switch(vm.RenderSelected)
    case {'x'}
        vm.z=y; vm.y=x;
    case {'y'}
        vm.z=y; vm.x=x;
    case {'z'}
        vm.y=y; vm.x=x;
end
data.volumes(dvs).MeasureList(n)=vm;
setMyData(data);

viewer3d('show3d_Callback',gcf,[false false],guidata(gcf));


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end

% ID's to volume struct location
dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));
id=data.subwindow(data.axes_select).volume_id_select;
editable=false(1,length(id));
dv2=zeros(1,length(id));
for i=1:length(id)    
    dv2(i)=structfind(data.volumes,'id',id(i));
    editable(i)=data.volumes(dv2(i)).Editable;
end
[editable,i]=sort(editable);
dv2=dv2(i);
dvs2=dv2(end);

n=structfind(data.volumes(dvs).MeasureList,'type','s');
if(isempty(n)), return; end
n=n(end);
x=data.volumes(dvs).MeasureList(n).x;
y=data.volumes(dvs).MeasureList(n).y;
z=data.volumes(dvs).MeasureList(n).z;
S=data.subwindow(data.axes_select).SliceSelected;
switch (data.volumes(dvs).MeasureList(n).RenderSelected)
case {'x'}
    J=squeeze(data.volumes(dvs2).volume_original(S(1),:,:,:));
    J=bitmapplot(y,z,J,struct('FillColor',[1 1 1 1],'Color',[1 1 1 1]))>0;
    data.volumes(dvs2).volume_original(S(1),:,:,:)=J;
case {'y'}
    J=squeeze(data.volumes(dvs2).volume_original(:,S(2),:,:));
    J=bitmapplot(x,z,J,struct('FillColor',[1 1 1 1],'Color',[1 1 1 1]))>0;
    data.volumes(dvs2).volume_original(:,S(2),:,:)=J;
case {'z'}
    J=squeeze(data.volumes(dvs2).volume_original(:,:,S(3),:));
    J=bitmapplot(x,y,J,struct('FillColor',[1 1 1 1],'Color',[1 1 1 1]))>0;
    data.volumes(dvs2).volume_original(:,:,S(3),:)=J;
end
setMyData(data);
viewer3d('UpdatedVolume_Callback',gcf,dvs2,guidata(gcf));
    

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
data=getMyData(); if(isempty(data)), return, end
n=structfind(data.substorage,'name','viewer3d_segment');
fn=fields(data.substorage(n).data.Options);
sel=get(handles.listbox2,'Value');
val=data.substorage(n).data.Options.(fn{sel});
set(handles.edit1,'String',num2str(val));


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
data=getMyData(); if(isempty(data)), return, end
n=structfind(data.substorage,'name','viewer3d_segment');
fn=fields(data.substorage(n).data.Options);
sel=get(handles.listbox2,'Value');
data.substorage(n).data.Options.(fn{sel})=str2double(get(handles.edit1,'String'));
setMyData(data);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on edit1 and none of its controls.
function edit1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.mouse.button='select_roi';
data.mouse.action='segment_roi';
setMyData(data);


