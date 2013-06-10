function varargout = viewer3d_dicominfo(varargin)
% VIEWER3D_DICOMINFO M-file for viewer3d_dicominfo.fig
%      VIEWER3D_DICOMINFO, by itself, creates a new VIEWER3D_DICOMINFO or raises the existing
%      singleton*.
%
%      H = VIEWER3D_DICOMINFO returns the handle to a new VIEWER3D_DICOMINFO or the handle to
%      the existing singleton*.
%
%      VIEWER3D_DICOMINFO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWER3D_DICOMINFO.M with the given input arguments.
%
%      VIEWER3D_DICOMINFO('Property','Value',...) creates a new VIEWER3D_DICOMINFO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewer3d_dicominfo_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewer3d_dicominfo_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help viewer3d_dicominfo

% Last Modified by GUIDE v2.5 10-Nov-2010 13:56:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewer3d_dicominfo_OpeningFcn, ...
                   'gui_OutputFcn',  @viewer3d_dicominfo_OutputFcn, ...
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


% --- Executes just before viewer3d_dicominfo is made visible.
function viewer3d_dicominfo_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewer3d_dicominfo (see VARARGIN)

% Choose default command line output for viewer3d_dicominfo
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes viewer3d_dicominfo wait for user response (see UIRESUME)
% uiwait(handles.figuredicominfo);

info=varargin{1};
if(isempty(info)), return; end
infocell=cell(100000,2);
[infocell,poscell]=showinfo(info,infocell,0,'');
infocell(poscell+1:end,:)=[];
set(handles.uitable1,'Data',infocell)


function [infocell,poscell] = showinfo(info,infocell,poscell,s)
fnames=fieldnames(info);
for i=1:length(fnames)
    type=fnames{i};
    data=info.(type);
    if(isnumeric(data))
        poscell=poscell+1;
        infocell{poscell,1}=[s type];
        infocell{poscell,2}=num2str(data(:)');
    elseif(ischar(data))
        poscell=poscell+1;
        infocell{poscell,1}=[s type];
        infocell{poscell,2}=data;
    elseif(iscell(data))
    elseif(isstruct(data))
        [infocell,poscell]=showinfo(data,infocell,poscell,[type '.']);
    end
end



% --- Outputs from this function are returned to the command line.
function varargout = viewer3d_dicominfo_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
