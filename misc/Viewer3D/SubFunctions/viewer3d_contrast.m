function varargout = viewer3d_contrast(varargin)
% VIEWER3D_CONTRAST M-file for viewer3d_contrast.fig
%      VIEWER3D_CONTRAST, by itself, creates a new VIEWER3D_CONTRAST or raises the existing
%      singleton*.
%
%      H = VIEWER3D_CONTRAST returns the handle to a new VIEWER3D_CONTRAST or the handle to
%      the existing singleton*.
%
%      VIEWER3D_CONTRAST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWER3D_CONTRAST.M with the given input arguments.
%
%      VIEWER3D_CONTRAST('Property','Value',...) creates a new VIEWER3D_CONTRAST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewer3d_contrast_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewer3d_contrast_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewer3d_contrast

% Last Modified by GUIDE v2.5 25-Jan-2011 11:41:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewer3d_contrast_OpeningFcn, ...
                   'gui_OutputFcn',  @viewer3d_contrast_OutputFcn, ...
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


% --- Executes just before viewer3d_contrast is made visible.
function viewer3d_contrast_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewer3d_contrast (see VARARGIN)

% Choose default command line output for viewer3d_contrast
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes viewer3d_contrast wait for user response (see UIRESUME)
% uiwait(handles.figurecontrast);


% --- Outputs from this function are returned to the command line.
function varargout = viewer3d_contrast_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement.
function slider_window_level_Callback(hObject, eventdata, handles)
% hObject    handle to slider_window_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_window_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_window_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_window_width_Callback(hObject, eventdata, handles)
% hObject    handle to slider_window_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_window_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_window_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on mouse motion over figure - except title and menu.
function figurecontrast_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figurecontrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_window_level_Callback(hObject, eventdata, handles)
% hObject    handle to edit_window_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_window_level as text
%        str2double(get(hObject,'String')) returns contents of edit_window_level as a double


% --- Executes during object creation, after setting all properties.
function edit_window_level_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_window_level (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_window_width_Callback(hObject, eventdata, handles)
% hObject    handle to edit_window_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_window_width as text
%        str2double(get(hObject,'String')) returns contents of edit_window_width as a double


% --- Executes during object creation, after setting all properties.
function edit_window_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_window_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pushbutton_autocontrast.
function pushbutton_autocontrast_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_autocontrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on pushbutton_autocontrast and none of its controls.
function pushbutton_autocontrast_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton_autocontrast (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
