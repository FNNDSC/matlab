function varargout = viewer3d_voxelsize(varargin)
% VIEWER3D_VOXELSIZE M-file for viewer3d_voxelsize.fig
%      VIEWER3D_VOXELSIZE, by itself, creates a new VIEWER3D_VOXELSIZE or raises the existing
%      singleton*.
%
%      H = VIEWER3D_VOXELSIZE returns the handle to a new VIEWER3D_VOXELSIZE or the handle to
%      the existing singleton*.
%
%      VIEWER3D_VOXELSIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWER3D_VOXELSIZE.M with the given input arguments.
%
%      VIEWER3D_VOXELSIZE('Property','Value',...) creates a new VIEWER3D_VOXELSIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewer3d_voxelsize_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewer3d_voxelsize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewer3d_voxelsize

% Last Modified by GUIDE v2.5 10-Nov-2010 13:54:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewer3d_voxelsize_OpeningFcn, ...
                   'gui_OutputFcn',  @viewer3d_voxelsize_OutputFcn, ...
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


% --- Executes just before viewer3d_voxelsize is made visible.
function viewer3d_voxelsize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewer3d_voxelsize (see VARARGIN)

% Choose default command line output for viewer3d_voxelsize
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes viewer3d_voxelsize wait for user response (see UIRESUME)
% uiwait(handles.figurevoxelsize);


% --- Outputs from this function are returned to the command line.
function varargout = viewer3d_voxelsize_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_scax_Callback(hObject, eventdata, handles)
% hObject    handle to edit_scax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_scax as text
%        str2double(get(hObject,'String')) returns contents of edit_scax as a double


% --- Executes during object creation, after setting all properties.
function edit_scax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_scax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_scay_Callback(hObject, eventdata, handles)
% hObject    handle to edit_scay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_scay as text
%        str2double(get(hObject,'String')) returns contents of edit_scay as a double


% --- Executes during object creation, after setting all properties.
function edit_scay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_scay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_scaz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_scaz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_scaz as text
%        str2double(get(hObject,'String')) returns contents of edit_scaz as a double


% --- Executes during object creation, after setting all properties.
function edit_scaz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_scaz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_volx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_volx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_volx as text
%        str2double(get(hObject,'String')) returns contents of edit_volx as a double


% --- Executes during object creation, after setting all properties.
function edit_volx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_volx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_voly_Callback(hObject, eventdata, handles)
% hObject    handle to edit_voly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_voly as text
%        str2double(get(hObject,'String')) returns contents of edit_voly as a double


% --- Executes during object creation, after setting all properties.
function edit_voly_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_voly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_volz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_volz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_volz as text
%        str2double(get(hObject,'String')) returns contents of edit_volz as a double


% --- Executes during object creation, after setting all properties.
function edit_volz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_volz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_apply.
function button_apply_Callback(hObject, eventdata, handles)
% hObject    handle to button_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
