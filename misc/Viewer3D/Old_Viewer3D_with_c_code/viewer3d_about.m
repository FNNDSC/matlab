function varargout = viewer3d_about(varargin)
% VIEWER3D_ABOUT M-file for viewer3d_about.fig
%      VIEWER3D_ABOUT, by itself, creates a new VIEWER3D_ABOUT or raises the existing
%      singleton*.
%
%      H = VIEWER3D_ABOUT returns the handle to a new VIEWER3D_ABOUT or the handle to
%      the existing singleton*.
%
%      VIEWER3D_ABOUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWER3D_ABOUT.M with the given input arguments.
%
%      VIEWER3D_ABOUT('Property','Value',...) creates a new VIEWER3D_ABOUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewer3d_about_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewer3d_about_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewer3d_about

% Last Modified by GUIDE v2.5 30-Oct-2008 19:58:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewer3d_about_OpeningFcn, ...
                   'gui_OutputFcn',  @viewer3d_about_OutputFcn, ...
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


% --- Executes just before viewer3d_about is made visible.
function viewer3d_about_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewer3d_about (see VARARGIN)

% Choose default command line output for viewer3d_about
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes viewer3d_about wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = viewer3d_about_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
