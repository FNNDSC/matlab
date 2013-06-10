function varargout = viewer3d_lightvector(varargin)
% VIEWER3D_LIGHTVECTOR M-file for viewer3d_lightvector.fig
%      VIEWER3D_LIGHTVECTOR, by itself, creates a new VIEWER3D_LIGHTVECTOR or raises the existing
%      singleton*.
%
%      H = VIEWER3D_LIGHTVECTOR returns the handle to a new VIEWER3D_LIGHTVECTOR or the handle to
%      the existing singleton*.
%
%      VIEWER3D_LIGHTVECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWER3D_LIGHTVECTOR.M with the given input arguments.
%
%      VIEWER3D_LIGHTVECTOR('Property','Value',...) creates a new VIEWER3D_LIGHTVECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewer3d_lightvector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewer3d_lightvector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewer3d_lightvector

% Last Modified by GUIDE v2.5 25-Feb-2009 14:27:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewer3d_lightvector_OpeningFcn, ...
                   'gui_OutputFcn',  @viewer3d_lightvector_OutputFcn, ...
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


% --- Executes just before viewer3d_lightvector is made visible.
function viewer3d_lightvector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewer3d_lightvector (see VARARGIN)

% Choose default command line output for viewer3d_lightvector
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes viewer3d_lightvector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = viewer3d_lightvector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_lightx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lightx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lightx as text
%        str2double(get(hObject,'String')) returns contents of edit_lightx as a double


% --- Executes during object creation, after setting all properties.
function edit_lightx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lightx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_lighty_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lighty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lighty as text
%        str2double(get(hObject,'String')) returns contents of edit_lighty as a double


% --- Executes during object creation, after setting all properties.
function edit_lighty_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lighty (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_lightz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_lightz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_lightz as text
%        str2double(get(hObject,'String')) returns contents of edit_lightz as a double


% --- Executes during object creation, after setting all properties.
function edit_lightz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_lightz (see GCBO)
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



