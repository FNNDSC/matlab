function varargout = viewer3d_histogram(varargin)
% This function is part of VIEWER3D
%
% color and alpha maps can be changed on the fly by dragging and creating
% new color/alpha markers with the left mouse button.
%
% Function is written by D.Kroon University of Twente (October 2008)

% Edit the above text to modify the response to help viewer3d_histogram

% Last Modified by GUIDE v2.5 10-Nov-2010 13:53:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewer3d_histogram_OpeningFcn, ...
                   'gui_OutputFcn',  @viewer3d_histogram_OutputFcn, ...
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


% --- Executes just before viewer3d_histogram is made visible.
function viewer3d_histogram_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewer3d_histogram (see VARARGIN)
% Choose default command line output for viewer3d_histogram
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

function figurehistogram_WindowButtonMotionFcn(hObject, eventdata, handles)

function varargout = viewer3d_histogram_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function popupmenu_colors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    set(hObject,'String',{'jet','hsv','hot','cool','spring','summer','autumn','winter','gray','bone','copper','pink'});
    set(hObject,'Value',3);
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_load_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu_colors.
function popupmenu_colors_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_colors contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_colors


% --- Executes on button press in pushbutton_update_view.
function pushbutton_update_view_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_update_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_auto_update.
function checkbox_auto_update_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_auto_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_auto_update
