function varargout = viewer3d(varargin)
% VIEWER3D a Matlab 3D volume renderer using the fast shearwarp algorithm.
%
% VIEWER3D(V, RENDERTYPE, SCALES);
%
% inputs,
% V : 3D Input image volume, of type double, single, uint8, uint16 or
% uint32 
%            (the render process uses only double calculations)
% RENDERTYPE: 'MIP' Maximum Intensity Render (default)
%             'VR' Volume Rendering
%             'VRC' Volume Rendering Color
%             'VRS' Volume Rendering with Shading
% SCALES: The sizes(height, width, depth) of one voxel. (default [1 1 1])
%
% Volume Data, 
%  Range of V must be [0 1] in case of double or single. Volume Data of 
%  type double has shorter render times than data of uint8 or uint16.
%
% example,
%   % Load data
%   load TestVolume;
%   viewer3d(V);
%
% See also: render_mip, render_bw, render_color, render_shaded
%
% Function is written by D.Kroon University of Twente (November 2008)

% Edit the above text to modify the response to help viewer3d

% Last Modified by GUIDE v2.5 04-Nov-2008 14:16:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewer3d_OpeningFcn, ...
                   'gui_OutputFcn',  @viewer3d_OutputFcn, ...
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


% --- Executes just before viewer3d is made visible.
function viewer3d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to viewer3d (see VARARGIN)

% Choose default command line output for viewer3d
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%matlabpool(3);

% addpath mexcode and help
try
    functionname='viewer3d.m';
    functiondir=which(functionname);
    functiondir=functiondir(1:end-length(functionname));
    addpath([functiondir '/help'])
catch end
% Initialized data storage structure
data.mouse_pressed=false;
data.mouse_button='';

% Get input voxel volume and convert to double
if (isempty(varargin)), 
    data.volume=zeros(3,3,3);
    data.volume_preview=zeros(3,3,3);
else
    if(ndims(varargin{1})==3)
        data.volume=varargin{1};
        switch(class(data.volume))
            case {'uint8','uint16'}
            case 'single'
                data.volume(data.volume<0)=0; data.volume(data.volume>1)=1;
            case 'double'
                data.volume(data.volume<0)=0; data.volume(data.volume>1)=1;
            otherwise
                warning('viewer3d:inputs', 'Unsupported input datatype converted to double');
                data.volume=im2double(data.volume);
                data.volume(data.volume<0)=0; data.volume(data.volume>1)=1;
        end
        data.volume_preview=imresize3d(data.volume,[],[32 32 32],'linear');
    else
        error('viewer3d:inputs', 'Input image not 3 dimensional');
    end
end

% Get input render type
if(length(varargin)>1)
    switch lower(varargin{2})
    case 'mip'
        data.render_type='mip';
    case 'vr'
        data.render_type='vr';
    case 'vrc'
        data.render_type='vrc';
    case 'vrs'
        data.render_type='vrs';
    otherwise
        error('viewer3d:inputs', 'Render type unknown');
    end
else
    data.render_type='mip';
end

% Get input voxelvolume scaling
if(length(varargin)>2)
    Scales=varargin{3}; Scales=sqrt(3)*Scales./sqrt(sum(Scales.^2));
    data.viewer_matrix=[Scales(1) 0 0 0; 0 Scales(2) 0 0; 0 0 Scales(3) 0; 0 0 0 1];
else
    data.viewer_matrix=[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
end

data.handle_viewer3d=gcf;
data.handle_histogram=[];
data.histogram_positions = [0.2 0.4 0.6 0.9]; 
data.histogram_alpha = [0 0.5 0.35 1]; 
data.histogram_colors= [0 0 0; 1 0 0; 1 1 0; 1 1 1];
data.first_render=true;
data.axes_size=[400 400];
data.histogram_pointselected=[];
data.mouse_position_pressed=[0 0];
data.mouse_position=[0 0];
data.mouse_position_last=[0 0];
data.shading_material='shiny';
data=loadmousepointershapes(data);
data.handles=handles;
setMyData(data);
createAlphaColorTable();
% Show the data
show3d(false)

% UIWAIT makes viewer3d wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function createAlphaColorTable()
% This function creates a Matlab colormap and alphamap from the markers
data=getMyData(); if(isempty(data)), return, end
    data.colortable=zeros(1000,3); 
    data.alphatable=zeros(1000,1);
    % Loop through all 256 color/alpha indexes
    for j=0:999
        i=j/999;
        if (i<data.histogram_positions(1)), alpha=0; color=data.histogram_colors(1,:);
        elseif(i>data.histogram_positions(end)), alpha=0; color=data.histogram_colors(end,:);
        elseif(i==data.histogram_positions(1)), alpha=data.histogram_alpha(1); color=data.histogram_colors(1,:);
        elseif(i==data.histogram_positions(end)), alpha=data.histogram_alpha(end); color=data.histogram_colors(end,:);
        else
            % Linear interpolate the color and alpha between markers
            index_down=find(data.histogram_positions<=i); index_down=index_down(end);
            index_up=find(data.histogram_positions>i); index_up=index_up(1);
            perc=(i-data.histogram_positions(index_down)) / (data.histogram_positions(index_up) - data.histogram_positions(index_down));
            color=(1-perc)*data.histogram_colors(index_down,:)+perc*data.histogram_colors(index_up,:);
            alpha=(1-perc)*data.histogram_alpha(index_down)+perc*data.histogram_alpha(index_up);
        end
        data.colortable(j+1,:)=color;
        data.alphatable(j+1)=alpha;
    end
setMyData(data);


function data=loadmousepointershapes(data)
I=1-(imread('icon_mouse_rotate1.png')>0); I(I==0)=NaN;
data.icon_mouse_rotate1=I;
I=1-(imread('icon_mouse_rotate2.png')>0); I(I==0)=NaN;
data.icon_mouse_rotate2=I;
I=1-(imread('icon_mouse_zoom.png')>0); I(I==0)=NaN;
data.icon_mouse_zoom=I;
I=1-(imread('icon_mouse_pan.png')>0); I(I==0)=NaN;
data.icon_mouse_pan=I;


function show3d(preview)
data=getMyData(); if(isempty(data)), return, end

% Calculate light and viewer vectors
data.ViewerVector = [0 0 1];
data.LightVector = [0.67 0.33 0.67];
    
if(preview)
    viewer_matrix=data.viewer_matrix*ResizeMatrix(size(data.volume_preview)./size(data.volume));
   
    switch data.render_type
    case 'mip'
        data.render_image = render_mip(data.volume_preview, data.axes_size(1:2), viewer_matrix);
    case 'vr'
        data.render_image = render_bw(data.volume_preview, data.axes_size(1:2), viewer_matrix, data.alphatable);
    case 'vrc'
        data.render_image = render_color(data.volume_preview, data.axes_size(1:2), viewer_matrix, data.alphatable, data.colortable);
    case 'vrs'
        data.render_image = render_shaded(data.volume_preview, data.axes_size(1:2), viewer_matrix, data.alphatable, data.colortable, data.LightVector, data.ViewerVector,data.shading_material);
    end
else
    set_mouse_shape('watch',data); pause(0.001);
    switch data.render_type
    case 'mip'
        data.render_image = render_mip(data.volume, data.axes_size(1:2), data.viewer_matrix);
    case 'vr'
        data.render_image = render_bw(data.volume, data.axes_size(1:2), data.viewer_matrix, data.alphatable);
    case 'vrc'
        data.render_image = render_color(data.volume, data.axes_size(1:2), data.viewer_matrix, data.alphatable, data.colortable);
    case 'vrs'
        data.render_image = render_shaded(data.volume, data.axes_size(1:2), data.viewer_matrix, data.alphatable, data.colortable, data.LightVector, data.ViewerVector,data.shading_material);
    end
    set_mouse_shape('arrow',data); pause(0.001);
end

if(data.first_render)
    data.imshow_handle=imshow(data.render_image); 
    data.first_render=false;
else
    set(data.imshow_handle,'Cdata',data.render_image);
end
data.axes_size=get(data.handles.axes3d,'PlotBoxAspectRatio');
set(get(data.handles.axes3d,'Children'),'ButtonDownFcn','viewer3d(''axes3d_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
setMyData(data);


% --- Outputs from this function are returned to the command line.
function varargout = viewer3d_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cursor_position_in_axes(hObject,handles);
data=getMyData(); if(isempty(data)), return, end
if(isempty(data)), return, end;
if(data.mouse_pressed)
    switch(data.mouse_button)
    case 'rotate1'
        r1=-360*(data.mouse_position_last(1)-data.mouse_position(1));
        r2=360*(data.mouse_position_last(2)-data.mouse_position(2));
        R=RotationMatrix([r1 r2 0]);
        data.viewer_matrix=R*data.viewer_matrix;
        setMyData(data);
        show3d(true)
    case 'rotate2'
        r1=100*(data.mouse_position_last(1)-data.mouse_position(1));
        r2=100*(data.mouse_position_last(2)-data.mouse_position(2));
        if(data.mouse_position(2)>0.5), r1=-r1; end
        if(data.mouse_position(1)<0.5), r2=-r2; end
        r3=r1+r2;
        R=RotationMatrix([0 0 r3]);
        data.viewer_matrix=R*data.viewer_matrix;
        setMyData(data);
        show3d(true)
    case 'pan'
        t2=200*(data.mouse_position_last(1)-data.mouse_position(1));
        t1=200*(data.mouse_position_last(2)-data.mouse_position(2));
        M=TranslateMatrix([t1 t2 0]);
        data.viewer_matrix=M*data.viewer_matrix;
        setMyData(data);
        show3d(true)      
    case 'zoom'
        z1=1+2*(data.mouse_position_last(1)-data.mouse_position(1));
        z2=1+2*(data.mouse_position_last(2)-data.mouse_position(2));
        z=0.5*(z1+z2); %sqrt(z1.^2+z2.^2);
        R=ResizeMatrix([z z z]); 
        data.viewer_matrix=R*data.viewer_matrix;
        setMyData(data);
        show3d(true)        
    otherwise
    end
end

function R=RotationMatrix(r)
% Determine the rotation matrix (View matrix) for rotation angles xyz ...
    Rx=[1 0 0 0; 0 cosd(r(1)) -sind(r(1)) 0; 0 sind(r(1)) cosd(r(1)) 0; 0 0 0 1];
    Ry=[cosd(r(2)) 0 sind(r(2)) 0; 0 1 0 0; -sind(r(2)) 0 cosd(r(2)) 0; 0 0 0 1];
    Rz=[cosd(r(3)) -sind(r(3)) 0 0; sind(r(3)) cosd(r(3)) 0 0; 0 0 1 0; 0 0 0 1];
    R=Rx*Ry*Rz;
    
function M=ResizeMatrix(s)
	M=[1/s(1) 0 0 0;
	   0 1/s(2) 0 0;
	   0 0 1/s(3) 0;
	   0 0 0 1];

function M=TranslateMatrix(t)
	M=[1 0 0 -t(1);
	   0 1 0 -t(2);
	   0 0 1 -t(3);
	   0 0 0 1];
 
function cursor_position_in_axes(hObject,handles)
data=getMyData(); 
if(isempty(data)), return, end;
data.mouse_position_last=data.mouse_position;
% Get position of the mouse in the large axes
p = get(0, 'PointerLocation');
pf = get(hObject, 'pos');
p(1:2) = p(1:2)-pf(1:2);
set(gcf, 'CurrentPoint', p(1:2));
p = get(handles.axes3d, 'CurrentPoint');
data.mouse_position=[p(1, 1) p(1, 2)]./data.axes_size(1:2);
setMyData(data);

function setMyData(data)
% Store data struct in figure
setappdata(gcf,'data3d',data);

function data=getMyData()
% Get data struct stored in figure
data=getappdata(gcf,'data3d');

% --- Executes on mouse press over axes background.
function axes3d_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes3d (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.mouse_pressed=true;
data.mouse_button=get(handles.figure1,'SelectionType');
if(strcmp(data.mouse_button,'normal'))
    if(sum((data.mouse_position-[0.5 0.5]).^2)<0.15)
        data.mouse_button='rotate1';
        set_mouse_shape('rotate1',data)
    else
        data.mouse_button='rotate2';
        set_mouse_shape('rotate2',data)
    end
end
if(strcmp(data.mouse_button,'extend'))
    data.mouse_button='pan';
    set_mouse_shape('pan',data)
end
if(strcmp(data.mouse_button,'alt'))
    data.mouse_button='zoom';
    set_mouse_shape('zoom',data)
end
data.mouse_position_pressed=data.mouse_position;
setMyData(data);

function set_mouse_shape(type,data)

switch(type)
case 'rotate1'
    set(gcf,'Pointer','custom','PointerShapeCData',data.icon_mouse_rotate1,'PointerShapeHotSpot',round(size(data.icon_mouse_rotate1)/2))
    set(data.handles.figure1,'Pointer','custom');
case 'rotate2'
    set(gcf,'Pointer','custom','PointerShapeCData',data.icon_mouse_rotate2,'PointerShapeHotSpot',round(size(data.icon_mouse_rotate2)/2))
    set(data.handles.figure1,'Pointer','custom');
case 'zoom'
    set(gcf,'Pointer','custom','PointerShapeCData',data.icon_mouse_zoom,'PointerShapeHotSpot',round(size(data.icon_mouse_zoom)/2))
    set(data.handles.figure1,'Pointer','custom');
case 'pan'
    set(gcf,'Pointer','custom','PointerShapeCData',data.icon_mouse_pan,'PointerShapeHotSpot',round(size(data.icon_mouse_pan)/2))
    set(data.handles.figure1,'Pointer','custom');
otherwise
    set(data.handles.figure1,'Pointer',type);
end
    



% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.mouse_pressed=false;
setMyData(data);
show3d(false)
set(handles.figure1,'Pointer','arrow');


function A=imresize3d(V,scale,tsize,ntype,npad)
% This function resizes a 3D image volume to new dimensions
% Vnew = imresize3d(V,scale,nsize,ntype,npad);
%
% inputs,
%   V: The input image volume
%   scale: scaling factor, when used set tsize to [];
%   nsize: new dimensions, when used set scale to [];
%   ntype: Type of interpolation ('nearest', 'linear', or 'cubic')
%   npad: Boundary condition ('replicate', 'symmetric', 'circular', 'fill', or 'bound')  
%
% outputs,
%   Vnew: The resized image volume
%
% example,
%   load('mri','D'); D=squeeze(D);
%   Dnew = imresize3d(D,[],[80 80 40],'nearest','bound');
%
% This function is written by D.Kroon University of Twente (July 2008)
% Check the inputs
if(exist('ntype', 'var') == 0), ntype='nearest'; end
if(exist('npad', 'var') == 0), npad='bound'; end
if(exist('scale', 'var')&&~isempty(scale)), tsize=round(size(V)*scale); end
if(exist('tsize', 'var')&&~isempty(tsize)),  scale=(tsize./size(V)); end

% Make transformation structure   
T = makehgtform('scale',scale);
tform = maketform('affine', T);

% Specify resampler
R = makeresampler(ntype, npad);

% Resize the image volueme
A = tformarray(V, tform, R, [1 2 3], [1 2 3], tsize, [], 0);


function [Mshear,Mwarp2D,c]=matrixshearwarp(Mview,sizes)

% Find the principal viewing axis
Vo=[Mview(1,2)*Mview(2,3) - Mview(2,2)*Mview(1,3);
    Mview(2,1)*Mview(1,3) - Mview(1,1)*Mview(2,3);
    Mview(1,1)*Mview(2,2) - Mview(2,1)*Mview(1,2)];

[maxv,c]=max(abs(Vo));

% Choose the corresponding Permutation matrix P
switch(c)
    case 1, %yzx
        P=[0 1 0 0;
           0 0 1 0;
           1 0 0 0;
           0 0 0 1;];
    case 2, % zxy
        P=[0 0 1 0;
           1 0 0 0;
           0 1 0 0;
           0 0 0 1;];
    case 3, % xyz
        P=[1 0 0 0;
           0 1 0 0;
           0 0 1 0;
           0 0 0 1;];
end

% Compute the permuted view matrix from Mview and P
Mview_p=Mview*inv(P);

% 180 degrees rotate detection
if(Mview_p(3,3)<0), c=c+3; end

% Compute the shear coeficients from the permuted view matrix
Si = (Mview_p(2,2)* Mview_p(1,3) - Mview_p(1,2)* Mview_p(2,3)) / (Mview_p(1,1)* Mview_p(2,2) - Mview_p(2,1)* Mview_p(1,2));
Sj = (Mview_p(1,1)* Mview_p(2,3) - Mview_p(2,1)* Mview_p(1,3)) / (Mview_p(1,1)* Mview_p(2,2) - Mview_p(2,1)* Mview_p(1,2));

% Compute the translation between the orgins of standard object coordinates
% and intermdiate image coordinates

if((c==1)||(c==4)), kmax=sizes(1)-1; end
if((c==2)||(c==5)), kmax=sizes(2)-1; end
if((c==3)||(c==6)), kmax=sizes(3)-1; end

if ((Si>=0)&&(Sj>=0)), Ti = 0;        Tj = 0;        end
if ((Si>=0)&&(Sj<0)),  Ti = 0;        Tj = -Sj*kmax; end
if ((Si<0)&&(Sj>=0)),  Ti = -Si*kmax; Tj = 0;        end
if ((Si<0)&&(Sj<0)),   Ti = -Si*kmax; Tj = -Sj*kmax; end

% Compute the shear matrix 
Mshear=[1  0 Si Ti;
        0  1 Sj Tj;
        0  0  1  0;
        0  0  0  1];
        
% Compute the 2Dwarp matrix
Mwarp2D=[Mview_p(1,1) Mview_p(1,2) (Mview_p(1,4)-Ti*Mview_p(1,1)-Tj*Mview_p(1,2)); 
         Mview_p(2,1) Mview_p(2,2) (Mview_p(2,4)-Ti*Mview_p(2,1)-Tj*Mview_p(2,2)); 
               0           0                                  1                  ];

% Compute the 3Dwarp matrix
% Mwarp3Da=[Mview_p(1,1) Mview_p(1,2) (Mview_p(1,3)-Si*Mview_p(1,1)-Sj*Mview_p(1,2)) Mview_p(1,4); 
%           Mview_p(2,1) Mview_p(2,2) (Mview_p(2,3)-Si*Mview_p(2,1)-Sj*Mview_p(2,2)) Mview_p(2,4); 
%           Mview_p(3,1) Mview_p(3,2) (Mview_p(3,3)-Si*Mview_p(3,1)-Sj*Mview_p(3,2)) Mview_p(3,4); 
%                 0           0                                  0                        1      ];
% Mwarp3Db=[1 0 0 -Ti;
%           0 1 0 -Tj;
%           0 0 1   0;
%           0 0 0   1];
% Mwarp3D=Mwarp3Da*Mwarp3Db;
% % Control matrix Mview
% Mview_control = Mwarp3D*Mshear*P;
% disp(Mview)
% disp(Mview_control)


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_config_Callback(hObject, eventdata, handles)
% hObject    handle to menu_config (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_change_alpha_colors_Callback(hObject, eventdata, handles)
% hObject    handle to menu_change_alpha_colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.handle_histogram=viewer3d_histogram(data.handle_viewer3d);
handles_histogram=guidata(data.handle_histogram);
data.handle_histogram_axes=handles_histogram.axes_histogram;
setMyData(data);
createHistogram();
drawHistogramPoints();

% --------------------------------------------------------------------
function menu_load_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dataold=getMyData();
dataold.volume=[];
if(ishandle(dataold.handle_histogram)), close(dataold.handle_histogram); end
uiload();
if(exist('data','var'))
    data.first_render=true;
    data.handle_viewer3d=dataold.handle_viewer3d;
    data.handles.axes3d=dataold.handles.axes3d;
    data.handles.figure1=dataold.handles.figure1;
    setMyData(data);
    createAlphaColorTable();
    show3d(false);
else
    viewer3d_error({'Matlab File does not contain','data from "Save Render"'})
end


% --------------------------------------------------------------------
function menu_save_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
uisave('data');


function menu_load_histogram_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
alpha=0;
uiload;
if(exist('positions','var'))
    data.histogram_positions=positions;
    data.histogram_colors=colors;
    data.histogram_alpha=alpha;
    setMyData(data);
    drawHistogramPoints();
    createAlphaColorTable();
    show3d(false);
else
    viewer3d_error({'Matlab File does not contain','data from "Save AlphaColors"'})
end

% --------------------------------------------------------------------
function menu_save_histogram_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
positions=data.histogram_positions;
colors=data.histogram_colors;
alpha=data.histogram_alpha;
uisave({'positions','colors','alpha'});

% --------------------------------------------------------------------
function menu_render_Callback(hObject, eventdata, handles)
% hObject    handle to menu_render (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_render_Mip_Callback(hObject, eventdata, handles)
% hObject    handle to menu_render_Mip (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.render_type='mip';
data.first_render=true;
setMyData(data);
show3d(false);

% --------------------------------------------------------------------
function menu_render_vr_Callback(hObject, eventdata, handles)
% hObject    handle to menu_render_vr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.render_type='vr';
data.first_render=true;
setMyData(data);
show3d(false);


% --------------------------------------------------------------------
function menu_render_vrc_Callback(hObject, eventdata, handles)
% hObject    handle to menu_render_vrc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.render_type='vrc';
data.first_render=true;
setMyData(data);
show3d(false);


% --------------------------------------------------------------------
function menu_render_vrs_Callback(hObject, eventdata, handles)
% hObject    handle to menu_render_vrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.render_type='vrs';
data.first_render=true;
setMyData(data);
show3d(false);


% --------------------------------------------------------------------
function menu_info_Callback(hObject, eventdata, handles)
% hObject    handle to menu_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_save_picture_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_picture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uiputfile({'*.png';'*.jpg'}, 'Save Rendered Image as');
data=getMyData(); if(isempty(data)), return, end
imwrite(data.render_image,[pathname filename]);


% --------------------------------------------------------------------
function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
viewer3d_about


   
function createHistogram()
% This function creates and show the (log) histogram of the data    
data=getMyData(); if(isempty(data)), return, end
    % Get histogram
    [data.histogram_countsy, data.histogram_countsx]=imhist(data.volume(:));
    % Log the histogram data
    data.histogram_countsy=log(data.histogram_countsy+100); data.histogram_countsy=data.histogram_countsy-min(data.histogram_countsy);
    data.histogram_countsx=data.histogram_countsx./max(data.histogram_countsx(:));
    data.histogram_countsy=data.histogram_countsy./max(data.histogram_countsy(:));
    % Focus on histogram axes
    figure(data.handle_histogram)    
    % Display the histogram
    stem(data.handle_histogram_axes,data.histogram_countsx,data.histogram_countsy,'Marker', 'none'); 
    hold(data.handle_histogram_axes,'on'); 
    % Set the axis of the histogram axes
    data.histogram_maxy=max(data.histogram_countsy(:));
    data.histogram_maxx=max(data.histogram_countsx(:));
    
    set(data.handle_histogram_axes,'yLim', [0 1]);
    set(data.handle_histogram_axes,'xLim', [0 1]);
setMyData(data);

% --- Executes on selection change in popupmenu_colors.
function popupmenu_colors_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_colors contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_colors
data=getMyData(); if(isempty(data)), return, end
    % Generate the new color markers
    c_choice=get(handles.popupmenu_colors,'Value');
    ncolors=length(data.histogram_positions);
    switch c_choice,
        case 1,new_colormap=jet(1000); 
        case 2, new_colormap=hsv(1000);
        case 3, new_colormap=hot(1000);
        case 4, new_colormap=cool(1000);
        case 5, new_colormap=spring(1000);
        case 6, new_colormap=summer(1000);
        case 7, new_colormap=autumn(1000);
        case 8, new_colormap=winter(1000);
        case 9, new_colormap=gray(1000);
        case 10, new_colormap=bone(1000);
        case 11, new_colormap=copper(1000);
        case 12, new_colormap=pink(1000);
        otherwise, new_colormap=hot(1000);
    end
    new_colormap=new_colormap(round(1:(end-1)/(ncolors-1):end),:);
    data.histogram_colors=new_colormap;
    
    % Draw the new color markers and make the color and alpha map
setMyData(data);
    drawHistogramPoints();
    createAlphaColorTable();
    show3d(false);



function drawHistogramPoints()
data=getMyData(); if(isempty(data)), return, end
    % Delete old points and line
    try
        delete(data.histogram_linehandle), 
        for i=1:length(data.histogram_pointhandle), 
           delete(data.histogram_pointhandle(i)), 
        end, 
    catch
    end
    stem(data.handle_histogram_axes,data.histogram_countsx,data.histogram_countsy,'Marker', 'none'); 
    hold(data.handle_histogram_axes,'on');
    
    % Display the markers and line through the markers.
    data.histogram_linehandle=plot(data.handle_histogram_axes,data.histogram_positions,data.histogram_alpha*data.histogram_maxy,'m');
    set(data.histogram_linehandle,'ButtonDownFcn','viewer3d(''lineHistogramButtonDownFcn'',gcbo,[],guidata(gcbo))');
    for i=1:length(data.histogram_positions)
        data.histogram_pointhandle(i)=plot(data.handle_histogram_axes,data.histogram_positions(i),data.histogram_alpha(i)*data.histogram_maxy,'bo','MarkerFaceColor',data.histogram_colors(i,:));
        set(data.histogram_pointhandle(i),'ButtonDownFcn','viewer3d(''pointHistogramButtonDownFcn'',gcbo,[],guidata(gcbo))');
    end
    
    % For detection of mouse up, down and motion in histogram figure.
    set(data.handle_histogram, 'WindowButtonDownFcn','viewer3d(''HistogramButtonDownFcn'',gcbo,[],guidata(gcbo))');
    set(data.handle_histogram, 'WindowButtonMotionFcn','viewer3d(''HistogramButtonMotionFcn'',gcbo,[],guidata(gcbo))');
    set(data.handle_histogram, 'WindowButtonUpFcn','viewer3d(''HistogramButtonUpFcn'',gcbo,[],guidata(gcbo))');
setMyData(data);    

function pointHistogramButtonDownFcn(hObject, eventdata, handles)
data=getMyData(); if(isempty(data)), return, end
data.mouse_button=get(data.handle_histogram,'SelectionType');
if(strcmp(data.mouse_button,'normal'))
    data.histogram_pointselected=find(data.histogram_pointhandle==gcbo);
    data.histogram_pointselectedhandle=gcbo;
    set(data.histogram_pointselectedhandle, 'MarkerSize',8);
    setMyData(data);
elseif(strcmp(data.mouse_button,'extend'))
    data.histogram_pointselected=find(data.histogram_pointhandle==gcbo);
    data.histogram_colors(data.histogram_pointselected,:)=rand(1,3);
    data.histogram_pointselected=[];
    setMyData(data);
    drawHistogramPoints();
    createAlphaColorTable();
    show3d(false);
elseif(strcmp(data.mouse_button,'alt'))
    data.histogram_pointselected=find(data.histogram_pointhandle==gcbo);

    data.histogram_positions(data.histogram_pointselected)=[];
    data.histogram_colors(data.histogram_pointselected,:)=[];
    data.histogram_alpha(data.histogram_pointselected)=[];

    data.histogram_pointselected=[];
    setMyData(data);
    drawHistogramPoints();
    createAlphaColorTable();
    show3d(false);
end


function HistogramButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function HistogramButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
if(~isempty(data.histogram_pointselected))
    set(data.histogram_pointselectedhandle, 'MarkerSize',6);
    data.histogram_pointselected=[];
    setMyData(data);
    createAlphaColorTable();
    % Show the data
    show3d(false)
end

function HistogramButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cursor_position_in_histogram_axes(hObject,handles);
data=getMyData(); if(isempty(data)), return, end
if(~isempty(data.histogram_pointselected))
 % Set point to location mouse
        data.histogram_positions(data.histogram_pointselected)=data.histogram_mouse_position(1,1); 
        data.histogram_alpha(data.histogram_pointselected)=data.histogram_mouse_position(1,2);
        
        % Correct new location
        if(data.histogram_alpha(data.histogram_pointselected)<0), data.histogram_alpha(data.histogram_pointselected)=0; end
        if(data.histogram_alpha(data.histogram_pointselected)>1), data.histogram_alpha(data.histogram_pointselected)=1; end
        if(data.histogram_positions(data.histogram_pointselected)<0), data.histogram_positions(data.histogram_pointselected)=0; end
        if(data.histogram_positions(data.histogram_pointselected)>1), data.histogram_positions(data.histogram_pointselected)=1; end
        if((data.histogram_pointselected>1)&&(data.histogram_positions(data.histogram_pointselected-1)>data.histogram_positions(data.histogram_pointselected)))
            data.histogram_positions(data.histogram_pointselected)=data.histogram_positions(data.histogram_pointselected-1);
        end
        
        if((data.histogram_pointselected<length(data.histogram_positions))&&(data.histogram_positions(data.histogram_pointselected+1)<data.histogram_positions(data.histogram_pointselected)))
            data.histogram_positions(data.histogram_pointselected)=data.histogram_positions(data.histogram_pointselected+1);
        end

        % Move point
        set(data.histogram_pointselectedhandle, 'xdata', data.histogram_positions(data.histogram_pointselected));
        set(data.histogram_pointselectedhandle, 'ydata', data.histogram_alpha(data.histogram_pointselected));
        
        % Move line
        set(data.histogram_linehandle, 'xdata',data.histogram_positions);
        set(data.histogram_linehandle, 'ydata',data.histogram_alpha);
end
setMyData(data);


function lineHistogramButtonDownFcn(hObject, eventdata, handles)
data=getMyData(); if(isempty(data)), return, end
        % New point on mouse location
        newposition=data.histogram_mouse_position(1,1);
        
        % List for the new markers
        newpositions=zeros(1,length(data.histogram_positions)+1);
        newalphas=zeros(1,length(data.histogram_alpha)+1);
        newcolors=zeros(size(data.histogram_colors,1)+1,3);

        % Check if the new point is between old points
        index_down=find(data.histogram_positions<=newposition); 
        if(isempty(index_down)) 
        else
            index_down=index_down(end);
            index_up=find(data.histogram_positions>newposition); 
            if(isempty(index_up)) 
            else
                index_up=index_up(1);
                
                % Copy the (first) old markers to the new lists
                newpositions(1:index_down)=data.histogram_positions(1:index_down);
                newalphas(1:index_down)=data.histogram_alpha(1:index_down);
                newcolors(1:index_down,:)=data.histogram_colors(1:index_down,:);
                
                % Add the new interpolated marker
                perc=(newposition-data.histogram_positions(index_down)) / (data.histogram_positions(index_up) - data.histogram_positions(index_down));
                color=(1-perc)*data.histogram_colors(index_down,:)+perc*data.histogram_colors(index_up,:);
                alpha=(1-perc)*data.histogram_alpha(index_down)+perc*data.histogram_alpha(index_up);
                
                newpositions(index_up)=newposition; 
                newalphas(index_up)=alpha; 
                newcolors(index_up,:)=color;
              
                % Copy the (last) old markers to the new lists
                newpositions(index_up+1:end)=data.histogram_positions(index_up:end);
                newalphas(index_up+1:end)=data.histogram_alpha(index_up:end);
                newcolors(index_up+1:end,:)=data.histogram_colors(index_up:end,:);
        
                % Make the new lists the used marker lists
                data.histogram_positions=newpositions; 
                data.histogram_alpha=newalphas; 
                data.histogram_colors=newcolors;
            end
        end
        
        % Update the histogram window
        cla(data.handle_histogram_axes);
setMyData(data);
drawHistogramPoints();
createAlphaColorTable();
show3d(false);

        


function cursor_position_in_histogram_axes(hObject,handles)
data=getMyData(); if(isempty(data)), return, end
    % Get position of the mouse in the large axes
    p = get(0, 'PointerLocation');
    pf = get(hObject, 'pos');
    p(1:2) = p(1:2)-pf(1:2);
    set(data.handle_histogram, 'CurrentPoint', p(1:2));
    p = get(data.handle_histogram_axes, 'CurrentPoint');
    data.histogram_mouse_position=[p(1, 1) p(1, 2)];
setMyData(data);


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('info.html');

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
data=getMyData(); if(isempty(data)), return, end
try
delete(data.handle_histogram);
catch end
try
rmappdata(gcf,'data3d');
catch end
delete(hObject);


% parallel
% matlabpool close;


% --------------------------------------------------------------------
function menu_shiny_Callback(hObject, eventdata, handles)
% hObject    handle to menu_shiny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.shading_material='shiny';
setMyData(data);
show3d(false);

% --------------------------------------------------------------------
function menu_dull_Callback(hObject, eventdata, handles)
% hObject    handle to menu_dull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.shading_material='dull';
setMyData(data);
show3d(false);

% --------------------------------------------------------------------
function menu_metal_Callback(hObject, eventdata, handles)
% hObject    handle to menu_metal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.shading_material='metal';
setMyData(data);
show3d(false);


% --------------------------------------------------------------------
function menu_rendersize400_Callback(hObject, eventdata, handles)
% hObject    handle to menu_rendersize400 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.axes_size=[400 400];
data.first_render=true;
setMyData(data);
show3d(false);


% --------------------------------------------------------------------
function menu_rendersize800_Callback(hObject, eventdata, handles)
% hObject    handle to menu_rendersize800 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.axes_size=[800 800];
data.first_render=true;
setMyData(data);
show3d(false);


