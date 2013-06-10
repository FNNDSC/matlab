function varargout = viewer3d_workspacevars(varargin)
% VIEWER3D_WORKSPACEVARS M-file for viewer3d_workspacevars.fig
%      VIEWER3D_WORKSPACEVARS, by itself, creates a new VIEWER3D_WORKSPACEVARS or raises the existing
%      singleton*.
%
%      H = VIEWER3D_WORKSPACEVARS returns the handle to a new VIEWER3D_WORKSPACEVARS or the handle to
%      the existing singleton*.
%
%      VIEWER3D_WORKSPACEVARS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWER3D_WORKSPACEVARS.M with the given input arguments.
%
%      VIEWER3D_WORKSPACEVARS('Property','Value',...) creates a new VIEWER3D_WORKSPACEVARS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewer3d_workspacevars_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewer3d_workspacevars_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewer3d_workspacevars

% Last Modified by GUIDE v2.5 10-Nov-2010 13:55:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewer3d_workspacevars_OpeningFcn, ...
                   'gui_OutputFcn',  @viewer3d_workspacevars_OutputFcn, ...
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


% --- Executes just before viewer3d_workspacevars is made visible.
function viewer3d_workspacevars_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewer3d_workspacevars (see VARARGIN)

% Choose default command line output for viewer3d_workspacevars
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes viewer3d_workspacevars wait for user response (see UIRESUME)
% uiwait(handles.figureworkspacevars);


% --- Outputs from this function are returned to the command line.
function varargout = viewer3d_workspacevars_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_vars.
function listbox_vars_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_vars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_vars contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_vars


% --- Executes during object creation, after setting all properties.
function listbox_vars_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_vars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_load.
function button_load_Callback(hObject, eventdata, handles)
% hObject    handle to button_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
