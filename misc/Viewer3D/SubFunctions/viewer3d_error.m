function varargout = viewer3d_error(varargin)
% VIEWER3D_ERROR M-file for viewer3d_error.fig
%      VIEWER3D_ERROR, by itself, creates a new VIEWER3D_ERROR or raises the existing
%      singleton*.
%
%      H = VIEWER3D_ERROR returns the handle to a new VIEWER3D_ERROR or the handle to
%      the existing singleton*.
%
%      VIEWER3D_ERROR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWER3D_ERROR.M with the given input arguments.
%
%      VIEWER3D_ERROR('Property','Value',...) creates a new VIEWER3D_ERROR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewer3d_error_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewer3d_error_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewer3d_error

% Last Modified by GUIDE v2.5 05-Nov-2008 14:39:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewer3d_error_OpeningFcn, ...
                   'gui_OutputFcn',  @viewer3d_error_OutputFcn, ...
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


% --- Executes just before viewer3d_error is made visible.
function viewer3d_error_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewer3d_error (see VARARGIN)

% Choose default command line output for viewer3d_error
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
if (~isempty(varargin)) 
    set(handles.text1,'string',varargin{1})
end

% UIWAIT makes viewer3d_error wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = viewer3d_error_OutputFcn(hObject, eventdata, handles) 
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
delete(handles.figure1);

