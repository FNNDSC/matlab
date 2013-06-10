function varargout = viewer3d(varargin)
% VIEWER3D is a Matlab GUI for fast shearwarp volume rendering. It also
% allows segmentation and measurements in the imagedata.
% 
%
% Just start with
%   VIEWER3D
%
% Or to display one or more matlab volumes
%
%   VIEWER3D(V);              VIEWER3D(V1,V2,V3 ....);
%
%
% inputs,
% V : 2D, 3D or 4D Input image, of type double, single, uint8, 
%            uint16, uint32, int8, int16 or int32 
%            (the render process uses only double calculations)
%
% example,
%   % Load data
%   load('ExampleData\CommandlineData.mat');
%   viewer3d(V);
%
% See also: render
%
% Function is written by D.Kroon University of Twente (January 2008 - January 2011)

% Edit the above text to modify the response to help viewer3ds

% Last Modified by GUIDE v2.5 12-Jan-2011 14:34:37

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

% addpath mexcode and help
functiondir=getFunctionFolder();
addpath(functiondir); 
addpath([functiondir '/Help']);
addpath([functiondir '/ReadData3D']);
addpath(genpath([functiondir '/SubFunctions']));

data.Menu=showmenu(hObject);
% Store handles to the figure menu
for i=1:length(data.Menu)
    z2=data.Menu(i);
    data.handles.(z2.Tag)=z2.Handle;
    if(isfield(z2,'Children')&&~isempty(z2.Children))
        for j=1:length(z2.Children)
            z3=z2.Children(j);
            data.handles.(z3.Tag)=z3.Handle;
        end
    end
end
data.handles.figure1=hObject;

% Disable warning
warning('off', 'MATLAB:maxNumCompThreads:Deprecated')

data.mouse.pressed=false;
data.mouse.button='arrow';
data.mouse.action='';

% Save the default config
filename_config=[functiondir '/default_config.mat'];
if(exist(filename_config,'file'))
    load(filename_config,'config')
    data.config=config;
else
    data.config.VolumeScaling=100;
    data.config.VolumeSize=32;
    data.config.ImageSizeRender=400;
    data.config.PreviewVolumeSize=32;
    data.config.ShearInterpolation= 'bilinear';
    data.config.WarpInterpolation= 'bilinear';
    data.config.PreRender= 0;
    data.config.StoreXYZ=0;
end


% Check if history information is present from a previous time
historyfile=[functiondir '/lastfiles.mat'];
if(exist(historyfile,'file')), 
    load(historyfile);
    data.history=history;
else
    for i=1:5, data.history.filenames{i}=''; end
end
data.history.historyfile=historyfile;

data.rendertypes(1).label='None';
data.rendertypes(1).type='black';
data.rendertypes(2).label='View X slice';
data.rendertypes(2).type='slicex';
data.rendertypes(3).label='View Y slice';
data.rendertypes(3).type='slicey';
data.rendertypes(4).label='View Z slice';
data.rendertypes(4).type='slicez';
data.rendertypes(5).label='MIP';
data.rendertypes(5).type='mip';
data.rendertypes(6).label='Greyscale';
data.rendertypes(6).type='vr';
data.rendertypes(7).label='Color';
data.rendertypes(7).type='vrc';
data.rendertypes(8).label='Shaded';
data.rendertypes(8).type='vrs';

data.figurehandles.viewer3d=gcf;
data.figurehandles.histogram=[];
data.figurehandles.console=[];
data.figurehandles.voxelsize=[];
data.figurehandles.lightvector=[];
data.figurehandles.contrast=[];
data.figurehandles.qualityspeed=[];
data.volumes=[];
data.substorage=[];
data.axes_select=[];
data.volume_select=[];
data.subwindow=[];
data.NumberWindows=0;
data.MenuVolume=[];
data=loadmousepointershapes(data);

data.NumberWindows=1;
data=addWindows(data);
setMyData(data);
showhistory(data);
allshow3d(false,true);

% Get input voxel volume and convert to double
if (~isempty(varargin)), 
    if(ndims(varargin{1})>=2)
        for i=1:length(varargin);
            V=varargin{i};
            volumemax=double(max(V(:))); volumemin=double(min(V(:)));
            info=struct;
            info.WindowWidth=volumemax-volumemin;
            info.WindowLevel=0.5*(volumemax+volumemin);     

            if(isnumeric(V)), addVolume(V,[1 1 1],info); end
        end
    else
        error('viewer3d:inputs', 'Input image not 3 dimensional');
    end
end

function addVolume(V,Scales,Info,Editable)
if(nargin<2), Scales=[1 1 1]; end
if(nargin<3), Info=[]; end
if(nargin<4), Editable=false; end
data=getMyData(); if(isempty(data)), return, end
for i=1:size(V,4)
    data=addOneVolume(data,V(:,:,:,i),Scales,Info,Editable);
end
data=addWindowsMenus(data);
setMyData(data);
addMenuVolume();

function data=addOneVolume(data,V,Scales,Info,Editable)
nv=length(data.volumes)+1;
data.volumes(nv).Editable=Editable; 
data.volumes(nv).WindowWidth=1; 
data.volumes(nv).WindowLevel=0.5; 
data.volumes(nv).volume_original=V;
data.volumes(nv).volume_scales=[1 1 1];
data.volumes(nv).info=Info;
data.volumes(nv).id=rand;
data.volumes(nv).Scales=Scales;
if(ndims(V)==2)
    data.volumes(nv).Size_original=[size(V) 1];
else
    data.volumes(nv).Size_original=size(V);
end

name=['Volume ' num2str(nv)];
while(~isempty(structfind(data.volumes,'name',name)))
    name=['Volume ' num2str(round(rand*10000))];
end
data.volumes(nv).name=name;

data.volumes(nv).MeasureList=[];
data.volumes(nv).histogram_pointselected=[];
data=checkvolumetype(data,nv);

data=makeVolumeXY(data,nv);
data=computeNormals(data,nv);
data=makePreviewVolume(data,nv);
data=makeRenderVolume(data,nv);
if(~isempty(Info)),
    if(isfield(Info,'WindowWidth'));
        data.volumes(nv).WindowWidth=Info.WindowWidth;
    end
    if (isfield(Info,'WindowCenter'));
        data.volumes(nv).WindowLevel=Info.WindowCenter;
    end
    if (isfield(Info,'WindowLevel'));
        data.volumes(nv).WindowLevel=Info.WindowLevel;
    end
end
data.volumes(nv).histogram_positions = [0 0.2 0.4 0.6 1];
data.volumes(nv).histogram_positions= data.volumes(nv).histogram_positions*(data.volumes(nv).volumemax-data.volumes(nv).volumemin)+data.volumes(nv).volumemin;
data.volumes(nv).histogram_alpha = [0 0.03 0.1 0.35 1]; 
data.volumes(nv).histogram_colors= [0 0 0; 0.7 0 0; 1 0 0; 1 1 0; 1 1 1];
data=createAlphaColorTable(nv,data);
        


function data=makePreviewVolume(data,dvs)
if(data.config.PreviewVolumeSize==100)
    data.volumes(dvs).volume_preview=data.volumes(dvs).volume_original;
else
    t=data.config.PreviewVolumeSize;
    data.volumes(dvs).volume_preview=imresize3d(data.volumes(dvs).volume_original,[],[t t t],'linear');
end

if(ndims(data.volumes(dvs).volume_preview)==2)
    data.volumes(dvs).Size_preview=[size(data.volumes(dvs).volume_preview) 1];
else
    data.volumes(dvs).Size_preview=size(data.volumes(dvs).volume_preview);
end


function functiondir=getFunctionFolder()
functionname='viewer3d.m';
functiondir=which(functionname);
functiondir=functiondir(1:end-length(functionname));

function data=makeRenderVolume(data,dvs)
if(data.config.VolumeScaling==100)
    data.volumes(dvs).volume=data.volumes(dvs).volume_original;
else
    data.volumes(dvs).volume=imresize3d(data.volumes(dvs).volume_original,data.config.VolumeScaling/100,[],'linear');
end
if(ndims(data.volumes(dvs).volume)==2)
    data.volumes(dvs).Size=[size(data.volumes(dvs).volume) 1];
else
    data.volumes(dvs).Size=size(data.volumes(dvs).volume);
end



function data=createAlphaColorTable(i,data)
% This function creates a Matlab colormap and alphamap from the markers
if(nargin<2)
    data=getMyData(); if(isempty(data)), return, end
end
if(nargin>0), 
    dvs=i; 
else
    dvs=data.volume_select;
end
    check=~isfield(data.volumes(dvs),'histogram_positions');
    if(~check), check=isempty(data.volumes(dvs).histogram_positions); end
    if(check)
        data.volumes(dvs).histogram_positions = [0 0.2 0.4 0.6 1];
        data.volumes(dvs).histogram_positions= data.volumes(dvs).histogram_positions*(data.volumes(dvs).volumemax-data.volumes(dvs).volumemin)+data.volumes(dvs).volumemin;
        data.volumes(dvs).histogram_alpha = [0 0.03 0.1 0.35 1]; 
        data.volumes(dvs).histogram_colors= [0 0 0; 0.7 0 0; 1 0 0; 1 1 0; 1 1 1];
        setMyData(data);
    end

    histogram_positions=data.volumes(dvs).histogram_positions;

    data.volumes(dvs).colortable=zeros(1000,3); 
    data.volumes(dvs).alphatable=zeros(1000,1);
    % Loop through all 256 color/alpha indexes
    
    i=linspace(data.volumes(dvs).volumemin,data.volumes(dvs).volumemax,1000);
    for j=1:1000
        if    (i(j)< histogram_positions(1)),   alpha=0;                         color=data.volumes(dvs).histogram_colors(1,:);
        elseif(i(j)> histogram_positions(end)), alpha=0;                         color=data.volumes(dvs).histogram_colors(end,:);
        elseif(i(j)==histogram_positions(1)),   alpha=data.volumes(dvs).histogram_alpha(1);   color=data.volumes(dvs).histogram_colors(1,:);
        elseif(i(j)==histogram_positions(end)), alpha=data.volumes(dvs).histogram_alpha(end); color=data.volumes(dvs).histogram_colors(end,:);
        else
            % Linear interpolate the color and alpha between markers
            index_down=find(histogram_positions<=i(j)); index_down=index_down(end);
            index_up  =find(histogram_positions>i(j) ); index_up=index_up(1);
            perc= (i(j)-histogram_positions(index_down)) / (histogram_positions(index_up) - histogram_positions(index_down));
            color=(1-perc)*data.volumes(dvs).histogram_colors(index_down,:)+perc*data.volumes(dvs).histogram_colors(index_up,:);
            alpha=(1-perc)*data.volumes(dvs).histogram_alpha(index_down)+perc*data.volumes(dvs).histogram_alpha(index_up);
        end
        data.volumes(dvs).colortable(j,:)=color;
        data.volumes(dvs).alphatable(j)=alpha;
    end
if(nargin<2)
    setMyData(data);
end

function data=loadmousepointershapes(data)
I=[0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0; 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0;
 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0; 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0;
 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0;
 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0; 0 0 1 0 0 0 1 1 1 1 0 0 0 0 0 0;
 0 1 1 1 1 1 0 1 0 0 1 1 1 1 1 1; 1 1 1 1 0 0 0 1 0 0 0 0 0 0 1 1;
 1 1 1 1 0 0 0 1 0 0 0 0 0 1 1 1; 1 0 0 0 0 0 0 0 1 0 1 0 0 0 1 1;
 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 1; 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0;
 0 0 0 0 0 0 0 0 1 1 1 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0];
I(I==0)=NaN; data.icons.icon_mouse_rotate1=I;
I=[1 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0; 1 1 0 1 1 1 1 1 1 1 1 1 1 0 0 0;
 1 1 1 1 1 1 0 0 0 0 0 1 1 1 0 0; 1 0 0 1 1 0 0 0 0 0 0 0 0 1 0 0;
 1 0 0 1 1 0 0 0 0 0 0 0 0 1 0 0; 1 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0;
 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1;
 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 1; 0 0 1 0 0 0 0 0 0 0 0 1 1 0 0 1;
 0 0 1 0 0 0 0 0 0 0 0 1 1 0 0 1; 0 0 1 1 1 0 0 0 0 0 1 1 1 1 1 1;
 0 0 0 1 1 1 1 1 1 1 1 1 1 0 1 1; 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 1]; 
I(I==0)=NaN; data.icons.icon_mouse_rotate2=I;
I=[0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0; 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0;
 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0; 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0;
 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0; 1 0 0 1 1 1 1 1 0 0 1 0 0 0 0 0;
 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0; 1 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0;
 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0; 0 0 1 0 0 0 0 1 1 1 1 0 0 0 0 0;
 0 0 0 1 1 1 1 0 0 1 1 1 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0 0;
 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0;
 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1];
I(I==0)=NaN; data.icons.icon_mouse_zoom=I;
I=[0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0;
 0 0 0 0 0 1 1 0 1 1 0 0 0 0 0 0; 0 0 0 0 0 1 0 1 0 1 0 0 0 0 0 0;
 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0; 0 0 1 1 0 0 0 1 0 0 0 1 1 0 0 0;
 0 1 1 0 0 0 0 1 0 0 0 0 1 1 0 0; 1 0 0 1 1 1 1 1 1 1 1 1 0 0 1 0;
 0 1 1 0 0 0 0 1 0 0 0 0 1 1 0 0; 0 0 1 1 0 0 0 1 0 0 0 1 1 0 0 0;
 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0; 0 0 0 0 0 1 0 1 0 1 0 0 0 0 0 0;
 0 0 0 0 0 1 1 0 1 1 0 0 0 0 0 0; 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0;
 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
I(I==0)=NaN; data.icons.icon_mouse_pan=I;


function allshow3d(preview,render_new_image)
data=getMyData(); if(isempty(data)), return, end
for i=1:data.NumberWindows
    show3d(preview,render_new_image,i);
end

function show3d(preview,render_new_image,wsel)
data=getMyData(); if(isempty(data)), return, end
tic;
if(nargin<3)
    wsel=data.axes_select;
else
    data.axes_select=wsel;
end

dvss=structfind(data.volumes,'id',data.subwindow(wsel).volume_id_select(1));

nvolumes=length(data.subwindow(wsel).volume_id_select);
  
if(isempty(dvss)), 
    data.subwindow(wsel).render_type='black';
    datarender.RenderType='black';
    datarender.ImageSize=[data.config.ImageSizeRender data.config.ImageSizeRender];
    datarender.imin=0; datarender.imax=1;
    renderimage = render(zeros(3,3,3),datarender);
    data.subwindow(wsel).render_image(1).image=renderimage;
else     
    if(render_new_image)
        for i=1:nvolumes
            dvss=structfind(data.volumes,'id',data.subwindow(wsel).volume_id_select(i));
            data.subwindow(wsel).render_image(i).image=MakeRenderImage(data,dvss,wsel,preview);
        end
    end
    if(nvolumes==1), combine='trans'; else combine=data.subwindow(wsel).combine; end
    for i=1:nvolumes
         dvss=structfind(data.volumes,'id',data.subwindow(wsel).volume_id_select(i));
         renderimage1=LevelRenderImage(data.subwindow(wsel).render_image(i).image,data,dvss,wsel);
         if(i==1)
             switch(combine)
                 case 'trans'
                    renderimage=renderimage1;
                 case 'rgb'
                    renderimage=zeros([size(renderimage1,1) size(renderimage1,2) 3]);
                    renderimage(:,:,i)=mean(renderimage1,3);
             end
         else
              switch(combine)
                 case 'trans'
                    renderimage=renderimage+renderimage1;
                 case 'rgb'
                    renderimage(:,:,i)=mean(renderimage1,3);
             end

         end
    end
    switch(combine)
        case 'trans'
         if(nvolumes>1), renderimage=renderimage*(1/nvolumes); end    
    end
end

    
data.subwindow(wsel).total_image=renderimage;

% Add position information etc. to the rendered image
data=InfoOnScreen(data);
data=showMeasureList(data);

% To range
data.subwindow(wsel).total_image(data.subwindow(wsel).total_image<0)=0;
data.subwindow(wsel).total_image(data.subwindow(wsel).total_image>1)=1;

if(data.subwindow(wsel).first_render)
    data.subwindow(wsel).imshow_handle=imshow(data.subwindow(wsel).total_image,'Parent',data.subwindow(wsel).handles.axes); drawnow('expose')
    data.subwindow(wsel).first_render=false;
else
    set(data.subwindow(wsel).imshow_handle,'Cdata',data.subwindow(wsel).total_image);
end

data.subwindow(wsel).axes_size=get(data.subwindow(wsel).handles.axes,'PlotBoxAspectRatio');

set(get(data.subwindow(wsel).handles.axes,'Children'),'ButtonDownFcn','viewer3d(''axes_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
data=console_addline(data,['Render Time : ' num2str(toc)]);

setMyData(data);

function renderimage=MakeRenderImage(data,dvss,wsel,preview)
datarender=struct();
datarender.ImageSize=[data.config.ImageSizeRender data.config.ImageSizeRender];
datarender.imin=data.volumes(dvss).volumemin;
datarender.imax=data.volumes(dvss).volumemax;
switch data.subwindow(wsel).render_type
case 'mip'
    datarender.RenderType='mip';
    datarender.ShearInterp=data.config.ShearInterpolation;
    datarender.WarpInterp=data.config.WarpInterpolation;
case 'vr'
    datarender.RenderType='bw';
    datarender.AlphaTable=data.volumes(dvss).alphatable;
    datarender.ShearInterp=data.config.ShearInterpolation;
    datarender.WarpInterp=data.config.WarpInterpolation;
case 'vrc'
    datarender.RenderType='color';
    datarender.AlphaTable=data.volumes(dvss).alphatable;
    datarender.ColorTable=data.volumes(dvss).colortable;
    datarender.ShearInterp=data.config.ShearInterpolation;
    datarender.WarpInterp=data.config.WarpInterpolation;
case 'vrs'
    datarender.RenderType='shaded';
    datarender.AlphaTable=data.volumes(dvss).alphatable; datarender.ColorTable=data.volumes(dvss).colortable;
    datarender.LightVector=data.subwindow(wsel).LightVector; datarender.ViewerVector=data.subwindow(wsel).ViewerVector;
    datarender.ShadingMaterial=data.subwindow(wsel).shading_material;
    datarender.ShearInterp=data.config.ShearInterpolation;
    datarender.WarpInterp=data.config.WarpInterpolation;
case 'slicex'
    datarender.RenderType='slicex';
    datarender.ColorTable=data.volumes(dvss).colortable;
    datarender.SliceSelected=data.subwindow(wsel).SliceSelected(1);
    datarender.WarpInterp='bicubic';   
    datarender.ColorSlice=data.subwindow(data.axes_select).ColorSlice;
case 'slicey'
    datarender.RenderType='slicey';
    datarender.ColorTable=data.volumes(dvss).colortable;
    datarender.SliceSelected=data.subwindow(wsel).SliceSelected(2);
    datarender.WarpInterp='bicubic';  
    datarender.ColorSlice=data.subwindow(data.axes_select).ColorSlice;
case 'slicez'
    datarender.RenderType='slicez';
    datarender.ColorTable=data.volumes(dvss).colortable;
    datarender.SliceSelected=data.subwindow(wsel).SliceSelected(3);
    datarender.WarpInterp='bicubic'; 
    datarender.ColorSlice=data.subwindow(data.axes_select).ColorSlice;
case 'black'
    datarender.RenderType='black';
end

if(preview)
    switch data.subwindow(wsel).render_type
        case {'slicex','slicey','slicez'}
            datarender.WarpInterp='nearest';
            datarender.Mview=data.subwindow(wsel).viewer_matrix;
            renderimage = render(data.volumes(dvss).volume_original, datarender);
        otherwise
            R=ResizeMatrix(data.volumes(dvss).Size_preview./data.volumes(dvss).Size_original);
            datarender.Mview=data.subwindow(wsel).viewer_matrix*R;
            renderimage = render(data.volumes(dvss).volume_preview,datarender);
    end
else
    mouse_button_old=data.mouse.button;
    set_mouse_shape('watch',data); drawnow('expose');
    switch data.subwindow(wsel).render_type
        case {'slicex','slicey','slicez'}
            datarender.Mview=data.subwindow(wsel).viewer_matrix;
            renderimage = render(data.volumes(dvss).volume_original, datarender);
        case 'black'
            renderimage = render(data.volumes(dvss).volume, datarender);
        otherwise
            datarender.Mview=data.subwindow(wsel).viewer_matrix*ResizeMatrix(data.volumes(dvss).Size./data.volumes(dvss).Size_original);
            datarender.VolumeX=data.volumes(dvss).volumex;
            datarender.VolumeY=data.volumes(dvss).volumey;
            datarender.Normals=data.volumes(dvss).normals;
            renderimage = render(data.volumes(dvss).volume, datarender);
    end
    set_mouse_shape(mouse_button_old,data); drawnow('expose'); 
end


function renderimage=LevelRenderImage(renderimage,data,dvss,wsel)
if(~isempty(dvss))
    switch data.subwindow(wsel).render_type
        case {'mip','slicex', 'slicey', 'slicez'}
            % The render image is scaled to fit to [0..1], perform both back scaling
            % and Window level and Window width
            if ((ndims(renderimage)==2)&&(data.volumes(dvss).WindowWidth~=0||data.volumes(dvss).WindowLevel~=0))
                m=(data.volumes(dvss).volumemax-data.volumes(dvss).volumemin)*(1/data.volumes(dvss).WindowWidth);
                o=(data.volumes(dvss).volumemin-data.volumes(dvss).WindowLevel)*(1/data.volumes(dvss).WindowWidth)+0.5;
                renderimage=renderimage*m+o;
            end
    end
end
    
function data=set_initial_view_matrix(data)
dvss=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));

switch data.subwindow(data.axes_select).render_type
    case 'slicex'
        data.subwindow(data.axes_select).viewer_matrix=[data.volumes(dvss).Scales(1)*data.subwindow(data.axes_select).Zoom 0 0 0; 0 data.volumes(dvss).Scales(2)*data.subwindow(data.axes_select).Zoom 0 0; 0 0 data.volumes(dvss).Scales(3)*data.subwindow(data.axes_select).Zoom 0; 0 0 0 1];
        data.subwindow(data.axes_select).viewer_matrix=[0 0 1 0;0 1 0 0; -1 0 0 0;0 0 0 1]*data.subwindow(data.axes_select).viewer_matrix;
    case 'slicey'
        data.subwindow(data.axes_select).viewer_matrix=[data.volumes(dvss).Scales(1)*data.subwindow(data.axes_select).Zoom 0 0 0; 0 data.volumes(dvss).Scales(2)*data.subwindow(data.axes_select).Zoom 0 0; 0 0 data.volumes(dvss).Scales(3)*data.subwindow(data.axes_select).Zoom 0; 0 0 0 1];
        data.subwindow(data.axes_select).viewer_matrix=[1 0 0 0;0 0 -1 0; 0 1 0 0;0 0 0 1]*data.subwindow(data.axes_select).viewer_matrix;
    case 'slicez'
        data.subwindow(data.axes_select).viewer_matrix=[data.volumes(dvss).Scales(1)*data.subwindow(data.axes_select).Zoom 0 0 0; 0 data.volumes(dvss).Scales(2)*data.subwindow(data.axes_select).Zoom 0 0; 0 0 data.volumes(dvss).Scales(3)*data.subwindow(data.axes_select).Zoom 0; 0 0 0 1];
        data.subwindow(data.axes_select).viewer_matrix=data.subwindow(data.axes_select).viewer_matrix*[1 0 0 0;0 1 0 0; 0 0 1 0;0 0 0 1];
    otherwise
        data.subwindow(data.axes_select).viewer_matrix=[data.volumes(dvss).Scales(1)*data.subwindow(data.axes_select).Zoom 0 0 0; 0 data.volumes(dvss).Scales(2)*data.subwindow(data.axes_select).Zoom 0 0; 0 0 data.volumes(dvss).Scales(3)*data.subwindow(data.axes_select).Zoom 0; 0 0 0 1];
end


% --- Outputs from this function are returned to the command line.
function varargout = viewer3d_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function set_menu_checks(data)

for i=1:data.NumberWindows
    C=data.subwindow(i).menu.Children(2).Children;
    for j=1:length(C)
        set(C(j).Handle,'Checked','off'); 
    end
    
    D=data.subwindow(i).menu.Children(3).Children;

    s=structfind(D,'Tag','menu_config_slicescolor');
    set(D(s).Handle,'Checked','off');
    if(data.subwindow(i).ColorSlice)
        set(D(s).Handle,'Checked','on');
    end
    s1=structfind(D,'Tag','menu_metal');
    s2=structfind(D,'Tag','menu_shiny');
    s3=structfind(D,'Tag','menu_dull');
    
    set(D(s1).Handle,'Checked','off');
    set(D(s2).Handle,'Checked','off');
    set(D(s3).Handle,'Checked','off');
    
    switch(data.subwindow(i).shading_material)
        case 'metal'
            set(D(s1).Handle,'Checked','on');
        case 'shiny'
            set(D(s2).Handle,'Checked','on');
        case 'dull'
          set(D(s3).Handle,'Checked','on');
    end
    s1=structfind(D,'Tag','menu_combine_trans');
    s2=structfind(D,'Tag','menu_combine_rgb');
    set(D(s1).Handle,'Checked','off');
    set(D(s2).Handle,'Checked','off');
    switch(data.subwindow(i).combine)
        case 'trans'
            set(D(s1).Handle,'Checked','on');
        case 'rgb'
            set(D(s2).Handle,'Checked','on');
    end
     
    if(data.subwindow(i).volume_id_select(1)>0)
        n=length(data.subwindow(i).volume_id_select);
        st=['wmenu-' num2str(i)];
        for j=1:n
            dvss=structfind(data.volumes,'id',data.subwindow(i).volume_id_select(j));
            st=[st '-' num2str(dvss)];
        end
        Ci=structfind(C,'Tag',st);
    else
        Ci=1;
    end
    if(~isempty(Ci))
        set(C(Ci).Handle,'Checked','on');
    end
    
    d=get(data.subwindow(i).menu.Children(1).Handle,'Children');
    e=zeros(size(d));
    for j=1:length(d), set(d(j),'Checked','off'); e(j)=get(d(j),'Position'); end
    [t,in]=sort(e); d=d(in);
    
    dv=structfind(data.rendertypes,'type',data.subwindow(i).render_type);
    set(d(dv),'Checked','on');
    
    sl=strcmp(data.subwindow(i).render_type(1:min(5,end)),'slice');
    if(sl)
       set(data.subwindow(i).menu.Children(4).Handle,'Enable','on')
       id=data.subwindow(i).volume_id_select;
       editable=false(1,length(id));
       for k=1:length(id)
           editable(k)=data.volumes(structfind(data.volumes,'id',data.subwindow(i).volume_id_select(k))).Editable;
       end
       if(any(editable))
           set(data.subwindow(i).menu.Children(5).Handle,'Enable','on')
       else
           set(data.subwindow(i).menu.Children(5).Handle,'Enable','off')
       end
    else
       set(data.subwindow(i).menu.Children(4).Handle,'Enable','off')
       set(data.subwindow(i).menu.Children(5).Handle,'Enable','off')
    end
end
menubar;


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menubar('MotionFcn',gcf);
 
cursor_position_in_axes(hObject,handles);
data=getMyData(); if(isempty(data)), return, end
if(isempty(data.axes_select)), return, end
if(strcmp(data.subwindow(data.axes_select).render_type,'black')), return; end

if((length(data.subwindow(data.axes_select).render_type)>5)&&strcmp(data.subwindow(data.axes_select).render_type(1:5),'slice'))
    data=mouseposition_to_voxelposition(data);
    setMyData(data);
end

if(data.mouse.pressed)
    switch(data.mouse.button)
    case 'rotate1'
        r1=-360*(data.subwindow(data.axes_select).mouse_position_last(1)-data.subwindow(data.axes_select).mouse_position(1));
        r2=360*(data.subwindow(data.axes_select).mouse_position_last(2)-data.subwindow(data.axes_select).mouse_position(2));
        R=RotationMatrix([r1 r2 0]);
        data.subwindow(data.axes_select).viewer_matrix=R*data.subwindow(data.axes_select).viewer_matrix;
        setMyData(data);
        show3d(true,true)
    case 'rotate2'
        r1=100*(data.subwindow(data.axes_select).mouse_position_last(1)-data.subwindow(data.axes_select).mouse_position(1));
        r2=100*(data.subwindow(data.axes_select).mouse_position_last(2)-data.subwindow(data.axes_select).mouse_position(2));
        if(data.subwindow(data.axes_select).mouse_position(2)>0.5), r1=-r1; end
        if(data.subwindow(data.axes_select).mouse_position(1)<0.5), r2=-r2; end
        r3=r1+r2;
        R=RotationMatrix([0 0 r3]);
        data.subwindow(data.axes_select).viewer_matrix=R*data.subwindow(data.axes_select).viewer_matrix;
        setMyData(data);
        show3d(true,true)
    case 'pan'
        t2=200*(data.subwindow(data.axes_select).mouse_position_last(1)-data.subwindow(data.axes_select).mouse_position(1));
        t1=200*(data.subwindow(data.axes_select).mouse_position_last(2)-data.subwindow(data.axes_select).mouse_position(2));
        M=TranslateMatrix([t1 t2 0]);
        data.subwindow(data.axes_select).viewer_matrix=M*data.subwindow(data.axes_select).viewer_matrix;
        setMyData(data);
        show3d(true,true)      
    case 'zoom'
        z1=1+2*(data.subwindow(data.axes_select).mouse_position_last(1)-data.subwindow(data.axes_select).mouse_position(1));
        z2=1+2*(data.subwindow(data.axes_select).mouse_position_last(2)-data.subwindow(data.axes_select).mouse_position(2));
        z=0.5*(z1+z2); 
        R=ResizeMatrix([z z z]); 
        data.subwindow(data.axes_select).Zoom=data.subwindow(data.axes_select).Zoom*(1/z);
        data.subwindow(data.axes_select).viewer_matrix=R*data.subwindow(data.axes_select).viewer_matrix;
        setMyData(data);
        show3d(true,true)       
    case 'drag'
        id=data.subwindow(data.axes_select).object_id_select;
        dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));
        n=structfind(data.volumes(dvs).MeasureList,'id',id(1));
        object=data.volumes(dvs).MeasureList(n);
        s=round(id(3)*length(object.x));
        if(s==0)
            object.x=object.x-mean(object.x(:))+ data.subwindow(data.axes_select).VoxelLocation(1);
            object.y=object.y-mean(object.y(:))+ data.subwindow(data.axes_select).VoxelLocation(2);
            object.z=object.z-mean(object.z(:))+ data.subwindow(data.axes_select).VoxelLocation(3);
        else
            
            object.x(s)=data.subwindow(data.axes_select).VoxelLocation(1);
            object.y(s)=data.subwindow(data.axes_select).VoxelLocation(2);
            object.z(s)=data.subwindow(data.axes_select).VoxelLocation(3);
        end
        switch object.type
            case 'd'
                dx=data.volumes(dvs).Scales(1)*(object.x(1)-object.x(2));
                dy=data.volumes(dvs).Scales(2)*(object.y(1)-object.y(2));
                dz=data.volumes(dvs).Scales(3)*(object.z(1)-object.z(2));
                distance=sqrt(dx.^2+dy.^2+dz.^2);
                object.varmm=distance;
            otherwise
        end
        data.volumes(dvs).MeasureList(n)=object;
        setMyData(data);
        show3d(false,false)
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
data=getMyData(); if(isempty(data)), return, end;
if(isempty(data.axes_select)), return, end
data.subwindow(data.axes_select).mouse_position_last=data.subwindow(data.axes_select).mouse_position;
% Get position of the mouse in the large axes
% p = get(0, 'PointerLocation');
% pf = get(hObject, 'pos');
% p(1:2) = p(1:2)-pf(1:2);
% set(gcf, 'CurrentPoint', p(1:2));
h=data.subwindow(data.axes_select).handles.axes;
if(~ishandle(h)), return; end
p = get(h, 'CurrentPoint');
if (~isempty(p))
    data.subwindow(data.axes_select).mouse_position=[p(1, 1) p(1, 2)]./data.subwindow(data.axes_select).axes_size(1:2);
end
setMyData(data);

function setMyData(data,handle)
% Store data struct in figure
if(nargin<2), handle=gcf; end
setappdata(handle,'data3d',data);

function data=getMyData(handle)
% Get data struct stored in figure
if(nargin<1), handle=gcf; end
data=getappdata(handle,'data3d');

% --- Executes on mouse press over axes background.
function axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));

ha=zeros(1,data.NumberWindows);
for i=1:data.NumberWindows, ha(i)=data.subwindow(i).handles.axes; end
data.axes_select=find(ha==gca);
data.mouse.pressed=true;
data.mouse.button=get(handles.figure1,'SelectionType');
data.subwindow(data.axes_select).mouse_position_pressed=data.subwindow(data.axes_select).mouse_position;
if(strcmp(data.mouse.button,'normal'))
    sr=strcmp(data.subwindow(data.axes_select).render_type(1:min(end,5)),'slice');
    if(sr)
        switch(data.mouse.action)
            case 'measure_distance'
                if(getnumberofpoints(data)==0)
                    % Do measurement
                    data=addMeasureList('p',data.subwindow(data.axes_select).VoxelLocation(1),data.subwindow(data.axes_select).VoxelLocation(2),data.subwindow(data.axes_select).VoxelLocation(3),0,data);
                    data.mouse.button='select_distance';
                    data.mouse.pressed=false;
                    setMyData(data);
                    show3d(false,false);
                    return
                elseif(getnumberofpoints(data)>0)
                    VoxelLocation1=[data.volumes(dvs).MeasureList(end).x data.volumes(dvs).MeasureList(end).y data.volumes(dvs).MeasureList(end).z];
                    VoxelLocation2=data.subwindow(data.axes_select).VoxelLocation;
                    % First remove the point (will be replaced by distance)
                    data=rmvMeasureList(data.volumes(dvs).MeasureList(end).id,data);
                    % Do measurement
                    x=[VoxelLocation1(1) VoxelLocation2(1)];
                    y=[VoxelLocation1(2) VoxelLocation2(2)];
                    z=[VoxelLocation1(3) VoxelLocation2(3)];
                    dx=data.volumes(dvs).Scales(1)*(x(1)-x(2));
                    dy=data.volumes(dvs).Scales(2)*(y(1)-y(2));
                    dz=data.volumes(dvs).Scales(3)*(z(1)-z(2));
                    distance=sqrt(dx.^2+dy.^2+dz.^2);
                    data=addMeasureList('d',x,y,z,distance,data);
                    data.mouse.action='';
                    data.mouse.pressed=false;
                    setMyData(data);
                    show3d(false,false);
                    return
                end
            case 'measure_landmark'
                
                data=addMeasureList('l',data.subwindow(data.axes_select).VoxelLocation(1),data.subwindow(data.axes_select).VoxelLocation(2),data.subwindow(data.axes_select).VoxelLocation(3),0,data);
                data.mouse.button='select_landmark';
                data.mouse.action='';
                data.mouse.pressed=false;
                setMyData(data);
                show3d(false,false);
                return
                
            case 'segment_click_roi'
                % Do measurement
                [vx,vy,vz]=getClickRoi(data);
                for i=1:length(vx), data=addMeasureList('p',vx(i),vy(i),vz(i),0,data); end
                data=points2roi(data,false);
                data.mouse.button='click_roi';
                
                data.subwindow(data.axes_select).click_roi=false;
                data.mouse.pressed=false;
                setMyData(data);
                show3d(false,false);
                return
                
            case 'measure_roi'
                % Do measurement
                data=addMeasureList('p',data.subwindow(data.axes_select).VoxelLocation(1),data.subwindow(data.axes_select).VoxelLocation(2),data.subwindow(data.axes_select).VoxelLocation(3),0,data);
                data.mouse.button='select_roi';
                data.mouse.pressed=false;
                setMyData(data);
                show3d(false,false);
                return
                
            case 'segment_roi'
                % Do measurement
                data=addMeasureList('p',data.subwindow(data.axes_select).VoxelLocation(1),data.subwindow(data.axes_select).VoxelLocation(2),data.subwindow(data.axes_select).VoxelLocation(3),0,data);
                data.mouse.button='select_roi';
                data.mouse.pressed=false;
                setMyData(data);
                show3d(true,false);
                return
            otherwise
                 id_detect=getHitMapClick(data);
                 if(id_detect(1)>0)
                     data.subwindow(data.axes_select).object_id_select=id_detect;
                     data.mouse.button='drag';
                     setMyData(data);
                     return;
                 end
        end
        
    end
    
    
    distance_center=sum((data.subwindow(data.axes_select).mouse_position-[0.5 0.5]).^2);
    if((distance_center<0.15)&&data.subwindow(data.axes_select).render_type(1)~='s')
        data.mouse.button='rotate1';
        set_mouse_shape('rotate1',data)
    else
        data.mouse.button='rotate2';
        set_mouse_shape('rotate2',data)
    end
end
if(strcmp(data.mouse.button,'open'))
    switch(data.mouse.action)
        case 'measure_roi'
            data=addMeasureList('p',data.subwindow(data.axes_select).VoxelLocation(1),data.subwindow(data.axes_select).VoxelLocation(2),data.subwindow(data.axes_select).VoxelLocation(3),0,data);
            data=points2roi(data,false);

            data.mouse.action='';
            data.mouse.pressed=false;
            setMyData(data);
            show3d(false,false);
            return            
            
        case 'segment_roi'
            data=addMeasureList('p',data.subwindow(data.axes_select).VoxelLocation(1),data.subwindow(data.axes_select).VoxelLocation(2),data.subwindow(data.axes_select).VoxelLocation(3),0,data);
            data=points2roi(data,true);

            data.mouse.action='';
            data.mouse.pressed=false;
            setMyData(data);
            show3d(false,true);
            return            
        otherwise
    end
end

if(strcmp(data.mouse.button,'extend'))
    data.mouse.button='pan';
    set_mouse_shape('pan',data)
end
if(strcmp(data.mouse.button,'alt'))
    if(data.subwindow(data.axes_select).render_type(1)=='s')
        id_detect=getHitMapClick(data);
        if(id_detect(1)>0)
            data=rmvMeasureList(id_detect(1),data);
            setMyData(data);
            show3d(false,false);
            return;
        end
    end
        data.mouse.button='zoom';
        set_mouse_shape('zoom',data);
end
setMyData(data);

function id_detect=getHitMapClick(data)
% Get the mouse position
x_2d=data.subwindow(data.axes_select).mouse_position(2);
y_2d=data.subwindow(data.axes_select).mouse_position(1); 

% To rendered image position
x_2d=round(x_2d*data.config.ImageSizeRender); 
y_2d=round(y_2d*data.config.ImageSizeRender);
m=3;
x_2d_start=x_2d-m; x_2d_start(x_2d_start<1)=1;
x_2d_end=x_2d+m; x_2d_end(x_2d_end>size(data.subwindow(data.axes_select).hitmap,1))=size(data.subwindow(data.axes_select).hitmap,1);
y_2d_start=y_2d-m; y_2d_start(y_2d_start<1)=1;
y_2d_end=y_2d+m; y_2d_end(y_2d_end>size(data.subwindow(data.axes_select).hitmap,2))=size(data.subwindow(data.axes_select).hitmap,2);
hitmap_part=data.subwindow(data.axes_select).hitmap(x_2d_start:x_2d_end,y_2d_start:y_2d_end,:);
h1=hitmap_part(:,:,1); h2=hitmap_part(:,:,2); h3=hitmap_part(:,:,3);
id_detect=[max(h1(:)) max(h2(:)) max(h3(:))];
if(isempty(id_detect)), id_detect=[0 0 0]; end

        

function data=points2roi(data,segment)
dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));

np=getnumberofpoints(data);
x=zeros(1,np); y=zeros(1,np); z=zeros(1,np);

for i=1:np;
    x(i)=data.volumes(dvs).MeasureList(end).x;
    y(i)=data.volumes(dvs).MeasureList(end).y;
    z(i)=data.volumes(dvs).MeasureList(end).z;
    data=rmvMeasureList(data.volumes(dvs).MeasureList(end).id,data);
end

[x,y,z]=interpcontour(x,y,z,2);

switch (data.subwindow(data.axes_select).render_type)
case {'slicex'}
    x_2d=y; y_2d=z; 
    sizeI=[size(data.volumes(dvs).volume_original,2) size(data.volumes(dvs).volume_original,3)];
case {'slicey'}
    x_2d=x; y_2d=z; 
    sizeI=[size(data.volumes(dvs).volume_original,1) size(data.volumes(dvs).volume_original,3)];
case {'slicez'}
    x_2d=x; y_2d=y; 
    sizeI=[size(data.volumes(dvs).volume_original,1) size(data.volumes(dvs).volume_original,2)];
end

I=bitmapplot(x_2d,y_2d,zeros(sizeI),struct('FillColor',[1 1 1 1],'Color',[1 1 1 1]))>0;

if(segment)
    data=addMeasureList('s',x,y,z,0,data);   
    
    data.volumes(dvs).MeasureList(length(data.volumes(dvs).MeasureList)).SliceSelected=0;
else
    volume=sum(I(:))*prod(data.volumes(dvs).Scales);
    data=addMeasureList('r',x,y,z,volume,data);
end


function [vx,vy,vz]=getClickRoi(data)
switch(data.subwindow(data.axes_select).render_type)
    case 'slicex'
        B=squeeze(data.volumes(dvs).volume_original(data.subwindow(data.axes_select).SliceSelected(1),:,:));
        Bx=data.subwindow(data.axes_select).VoxelLocation(2); By=data.subwindow(data.axes_select).VoxelLocation(3);
    case 'slicey'
        B=squeeze(data.volumes(dvs).volume_original(:,data.subwindow(data.axes_select).SliceSelected(2),:));
        Bx=data.subwindow(data.axes_select).VoxelLocation(1); By=data.subwindow(data.axes_select).VoxelLocation(3);
    case 'slicez'
        B=squeeze(data.volumes(dvs).volume_original(:,:,data.subwindow(data.axes_select).SliceSelected(3)));
        Bx=data.subwindow(data.axes_select).VoxelLocation(1); By=data.subwindow(data.axes_select).VoxelLocation(2);
end
B=(B-data.volumes(dvs).WindowLevel)./data.volumes(dvs).WindowWidth;
Bx=round(max(min(Bx,size(B,1)-1),2));
By=round(max(min(By,size(B,2)-1),2));
val=mean(mean(B(Bx-1:Bx+1,By-1:By+1)));
B=B-val; B=abs(B)<0.15;
L=bwlabel(B);
B=L==L(Bx,By);
B=bwmorph(bwmorph(bwmorph(imfill(B,'holes'),'remove'),'skel'),'spur',inf);
[x,y]=find(B);
for i=2:length(x)
    dist=(x(i:end)-x(i-1)).^2+(y(i:end)-y(i-1)).^2;
    [t,j]=min(dist); j=j+i-1;
    t=x(i); x(i)=x(j); x(j)=t;
    t=y(i); y(i)=y(j); y(j)=t;
    dist=(x(1)-x(i)).^2+(y(1)-y(i)).^2;
    if((i>4)&&dist<2), break; end
end
x=x(1:3:i); y=y(1:3:i);
switch(data.subwindow(data.axes_select).render_type)
    case 'slicex'
        vx=repmat(data.subwindow(data.axes_select).SliceSelected(1),size(x));
        vy=x; vz=y;
    case 'slicey'
        vy=repmat(data.subwindow(data.axes_select).SliceSelected(2),size(x));
        vx=x; vz=y;
    case 'slicez'
        vz=repmat(data.subwindow(data.axes_select).SliceSelected(3),size(x));
        vx=x; vy=y;
end


function p=getnumberofpoints(data)
p=0;
dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));
for i=length(data.volumes(dvs).MeasureList):-1:1,
    if(data.volumes(dvs).MeasureList(i).type=='p'), p=p+1; else return; end
end

function data=showMeasureList(data)
    dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));
    data.subwindow(data.axes_select).hitmap=zeros([size(data.subwindow(data.axes_select).total_image,1) size(data.subwindow(data.axes_select).total_image,2) 3]);
    if(~isfield(data.volumes(dvs),'MeasureList')), return; end
    if(length(data.subwindow(data.axes_select).render_type)<6), return; end
    SliceSelected=data.subwindow(data.axes_select).SliceSelected(uint8(data.subwindow(data.axes_select).render_type(6))-119);
    for i=1:length(data.volumes(dvs).MeasureList)
        S=data.volumes(dvs).MeasureList(i).SliceSelected;
        if(data.subwindow(data.axes_select).render_type(6)==data.volumes(dvs).MeasureList(i).RenderSelected&&(SliceSelected==S||S==0))
                id=data.volumes(dvs).MeasureList(i).id;
                x=data.volumes(dvs).MeasureList(i).x;
                y=data.volumes(dvs).MeasureList(i).y;
                z=data.volumes(dvs).MeasureList(i).z;

                [x,y]=voxelposition_to_imageposition(x,y,z,data);

                switch data.volumes(dvs).MeasureList(i).type
                    case 'd'
                        distancemm=data.volumes(dvs).MeasureList(i).varmm;
                        data=plotDistance(x,y,distancemm,id,data);
                    case 'r'
                        volumemm=data.volumes(dvs).MeasureList(i).varmm;
                        data=plotRoi(x,y,volumemm,id,data);
                     case 's'
                        data=plotSegRoi(x,y,id,data);
                    case 'p'
                        data=plotPoint(x,y,id,data);
                    case 'l'
                        data=plotPointBlue(x,y,id,data);
                end
        end
    end
    
function data=plotPoint(x,y,id,data)
I=data.subwindow(data.axes_select).total_image;
I=bitmapplot(x,y,I,struct('Marker','*','MarkerColor',[1 0 0 1],'Color',[0 0 1 1]));
data.subwindow(data.axes_select).hitmap=bitmapplot(x,y,data.subwindow(data.axes_select).hitmap,struct('Marker','*','MarkerColor',[id id 0 1],'Color',[id id 0 1]));
data.subwindow(data.axes_select).total_image=I;

function data=plotPointBlue(x,y,id,data)
I=data.subwindow(data.axes_select).total_image;
I=bitmapplot(x,y,I,struct('Marker','*','MarkerColor',[0 0 1 1],'Color',[1 0 0 1]));
data.subwindow(data.axes_select).hitmap=bitmapplot(x,y,data.subwindow(data.axes_select).hitmap,struct('Marker','*','MarkerColor',[id id 0 1],'Color',[id id 0 1]));
data.subwindow(data.axes_select).total_image=I;

function data=plotDistance(x,y,distancemm,id,data)
I=data.subwindow(data.axes_select).total_image;
I=bitmapplot(x,y,I,struct('Marker','*','MarkerColor',[1 0 0 1],'Color',[0 0 1 1]));
MC=zeros(length(x),4); MC(:,1)=id; MC(:,2)=id; MC(:,3)=(1:length(x))/length(x); MC(:,4)=1;
data.subwindow(data.axes_select).hitmap=bitmapplot(x,y,data.subwindow(data.axes_select).hitmap,struct('Marker','*','MarkerColor',MC,'Color',[id id 0 1]));
info=[num3str(distancemm,0,2) ' mm']; 
I=bitmaptext(info,I,[mean(x)-5 mean(y)-5],struct('Color',[0 1 0 1]));
data.subwindow(data.axes_select).total_image=I;

function data=plotRoi(x,y,volumemm,id,data)
I=data.subwindow(data.axes_select).total_image;
I=bitmapplot(x,y,I,struct('FillColor',[0 0 1 0.1],'Color',[1 0 0 1]));
data.subwindow(data.axes_select).hitmap=bitmapplot(x,y,data.subwindow(data.axes_select).hitmap,struct('Color',[id id 0 1]));
info=[num3str(volumemm,0,2) ' mm^3']; 
I=bitmaptext(info,I,[mean(x)-5 mean(y)-5],struct('Color',[0 1 0 1]));
data.subwindow(data.axes_select).total_image=I;


function data=plotSegRoi(x,y,id,data)
I=data.subwindow(data.axes_select).total_image;
I=bitmapplot(x,y,I,struct('FillColor',[0 1 1 0.3],'Color',[0 1 1 1],'Marker','+'));
MC=zeros(length(x),4); MC(:,1)=id; MC(:,2)=id; MC(:,3)=(1:length(x))/length(x); MC(:,4)=1;
data.subwindow(data.axes_select).hitmap=bitmapplot(x,y,data.subwindow(data.axes_select).hitmap,struct('Marker','+','MarkerColor',MC,'Color',[id id 0 1]));
data.subwindow(data.axes_select).total_image=I;


function numstr=num3str(num,bef,aft)
    numstr=num2str(num,['%.' num2str(aft) 'f']);
    if(aft>0), maxlen = bef + aft +1; else maxlen = bef; end
    while (length(numstr)<maxlen), numstr=['0' numstr]; end
    

function data=addMeasureList(type,x,y,z,varmm,data)
    dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));
    if(isempty(data.volumes(dvs).MeasureList)), p=1; else p=length(data.volumes(dvs).MeasureList)+1; end
    data.volumes(dvs).MeasureList(p).id=(rand+sum(clock)-floor(sum(clock)))/2;
    data.volumes(dvs).MeasureList(p).type=type;
    data.volumes(dvs).MeasureList(p).RenderSelected=data.subwindow(data.axes_select).render_type(6);
    SliceSelected=data.subwindow(data.axes_select).SliceSelected(uint8(data.subwindow(data.axes_select).render_type(6))-119);
    data.volumes(dvs).MeasureList(p).SliceSelected=SliceSelected;
    data.volumes(dvs).MeasureList(p).x=x;
    data.volumes(dvs).MeasureList(p).y=y;
    data.volumes(dvs).MeasureList(p).z=z;
    data.volumes(dvs).MeasureList(p).varmm=varmm;
    data=calcTotalVolume(data);

function data=rmvMeasureList(id,data)
    dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));
    index=-1;
    for i=1:length(data.volumes(dvs).MeasureList)
        if(data.volumes(dvs).MeasureList(i).id==id), index=i;end
    end
    if(index>-1)
        data.volumes(dvs).MeasureList(index)=[];
    end
   data=calcTotalVolume(data);

function data=calcTotalVolume(data)
    dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));
    data.subwindow(data.axes_select).tVolumemm=0;
    for i=1:length(data.volumes(dvs).MeasureList)
        if(data.volumes(dvs).MeasureList(i).type=='r')
            data.subwindow(data.axes_select).tVolumemm=data.subwindow(data.axes_select).tVolumemm+data.volumes(dvs).MeasureList(i).varmm;
        end
    end
   
    
function set_mouse_shape(type,data)
if(isempty(type)), type='normal'; end
switch(type)
case 'rotate1'
    set(gcf,'Pointer','custom','PointerShapeCData',data.icons.icon_mouse_rotate1,'PointerShapeHotSpot',round(size(data.icons.icon_mouse_rotate1)/2))
    set(data.handles.figure1,'Pointer','custom');
case 'rotate2'
    set(gcf,'Pointer','custom','PointerShapeCData',data.icons.icon_mouse_rotate2,'PointerShapeHotSpot',round(size(data.icons.icon_mouse_rotate2)/2))
    set(data.handles.figure1,'Pointer','custom');
case 'select_distance'
    set(data.handles.figure1,'Pointer','crosshair')
case 'select_landmark'
    set(data.handles.figure1,'Pointer','crosshair')
case 'select_roi'
    set(data.handles.figure1,'Pointer','crosshair')
case 'click_roi'
    set(data.handles.figure1,'Pointer','crosshair')   
case 'normal'
    set(data.handles.figure1,'Pointer','arrow')
case 'alt'
    set(data.handles.figure1,'Pointer','arrow')
case 'open'
    set(data.handles.figure1,'Pointer','arrow')
case 'zoom'
    set(gcf,'Pointer','custom','PointerShapeCData',data.icons.icon_mouse_zoom,'PointerShapeHotSpot',round(size(data.icons.icon_mouse_zoom)/2))
    set(data.handles.figure1,'Pointer','custom');
case 'pan'
    set(gcf,'Pointer','custom','PointerShapeCData',data.icons.icon_mouse_pan,'PointerShapeHotSpot',round(size(data.icons.icon_mouse_pan)/2))
    set(data.handles.figure1,'Pointer','custom');
    otherwise
    set(data.handles.figure1,'Pointer','arrow')        
end
  
% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
if(isempty(data.axes_select)), return, end
if(data.mouse.pressed)
    data.mouse.pressed=false;
    setMyData(data);
    show3d(false,true)
end
switch(data.mouse.action)
    case 'measure_distance',
        set_mouse_shape('select_distance',data)
    case 'measure_roi',
        set_mouse_shape('select_roi',data)
    otherwise
        set_mouse_shape('arrow',data)
end



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
if(ndims(V)>2)
    if(exist('tsize', 'var')&&~isempty(tsize)),  scale=(tsize./size(V)); end
    vmin=min(V(:));
    vmax=max(V(:));

    % Make transformation structure   
    T = makehgtform('scale',scale);
    tform = maketform('affine', T);

    % Specify resampler
    R = makeresampler(ntype, npad);

    % Resize the image volueme
    A = tformarray(V, tform, R, [1 2 3], [1 2 3], tsize, [], 0);

    % Limit to range
    A(A<vmin)=vmin; A(A>vmax)=vmax;
else
    if(exist('tsize', 'var')&&~isempty(tsize)),  
        tsize=tsize(1:2);
        scale=(tsize./size(V)); 
    end
    vmin=min(V(:));
    vmax=max(V(:));

    switch(ntype(1))
        case 'n'
            ntype2='nearest';
        case 'l'
            ntype2='bilinear';
        otherwise
            ntype2='bicubic';
    end
    
    % Transform the image
    A=imresize(V,scale.*size(V),ntype2);
    

    % Limit to range
    A(A<vmin)=vmin; A(A>vmax)=vmax;
end

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
data.volume_select=eventdata;
data.figurehandles.histogram=viewer3d_histogram(data.figurehandles.viewer3d);
handles_histogram=guidata(data.figurehandles.histogram);
data.figurehandles.histogram_axes=handles_histogram.axes_histogram;
setMyData(data);
createHistogram();
drawHistogramPoints();

% --------------------------------------------------------------------
function menu_load_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData();
if(ishandle(data.figurehandles.histogram)), close(data.figurehandles.histogram); end
[filename, dirname] = uigetfile('*.mat', 'Select a Viewer3D Matlab file',fileparts(data.history.filenames{1}));
if(ischar(filename))
    filename=[dirname filename];
    load_view(filename);
else
    viewer3d_error({'No File selected'}); return
end

function load_view(filename)
dataold=getMyData();
if(exist(filename,'file'))
    load(filename);
else
    viewer3d_error({'File Not Found'}); return    
end
if(exist('data','var'))
      % Remove current Windows and VolumeMenu's
      dataold.NumberWindows=0;
      dataold=deleteWindows(dataold);
      for i=1:length(dataold.volumes)
        delete(dataold.MenuVolume(i).Handle);
      end
      
      % Temporary store the loaded data in a new variable
      datanew=data;
      
      % Make an empty data-structure 
      data=struct;
      % Add the current figure handles and other information about the
      % current render figure.
      data.Menu=dataold.Menu;
      data.handles=dataold.handles;
      data.mouse=dataold.mouse;
      data.config=dataold.config;
      data.history=dataold.history;
      data.rendertypes=dataold.rendertypes;
      data.figurehandles=dataold.figurehandles;
      data.volumes=[];
      data.axes_select=[];
      data.volume_select=[];
      data.subwindow=[];
      data.NumberWindows=0;
      data.MenuVolume=[];
      data.icons=dataold.icons; 
      
   
      % Add the loaded volumes
      data.volumes=datanew.volumes;
      for nv=1:length(data.volumes)
        data=makeVolumeXY(data,nv);
        data=computeNormals(data,nv);
        data=makePreviewVolume(data,nv);
        data=makeRenderVolume(data,nv);
        data=createAlphaColorTable(nv,data);
      end
      
      data.NumberWindows=datanew.NumberWindows;
      data=addWindows(data);
     
 cfield={'tVolumemm', ...
 'VoxelLocation','mouse_position_pressed','mouse_position','mouse_position_last','shading_material', ...
 'ColorSlice','render_type','ViewerVector','LightVector','volume_id_select','object_id_select' ...
 'render_image','total_image','hitmap','axes_size','Zoom','viewer_matrix','SliceSelected','Mview','combine'};
      
      for i=1:data.NumberWindows
        for j=1:length(cfield);
            if(isfield(datanew.subwindow(i),cfield{j}))
                data.subwindow(i).(cfield{j})=datanew.subwindow(i).(cfield{j});
            else
            	data.subwindow(i).(cfield{j})=dataold.subwindow(1).(cfield{j});
            end
        end
      end
      
      data.substorage=datanew.substorage;
      data.axes_select=datanew.axes_select;
      data.volume_select=datanew.volume_select;
      setMyData(data);
      
      addMenuVolume();
      set_menu_checks(data);
      allshow3d(false,true);
    
    %              Menu: [1x5 struct]
    %           handles: [1x1 struct]
    %             mouse: [1x1 struct]
    %            config: [1x1 struct]
    %           history: [1x1 struct]
    %       rendertypes: [1x8 struct]
    %     figurehandles: [1x1 struct]
    %           volumes: [1x2 struct]
    %       axes_select: 1
    %     volume_select: 2
    %         subwindow: [1x2 struct]
    %     NumberWindows: 2
    %        MenuVolume: [1x2 struct]
    %             icons: [1x1 struct]
    %        substorage:

else
    viewer3d_error({'Matlab File does not contain','data from "Save View"'})
end

function data=add_filename_to_history(data,filename)
% Add curent filename to history
for i=1:5
    if(strcmpi(data.history.filenames{i},filename));
        data.history.filenames{i}=''; 
    end
end

for i=5:-1:1
    if(i==1)
        data.history.filenames{i}=filename;
    else
        data.history.filenames{i}=data.history.filenames{i-1};
    end
end
% Save filename history
history=data.history;
save(data.history.historyfile,'history');
showhistory(data);
  

function load_variable_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
V=eventdata;
volumemax=double(max(V(:))); volumemin=double(min(V(:)));
info=struct;
info.WindowWidth=volumemax-volumemin;
info.WindowLevel=0.5*(volumemax+volumemin);     
addVolume(V,[1 1 1],info);

% --------------------------------------------------------------------
function menu_load_data_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
if(ishandle(data.figurehandles.histogram)), close(data.figurehandles.histogram); end
[volume,info]=ReadData3D;
% Make the volume nD -> 4D
V=reshape(volume,size(volume,1),size(volume,2),size(volume,3),[]);
if(isempty(info)),return; end
scales=info.PixelDimensions;
if(nnz(scales)<3)
	viewer3d_error({'Pixel Scaling Unknown using [1, 1, 1]'})
	scales=[1 1 1];
end

if(exist('volume','var'))
    addVolume(V,scales,info)
else
    viewer3d_error({'Matlab Data Load Error'})
end

    

% --------------------------------------------------------------------
function menu_save_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
for dvs=1:length(data.volumes)
    data.volumes(dvs).volume_preview=[];
    data.volumes(dvs).volume=[];
    data.volumes(dvs).volumex=[];
    data.volumes(dvs).volumey=[];
    data.volumes(dvs).normals=[];
end
[filename, dirname] = uiputfile('*.mat', 'Store a Viewer3D file',fileparts(data.history.filenames{1}));
if(ischar(filename))
    filename=[dirname filename];
    h = waitbar(0,'Please wait...'); drawnow('expose')
    save(filename,'data');
    close(h);
else
    viewer3d_error({'No File selected'}); return
end

% Add curent filename to history
data=getMyData(); if(isempty(data)), return, end
data=add_filename_to_history(data,filename);
setMyData(data);


function menu_load_histogram_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
alpha=0;
uiload;
if(exist('positions','var'))
    data.volumes(dvs).histogram_positions=positions;
    data.volumes(dvs).histogram_colors=colors;
    data.volumes(dvs).histogram_alpha=alpha;
    setMyData(data);
    drawHistogramPoints();
    createAlphaColorTable();
    show3d(false,true);
else
    viewer3d_error({'Matlab File does not contain','data from "Save AlphaColors"'})
end
% --------------------------------------------------------------------
function menu_save_histogram_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
positions=data.volumes(dvs).histogram_positions;
colors=data.volumes(dvs).histogram_colors;
alpha=data.volumes(dvs).histogram_alpha;
uisave({'positions','colors','alpha'});

% --------------------------------------------------------------------
function menu_render_Callback(hObject, eventdata, handles)
% hObject    handle to menu_render (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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
imwrite(data.subwindow(data.axes_select).total_image,[pathname filename]);

% --------------------------------------------------------------------
function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
viewer3d_about
   
function createHistogram()
% This function creates and show the (log) histogram of the data    
data=getMyData(); if(isempty(data)), return, end
    dvs=data.volume_select;

    % Get histogram
    volumepart=single(data.volumes(dvs).volume(1:8:end));
    data.volumes(dvs).histogram_countsx=linspace(data.volumes(dvs).volumemin,data.volumes(dvs).volumemax,1000);
    data.volumes(dvs).histogram_countsy=hist(volumepart,data.volumes(dvs).histogram_countsx);
    
    % Log the histogram data
    data.volumes(dvs).histogram_countsy=log(data.volumes(dvs).histogram_countsy+100);
    data.volumes(dvs).histogram_countsy=data.volumes(dvs).histogram_countsy-min(data.volumes(dvs).histogram_countsy);
    data.volumes(dvs).histogram_countsy=data.volumes(dvs).histogram_countsy./max(data.volumes(dvs).histogram_countsy(:));
    
    % Focus on histogram axes
    figure(data.figurehandles.histogram)    
    % Display the histogram
    stem(data.figurehandles.histogram_axes,data.volumes(dvs).histogram_countsx,data.volumes(dvs).histogram_countsy,'Marker', 'none'); 
    hold(data.figurehandles.histogram_axes,'on'); 
    % Set the axis of the histogram axes
    data.volumes(dvs).histogram_maxy=max(data.volumes(dvs).histogram_countsy(:));
    data.volumes(dvs).histogram_maxx=max(data.volumes(dvs).histogram_countsx(:));
    
    set(data.figurehandles.histogram_axes,'yLim', [0 1]);
    set(data.figurehandles.histogram_axes,'xLim', [data.volumes(dvs).volumemin data.volumes(dvs).volumemax]);
setMyData(data);

% --- Executes on selection change in popupmenu_colors.
function popupmenu_colors_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_colors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_colors contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_colors
data=getMyData(); if(isempty(data)), return, end
    dvs=data.volume_select;
    % Generate the new color markers
    c_choice=get(handles.popupmenu_colors,'Value');
    ncolors=length(data.volumes(dvs).histogram_positions);
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
    data.volumes(dvs).histogram_colors=new_colormap;
    
    % Draw the new color markers and make the color and alpha map
    setMyData(data);
    drawHistogramPoints();
    createAlphaColorTable();
    show3d(false,true);

function drawHistogramPoints()
data=getMyData(); if(isempty(data)), return, end
    dvs=data.volume_select;

    % Delete old points and line
    try
        delete(data.volumes(dvs).histogram_linehandle), 
        for i=1:length(data.volumes(dvs).histogram_pointhandle), 
           delete(data.volumes(dvs).histogram_pointhandle(i)), 
        end, 
    catch
    end
    stem(data.figurehandles.histogram_axes,data.volumes(dvs).histogram_countsx,data.volumes(dvs).histogram_countsy,'Marker', 'none'); 
    hold(data.figurehandles.histogram_axes,'on');
    
    % Display the markers and line through the markers.
    data.volumes(dvs).histogram_linehandle=plot(data.figurehandles.histogram_axes,data.volumes(dvs).histogram_positions,data.volumes(dvs).histogram_alpha*data.volumes(dvs).histogram_maxy,'m');
    set(data.volumes(dvs).histogram_linehandle,'ButtonDownFcn','viewer3d(''lineHistogramButtonDownFcn'',gcbo,[],guidata(gcbo))');
    for i=1:length(data.volumes(dvs).histogram_positions)
        data.volumes(dvs).histogram_pointhandle(i)=plot(data.figurehandles.histogram_axes,data.volumes(dvs).histogram_positions(i),data.volumes(dvs).histogram_alpha(i)*data.volumes(dvs).histogram_maxy,'bo','MarkerFaceColor',data.volumes(dvs).histogram_colors(i,:));
        set(data.volumes(dvs).histogram_pointhandle(i),'ButtonDownFcn','viewer3d(''pointHistogramButtonDownFcn'',gcbo,[],guidata(gcbo))');
    end
    
    % For detection of mouse up, down and  in histogram figure.
    set(data.figurehandles.histogram, 'WindowButtonDownFcn','viewer3d(''HistogramButtonDownFcn'',gcbo,[],guidata(gcbo))');
    set(data.figurehandles.histogram, 'WindowButtonMotionFcn','viewer3d(''HistogramButtonMotionFcn'',gcbo,[],guidata(gcbo))');
    set(data.figurehandles.histogram, 'WindowButtonUpFcn','viewer3d(''HistogramButtonUpFcn'',gcbo,[],guidata(gcbo))');
setMyData(data);    

function pointHistogramButtonDownFcn(hObject, eventdata, handles)
data=getMyData(); if(isempty(data)), return, end
dvs=data.volume_select;
data.mouse.button=get(data.figurehandles.histogram,'SelectionType');
if(strcmp(data.mouse.button,'normal'))
    data.volumes(dvs).histogram_pointselected=find(data.volumes(dvs).histogram_pointhandle==gcbo);
    data.volumes(dvs).histogram_pointselectedhandle=gcbo;
    set(data.volumes(dvs).histogram_pointselectedhandle, 'MarkerSize',8);
    setMyData(data);
elseif(strcmp(data.mouse.button,'extend'))
    data.volumes(dvs).histogram_pointselected=find(data.volumes(dvs).histogram_pointhandle==gcbo);
    data.volumes(dvs).histogram_colors(data.volumes(dvs).histogram_pointselected,:)=rand(1,3);
    data.volumes(dvs).histogram_pointselected=[];
    setMyData(data);
    drawHistogramPoints();
    createAlphaColorTable();    
    % Show the data
    histogram_handles=guidata(data.figurehandles.histogram);
    if(get(histogram_handles.checkbox_auto_update,'value'))
        show3d(false,true);
    else
        show3d(true,true);    
    end

elseif(strcmp(data.mouse.button,'alt'))
    data.volumes(dvs).histogram_pointselected=find(data.volumes(dvs).histogram_pointhandle==gcbo);

    data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected)=[];
    data.volumes(dvs).histogram_colors(data.volumes(dvs).histogram_pointselected,:)=[];
    data.volumes(dvs).histogram_alpha(data.volumes(dvs).histogram_pointselected)=[];

    data.volumes(dvs).histogram_pointselected=[];
    setMyData(data);
    drawHistogramPoints();
    createAlphaColorTable();
    % Show the data
    histogram_handles=guidata(data.figurehandles.histogram);
    if(get(histogram_handles.checkbox_auto_update,'value'))
        show3d(false,true);
    else
        show3d(true,true);    
    end
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
dvs=data.volume_select;
if(~isempty(data.volumes(dvs).histogram_pointselected))
    set(data.volumes(dvs).histogram_pointselectedhandle, 'MarkerSize',6);
    data.volumes(dvs).histogram_pointselected=[];
    setMyData(data);
    createAlphaColorTable();
    % Show the data
    histogram_handles=guidata(data.figurehandles.histogram);
    if(get(histogram_handles.checkbox_auto_update,'value'))
        allshow3d(false,true);
    else
        allshow3d(true,true);
    end
 end

function Histogram_pushbutton_update_view_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_update_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
allshow3d(false,true)

function HistogramButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cursor_position_in_histogram_axes(hObject,handles);
data=getMyData(); if(isempty(data)), return, end
dvs=data.volume_select;
if(~isempty(data.volumes(dvs).histogram_pointselected))
 % Set point to location mouse
        data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected)=data.volumes(dvs).histogram_mouse_position(1,1); 
        data.volumes(dvs).histogram_alpha(data.volumes(dvs).histogram_pointselected)=data.volumes(dvs).histogram_mouse_position(1,2);
        
        % Correct new location
        
        if(data.volumes(dvs).histogram_alpha(data.volumes(dvs).histogram_pointselected)<0), data.volumes(dvs).histogram_alpha(data.volumes(dvs).histogram_pointselected)=0; end
        if(data.volumes(dvs).histogram_alpha(data.volumes(dvs).histogram_pointselected)>1), data.volumes(dvs).histogram_alpha(data.volumes(dvs).histogram_pointselected)=1; end
        
        if(data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected)<data.volumes(dvs).volumemin), data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected)=data.volumes(dvs).volumemin; end
        if(data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected)>data.volumes(dvs).volumemax), data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected)=data.volumes(dvs).volumemax; end
        
        if((data.volumes(dvs).histogram_pointselected>1)&&(data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected-1)>data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected)))
            data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected)=data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected-1);
        end
        
        if((data.volumes(dvs).histogram_pointselected<length(data.volumes(dvs).histogram_positions))&&(data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected+1)<data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected)))
            data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected)=data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected+1);
        end

        % Move point
        set(data.volumes(dvs).histogram_pointselectedhandle, 'xdata', data.volumes(dvs).histogram_positions(data.volumes(dvs).histogram_pointselected));
        set(data.volumes(dvs).histogram_pointselectedhandle, 'ydata', data.volumes(dvs).histogram_alpha(data.volumes(dvs).histogram_pointselected));
        
        % Move line
        set(data.volumes(dvs).histogram_linehandle, 'xdata',data.volumes(dvs).histogram_positions);
        set(data.volumes(dvs).histogram_linehandle, 'ydata',data.volumes(dvs).histogram_alpha);
end
setMyData(data);

function lineHistogramButtonDownFcn(hObject, eventdata, handles)
data=getMyData(); if(isempty(data)), return, end
dvs=data.volume_select;
        % New point on mouse location
        newposition=data.volumes(dvs).histogram_mouse_position(1,1);
        
        % List for the new markers
        newpositions=zeros(1,length(data.volumes(dvs).histogram_positions)+1);
        newalphas=zeros(1,length(data.volumes(dvs).histogram_alpha)+1);
        newcolors=zeros(size(data.volumes(dvs).histogram_colors,1)+1,3);

        % Check if the new point is between old points
        index_down=find(data.volumes(dvs).histogram_positions<=newposition); 
        if(isempty(index_down)) 
        else
            index_down=index_down(end);
            index_up=find(data.volumes(dvs).histogram_positions>newposition); 
            if(isempty(index_up)) 
            else
                index_up=index_up(1);
                
                % Copy the (first) old markers to the new lists
                newpositions(1:index_down)=data.volumes(dvs).histogram_positions(1:index_down);
                newalphas(1:index_down)=data.volumes(dvs).histogram_alpha(1:index_down);
                newcolors(1:index_down,:)=data.volumes(dvs).histogram_colors(1:index_down,:);
                
                % Add the new interpolated marker
                perc=(newposition-data.volumes(dvs).histogram_positions(index_down)) / (data.volumes(dvs).histogram_positions(index_up) - data.volumes(dvs).histogram_positions(index_down));
                color=(1-perc)*data.volumes(dvs).histogram_colors(index_down,:)+perc*data.volumes(dvs).histogram_colors(index_up,:);
                alpha=(1-perc)*data.volumes(dvs).histogram_alpha(index_down)+perc*data.volumes(dvs).histogram_alpha(index_up);
                
                newpositions(index_up)=newposition; 
                newalphas(index_up)=alpha; 
                newcolors(index_up,:)=color;
              
                % Copy the (last) old markers to the new lists
                newpositions(index_up+1:end)=data.volumes(dvs).histogram_positions(index_up:end);
                newalphas(index_up+1:end)=data.volumes(dvs).histogram_alpha(index_up:end);
                newcolors(index_up+1:end,:)=data.volumes(dvs).histogram_colors(index_up:end,:);
        
                % Make the new lists the used marker lists
                data.volumes(dvs).histogram_positions=newpositions; 
                data.volumes(dvs).histogram_alpha=newalphas; 
                data.volumes(dvs).histogram_colors=newcolors;
            end
        end
        
        % Update the histogram window
        cla(data.figurehandles.histogram_axes);
setMyData(data);
drawHistogramPoints();
createAlphaColorTable();
% Show the data
histogram_handles=guidata(data.figurehandles.histogram);
if(get(histogram_handles.checkbox_auto_update,'value'))
    show3d(false,true);
else
    show3d(true,true);    
end
       
function cursor_position_in_histogram_axes(hObject,handles)
data=getMyData(); if(isempty(data)), return, end
    dvs=data.volume_select;

%     % Get position of the mouse in the large axes
%     p = get(0, 'PointerLocation');
%     pf = get(hObject, 'pos');
%     p(1:2) = p(1:2)-pf(1:2);
%     set(data.figurehandles.histogram, 'CurrentPoint', p(1:2));
    p = get(data.figurehandles.histogram_axes, 'CurrentPoint');
    data.volumes(dvs).histogram_mouse_position=[p(1, 1) p(1, 2)];
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
data=getMyData(); if(isempty(data)), delete(hObject); return, end
try 
if(ishandle(data.figurehandles.histogram)), delete(data.figurehandles.histogram); end
if(ishandle(data.figurehandles.qualityspeed)), delete(data.figurehandles.qualityspeed); end
if(ishandle(data.figurehandles.console)), delete(data.figurehandles.console);  end
if(ishandle(data.figurehandles.contrast)), delete(data.figurehandles.contrast); end
if(ishandle(data.figurehandles.voxelsize)), delete(data.figurehandles.voxelsize); end
if(ishandle(data.figurehandles.lightvector)),  delete(data.figurehandles.lightvector); end
catch me
    disp(me.message);
end

% Remove the data of this figure
try rmappdata(gcf,'data3d'); catch end
delete(hObject);


% --------------------------------------------------------------------
function menu_shiny_Callback(hObject, eventdata, handles)
% hObject    handle to menu_shiny (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.axes_select=eventdata;
data.subwindow(data.axes_select).shading_material='shiny';
set_menu_checks(data);
setMyData(data);
show3d(false,true);

% --------------------------------------------------------------------
function menu_dull_Callback(hObject, eventdata, handles)
% hObject    handle to menu_dull (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.axes_select=eventdata;
data.subwindow(data.axes_select).shading_material='dull';
set_menu_checks(data);
setMyData(data);
show3d(false,true);

% --------------------------------------------------------------------
function menu_metal_Callback(hObject, eventdata, handles)
% hObject    handle to menu_metal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.axes_select=eventdata;
data.subwindow(data.axes_select).shading_material='metal';
set_menu_checks(data);
setMyData(data);
show3d(false,true);


function menu_combine_Callback(hObject, eventdata, handles)
% hObject    handle to menu_metal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.axes_select=eventdata(1);
switch(eventdata(2))
    case 1
        data.subwindow(data.axes_select).combine='trans';
    case 2
        data.subwindow(data.axes_select).combine='rgb';
end
setMyData(data);
set_menu_checks(data);
show3d(false,true);

function button_voxelsize_apply_Callback(hObject, eventdata, handles)
data=getMyData(); if(isempty(data)), return, end
dvs=data.volume_select;
handles_voxelsize=guidata(data.figurehandles.voxelsize);

Scales_old=data.volumes(dvs).Scales;
data.volumes(dvs).Scales(1)=str2double(get(handles_voxelsize.edit_scax,'String'));
data.volumes(dvs).Scales(2)=str2double(get(handles_voxelsize.edit_scay,'String'));
data.volumes(dvs).Scales(3)=str2double(get(handles_voxelsize.edit_scaz,'String'));
        
for i=1:data.NumberWindows
    if(data.volumes(dvs).id==data.subwindow(i).volume_id_select(1))
        Zoom_old=data.subwindow(i).Zoom;
        data.subwindow(i).first_render=true;
        data.subwindow(i).Zoom=(sqrt(3)./sqrt(sum(data.volumes(dvs).Scales.^2)));
        data.subwindow(i).viewer_matrix=data.subwindow(i).viewer_matrix*ResizeMatrix((Scales_old.*Zoom_old)./(data.volumes(dvs).Scales.*data.subwindow(i).Zoom));
    end
end

%data=set_initial_view_matrix(data);

setMyData(data);
show3d(false,true);

% --------------------------------------------------------------------
function show3d_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(~isempty(eventdata))
    show3d(eventdata(1),eventdata(2));
else
    show3d(false,false);
end


% --------------------------------------------------------------------
function UpdatedVolume_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dvs=eventdata(1);
data=getMyData(); if(isempty(data)), return, end
data=makePreviewVolume(data,dvs);
data=makeRenderVolume(data,dvs);
setMyData(data);
allshow3d(true,true);

% --------------------------------------------------------------------
function menu_voxelsize_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voxelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
dvs=eventdata;
data.volume_select=dvs;
data.figurehandles.voxelsize=viewer3d_voxelsize;
setMyData(data);
handles_voxelsize=guidata(data.figurehandles.voxelsize);
set(handles_voxelsize.edit_volx,'String',num2str(size(data.volumes(dvs).volume,1)));
set(handles_voxelsize.edit_voly,'String',num2str(size(data.volumes(dvs).volume,2)));
set(handles_voxelsize.edit_volz,'String',num2str(size(data.volumes(dvs).volume,3)));
set(handles_voxelsize.edit_scax,'String',num2str(data.volumes(dvs).Scales(1)));
set(handles_voxelsize.edit_scay,'String',num2str(data.volumes(dvs).Scales(2)));
set(handles_voxelsize.edit_scaz,'String',num2str(data.volumes(dvs).Scales(3)));


function button_lightvector_apply_Callback(hObject, eventdata, handles)
data=getMyData(); if(isempty(data)), return, end
handles_lightvector=guidata(data.figurehandles.lightvector);
data.subwindow(data.axes_select).LightVector(1)=str2double(get(handles_lightvector.edit_lightx,'String'));
data.subwindow(data.axes_select).LightVector(2)=str2double(get(handles_lightvector.edit_lighty,'String'));
data.subwindow(data.axes_select).LightVector(3)=str2double(get(handles_lightvector.edit_lightz,'String'));
setMyData(data);
show3d(false,true);

% --------------------------------------------------------------------
function menu_lightvector_Callback(hObject, eventdata, handles)
% hObject    handle to menu_voxelsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.axes_select=eventdata;
data.figurehandles.lightvector=viewer3d_lightvector;
setMyData(data);
handles_lightvector=guidata(data.figurehandles.lightvector);
set(handles_lightvector.edit_lightx,'String',num2str(data.subwindow(data.axes_select).LightVector(1)));
set(handles_lightvector.edit_lighty,'String',num2str(data.subwindow(data.axes_select).LightVector(2)));
set(handles_lightvector.edit_lightz,'String',num2str(data.subwindow(data.axes_select).LightVector(3)));


% --------------------------------------------------------------------
function menu_load_worksp_Callback(hObject, eventdata, handles)
% hObject    handle to menu_load_worksp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.figurehandles.workspacevars=viewer3d_workspacevars;
setMyData(data)
% Get variables in the workspace
vars = evalin('base','who');
% Select only variables with 3 dimensions
vars3d=[];
for i=1:length(vars),
    if(evalin('base',['ndims(' vars{i} ')'])>1), vars3d{length(vars3d)+1}=vars{i}; end
end
% Show the 3D variables in the workspace
handles_workspacevars=guidata(data.figurehandles.workspacevars);
set(handles_workspacevars.listbox_vars,'String',vars3d);

% --- Executes on button press in pushbutton1.
function workspacevars_button_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
handles_workspacevars=guidata(data.figurehandles.workspacevars);
list_entries = get(handles_workspacevars.listbox_vars,'String');
index_selected = get(handles_workspacevars.listbox_vars,'Value');
if length(index_selected) ~= 1
	errordlg('You must select one variable')
    return;
else
    var1 = list_entries{index_selected(1)};
    evalin('base',['viewer3d(''load_variable_Callback'',gcf,' var1 ',guidata(gcf))']);
end 
if(ishandle(data.figurehandles.workspacevars)), close(data.figurehandles.workspacevars); end


function console_button_clear_Callback(hObject, eventdata, handles)
data=getMyData(); if(isempty(data)), return, end
data.subwindow(data.axes_select).consoletext=[];
data.subwindow(data.axes_select).consolelines=0;
set(data.figurehandles.console_edit,'String','');
setMyData(data);

function data=console_addline(data,newline)
if(ishandle(data.figurehandles.console)),
    data.subwindow(data.axes_select).consolelines=data.subwindow(data.axes_select).consolelines+1;
    data.subwindow(data.axes_select).consoletext{data.subwindow(data.axes_select).consolelines}=newline;
    if(data.subwindow(data.axes_select).consolelines>14), 
        data.subwindow(data.axes_select).consolelines=14; 
        data.subwindow(data.axes_select).consoletext={data.subwindow(data.axes_select).consoletext{2:end}}; 
    end
    set(data.figurehandles.console_edit,'String',data.subwindow(data.axes_select).consoletext);
end

% --------------------------------------------------------------------
function menu_console_Callback(hObject, eventdata, handles)
% hObject    handle to menu_console (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
keyboard
data.figurehandles.console=viewer3d_console;
handles_console=guidata(data.figurehandles.console);
data.figurehandles.console_edit=handles_console.edit_console;
data.subwindow(data.axes_select).consoletext=[];
data.subwindow(data.axes_select).consolelines=0;
setMyData(data)
set(data.figurehandles.console_edit,'String','');


function menu_compile_files_Callback(hObject, eventdata, handles)
% This script will compile all the C files
cd('SubFunctions');
clear affine_transform_2d_double;
mex affine_transform_2d_double.c image_interpolation.c -v
cd('..');


% --------------------------------------------------------------------
function menu_quality_speed_Callback(hObject, eventdata, handles)
% hObject    handle to menu_quality_speed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.figurehandles.qualityspeed=viewer3d_qualityspeed;
setMyData(data);
handles_qualityspeed=guidata(data.figurehandles.qualityspeed);
switch(data.config.VolumeScaling)
    case{25}
        set(handles_qualityspeed.uipanel_VolumeScaling,'SelectedObject',handles_qualityspeed.radiobutton_scaling25);
    case{50}
        set(handles_qualityspeed.uipanel_VolumeScaling,'SelectedObject',handles_qualityspeed.radiobutton_scaling50);
    case{100}
        set(handles_qualityspeed.uipanel_VolumeScaling,'SelectedObject',handles_qualityspeed.radiobutton_scaling100);
    case{200}
        set(handles_qualityspeed.uipanel_VolumeScaling,'SelectedObject',handles_qualityspeed.radiobutton_scaling200);
end
switch(data.config.PreviewVolumeSize)
    case{32}
        set(handles_qualityspeed.uipanel_PreviewVolumeSize,'SelectedObject',handles_qualityspeed.radiobutton_preview_32);
    case{64}
        set(handles_qualityspeed.uipanel_PreviewVolumeSize,'SelectedObject',handles_qualityspeed.radiobutton_preview_64);
    case{100}
        set(handles_qualityspeed.uipanel_PreviewVolumeSize,'SelectedObject',handles_qualityspeed.radiobutton_preview_100);
end
switch(data.config.ImageSizeRender)
    case{150}
        set(handles_qualityspeed.uipanel_ImageSizeRender,'SelectedObject',handles_qualityspeed.radiobutton_rendersize150);
    case{250}
        set(handles_qualityspeed.uipanel_ImageSizeRender,'SelectedObject',handles_qualityspeed.radiobutton_rendersize250);
    case{400}
        set(handles_qualityspeed.uipanel_ImageSizeRender,'SelectedObject',handles_qualityspeed.radiobutton_rendersize400);
    case{600}
        set(handles_qualityspeed.uipanel_ImageSizeRender,'SelectedObject',handles_qualityspeed.radiobutton_rendersize600);
    case{800}
        set(handles_qualityspeed.uipanel_ImageSizeRender,'SelectedObject',handles_qualityspeed.radiobutton_rendersize800);
    case{1400}
        set(handles_qualityspeed.uipanel_ImageSizeRender,'SelectedObject',handles_qualityspeed.radiobutton_rendersize1400);
    case{2500}
        set(handles_qualityspeed.uipanel_ImageSizeRender,'SelectedObject',handles_qualityspeed.radiobutton_rendersize2500);
end
switch(data.config.ShearInterpolation)
    case{'bilinear'}
        set(handles_qualityspeed.uipanel_ShearInterpolation,'SelectedObject',handles_qualityspeed.radiobutton_shear_int_bilinear);
    case{'nearest'}
        set(handles_qualityspeed.uipanel_ShearInterpolation,'SelectedObject',handles_qualityspeed.radiobutton_shear_int_nearest);
end
switch(data.config.WarpInterpolation)
    case{'bicubic'}
        set(handles_qualityspeed.uipanel_WarpInterpolation,'SelectedObject',handles_qualityspeed.radiobutton_warp_int_bicubic);
    case{'bilinear'}
        set(handles_qualityspeed.uipanel_WarpInterpolation,'SelectedObject',handles_qualityspeed.radiobutton_warp_int_bilinear);
    case{'nearest'}
        set(handles_qualityspeed.uipanel_WarpInterpolation,'SelectedObject',handles_qualityspeed.radiobutton_warp_int_nearest);
end
set(handles_qualityspeed.checkbox_prerender,'Value',data.config.PreRender);
set(handles_qualityspeed.checkbox_storexyz,'Value',data.config.StoreXYZ);


% --- Executes on button press in pushbutton_applyconfig.
function qualityspeed_pushbutton_applyconfig_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_applyconfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
handles_qualityspeed=guidata(data.figurehandles.qualityspeed);

VolumeScaling=get(get(handles_qualityspeed.uipanel_VolumeScaling,'SelectedObject'),'Tag');
PreviewVolumeSize=get(get(handles_qualityspeed.uipanel_PreviewVolumeSize,'SelectedObject'),'Tag');
ShearInterpolation=get(get(handles_qualityspeed.uipanel_ShearInterpolation,'SelectedObject'),'Tag');
WarpInterpolation=get(get(handles_qualityspeed.uipanel_WarpInterpolation,'SelectedObject'),'Tag');
ImageSizeRender=get(get(handles_qualityspeed.uipanel_ImageSizeRender,'SelectedObject'),'Tag');

VolumeScaling=str2double(VolumeScaling(20:end));
ImageSizeRender=str2double(ImageSizeRender(23:end));

PreviewVolumeSize=str2double(PreviewVolumeSize(21:end));
data.config.ShearInterpolation=ShearInterpolation(23:end);
data.config.WarpInterpolation=WarpInterpolation(22:end);
data.config.PreRender=get(handles_qualityspeed.checkbox_prerender,'Value');
data.config.StoreXYZ=get(handles_qualityspeed.checkbox_storexyz,'Value');

if(ImageSizeRender~=data.config.ImageSizeRender)
    s=data.config.ImageSizeRender/ImageSizeRender;
    data.subwindow(data.axes_select).viewer_matrix=data.subwindow(data.axes_select).viewer_matrix*ResizeMatrix([s s s]);
    data.config.ImageSizeRender=ImageSizeRender;
end

scale_change=data.config.VolumeScaling~=VolumeScaling;
if(scale_change)
      data.config.VolumeScaling=VolumeScaling;
      for dvs=1:length(data.volumes)
          data=makeRenderVolume(data,dvs);
      end
end

if(data.config.PreviewVolumeSize~=PreviewVolumeSize)
    data.config.PreviewVolumeSize=PreviewVolumeSize;
    for dvs=1:length(data.volumes)
        data=makePreviewVolume(data,dvs);
    end
end
for dvs=1:length(data.volumes)
    data.volume_id_select(1)=data.volumes(dvs).id;
    if((isempty(data.volumes(dvs).volumey)||scale_change)&&data.config.StoreXYZ)
        data=makeVolumeXY(data);
    end
    if(~data.config.StoreXYZ)
        data.volumes(dvs).volumex=[]; data.volumes(dvs).volumey=[];
    end
end


if((isempty(data.volumes(dvs).normals)||scale_change)&&data.config.PreRender)
    % Make normals
    for dvs=1:length(data.volumes)
        data=computeNormals(data,dvs);
    end
end
if(~data.config.PreRender)
    data.volumes(dvs).normals=[];
end

data.subwindow(data.axes_select).first_render=true;
setMyData(data);
show3d(false,true);

function data=makeVolumeXY(data,dvs)
if(data.config.StoreXYZ)
    data.volumes(dvs).volumex=shiftdim(data.volumes(dvs).volume,1);
    data.volumes(dvs).volumey=shiftdim(data.volumes(dvs).volume,2);
else
    data.volumes(dvs).volumex=[];
    data.volumes(dvs).volumey=[];
end

function data=computeNormals(data,dvs)
if(data.config.PreRender)
    % Pre computer Normals for faster shading rendering.
    [fy,fx,fz]=gradient(imgaussian(double(data.volumes(dvs).volume),1/2));
    flength=sqrt(fx.^2+fy.^2+fz.^2)+1e-6;
    data.volumes(dvs).normals=zeros([size(fx) 3]);
    data.volumes(dvs).normals(:,:,:,1)=fx./flength;
    data.volumes(dvs).normals(:,:,:,2)=fy./flength;
    data.volumes(dvs).normals(:,:,:,3)=fz./flength;
else
    data.volumes(dvs).normals=[];
end

function I=imgaussian(I,sigma,siz)
% IMGAUSSIAN filters an 1D, 2D or 3D image with an gaussian filter.
% This function uses IMFILTER, for the filtering but instead of using
% a multidimensional gaussian kernel, it uses the fact that a gaussian
% filter can be separated in 1D gaussian kernels.
%
% J=IMGAUSSIAN(I,SIGMA,SIZE)
%
% inputs,
%   I: The 1D, 2D, or 3D input image
%   SIGMA: The sigma used for the gaussian
%   SIZE: Kernel size (single value) (default: sigma*6)
% 
% outputs,
%   J: The gaussian filterd image
%
% example,
%   I = im2double(rgb2gray(imread('peppers.png')));
%   figure, imshow(imgaussian(I,3));
% 
% Function is written by D.Kroon University of Twente (October 2008)

if(~exist('siz','var')), siz=sigma*6; end

% Make 1D gaussian kernel
x=-(siz/2)+0.5:siz/2;
H = exp(-(x.^2/(2*sigma^2))); 
H = H/sum(H(:));

% Filter each dimension with the 1D gaussian kernels
if(ndims(I)==1)
    I=imfilter(I,H);
elseif(ndims(I)==2)
    Hx=reshape(H,[length(H) 1]); 
    Hy=reshape(H,[1 length(H)]); 
    I=imfilter(imfilter(I,Hx),Hy);
elseif(ndims(I)==3)
    Hx=reshape(H,[length(H) 1 1]); 
    Hy=reshape(H,[1 length(H) 1]); 
    Hz=reshape(H,[1 1 length(H)]);
    I=imfilter(imfilter(imfilter(I,Hx),Hy),Hz);
else
    error('imgaussian:input','unsupported input dimension');
end

             
% --- Executes on button press in pushbutton_saveconfig.
function qualityspeed_pushbutton_saveconfig_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveconfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
handles_qualityspeed=guidata(data.figurehandles.qualityspeed);
VolumeScaling=get(get(handles_qualityspeed.uipanel_VolumeScaling,'SelectedObject'),'Tag');
PreviewVolumeSize=get(get(handles_qualityspeed.uipanel_PreviewVolumeSize,'SelectedObject'),'Tag');
ShearInterpolation=get(get(handles_qualityspeed.uipanel_ShearInterpolation,'SelectedObject'),'Tag');
WarpInterpolation=get(get(handles_qualityspeed.uipanel_WarpInterpolation,'SelectedObject'),'Tag');
ImageSizeRender=get(get(handles_qualityspeed.uipanel_ImageSizeRender,'SelectedObject'),'Tag');
VolumeScaling=str2double(VolumeScaling(20:end));
PreviewVolumeSize=str2double(PreviewVolumeSize(21:end));
data.config.ImageSizeRender=str2double(ImageSizeRender(23:end));
data.config.ShearInterpolation=ShearInterpolation(23:end);
data.config.WarpInterpolation=WarpInterpolation(22:end);
data.config.PreRender=get(handles_qualityspeed.checkbox_prerender,'Value');
data.config.StoreXYZ=get(handles_qualityspeed.checkbox_storexyz,'Value');
data.config.VolumeScaling=VolumeScaling;
data.config.PreviewVolumeSize=PreviewVolumeSize;

% Save the default config
config=data.config;
functiondir=which('viewer3d.m'); functiondir=functiondir(1:end-length('viewer3d.m'));
save([functiondir '/default_config.mat'],'config')


% --------------------------------------------------------------------
function menu_measure_Callback(hObject, eventdata, handles)
% hObject    handle to menu_measure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_config_contrast_Callback(hObject, eventdata, handles)
% hObject    handle to menu_config_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.figurehandles.contrast=viewer3d_contrast(data.figurehandles.viewer3d);
handles_contrast=guidata(data.figurehandles.contrast);

dvs=eventdata;
data.volume_select=dvs;

c=(data.volumes(dvs).volumemin+data.volumes(dvs).volumemax)/2;
dmin=c-data.volumes(dvs).volumemin;
dmax=data.volumes(dvs).volumemax-c;
amin=c-dmin*4; amax=c+dmax*4;
set(handles_contrast.slider_window_width,'Min',0);
set(handles_contrast.slider_window_width,'Max',amax);
set(handles_contrast.slider_window_level,'Min',amin);
set(handles_contrast.slider_window_level,'Max',amax);

data.volumes(dvs).WindowWidth=min(max(data.volumes(dvs).WindowWidth,0),amax);
data.volumes(dvs).WindowLevel=min(max(data.volumes(dvs).WindowLevel,amin),amax);

set(handles_contrast.slider_window_width,'value',data.volumes(dvs).WindowWidth);
set(handles_contrast.slider_window_level,'value',data.volumes(dvs).WindowLevel);
set(handles_contrast.edit_window_width,'String',num2str(data.volumes(dvs).WindowWidth));
set(handles_contrast.edit_window_level,'String',num2str(data.volumes(dvs).WindowLevel));
setMyData(data);


% --------------------------------------------------------------------
function menu_measure_distance_Callback(hObject, eventdata, handles)
% hObject    handle to menu_measure_distance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.mouse.button='select_distance';
data.mouse.action='measure_distance';
setMyData(data);
set_mouse_shape('select_distance',data)
    

% --------------------------------------------------------------------
function menu_measure_roi_Callback(hObject, eventdata, handles)
% hObject    handle to menu_measure_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.mouse.button='select_roi';
data.mouse.action='measure_roi';
setMyData(data);
set_mouse_shape('select_roi',data)

% --------------------------------------------------------------------
function menu_segment_roi_Callback(hObject, eventdata, handles)
% hObject    handle to menu_measure_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.mouse.button='select_roi';
data.mouse.action='segment_roi';
setMyData(data);
viewer3d_segment;
set_mouse_shape('select_roi',data)

function data=checkvolumetype(data,nv)
if(nargin<2), s=1; e=length(data.volumes); else s=nv; e=nv; end
for i=s:e
     data.volumes(i).volumemin=double(min(data.volumes(i).volume_original(:)));
     data.volumes(i).volumemax=double(max(data.volumes(i).volume_original(:)));
     if( data.volumes(i).volumemax==0),  data.volumes(i).volumemax=1; end
     switch(class(data.volumes(i).volume_original))
     case {'uint8','uint16','uint32','int8','int16','int32','single','double'}
     otherwise
        viewer3d_error({'Unsupported input datatype converted to double'});
        data.volumes(i).volume_original=double(data.volumes(i).volume_original);
     end
     data.volumes(i).WindowWidth=data.volumes(i).volumemax-data.volumes(i).volumemin;
     data.volumes(i).WindowLevel=0.5*(data.volumes(i).volumemax+data.volumes(i).volumemin);     
end
    
% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
if(isempty(data.axes_select)), return, end
switch data.subwindow(data.axes_select).render_type
    case {'slicex','slicey','slicez'}
        handles=guidata(hObject);
        data=changeslice(eventdata.VerticalScrollCount,handles,data);
        setMyData(data);
        show3d(false,true);
end

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
if(strcmp(eventdata.Key,'uparrow')), eventdata.Character='+'; end
if(strcmp(eventdata.Key,'downarrow')), eventdata.Character='-'; end
    
switch data.subwindow(data.axes_select).render_type
    case {'slicex','slicey','slicez'}
        handles=guidata(hObject);
        switch(eventdata.Character)
            case '+'
                data=changeslice(1,handles,data);
                setMyData(data); show3d(true,true);
            case '-'
                data=changeslice(-1,handles,data);
                setMyData(data); show3d(true,true);
            case 'r'
                menu_measure_roi_Callback(hObject, eventdata, handles);
            case 'd'
                menu_measure_distance_Callback(hObject, eventdata, handles);
            case 'l'
                menu_measure_landmark_Callback(hObject, eventdata, handles);
            case 'c'
                 menu_segment_roi_Callback(hObject, eventdata, handles);
            otherwise
        end
     otherwise        
end

function data=changeslice(updown,handles,data)
dvss=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));
switch data.subwindow(data.axes_select).render_type
case 'slicex'
    data.subwindow(data.axes_select).SliceSelected(1)=data.subwindow(data.axes_select).SliceSelected(1)+updown;
    if(data.subwindow(data.axes_select).SliceSelected(1)>size(data.volumes(dvss).volume_original,1)),  data.subwindow(data.axes_select).SliceSelected(1)=size(data.volumes(dvss).volume_original,1); end
case 'slicey'
    data.subwindow(data.axes_select).SliceSelected(2)=data.subwindow(data.axes_select).SliceSelected(2)+updown;
    if(data.subwindow(data.axes_select).SliceSelected(2)>size(data.volumes(dvss).volume_original,2)),  data.subwindow(data.axes_select).SliceSelected(2)=size(data.volumes(dvss).volume_original,2); end
case 'slicez'
    data.subwindow(data.axes_select).SliceSelected(3)=data.subwindow(data.axes_select).SliceSelected(3)+updown;
    if(data.subwindow(data.axes_select).SliceSelected(3)>size(data.volumes(dvss).volume_original,3)),  data.subwindow(data.axes_select).SliceSelected(3)=size(data.volumes(dvss).volume_original,3); end
end
% Boundary limit
data.subwindow(data.axes_select).SliceSelected(data.subwindow(data.axes_select).SliceSelected<1)=1;
% Stop measurement
data.mouse.action='';


% --- Executes on key release with focus on figure1 and none of its controls.
function figure1_KeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
switch data.subwindow(data.axes_select).render_type
    case {'slicex','slicey','slicez'}
        show3d(false,true);
end

function data=InfoOnScreen(data)
if (size(data.subwindow(data.axes_select).total_image,3)==3)
    I=data.subwindow(data.axes_select).total_image;
else
    % Greyscale to color
    I(:,:,1)=data.subwindow(data.axes_select).total_image; 
    I(:,:,2)=data.subwindow(data.axes_select).total_image; 
    I(:,:,3)=data.subwindow(data.axes_select).total_image;
end

if(data.subwindow(data.axes_select).render_type(1)=='s')
    dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));
    info=cell(1,5);
    switch data.subwindow(data.axes_select).render_type
    case 'slicex'
        info{1}=['Slice X : ' num2str(data.subwindow(data.axes_select).SliceSelected(1))];
    case 'slicey'
        info{1}=['Slice y : ' num2str(data.subwindow(data.axes_select).SliceSelected(2))];
    case 'slicez'
        info{1}=['Slice Z : ' num2str(data.subwindow(data.axes_select).SliceSelected(3))];
    end
    VL=data.subwindow(data.axes_select).VoxelLocation;
    VL(1)=min(max(VL(1),1),data.volumes(dvs).Size_original(1));
    VL(2)=min(max(VL(2),1),data.volumes(dvs).Size_original(2));
    VL(3)=min(max(VL(3),1),data.volumes(dvs).Size_original(3));
    
    info{2}=['ROIs mm^3: ' num2str(data.subwindow(data.axes_select).tVolumemm)];
    info{3}=['x,y,z px: ' num2str(VL(1)) ' - ' num2str(VL(2)) ' - ' num2str(VL(3))]; 
    info{4}=['x,y,z mm: ' num2str(VL(1)*data.volumes(dvs).Scales(1)) ' - ' num2str(VL(2)*data.volumes(dvs).Scales(2)) ' - ' num2str(VL(3)*data.volumes(dvs).Scales(3))]; 
    info{5}=['Val: ' num2str(data.volumes(dvs).volume_original(VL(1),VL(2),VL(3)))];
    I=bitmaptext(info,I,[1 1],struct('Color',[0 1 0 1]));
end

data.subwindow(data.axes_select).total_image=I;




function I=bitmaptext(lines,I,pos,options)
% The function BITMAPTEXT will insert textline(s) on the specified position
% in the image.
%
% I=bitmaptext(Text,Ibackground,Position,options)
%
% inputs,
%   Text : Cell array with text lines
%   Ibackground: the bitmap used as background when a m x n x 3 matrix
%       color plots are made, when m x n a greyscale plot. If empty []
%       autosize to fit text.
%   Position: x,y position of the text
%   options: struct with options such as color
%
% outputs,
%   Iplot: The bitmap containing the plotted text
%
% note,
%   Colors are always [r(ed) g(reen) b(lue) a(pha)], with range 0..1.
%   when Ibackground is grayscale, the mean of r,g,b is used as grey value.
%
% options,
%   options.Color: The color of the text.
%   options.FontSize: The size of the font, 1,2 or 3 (small,medium,large).
%
% example,
%
%  % The text consisting of 2 lines
%  lines={'a_A_j_J?,','ImageText version 1.1'};
%  % Background image
%  I=ones([256 256 3]);
%  % Plot text into background image
%  I=bitmaptext(lines,I,[1 1],struct('FontSize',3));
%  % Show the result
%  figure, imshow(I),
%
% Function is written by D.Kroon University of Twente (March 2009)
global character_images;

% Process inputs
defaultoptions=struct('Color',[0 0 1 1],'FontSize',1);
if(~exist('options','var')), 
    options=defaultoptions; 
else
    tags = fieldnames(defaultoptions);
    for i=1:length(tags)
         if(~isfield(options,tags{i})),  options.(tags{i})=defaultoptions.(tags{i}); end
    end
    if(length(tags)~=length(fieldnames(options))), 
        warning('register_images:unknownoption','unknown options found');
    end
end

% If single line make it a cell array
if(~iscell(lines)), lines={lines}; end

if(~exist('I','var')), I=[]; end
if(exist('pos','var')),
     if(length(pos)~=2)
         error('imagtext:inputs','position must have x,y coordinates'); 
     end
else
    pos=[1 1];
end
% Round the position
pos=round(pos);

% Set the size of the font
fsize=options.FontSize;

% The character bitmap and character set;
character_set='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*()_+-=[]\;'''',./{}|:"<>?';
if(isempty(character_images)), character_images=load_font(); end

% Font parameters
Font_sizes_x=[8 10 11];
Font_sizes_y=[13 15 18];
Font_startx=[1 1 1];
Font_starty=[1 14 29];

% Get maximum sentence length
lengths=zeros(1,length(lines));
for i=1:length(lines), lengths(i)=length(lines{i}); end 
max_line_length=max(lengths);

% Make text image from the lines
lines_image=zeros([(Font_sizes_y(fsize)+4)*length(lines),max_line_length*Font_sizes_x(fsize)],'double');
for j=1:length(lines)
    line=lines{j};
    for i=1:length(line),
        [t,p]=find(character_set==line(i));
        if(~isempty(p))
            p=p(1)-1;
            character_bitmap=character_images(Font_starty(fsize):(Font_starty(fsize)+Font_sizes_y(fsize)-1),Font_startx(fsize)+(1+p*Font_sizes_x(fsize)):Font_startx(fsize)+((p+1)*Font_sizes_x(fsize)));
            posx=Font_sizes_x(fsize)*(i-1);
            posy=(Font_sizes_y(fsize)+4)*(j-1);
            lines_image((1:Font_sizes_y(fsize))+posy,(1:Font_sizes_x(fsize))+posx)=character_bitmap;
        end
    end
end

if(isempty(I)), I=zeros([size(lines_image) 3]); end

% Remove part of textimage which will be outside of the output image
if(pos(1)<1), lines_image=lines_image(2-pos(1):end,:); pos(1)=1; end
if(pos(2)<2), lines_image=lines_image(:,2-pos(2):end); pos(2)=1; end
if((pos(1)+size(lines_image,1))>size(I,1)), dif=size(I,1)-(pos(1)+size(lines_image,1)); lines_image=lines_image(1:end+dif,:); end
if((pos(2)+size(lines_image,2))>size(I,2)), dif=size(I,2)-(pos(2)+size(lines_image,2)); lines_image=lines_image(:,1:end+dif); end
% Make text image the same size as background image
I_line=zeros([size(I,1) size(I,2)]);
I_line(pos(1):(pos(1)+size(lines_image,1)-1),pos(2):(pos(2)+size(lines_image,2)-1))=lines_image;
I_line=I_line*options.Color(4);
% Insert the text image into the output image
if(~isempty(lines_image))
    if(size(I,3)==3)
        for i=1:3
            I(:,:,i)=I(:,:,i).*(1-I_line)+options.Color(i)*(I_line);
        end
    else
        I=I.*(1-I_line)+mean(options.Color(1:3))*(I_line);
    end
end

function character_images=load_font()
character_images=uint8([0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 9 9 6 0 0 0 0 1 4 2 3 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 4 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 6 0 0 0 0 0 0 0 0 0 0 0 0 4 9 9 9 2 0 0 0 0 0 0 0 0 3 9 2 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 1 7 1 0 0 0 5 9 1 0 0 0 0 0 3 9 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 9 9 6 0 0 0 3 9 9 9 9 9 1 0 0 0 4 9 9 6 3 2 1 8 9 9 9 8 1 0 3 9 9 9 9 9 6 0 0 5 9 9 9 9 9 5 0 0 5 9 9 6 4 1 2 9 9 2 2 9 9 2 0 4 9 9 9 9 5 0 0 0 1 8 9 9 9 8 3 9 9 6 1 8 9 6 2 9 9 9 8 1 0 0 8 9 1 0 0 2 9 6 4 9 3 0 3 9 9 6 0 0 4 9 9 6 0 0 0 5 9 9 9 9 3 0 0 0 4 9 9 6 0 0 2 9 9 9 9 6 0 0 0 0 5 9 9 6 5 0 3 9 9 9 9 9 9 1 4 9 9 3 3 9 9 9 8 9 8 1 1 8 9 9 9 9 9 1 2 9 9 5 5 9 6 0 2 9 9 2 3 9 9 1 0 5 9 5 0 3 9 9 9 9 3 0 0 0 4 9 3 0 0 0 0 0 5 9 9 3 0 0 0 0 3 9 9 6 0 0 0 0 0 0 8 5 0 0 0 1 8 9 9 8 1 0 0 0 0 2 9 9 8 1 0 5 9 9 9 9 3 0 0 0 4 9 9 5 0 0 0 0 4 9 9 5 0 0 0 0 3 9 9 5 0 0 0 0 0 4 5 0 0 0 0 1 8 1 0 4 2 0 0 0 1 4 3 2 0 0 0 0 4 9 9 9 2 0 0 2 9 9 5 0 0 0 0 0 0 8 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 3 2 0 0 0 0 0 0 0 0 5 1 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 9 1 0 0 0 8 9 3 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 6 0 0 0 0 0 0 8 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 1 8 3 0 0 0 0 4 8 1 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 5 8 1 5 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 5 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 0 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 3 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 1 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 5 4 1 0 0 0 3 2 0 0 2 6 0 0 4 5 0 0 3 9 2 0 2 5 0 0 2 8 1 0 3 3 0 0 1 5 0 0 0 5 1 0 0 1 4 0 4 3 0 0 3 9 1 0 3 2 0 0 2 5 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 2 0 0 3 2 0 0 4 5 0 0 0 4 1 0 0 0 0 1 8 5 0 0 4 5 1 0 4 5 1 0 1 5 0 0 4 5 0 0 3 6 0 0 0 7 1 0 0 5 1 0 4 5 0 0 3 8 1 0 3 3 0 0 4 3 0 0 3 3 0 0 4 6 0 3 3 0 4 2 0 5 1 0 4 1 0 0 0 5 0 0 5 0 0 0 0 5 1 2 3 0 0 0 0 5 1 0 5 3 0 0 4 2 0 0 2 3 0 0 2 5 0 0 3 3 0 0 4 2 0 0 3 5 2 3 0 0 0 0 4 3 0 0 8 2 0 0 4 6 0 0 3 3 0 0 0 0 5 3 4 0 0 0 1 4 0 0 0 0 0 0 0 3 8 1 0 0 0 0 5 1 0 0 3 3 0 0 3 5 0 0 4 2 0 0 2 6 0 0 4 3 0 0 2 6 0 0 4 2 0 0 0 0 3 5 0 0 0 0 3 3 0 0 2 3 0 0 0 2 5 3 2 0 0 0 2 5 0 0 4 2 0 0 4 1 0 5 1 0 0 0 0 5 2 2 6 0 0 0 0 1 8 9 6 0 0 0 1 1 3 2 1 3 0 0 0 0 0 2 5 0 0 0 0 4 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 3 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 6 0 0 0 0 0 0 5 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 3 3 0 0 0 0 0 0 4 2 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 2 9 1 2 8 1 0 0 0 0 0 0 3 8 1 0 8 3 0 0 0 0 0 0 2 6 0 0 4 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 2 9 9 9 3 0 0 0 5 2 8 9 9 1 0 0 0 4 9 9 6 5 1 0 1 8 9 9 2 5 0 0 1 8 9 9 6 0 0 0 4 9 9 9 9 6 0 0 0 8 9 9 3 9 3 0 3 3 8 9 8 1 0 0 3 9 9 3 0 0 0 0 5 9 9 9 3 0 0 0 0 5 1 3 9 9 8 1 0 0 3 3 0 0 1 8 7 8 8 2 9 8 1 3 9 4 9 9 8 1 0 0 0 5 9 9 8 1 0 5 9 3 9 9 9 1 0 0 0 5 9 9 2 8 6 0 5 9 3 3 9 8 1 0 0 5 9 9 7 5 0 1 8 9 9 9 9 2 0 3 9 2 0 4 9 3 0 4 9 9 3 2 9 9 6 5 9 5 0 0 4 9 6 1 8 9 2 2 9 9 1 1 8 9 1 0 3 9 6 0 3 9 9 9 9 6 0 0 0 3 2 2 3 0 0 0 3 2 0 0 2 5 0 1 4 0 0 0 0 0 0 0 2 5 0 0 0 3 3 0 3 3 0 5 0 0 0 0 0 5 1 3 3 0 0 1 5 0 0 0 0 0 0 0 3 2 0 0 2 5 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 2 0 0 3 2 0 5 5 0 0 0 0 4 1 0 0 0 0 1 4 5 1 1 4 5 1 0 4 3 5 0 1 5 0 1 5 0 0 0 0 4 2 0 0 7 1 0 0 3 2 1 4 0 0 0 0 3 3 0 3 3 0 0 1 4 0 0 3 3 0 0 0 0 0 0 0 0 4 2 0 0 0 0 4 1 0 0 0 5 0 0 4 2 0 0 2 3 0 1 4 0 5 3 0 5 1 0 0 8 2 3 5 0 0 0 0 5 2 0 7 1 0 0 0 0 0 3 5 0 0 0 0 0 2 3 0 0 0 0 0 0 0 0 3 2 0 0 0 0 0 0 3 3 0 0 0 4 3 1 4 0 0 0 1 4 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 5 1 0 0 3 2 0 0 3 3 0 0 3 2 0 0 0 5 0 0 4 1 0 0 1 4 0 0 0 0 3 3 0 0 0 0 4 1 0 8 9 3 0 0 4 9 9 9 9 6 0 0 3 2 0 0 0 0 0 0 2 9 9 5 0 0 0 0 4 3 0 0 3 5 0 0 0 4 2 0 0 0 0 0 2 9 9 9 9 1 0 0 0 0 0 5 2 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 3 0 0 0 0 0 0 0 0 0 0 0 3 9 9 9 9 9 9 3 0 0 0 3 3 0 0 0 0 0 0 3 3 0 0 0 0 0 3 3 0 0 0 0 0 0 0 8 9 1 0 0 0 0 0 5 5 0 0 0 0 0 0 5 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 3 3 0 0 0 0 0 0 3 2 0 0 0 0 0 0 3 3 0 0 0 0 0 0 8 8 1 0 0 0 5 3 0 5 2 0 0 0 0 0 1 8 6 0 0 0 0 5 9 1 0 0 0 0 0 0 0 0 1 4 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 1 1 0 0 5 2 0 0 5 9 1 0 1 7 1 0 4 5 0 0 3 9 1 0 7 1 0 0 8 6 0 0 5 1 0 0 3 6 0 0 0 1 5 0 0 0 0 0 5 2 0 1 8 3 0 0 3 9 1 0 3 3 0 0 0 0 3 3 0 0 0 0 0 0 0 2 3 0 0 0 0 5 1 3 8 1 0 0 0 0 3 3 0 0 0 1 8 2 2 8 1 3 2 0 3 8 1 0 3 3 0 0 5 3 0 0 2 6 0 0 5 8 1 0 1 7 1 0 5 3 0 0 8 6 0 0 0 2 9 6 0 2 2 0 3 3 0 0 4 6 0 0 0 5 1 0 0 0 0 0 3 2 0 0 2 3 0 0 3 3 0 0 2 5 0 1 4 0 0 0 0 4 1 0 1 8 1 1 8 2 0 0 2 3 0 0 0 5 1 0 3 2 0 1 8 1 0 0 0 5 1 0 5 0 0 0 3 9 9 9 8 1 0 2 3 0 0 0 0 0 0 0 2 5 0 0 0 2 5 0 3 9 9 6 0 0 0 0 0 5 9 9 3 0 0 2 3 0 0 0 0 0 0 0 3 9 9 9 9 3 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 2 0 0 3 2 8 3 0 0 0 0 0 4 1 0 0 0 0 1 4 2 3 4 2 5 1 0 4 1 4 1 1 5 0 3 3 0 0 0 0 2 3 0 0 7 1 0 0 5 1 2 3 0 0 0 0 2 3 0 3 3 0 0 5 2 0 0 0 5 9 9 6 0 0 0 0 0 4 2 0 0 0 0 4 1 0 0 0 5 0 0 1 4 0 0 4 1 0 1 5 0 5 5 0 5 0 0 0 1 8 6 0 0 0 0 0 0 7 6 2 0 0 0 0 0 1 5 0 0 0 0 0 0 2 3 0 0 0 0 0 0 0 0 5 0 0 0 0 0 8 9 6 0 0 0 3 5 0 1 4 0 0 0 1 8 9 9 8 1 0 0 2 5 8 9 9 1 0 0 0 0 0 1 4 0 0 0 0 8 9 9 6 0 0 0 2 6 0 0 3 8 1 0 4 1 0 0 1 5 0 0 0 0 3 3 0 0 0 0 4 1 4 2 2 3 0 0 0 2 3 4 1 0 0 0 0 8 9 1 0 0 0 0 0 0 1 8 9 8 1 0 0 0 0 0 0 0 0 0 0 2 3 0 0 0 0 0 0 3 6 5 1 0 0 0 0 0 0 7 1 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 3 0 0 0 0 0 0 7 1 0 0 0 0 0 0 8 9 1 0 0 0 0 0 4 3 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 2 0 0 0 0 0 0 3 3 0 0 0 0 0 0 8 8 1 0 0 0 0 0 0 0 0 0 0 0 0 5 9 1 0 0 0 0 0 0 1 8 6 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 1 8 9 9 9 2 0 0 5 2 0 0 0 3 2 0 5 0 0 0 0 0 0 2 3 0 0 0 1 5 0 1 8 9 9 9 9 8 1 0 0 1 5 0 0 0 0 1 5 0 0 0 3 3 0 0 3 2 0 0 2 3 0 0 0 0 3 3 0 0 0 0 0 0 0 2 3 0 0 0 0 5 9 6 0 0 0 0 0 0 3 3 0 0 0 1 5 0 2 5 0 3 2 0 3 2 0 0 2 3 0 1 4 0 0 0 0 4 1 0 5 2 0 0 0 3 2 1 5 0 0 0 2 6 0 0 0 2 3 0 0 0 0 0 0 8 9 9 8 1 0 0 0 5 1 0 0 0 0 0 3 2 0 0 2 3 0 0 0 7 1 0 5 1 0 0 5 1 5 6 0 5 0 0 0 1 8 9 1 0 0 0 0 5 1 0 2 3 0 0 0 0 1 8 1 0 0 0 2 5 0 0 4 2 0 0 3 2 0 0 2 9 1 2 3 0 0 0 0 0 0 0 2 5 0 0 0 2 5 0 3 3 0 5 0 0 0 0 0 5 1 3 3 0 0 2 3 0 0 8 9 9 5 0 3 2 0 0 2 3 0 0 0 0 3 3 0 0 0 0 7 1 0 0 3 2 0 0 3 9 2 5 3 0 0 0 0 4 1 0 0 0 0 1 4 0 8 6 0 5 1 0 4 1 1 5 1 5 0 3 3 0 0 0 0 2 3 0 0 8 9 9 9 3 0 3 3 0 0 0 0 2 3 0 3 9 9 9 3 0 0 0 0 0 0 0 3 6 0 0 0 0 4 2 0 0 0 0 4 1 0 0 0 5 0 0 0 5 1 1 5 0 0 0 5 2 3 5 2 5 0 0 0 1 8 8 1 0 0 0 0 0 2 5 0 0 0 0 0 0 7 1 0 0 0 0 0 0 2 3 0 0 0 0 0 0 1 8 2 0 0 0 0 0 0 0 4 3 0 0 4 9 9 9 9 3 0 0 0 0 0 0 2 5 0 0 3 9 3 0 1 5 0 0 0 0 0 3 2 0 0 0 2 2 0 0 2 1 0 0 0 3 9 9 6 5 1 0 4 1 0 0 1 5 0 0 0 0 3 3 0 0 0 0 4 1 5 1 2 3 0 0 0 3 3 4 1 0 0 0 0 0 1 8 9 2 0 0 5 9 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 1 0 0 0 0 0 5 1 1 5 0 0 0 0 0 1 7 1 0 0 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 0 1 8 9 9 9 9 9 2 0 8 9 9 9 9 8 1 3 9 9 9 9 9 9 3 0 0 0 3 3 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 4 6 0 0 0 0 0 0 0 0 8 3 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 3 0 0 0 0 0 0 0 0 0 0 3 9 3 0 0 0 2 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 7 1 0 0 3 2 0 0 5 1 0 0 0 3 2 0 5 0 0 0 0 0 0 2 3 0 0 0 1 5 0 0 5 0 0 0 0 0 0 0 0 1 5 0 0 0 0 1 5 0 0 0 2 3 0 0 3 2 0 0 2 3 0 0 0 0 3 3 0 0 0 0 0 0 0 2 3 0 0 0 0 5 4 8 1 0 0 0 0 0 3 3 0 0 0 1 5 0 2 5 0 3 2 0 3 2 0 0 2 3 0 1 4 0 0 0 0 4 1 0 5 1 0 0 0 3 2 1 5 0 0 0 1 5 0 0 0 2 3 0 0 0 0 0 0 0 0 0 2 6 0 0 0 5 1 0 0 0 0 0 3 2 0 0 2 3 0 0 0 3 2 2 5 0 0 0 4 2 5 4 2 4 0 0 0 2 9 9 2 0 0 0 0 2 3 0 5 1 0 0 0 1 8 1 0 0 0 0 4 9 9 9 9 5 0 0 3 2 0 0 0 3 2 1 5 0 0 0 0 0 0 0 2 5 0 0 0 3 3 0 3 3 0 0 0 0 0 0 0 5 1 0 0 0 0 1 4 0 0 0 0 4 1 0 3 2 0 0 2 3 0 0 0 0 3 3 0 0 0 0 7 1 0 0 4 2 0 0 3 2 0 0 5 1 0 0 0 4 1 0 0 3 2 1 4 0 1 1 0 5 1 0 4 1 0 3 3 5 0 1 5 0 0 0 0 4 2 0 0 7 1 0 0 0 0 1 4 0 0 0 0 4 2 0 3 3 0 2 8 1 0 0 0 0 0 0 0 7 1 0 0 0 4 2 0 0 0 0 4 1 0 0 1 5 0 0 0 2 3 3 2 0 0 0 5 5 2 3 5 4 0 0 0 7 1 3 6 0 0 0 0 0 2 5 0 0 0 0 0 5 2 0 0 0 0 0 0 0 2 3 0 0 0 0 0 3 9 1 0 0 0 0 0 0 0 0 0 5 0 0 0 0 0 1 4 0 0 0 0 0 0 0 0 5 0 0 3 6 0 0 0 5 1 0 0 0 0 5 1 0 0 0 4 1 0 0 2 3 0 0 0 0 0 0 0 5 0 0 4 2 0 0 1 4 0 0 0 0 0 0 0 0 0 0 4 1 1 8 9 6 0 0 8 9 9 9 9 3 0 0 4 1 0 0 2 3 0 0 0 0 3 9 9 2 0 0 0 0 0 0 0 0 0 0 3 3 1 5 4 5 0 0 0 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 2 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 3 0 0 0 0 0 0 0 0 3 6 0 0 0 0 0 2 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 1 5 0 0 1 8 2 0 0 5 6 0 0 1 7 1 0 4 3 0 0 0 8 2 0 7 1 0 0 4 6 0 0 4 3 0 0 0 0 0 0 0 1 5 0 0 0 0 0 5 1 0 0 5 3 0 0 3 2 0 0 2 3 0 0 0 0 3 3 0 0 0 0 0 0 0 2 3 0 0 0 0 5 1 2 8 1 0 0 0 0 3 3 0 0 0 1 5 0 2 5 0 3 2 0 3 2 0 0 2 3 0 0 5 1 0 0 0 5 0 0 5 6 0 0 0 5 1 0 5 1 0 0 4 6 0 0 0 2 3 0 0 0 0 0 5 1 0 0 2 5 0 0 0 5 1 0 2 8 1 0 3 3 0 1 8 3 0 0 0 0 5 5 1 0 0 0 2 4 3 2 6 2 0 0 3 8 1 0 8 3 0 0 0 0 5 2 3 0 0 0 1 8 1 0 0 5 0 0 5 0 0 0 0 5 1 0 3 2 0 0 0 7 1 0 4 3 0 0 0 8 2 0 2 5 0 0 0 7 1 0 3 3 0 0 0 5 1 0 0 5 1 0 0 0 0 0 5 1 0 0 0 4 1 0 3 2 0 0 2 3 0 0 0 0 3 3 0 0 0 0 5 3 0 1 8 1 0 0 3 2 0 0 2 5 0 0 0 4 1 0 0 3 2 1 4 0 0 0 0 5 1 0 4 1 0 0 8 6 0 0 4 5 0 0 3 6 0 0 0 7 1 0 0 0 0 0 4 3 0 0 3 6 0 0 3 3 0 0 3 5 0 0 7 1 0 0 1 4 0 0 0 0 4 2 0 0 0 0 3 5 0 0 3 5 0 0 0 0 8 8 1 0 0 0 5 5 1 1 8 3 0 0 5 2 0 0 4 5 0 0 0 0 2 5 0 0 0 0 3 3 0 0 0 5 0 0 0 0 2 3 0 0 0 0 4 6 0 0 0 0 0 0 5 2 0 0 4 5 0 0 0 0 0 1 4 0 0 0 5 3 0 0 3 5 0 0 0 5 2 0 0 5 0 0 0 0 1 4 0 0 0 0 3 2 0 0 2 3 0 0 0 0 0 0 4 2 0 0 1 3 0 0 4 2 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 3 2 5 1 0 0 0 4 9 9 9 8 1 0 0 0 0 5 0 0 5 0 0 0 0 0 0 0 0 0 0 3 5 0 3 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 3 3 0 0 0 0 2 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 9 5 0 0 0 0 0 0 8 8 1 0 0 0 0 7 1 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 2 0 0 0 0 0 0 3 3 0 0 0 0 0 0 8 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 1 0 0 0 0 1 8 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 3 9 9 9 4 9 2 4 9 4 9 9 9 1 0 0 0 5 9 9 9 2 0 0 2 9 9 9 6 8 6 0 0 5 9 9 9 8 1 0 5 9 9 9 9 5 0 0 1 8 9 9 6 3 0 3 9 9 2 2 9 9 3 0 8 9 9 9 9 8 1 0 0 0 0 2 3 0 0 0 5 9 1 4 9 9 3 0 8 9 9 9 9 8 1 8 9 5 2 9 3 3 9 6 9 9 2 2 9 9 3 0 1 8 9 9 9 2 0 0 5 4 9 9 9 3 0 0 1 8 9 9 6 5 0 0 8 9 9 9 9 2 0 0 5 9 9 9 8 1 0 0 0 2 9 9 8 1 0 0 1 8 9 9 3 9 3 0 0 0 3 5 0 0 0 0 1 8 1 0 7 1 0 3 9 9 2 2 9 9 3 0 0 0 2 8 1 0 0 0 4 9 9 9 9 6 1 8 9 9 1 0 8 9 9 4 9 9 9 9 9 3 0 0 0 5 9 9 9 2 0 1 8 9 9 9 9 2 0 3 9 9 9 9 9 8 1 0 5 9 9 9 1 0 0 0 1 8 9 9 9 5 0 3 9 9 2 2 9 9 3 0 4 9 9 9 9 5 0 0 0 5 9 9 2 0 0 3 9 9 6 0 0 8 6 2 9 9 9 9 9 9 3 8 9 9 1 1 8 9 8 5 9 9 3 0 2 6 0 0 0 4 9 9 6 0 0 0 5 9 9 9 1 0 0 0 0 5 9 9 6 0 0 2 9 9 6 0 0 5 6 0 8 9 9 9 9 1 0 0 3 9 9 9 8 1 0 0 0 4 9 9 6 0 0 0 0 0 3 3 0 0 0 0 4 5 0 0 5 3 0 5 9 8 1 1 8 9 5 0 1 8 9 9 9 2 0 0 4 9 9 9 9 6 0 0 4 9 9 9 9 6 0 1 8 9 9 9 9 2 0 0 0 8 9 9 6 0 0 0 0 0 4 9 9 3 0 0 0 5 9 9 6 0 0 0 0 0 8 9 9 2 0 0 0 0 3 2 0 0 0 0 0 8 9 9 8 1 0 0 2 9 9 9 5 0 0 0 0 5 9 9 5 0 0 0 0 0 5 6 0 0 0 0 1 7 1 0 5 2 0 0 0 4 1 5 1 0 0 0 0 0 3 2 0 0 0 0 0 0 3 9 9 2 0 0 0 0 0 0 0 0 0 0 0 5 9 9 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 5 2 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 7 1 0 0 0 4 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 1 0 0 0 0 0 0 8 8 1 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 4 2 0 0 0 0 0 0 3 3 0 0 0 0 0 0 8 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 6 0 0 8 9 1 0 0 0 0 0 0 0 8 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 1 0 0 0 0 0 0 0 0 0 0 0 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 9 3 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 9 5 0 0 0 0 4 2 5 0 0 0 0 0 0 3 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 5 0 0 0 0 4 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 3 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 8 3 0 0 0 0 4 8 1 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 9 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 9 6 0 0 0 0 0 0 0 0 4 9 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 9 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 1 0 8 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 1 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 9 1 0 0 0 8 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 9 9 9 9 9 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 3 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 5 2 5 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 4 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 9 9 9 1 0 0 0 0 0 0 0 0 0 0 3 9 6 0 0 0 0 0 0 0 0 0 0 0 5 3 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 3 9 6 0 0 0 0 0 0 0 0 8 9 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 3 0 0 0 0 0 0 1 8 9 9 3 0 0 0 0 0 0 8 9 9 8 1 0 0 0 0 0 0 0 5 8 1 0 0 0 0 4 9 9 9 9 5 0 0 0 0 0 0 1 8 9 9 5 0 0 2 9 9 9 9 9 8 1 0 0 0 0 8 9 9 6 0 0 0 0 0 0 5 9 9 6 0 0 0 0 0 0 3 9 9 6 0 0 0 0 0 0 0 4 6 0 0 0 0 0 0 0 4 9 9 8 1 0 0 0 0 0 3 3 2 5 0 0 0 0 0 0 5 9 9 9 6 0 0 0 0 4 9 9 3 0 0 0 0 0 0 0 0 8 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 2 6 0 0 0 0 4 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 9 5 0 0 0 0 3 9 9 3 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 1 0 0 0 0 0 0 1 8 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 6 0 2 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 9 9 8 1 0 0 0 2 9 9 9 9 9 9 2 0 0 0 0 0 8 9 9 8 1 7 1 0 8 9 9 9 9 9 3 0 0 2 9 9 9 9 9 9 9 3 0 0 4 9 9 9 9 9 9 9 2 0 0 0 8 9 9 9 2 5 0 0 8 9 9 1 1 8 9 8 1 0 2 9 9 9 9 9 9 2 0 0 0 0 2 9 9 9 9 9 9 3 9 9 9 5 3 9 9 8 1 2 9 9 9 9 9 2 0 0 0 5 9 8 1 0 0 0 5 9 6 3 9 9 2 0 1 8 9 9 5 0 0 0 5 9 9 9 2 0 0 0 3 9 9 9 9 9 6 0 0 0 0 0 5 9 9 9 2 0 0 1 8 9 9 9 9 9 1 0 0 0 0 0 8 9 9 8 3 3 0 1 8 9 9 9 9 9 9 6 0 4 9 9 9 2 2 9 9 9 6 8 9 9 8 1 0 8 9 9 6 5 9 9 6 0 1 8 9 9 3 4 9 9 3 0 0 8 9 9 1 2 9 9 6 0 0 4 9 9 3 0 0 8 9 9 9 9 9 1 0 0 2 9 9 3 3 0 0 0 0 0 1 8 2 0 0 8 3 0 0 0 2 9 2 0 0 3 8 1 0 0 0 0 0 3 7 7 1 0 0 0 0 4 2 0 0 0 0 0 0 0 0 0 3 9 1 0 0 0 0 0 2 5 0 0 0 0 7 1 0 0 0 5 2 0 0 3 5 0 0 0 0 4 5 0 0 3 6 0 0 0 0 3 6 0 0 3 5 0 0 0 0 0 0 4 6 0 0 0 0 0 0 4 6 0 0 3 6 0 0 0 0 0 3 3 2 3 0 0 0 0 0 5 3 0 0 2 6 0 0 0 2 5 0 0 5 1 0 0 0 0 0 0 5 5 4 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 8 1 0 0 0 0 0 0 1 8 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 8 6 0 0 0 0 0 0 5 8 1 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 1 0 5 6 0 0 0 0 0 0 0 0 0 5 6 0 0 5 5 0 0 0 0 0 0 0 0 0 0 5 9 9 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 5 4 2 0 0 0 0 0 7 1 0 0 1 8 1 0 0 2 9 2 0 0 2 9 8 1 0 0 5 1 0 0 0 5 3 0 0 0 7 1 0 0 0 3 3 0 0 0 2 5 0 0 0 0 4 2 0 1 8 2 0 0 1 8 6 0 0 1 5 0 0 0 0 5 1 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 7 1 0 0 5 5 0 0 0 0 0 7 1 0 0 0 0 0 0 7 6 3 0 0 2 7 5 0 0 2 9 6 0 0 0 4 3 0 0 1 8 3 0 0 1 8 3 0 0 0 2 5 0 0 0 3 6 0 0 0 8 3 0 0 0 8 5 0 0 0 7 1 0 0 2 9 1 0 0 0 8 2 0 0 2 9 3 0 1 5 0 0 4 2 0 1 5 0 0 2 5 0 0 0 0 3 3 0 0 3 3 0 0 0 0 3 5 0 1 5 0 0 0 0 0 2 5 0 0 3 6 0 0 0 2 8 1 0 0 0 7 1 0 0 0 5 1 0 0 0 7 1 0 0 1 7 1 0 0 0 0 0 2 3 0 0 0 0 0 3 3 0 0 0 1 5 0 0 0 0 0 0 0 0 0 5 1 0 0 0 0 1 8 2 7 1 0 0 0 0 4 2 0 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 2 5 0 0 0 1 5 0 0 0 0 7 1 0 0 0 7 1 0 0 0 3 2 0 0 0 5 0 0 0 0 5 1 0 0 0 0 0 4 5 0 0 0 0 0 0 7 1 0 0 0 7 1 0 0 0 0 4 2 3 3 0 0 0 0 0 5 0 0 0 0 0 0 0 0 2 5 0 0 5 1 0 0 0 0 0 4 6 0 0 5 5 0 0 0 0 0 2 9 9 9 1 0 0 0 2 9 1 3 3 1 8 2 0 0 0 0 0 0 3 6 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 6 0 0 0 0 0 0 0 0 8 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 4 2 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 3 0 2 9 2 0 0 0 0 0 0 0 3 9 3 0 0 0 0 4 9 2 0 0 0 0 0 0 0 8 3 0 0 3 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 1 8 9 9 9 5 0 0 0 0 3 3 2 9 9 9 3 0 0 0 0 0 8 9 9 9 3 5 0 0 0 3 9 9 9 3 3 3 0 0 0 4 9 9 9 8 1 0 0 0 1 8 9 9 9 9 9 3 0 0 0 3 9 9 9 2 8 9 2 0 1 5 3 9 9 9 2 0 0 0 0 8 9 9 3 0 0 0 0 0 3 9 9 9 9 8 1 0 0 0 0 1 5 0 3 9 9 9 1 0 0 0 0 3 3 0 0 0 2 9 6 5 9 5 2 9 9 2 0 2 9 8 1 8 9 9 2 0 0 0 0 1 8 9 9 9 1 0 0 4 9 3 3 9 9 9 3 0 0 0 0 2 9 9 9 3 3 9 5 0 2 9 9 2 2 9 9 6 0 0 0 1 8 9 9 8 5 2 0 0 8 9 9 9 9 9 6 0 0 3 9 6 0 0 3 9 9 1 0 3 9 9 9 2 1 8 9 9 5 5 9 9 2 0 0 2 9 9 5 0 8 9 9 1 1 8 9 8 1 0 8 9 9 1 0 1 8 9 5 0 0 8 9 9 9 9 9 2 0 0 0 0 4 2 2 6 0 0 0 0 0 7 1 0 0 0 4 2 0 0 5 1 0 0 0 0 1 7 1 0 0 5 1 0 0 0 0 7 1 0 0 7 1 0 0 0 3 3 0 0 0 2 5 0 0 0 0 4 2 0 5 1 0 0 0 0 0 0 0 0 1 5 0 0 0 0 5 1 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 7 1 0 8 3 0 0 0 0 0 0 7 1 0 0 0 0 0 0 7 2 8 1 0 4 3 5 0 0 2 5 5 3 0 0 4 3 0 0 4 3 0 0 0 0 1 8 1 0 0 2 5 0 0 0 0 5 1 0 4 3 0 0 0 0 0 5 2 0 0 7 1 0 0 0 4 2 0 0 2 6 0 0 0 0 3 3 0 1 5 0 0 4 2 0 1 5 0 0 2 5 0 0 0 0 3 3 0 0 1 5 0 0 0 0 5 1 0 0 7 1 0 8 3 0 2 5 0 0 0 3 6 0 2 8 1 0 0 0 0 2 6 0 0 4 3 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 2 3 0 0 0 0 0 0 0 0 0 0 2 5 0 0 0 0 0 0 0 0 3 6 0 0 0 0 0 5 3 0 7 1 0 0 0 0 4 2 0 0 0 0 0 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 0 0 4 2 0 0 0 0 7 1 0 0 1 5 0 0 0 0 7 1 0 0 0 3 3 0 0 1 4 0 0 0 0 4 2 0 0 0 0 0 4 5 0 0 0 0 0 2 6 0 0 5 9 8 1 0 0 2 9 9 9 9 9 9 2 0 0 0 7 1 0 0 0 0 0 0 0 0 4 9 9 3 0 0 0 0 0 2 8 1 0 0 0 8 2 0 0 0 0 7 1 0 0 0 0 0 0 0 1 8 9 9 9 1 0 0 0 0 0 0 0 5 3 0 0 0 0 0 0 2 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 9 9 9 9 9 9 9 9 2 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 8 9 2 0 0 0 0 0 0 0 5 5 0 0 0 0 0 0 0 0 5 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 2 9 9 1 0 0 0 0 3 6 0 0 5 5 0 0 0 0 0 0 0 8 6 0 0 0 0 0 0 0 0 8 8 1 0 0 0 0 0 7 1 0 0 0 4 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 4 6 0 0 0 3 6 8 1 0 0 5 3 0 0 1 8 2 0 0 0 8 6 0 0 3 6 0 0 0 5 9 3 0 0 3 5 0 0 0 2 8 1 0 0 0 0 1 5 0 0 0 0 0 0 3 6 0 0 1 8 9 1 0 0 1 8 6 0 0 2 9 1 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 1 5 0 0 1 1 0 0 0 0 0 0 3 3 0 0 0 0 1 8 3 0 5 8 1 2 8 1 0 0 8 9 1 0 1 8 1 0 0 2 9 1 0 0 1 8 2 0 0 3 6 6 0 0 0 5 3 0 0 3 8 1 0 0 5 6 3 0 0 0 0 4 9 9 1 0 1 1 0 0 8 2 0 0 2 9 2 0 0 0 1 5 0 0 0 0 0 0 0 1 5 0 0 0 0 5 1 0 0 0 7 1 0 0 0 5 2 0 0 5 1 0 0 0 0 1 5 0 0 0 5 5 0 0 4 6 0 0 0 1 8 1 0 0 0 2 6 0 0 0 7 1 0 0 3 6 0 0 0 0 1 5 0 0 5 1 0 0 0 0 7 1 0 0 1 8 1 0 1 5 0 0 0 0 0 0 0 0 0 0 5 1 0 0 0 0 4 3 0 0 7 1 0 7 1 0 0 0 0 0 2 5 0 3 5 0 0 0 1 7 1 0 0 0 0 0 0 0 0 1 5 0 0 0 0 5 1 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 7 1 8 2 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 7 1 5 3 1 5 1 5 0 0 2 5 1 7 1 0 4 3 0 0 7 1 0 0 0 0 0 4 3 0 0 2 5 0 0 0 0 5 1 0 7 1 0 0 0 0 0 3 3 0 0 7 1 0 0 3 8 1 0 0 0 8 2 0 0 0 0 0 0 1 5 0 0 4 2 0 1 5 0 0 2 5 0 0 0 0 3 3 0 0 0 4 2 0 0 2 6 0 0 0 5 1 1 6 5 0 3 3 0 0 0 0 4 7 8 1 0 0 0 0 0 0 3 5 3 5 0 0 0 0 0 0 0 0 5 2 0 0 0 0 0 0 0 2 5 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 1 8 9 6 0 0 0 0 0 3 6 0 0 7 1 0 0 0 0 4 9 9 9 9 2 0 0 0 0 7 1 5 9 9 3 0 0 0 0 0 0 0 0 7 1 0 0 0 0 1 8 9 9 9 1 0 0 0 0 4 5 0 0 3 9 5 0 0 2 6 0 0 0 0 4 3 0 0 0 0 0 3 5 0 0 0 0 0 2 5 0 4 5 0 7 1 0 0 0 0 4 2 4 2 0 0 0 0 0 2 9 9 3 0 0 0 0 0 0 0 0 1 8 9 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 1 0 0 0 0 0 0 0 0 4 5 5 3 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 8 9 2 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 2 9 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 2 0 0 0 0 0 0 0 0 0 0 2 9 3 0 0 0 0 0 0 0 0 0 5 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 1 5 0 0 0 3 6 0 0 0 0 0 7 1 0 4 3 0 0 0 0 0 0 0 0 7 1 0 0 0 0 4 3 0 0 7 1 0 0 0 0 2 5 0 0 0 0 1 5 0 0 0 0 0 0 7 1 0 0 0 1 8 1 0 0 1 5 0 0 0 0 5 1 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 1 5 0 8 6 0 0 0 0 0 0 0 3 3 0 0 0 0 1 5 0 0 4 3 0 1 7 1 0 0 8 2 0 0 0 5 1 0 0 5 1 0 0 0 0 1 5 0 0 3 6 0 0 0 0 0 7 1 0 7 1 0 0 0 0 5 3 0 0 0 0 4 5 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 1 5 0 0 0 0 5 1 0 0 0 3 3 0 0 1 5 0 0 0 3 2 0 5 6 0 2 3 0 0 0 0 4 6 4 5 0 0 0 0 0 4 6 0 0 0 5 2 0 0 0 0 0 0 4 6 0 0 0 0 0 3 3 0 0 3 5 0 0 0 0 8 9 9 9 9 3 0 0 1 5 0 0 0 0 0 0 0 0 0 0 5 1 0 0 0 0 3 3 0 0 8 9 9 8 1 0 0 0 0 0 2 9 9 9 5 0 0 0 1 5 0 0 0 0 0 0 0 0 0 1 8 9 9 9 9 9 1 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 8 9 2 8 3 0 0 0 0 0 0 7 1 0 0 0 0 0 0 7 1 2 8 5 2 1 5 0 0 2 5 0 4 5 0 4 3 0 1 5 0 0 0 0 0 0 3 3 0 0 2 5 0 0 0 2 6 0 1 5 0 0 0 0 0 0 3 3 0 0 8 9 9 9 6 0 0 0 0 0 0 8 9 9 9 1 0 0 0 0 0 0 4 2 0 0 0 0 0 2 5 0 0 0 0 3 3 0 0 0 2 5 0 0 4 2 0 0 0 5 1 3 3 5 1 4 2 0 0 0 0 0 8 3 0 0 0 0 0 0 0 0 4 8 1 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 2 5 0 0 0 0 0 0 0 0 1 8 2 0 0 0 0 0 0 0 0 0 4 6 0 0 0 1 8 1 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 7 5 3 0 0 5 3 0 0 0 0 0 0 2 5 0 0 0 0 0 4 1 0 0 1 3 0 0 0 0 0 5 9 9 6 2 5 0 0 2 6 0 0 0 0 4 3 0 0 0 0 0 3 5 0 0 0 0 0 2 5 0 7 1 0 7 1 0 0 0 0 5 1 4 2 0 0 0 0 0 0 0 0 5 9 5 0 0 0 3 9 9 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 8 1 0 0 0 0 0 0 1 7 1 1 8 1 0 0 0 0 0 0 2 8 1 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 9 9 9 9 9 9 8 1 0 4 9 9 9 9 9 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 1 0 0 0 0 0 2 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 8 9 9 9 9 6 0 0 0 3 3 0 0 0 0 0 5 1 0 4 2 0 0 0 0 0 0 0 1 5 0 0 0 0 0 3 3 0 1 8 9 9 9 9 9 9 6 0 0 0 0 1 5 0 0 0 0 0 1 5 0 0 0 0 0 7 1 0 0 1 5 0 0 0 0 5 1 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 1 8 9 5 0 0 0 0 0 0 0 0 3 3 0 0 0 0 1 5 0 0 4 3 0 1 7 1 0 0 7 1 0 0 0 5 1 0 0 7 1 0 0 0 0 0 7 1 0 3 3 0 0 0 0 0 5 1 1 5 0 0 0 0 0 3 3 0 0 0 0 4 2 0 0 0 0 0 0 0 2 9 9 9 9 3 0 0 0 0 1 5 0 0 0 0 0 0 0 1 5 0 0 0 0 5 1 0 0 0 0 7 1 0 4 2 0 0 0 2 5 1 5 5 1 4 2 0 0 0 0 0 5 6 0 0 0 0 0 0 0 8 2 0 2 5 0 0 0 0 0 0 4 5 0 0 0 0 0 0 8 9 9 9 9 8 1 0 0 0 7 1 0 0 0 5 6 0 1 7 1 0 0 0 0 0 0 0 0 0 5 1 0 0 0 0 4 2 0 0 7 1 0 7 1 0 0 0 0 0 2 5 0 3 5 0 0 0 1 7 1 0 0 8 9 9 9 5 0 1 5 0 0 0 0 5 1 0 0 0 0 0 3 3 0 0 0 0 0 4 2 0 0 0 1 5 0 0 0 0 7 1 0 0 5 2 0 0 0 0 0 7 1 0 0 0 5 1 0 7 1 0 5 8 1 1 5 0 0 2 5 0 0 8 2 4 3 0 0 7 1 0 0 0 0 0 4 3 0 0 2 9 9 9 9 8 1 0 0 7 1 0 0 0 0 0 3 3 0 0 7 1 0 2 9 1 0 0 0 0 0 0 0 0 1 8 3 0 0 0 0 0 4 2 0 0 0 0 0 2 5 0 0 0 0 3 3 0 0 0 0 5 1 0 7 1 0 0 0 4 2 5 1 3 3 4 2 0 0 0 0 5 2 5 3 0 0 0 0 0 0 0 2 5 0 0 0 0 0 0 0 3 5 0 0 3 3 0 0 0 0 0 2 5 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 0 0 0 0 0 4 2 0 0 3 9 9 9 9 9 8 1 0 0 0 0 0 0 0 0 3 3 0 0 0 8 5 0 0 0 0 5 0 0 0 0 0 0 4 2 0 0 0 0 1 5 0 0 0 0 7 1 0 0 0 0 0 0 0 0 3 3 0 0 1 5 0 0 0 0 4 2 0 0 0 0 0 3 3 0 0 0 0 0 2 5 0 5 2 0 7 1 0 0 4 9 9 9 9 9 8 1 0 0 0 0 0 0 0 0 5 1 0 0 0 0 0 3 9 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 8 5 6 0 8 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 8 1 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 9 9 9 9 9 9 9 9 2 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 8 6 0 0 0 0 0 0 0 0 0 0 5 8 1 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 2 0 0 0 0 0 0 0 0 0 0 2 9 3 0 0 0 0 0 0 3 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 8 2 0 0 0 1 5 0 0 0 3 6 0 0 0 0 0 7 1 0 4 3 0 0 0 0 0 0 0 0 7 1 0 0 0 0 4 3 0 0 7 1 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 7 1 0 0 0 1 8 1 0 0 1 5 0 0 0 0 5 1 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 1 7 1 4 3 0 0 0 0 0 0 0 3 3 0 0 0 0 1 5 0 0 4 3 0 1 7 1 0 0 7 1 0 0 0 5 1 0 0 5 1 0 0 0 0 1 5 0 0 3 5 0 0 0 0 0 7 1 0 7 1 0 0 0 0 4 3 0 0 0 0 4 2 0 0 0 0 0 0 0 0 0 0 0 0 8 2 0 0 0 1 5 0 0 0 0 0 0 0 1 5 0 0 0 0 5 1 0 0 0 0 4 3 1 5 0 0 0 0 0 5 3 3 3 3 5 1 0 0 0 0 8 3 3 8 1 0 0 0 0 0 3 6 0 5 1 0 0 0 0 0 4 5 0 0 0 0 0 0 2 5 0 0 0 0 4 3 0 0 0 7 1 0 0 0 0 5 1 0 5 2 0 0 0 0 0 0 0 0 0 5 1 0 0 0 0 5 1 0 0 7 1 0 0 0 0 0 0 0 0 2 5 0 0 0 0 0 0 0 5 1 0 0 0 0 1 5 0 0 1 5 0 0 0 0 5 1 0 0 0 0 0 3 3 0 0 0 0 0 4 2 0 0 0 2 6 0 0 0 0 7 1 0 0 2 6 0 0 0 0 0 7 1 0 0 0 5 1 0 7 1 0 0 0 0 1 5 0 0 2 5 0 0 2 6 4 3 0 0 4 3 0 0 0 0 1 8 1 0 0 2 5 0 0 0 0 0 0 0 4 2 0 0 0 0 0 7 1 0 0 7 1 0 0 2 6 0 0 0 4 2 0 0 0 0 2 5 0 0 0 0 0 4 2 0 0 0 0 0 2 5 0 0 0 0 4 3 0 0 0 0 3 3 3 5 0 0 0 0 3 5 5 0 2 5 5 1 0 0 0 5 3 0 0 8 2 0 0 0 0 0 0 2 5 0 0 0 0 0 0 2 6 0 0 0 3 3 0 0 0 0 0 2 5 0 0 0 0 0 0 2 9 1 0 0 0 0 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 3 3 0 0 0 4 3 0 0 0 0 5 0 0 0 0 0 0 7 1 0 0 0 0 1 4 0 0 0 0 5 1 0 0 0 0 0 0 0 0 7 1 0 0 0 7 1 0 0 0 5 1 0 0 0 0 0 0 0 0 0 0 0 0 2 5 0 1 8 9 9 3 0 0 0 0 7 1 5 1 0 0 0 0 2 6 0 0 0 1 7 1 0 0 0 0 1 5 0 0 4 2 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 5 6 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 3 9 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 8 1 0 0 0 0 0 0 0 8 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 7 1 0 0 0 8 6 0 0 0 3 6 6 0 0 0 5 3 0 0 1 8 1 0 0 0 3 9 1 0 3 5 0 0 0 3 9 3 0 0 2 6 0 0 0 0 3 6 0 0 0 0 1 5 0 0 0 0 0 0 3 5 0 0 0 5 9 1 0 0 1 5 0 0 0 0 5 1 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 1 5 0 0 5 3 0 0 0 0 0 0 3 3 0 0 0 0 1 5 0 0 4 3 0 1 7 1 0 0 7 1 0 0 0 5 1 0 0 2 6 0 0 0 0 5 2 0 0 3 9 5 0 0 0 3 3 0 0 3 3 0 0 0 3 9 3 0 0 0 0 4 2 0 0 0 0 0 0 3 5 0 0 0 0 5 2 0 0 0 1 7 1 0 0 8 5 0 0 1 8 1 0 0 8 9 1 0 0 0 0 1 7 5 2 0 0 0 0 0 5 6 1 1 6 5 0 0 0 1 8 2 0 0 2 9 1 0 0 0 0 0 8 4 5 0 0 0 0 0 5 5 0 0 0 3 3 0 0 5 1 0 0 0 0 1 5 0 0 0 7 1 0 0 0 2 8 1 0 0 7 1 0 0 0 3 8 1 0 0 5 1 0 0 0 3 3 0 0 0 7 1 0 0 0 1 4 0 0 0 2 5 0 0 0 0 0 0 0 2 6 0 0 0 0 1 5 0 0 1 5 0 0 0 0 5 1 0 0 0 0 0 3 3 0 0 0 0 0 3 8 1 0 0 8 3 0 0 0 0 7 1 0 0 0 5 2 0 0 0 0 7 1 0 0 0 5 1 0 7 1 0 0 0 0 1 5 0 0 2 5 0 0 0 5 9 3 0 0 0 8 5 0 0 1 8 3 0 0 0 2 5 0 0 0 0 0 0 0 1 8 2 0 0 1 8 3 0 0 0 7 1 0 0 0 4 3 0 0 4 9 1 0 0 0 4 2 0 0 0 0 0 4 2 0 0 0 0 0 0 8 2 0 0 1 7 1 0 0 0 0 0 7 6 1 0 0 0 0 2 6 3 0 0 8 8 1 0 0 4 5 0 0 0 0 8 2 0 0 0 0 0 2 5 0 0 0 0 0 1 7 1 0 0 0 3 3 0 0 0 0 0 2 5 0 0 0 0 0 3 8 1 0 0 1 5 0 0 0 4 6 0 0 0 3 8 1 0 0 0 0 0 0 0 7 1 0 0 0 3 8 1 0 0 2 9 1 0 0 0 1 8 1 0 0 5 2 0 0 0 0 0 2 6 0 0 0 0 0 0 7 1 0 0 2 6 0 0 0 0 0 0 0 0 8 2 0 0 0 0 3 3 0 0 2 5 0 0 0 0 0 0 8 8 1 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 7 1 5 1 0 0 0 0 2 9 9 9 9 9 1 0 0 0 0 0 1 5 0 0 4 2 0 0 0 0 0 0 0 0 0 0 0 0 0 5 3 0 1 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 3 0 0 0 0 0 0 2 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 5 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 1 0 0 0 0 0 0 0 2 9 9 1 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 2 9 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 3 0 0 0 0 3 9 2 0 0 0 0 0 0 0 0 1 8 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 2 9 9 9 9 3 8 8 1 4 9 3 3 9 9 9 3 0 0 0 0 1 8 9 9 9 6 0 0 0 0 4 9 9 9 6 3 9 5 0 0 3 9 9 9 9 6 0 0 0 2 9 9 9 9 9 9 2 0 0 0 4 9 9 9 4 7 1 0 3 9 9 8 1 0 8 9 9 3 0 4 9 9 9 9 9 9 5 0 0 0 0 0 0 1 7 1 0 0 0 3 9 6 0 1 8 9 9 3 0 4 9 9 9 9 9 9 5 2 9 9 9 1 4 9 5 1 8 9 3 9 9 9 1 0 8 9 9 3 0 0 3 9 9 9 9 3 0 0 0 3 3 4 9 9 9 6 0 0 0 0 5 9 9 9 6 3 3 0 0 4 9 9 9 9 9 6 0 0 0 3 9 9 9 9 9 3 0 0 0 0 0 3 9 9 9 3 0 0 0 0 3 9 9 9 2 5 9 3 0 0 0 0 4 8 1 0 0 0 0 0 3 6 0 0 5 3 0 0 2 9 9 9 1 1 8 9 9 2 0 0 0 0 3 9 1 0 0 0 0 2 9 9 9 9 9 9 3 0 8 9 9 6 0 0 4 9 9 9 4 9 9 9 9 9 9 9 1 0 0 0 1 8 9 9 9 6 0 0 0 8 9 9 9 9 9 6 0 0 2 9 9 9 9 9 9 9 5 0 0 4 9 9 9 9 2 0 0 0 0 0 3 9 9 9 9 9 1 0 2 9 9 9 1 1 8 9 9 2 0 2 9 9 9 9 9 9 2 0 0 0 2 9 9 9 3 0 0 0 2 9 9 9 5 0 0 3 9 5 2 9 9 9 9 9 9 9 9 2 8 9 9 5 0 0 5 9 9 9 4 9 9 9 2 0 1 8 3 0 0 0 0 5 9 9 9 2 0 0 0 3 9 9 9 9 3 0 0 0 0 0 1 8 9 9 9 2 0 0 1 8 9 9 5 0 0 1 8 5 0 4 3 8 9 9 9 5 0 0 0 0 8 9 9 9 9 5 0 0 0 0 0 8 9 9 9 1 0 0 0 0 0 0 4 6 0 0 0 0 0 2 9 2 0 0 4 6 0 0 4 9 9 6 0 0 8 9 9 3 0 0 4 9 9 9 9 6 0 0 0 2 9 9 9 9 9 9 3 0 0 1 8 9 9 9 9 9 3 0 0 5 9 9 9 9 9 6 0 0 0 0 3 9 9 9 8 1 0 0 0 0 0 0 5 9 9 8 1 0 0 0 2 9 9 9 8 1 0 0 0 0 0 1 8 9 9 3 0 0 0 0 0 0 4 3 0 0 0 0 0 0 1 8 9 9 8 1 0 0 0 0 5 9 9 9 2 0 0 0 0 0 0 5 9 9 8 1 0 0 0 0 0 0 8 8 1 0 0 0 0 0 4 6 0 0 3 5 0 0 0 0 0 5 0 7 1 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 3 9 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 9 6 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 6 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 1 8 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 5 0 0 0 0 0 0 0 0 2 9 9 1 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 2 9 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 5 0 0 5 6 0 0 0 0 0 0 0 0 0 0 1 8 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 9 8 1 4 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 9 8 1 0 0 0 0 1 5 0 7 1 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 3 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 4 2 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 1 0 3 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 6 0 0 0 0 4 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 9 5 0 0 0 0 3 9 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 6 0 0 0 0 0 0 8 8 1 0 0 0 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 9 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 9 9 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 9 9 5 0 0 0 0 0 0 0 0 0 0 4 9 9 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 9 9 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 9 9 9 9 9 9 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 1 0 0 0 0 0 0 0 0 0 4 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 9 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 4 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 9 9 9 9 1 0 0 0 0 0 0 0 0 0 0 0 2 9 9 1 0 0 0 0 0 0 0 0 0 0 0 3 9 1 0 0 0 0 0 0 0 0 0 4 6 0 0 0 0 0 1 8 9 1 0 0 0 0 0 0 0 0 5 9 9 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 2 0 0 0 0 0 0 0 3 9 9 9 3 0 0 0 0 0 0 3 9 9 9 5 0 0 0 0 0 0 0 0 1 8 6 0 0 0 0 0 3 9 9 9 9 9 5 0 0 0 0 0 0 0 2 9 9 9 5 0 0 3 9 9 9 9 9 9 8 1 0 0 0 0 3 9 9 9 2 0 0 0 0 0 0 2 9 9 9 2 0 0 0 0 0 0 1 8 9 9 3 0 0 0 0 0 0 0 2 9 2 0 0 0 0 0 0 0 8 3 0 0 8 3 0 0 0 0 0 0 4 2 1 7 1 0 0 0 0 0 3 9 9 9 9 5 0 0 0 0 1 8 9 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 0 0 4 5 0 0 0 0 3 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 9 9 3 0 0 0 0 3 9 9 9 1 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 9 5 0 0 0 0 0 0 0 0 8 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 2 9 5 0 0 0 0 0 0 4 9 1 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 3 0 4 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 9 9 9 6 0 0 0 0 3 9 9 9 9 9 9 8 1 0 0 0 0 0 3 9 9 9 5 2 6 0 1 8 9 9 9 9 9 8 1 0 0 2 9 9 9 9 9 9 9 9 2 0 0 3 9 9 9 9 9 9 9 9 5 0 0 0 3 9 9 9 6 2 6 0 0 8 9 9 5 0 4 9 9 8 1 0 1 8 9 9 9 9 9 9 1 0 0 0 0 0 8 9 9 9 9 9 8 2 9 9 9 9 1 0 8 9 9 3 1 8 9 9 9 9 5 0 0 0 0 5 9 9 1 0 0 0 2 9 9 5 5 9 9 3 0 0 4 9 9 9 6 0 0 0 3 9 9 9 5 0 0 0 0 3 9 9 9 9 9 9 3 0 0 0 0 0 3 9 9 9 5 0 0 0 3 9 9 9 9 9 9 5 0 0 0 0 0 0 4 9 9 9 3 5 1 0 1 8 9 9 9 9 9 9 9 6 0 4 9 9 9 5 0 4 9 9 9 5 5 9 9 9 3 0 3 9 9 9 6 5 9 9 9 3 0 0 8 9 9 9 6 9 9 6 0 0 3 9 9 8 1 2 9 9 9 1 0 0 8 9 9 3 0 0 5 9 9 9 9 9 8 1 0 0 1 8 9 6 8 2 0 0 0 0 0 0 4 8 1 0 0 8 5 0 0 0 0 8 6 0 0 0 8 5 0 0 0 0 0 0 0 5 6 6 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 0 0 5 8 1 0 0 0 0 0 2 5 0 0 0 0 2 8 1 0 0 0 3 6 0 0 0 8 2 0 0 0 0 2 9 1 0 0 8 2 0 0 0 0 1 8 1 0 0 5 1 0 0 0 0 0 0 2 9 2 0 0 0 0 0 0 4 5 0 0 0 2 6 0 0 0 0 0 0 5 2 2 6 0 0 0 0 0 3 6 0 0 0 4 5 0 0 0 0 7 1 0 3 5 0 0 0 0 0 0 0 0 2 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 0 2 9 1 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 5 0 0 0 0 0 0 0 0 5 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 5 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 6 0 1 8 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 9 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 2 8 1 0 0 0 0 0 5 2 0 0 0 3 8 1 0 0 0 5 6 0 0 0 4 9 6 0 0 0 4 3 0 0 0 2 9 1 0 0 0 7 1 0 0 0 0 5 2 0 0 0 1 7 1 0 0 0 0 3 5 0 0 5 6 0 0 0 3 9 6 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 5 2 0 0 0 2 9 1 0 0 0 0 4 2 0 0 0 0 0 0 0 7 6 3 0 0 0 4 9 6 0 0 2 7 8 1 0 0 0 5 2 0 0 0 5 8 1 0 0 5 6 0 0 0 0 0 7 1 0 0 0 5 5 0 0 0 4 6 0 0 0 4 8 1 0 0 0 7 1 0 0 0 4 6 0 0 0 0 4 5 0 0 0 5 9 1 0 1 7 1 0 1 5 0 0 2 6 0 0 2 6 0 0 0 0 0 5 2 0 0 4 5 0 0 0 0 0 4 5 0 0 7 1 0 0 0 0 0 0 5 2 0 3 6 0 0 0 0 3 6 0 0 0 0 7 1 0 0 0 0 7 1 0 0 0 5 2 0 0 0 3 6 0 0 0 0 0 0 0 7 1 0 0 0 0 0 1 8 1 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 2 8 2 6 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 0 4 5 0 0 0 0 0 0 0 0 0 0 0 0 0 3 6 0 0 0 0 7 1 0 0 0 2 5 0 0 0 0 4 3 0 0 0 0 7 1 0 0 0 4 2 0 0 0 1 5 0 0 0 0 0 0 2 9 2 0 0 0 0 0 0 8 2 0 0 0 1 7 1 0 0 0 0 0 5 1 2 6 0 0 0 0 0 5 1 0 0 0 0 0 0 0 0 1 5 0 0 0 5 0 0 0 0 0 0 0 0 7 2 7 1 0 0 0 0 0 0 0 5 9 9 8 1 0 0 0 1 8 9 9 9 9 9 8 1 0 0 0 0 0 0 0 4 5 0 0 0 0 0 0 3 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 3 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 3 0 0 0 0 0 0 0 0 4 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 1 0 3 9 2 0 0 0 0 0 0 0 0 0 0 8 8 1 0 4 8 1 0 0 0 0 0 0 0 0 0 5 6 0 0 0 8 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 4 9 9 9 9 1 0 0 0 0 2 6 0 5 9 9 8 1 0 0 0 0 0 2 9 9 9 8 3 5 0 0 0 0 8 9 9 8 1 5 2 0 0 0 2 9 9 9 9 3 0 0 0 0 0 8 9 9 9 9 9 9 1 0 0 0 1 8 9 9 5 1 8 9 2 0 0 7 1 5 9 9 5 0 0 0 0 0 5 9 9 9 1 0 0 0 0 0 4 9 9 9 9 9 5 0 0 0 0 0 0 7 1 0 0 8 9 9 6 0 0 0 0 0 7 1 0 0 0 1 8 9 3 8 9 2 3 9 9 2 0 1 8 9 2 3 9 9 6 0 0 0 0 0 0 4 9 9 9 5 0 0 0 4 9 6 0 8 9 9 8 1 0 0 0 0 0 8 9 9 8 1 5 9 5 0 1 8 9 6 0 2 9 9 2 0 0 0 0 5 9 9 9 2 7 1 0 0 8 9 9 9 9 9 9 8 1 0 2 9 9 1 0 0 8 9 8 1 0 4 9 9 9 5 0 2 9 9 9 9 9 9 9 3 0 0 0 3 9 9 6 0 5 9 9 5 0 3 9 9 6 0 1 8 9 9 1 0 0 4 9 9 5 0 0 5 9 9 9 9 9 9 1 0 0 0 0 3 6 0 5 3 0 0 0 0 0 5 2 0 0 0 0 5 2 0 0 3 5 0 0 0 0 0 3 6 0 0 0 4 3 0 0 0 0 2 6 0 0 0 7 1 0 0 0 0 5 2 0 0 0 1 7 1 0 0 0 0 3 5 0 3 5 0 0 0 0 0 2 6 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 5 2 0 0 3 8 1 0 0 0 0 0 4 2 0 0 0 0 0 0 0 7 3 8 1 0 0 8 4 6 0 0 2 6 4 5 0 0 0 5 2 0 0 3 6 0 0 0 0 0 5 5 0 0 0 0 7 1 0 0 0 0 7 1 0 3 6 0 0 0 0 0 3 5 0 0 0 7 1 0 0 0 0 7 1 0 0 0 7 1 0 0 0 0 7 1 0 1 7 1 0 1 5 0 0 2 6 0 0 2 6 0 0 0 0 0 5 2 0 0 1 7 1 0 0 0 0 8 2 0 0 5 2 0 0 0 0 0 0 5 1 0 0 4 5 0 0 1 8 1 0 0 0 0 2 6 0 0 0 4 3 0 0 0 0 5 2 0 0 1 8 1 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 5 2 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 5 3 2 6 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 3 0 0 0 0 7 1 0 0 0 2 6 0 0 0 0 5 2 0 0 0 0 4 2 0 0 0 7 1 0 0 0 0 7 1 0 0 0 0 0 1 8 2 0 0 0 0 0 1 7 1 0 1 8 9 8 1 0 0 0 0 0 7 1 3 5 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 3 5 0 0 0 0 0 0 0 4 3 0 3 6 0 0 0 0 0 0 4 6 0 0 0 0 0 0 0 0 0 0 2 9 2 0 0 0 0 0 0 0 0 0 1 8 2 0 0 0 0 0 0 1 8 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 0 4 9 6 0 0 0 0 0 0 0 0 3 9 2 0 0 0 0 0 0 0 0 3 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 5 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 5 9 6 0 0 0 0 0 0 8 5 0 0 5 6 0 0 0 0 0 0 0 0 0 5 9 3 0 0 0 0 2 9 8 1 0 0 0 0 0 0 0 5 2 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 1 8 2 0 0 0 2 7 8 3 0 0 3 9 1 0 0 0 4 8 1 0 0 2 9 5 0 0 1 8 2 0 0 2 9 6 2 0 0 2 9 2 0 0 0 5 5 0 0 0 0 0 0 7 1 0 0 0 0 0 0 1 8 1 0 0 4 7 7 1 0 0 0 7 6 3 0 0 5 5 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 7 1 0 0 3 5 0 0 0 0 0 0 0 7 1 0 0 0 0 0 5 9 1 2 9 8 1 2 6 0 0 0 5 4 6 0 0 5 5 0 0 0 0 5 5 0 0 0 4 6 0 0 0 2 7 8 2 0 0 2 9 1 0 0 1 8 2 0 0 2 8 6 2 0 0 0 0 2 6 3 8 1 1 7 1 0 0 5 5 0 0 0 8 8 1 0 0 0 0 7 1 0 0 0 0 0 0 0 0 7 1 0 0 0 1 7 1 0 0 1 7 1 0 0 0 0 5 3 0 0 8 2 0 0 0 0 0 1 7 1 0 0 5 3 0 0 0 3 6 0 0 0 1 7 1 0 0 0 0 4 5 0 0 0 5 2 0 0 0 3 5 0 0 0 0 0 5 3 0 3 6 0 0 0 0 0 5 2 0 0 0 0 5 2 0 0 5 1 0 0 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 7 1 0 0 7 1 0 3 3 0 0 0 0 0 0 1 7 1 0 4 2 0 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 5 2 0 3 6 0 0 0 0 0 0 0 4 2 0 0 0 0 0 0 0 7 2 8 2 0 3 6 2 6 0 0 2 6 1 8 1 0 0 5 2 0 0 8 2 0 0 0 0 0 1 7 1 0 0 0 7 1 0 0 0 0 7 1 0 5 1 0 0 0 0 0 0 7 1 0 0 7 1 0 0 0 0 7 1 0 0 0 7 1 0 0 0 0 0 0 0 0 7 1 0 1 5 0 0 2 5 0 0 2 6 0 0 0 0 0 5 2 0 0 0 5 2 0 0 0 2 8 1 0 0 4 2 0 2 9 5 0 0 7 1 0 0 0 5 3 0 8 2 0 0 0 0 0 0 4 3 0 2 6 0 0 0 0 0 5 2 0 0 5 3 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 5 5 0 0 0 0 0 2 6 0 2 6 0 0 0 0 0 3 6 8 9 9 6 0 0 0 0 0 3 3 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 4 3 0 0 0 4 3 0 0 0 0 5 3 0 0 0 0 5 3 0 0 1 7 1 0 0 0 0 5 2 0 0 0 0 0 1 8 1 0 0 0 0 0 1 7 1 1 8 3 1 7 1 0 0 0 8 9 9 9 9 9 9 6 0 0 0 4 2 0 0 0 0 0 0 0 0 0 1 8 9 8 1 0 0 0 0 0 0 3 6 0 0 0 5 3 0 0 0 0 0 4 2 0 0 0 0 0 0 0 0 0 0 2 9 6 0 0 0 0 0 0 0 0 0 3 8 1 0 0 0 0 0 0 0 5 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 9 9 9 9 9 9 9 2 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 3 6 0 0 0 0 0 0 0 0 0 0 8 9 9 1 0 0 0 0 0 0 0 3 9 1 0 0 0 0 0 0 0 0 3 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 8 9 9 1 0 0 0 0 2 9 1 0 2 9 1 0 0 0 0 0 0 0 4 9 3 0 0 0 0 0 0 0 0 3 9 6 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 3 5 0 0 0 2 9 3 0 0 0 0 3 5 0 0 1 7 1 0 0 0 0 3 5 0 0 4 2 0 0 0 0 2 9 2 0 0 5 2 0 0 0 0 0 5 1 0 0 0 0 0 7 1 0 0 0 0 0 0 5 2 0 0 0 0 4 8 1 0 0 0 8 5 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 7 1 0 4 6 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 5 3 0 0 8 2 0 1 7 1 0 0 5 8 1 0 0 1 7 1 0 0 3 5 0 0 0 0 0 4 3 0 0 2 9 2 0 0 0 0 2 5 0 0 5 2 0 0 0 0 2 9 2 0 0 0 0 2 9 6 0 0 0 0 0 0 0 5 3 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 7 1 0 0 0 1 7 1 0 0 0 5 3 0 0 0 1 7 1 0 0 4 3 0 0 0 0 0 2 5 0 0 0 0 5 3 0 3 6 0 0 0 0 0 4 3 0 0 0 0 8 2 0 0 0 0 0 0 0 2 6 0 0 0 0 0 1 8 1 0 1 8 1 0 0 0 0 5 2 0 0 0 4 6 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 4 3 0 0 7 1 0 3 3 0 0 0 0 0 0 1 7 1 0 4 3 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 5 2 4 6 0 0 0 0 0 0 0 0 4 2 0 0 0 0 0 0 0 7 1 3 5 0 5 3 2 6 0 0 2 6 0 4 5 0 0 5 2 0 1 7 1 0 0 0 0 0 0 5 1 0 0 0 7 1 0 0 0 1 7 1 1 7 1 0 0 0 0 0 0 5 2 0 0 7 1 0 0 0 4 5 0 0 0 0 4 8 1 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 2 6 0 0 0 0 0 5 2 0 0 0 3 6 0 0 0 4 3 0 0 0 4 3 0 4 5 7 1 1 7 1 0 0 0 0 7 6 3 0 0 0 0 0 0 0 0 7 2 8 1 0 0 0 0 0 0 0 0 4 5 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 2 9 9 5 0 0 0 0 0 0 5 2 0 2 6 0 0 0 0 0 3 9 2 0 0 3 5 0 0 0 0 4 3 3 9 9 9 1 0 0 0 0 0 0 0 0 3 6 0 0 0 0 0 0 5 9 9 9 5 0 0 0 0 0 2 9 1 0 1 8 6 3 0 0 1 7 1 0 0 0 0 5 2 0 0 0 0 0 1 8 1 0 0 0 0 0 1 7 1 3 5 0 1 7 1 0 0 0 0 1 7 1 3 3 0 0 0 0 0 0 8 9 9 1 0 0 0 0 0 0 0 0 0 4 9 9 9 3 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 1 8 2 8 2 0 0 0 0 0 0 0 0 4 6 0 0 0 0 0 0 0 0 4 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 4 9 6 0 0 0 0 0 0 0 0 2 9 1 0 0 0 0 0 0 0 0 2 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 4 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 5 0 0 0 0 0 0 0 0 0 0 0 0 4 9 5 0 0 0 0 0 0 0 0 0 2 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 3 5 0 0 0 2 8 1 0 0 0 0 1 7 1 0 3 5 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 5 2 0 1 7 1 0 0 0 0 0 3 3 0 0 0 0 0 7 1 0 0 0 0 0 1 7 1 0 0 0 0 2 8 1 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 7 1 5 5 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 5 2 0 0 7 1 0 1 7 1 0 0 5 2 0 0 0 1 7 1 0 0 5 2 0 0 0 0 0 2 6 0 0 2 8 1 0 0 0 0 1 7 1 1 7 1 0 0 0 0 0 5 2 0 0 0 0 2 8 1 0 0 0 0 0 0 0 0 5 9 9 9 5 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 7 1 0 0 0 1 7 1 0 0 0 3 6 0 0 0 4 5 0 0 0 3 5 0 2 9 2 0 4 3 0 0 0 0 0 5 6 6 0 0 0 0 0 0 2 8 1 0 0 3 6 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 3 6 0 0 0 5 3 0 0 0 0 5 9 9 9 9 9 1 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 4 3 0 0 8 9 9 9 3 0 0 0 0 0 0 1 8 9 9 9 3 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 8 9 9 9 9 9 8 1 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 5 9 5 3 9 1 0 0 0 0 0 0 4 2 0 0 0 0 0 0 0 7 1 1 8 2 8 1 2 6 0 0 2 6 0 1 8 1 0 5 2 0 1 7 1 0 0 0 0 0 0 5 2 0 0 0 7 1 0 0 0 5 3 0 1 7 1 0 0 0 0 0 0 5 2 0 0 8 9 9 9 9 5 0 0 0 0 0 0 2 9 9 9 5 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 2 6 0 0 0 0 0 5 2 0 0 0 1 8 1 0 0 7 1 0 0 0 3 5 0 5 1 5 2 1 5 0 0 0 0 0 3 8 1 0 0 0 0 0 0 0 0 2 9 3 0 0 0 0 0 0 0 0 2 8 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 0 8 3 0 0 0 0 3 6 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 5 6 9 1 0 1 8 1 0 0 0 0 0 0 0 5 3 0 0 0 0 0 2 3 0 0 0 4 1 0 0 0 0 0 2 9 9 9 2 3 5 0 0 1 7 1 0 0 0 0 5 2 0 0 0 0 0 1 8 1 0 0 0 0 0 1 7 1 3 5 0 1 7 1 0 0 0 0 1 7 1 4 3 0 0 0 0 0 0 0 0 1 8 9 2 0 0 0 2 9 9 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 9 3 0 0 0 0 0 0 0 0 8 2 0 3 8 1 0 0 0 0 0 0 0 5 5 0 0 0 0 0 0 0 0 3 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 9 9 9 9 9 9 9 1 0 3 9 9 9 9 9 9 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 3 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 3 0 0 0 0 0 0 4 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 2 9 9 9 9 9 5 0 0 0 2 6 0 0 0 0 0 0 7 1 0 4 3 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 5 2 0 1 8 9 9 9 9 9 9 9 5 0 0 0 0 0 7 1 0 0 0 0 0 1 7 1 0 0 0 0 1 7 1 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 8 9 6 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 5 2 0 0 7 1 0 1 7 1 0 0 5 2 0 0 0 1 7 1 0 0 7 1 0 0 0 0 0 2 6 0 0 2 6 0 0 0 0 0 0 7 1 1 7 1 0 0 0 0 0 5 2 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 4 5 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 8 2 0 0 7 1 0 0 0 2 6 0 4 9 5 0 5 2 0 0 0 0 0 2 9 2 0 0 0 0 0 0 0 5 3 0 0 5 2 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 8 2 0 0 0 3 6 0 0 0 0 5 2 0 0 0 1 8 5 0 0 7 1 0 0 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 4 2 0 0 7 1 0 3 3 0 0 0 0 0 0 1 7 1 0 4 3 0 0 0 0 7 1 0 0 3 9 9 9 9 3 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 4 3 0 0 0 0 3 5 0 0 0 0 5 3 0 0 2 6 0 0 0 0 0 0 4 2 0 0 0 0 7 1 0 7 1 0 5 6 6 0 2 6 0 0 2 6 0 0 4 5 0 5 2 0 1 7 1 0 0 0 0 0 0 5 1 0 0 0 8 9 9 9 9 3 0 0 1 7 1 0 0 0 0 0 0 5 1 0 0 7 1 0 0 5 3 0 0 0 0 0 0 0 0 0 0 4 9 1 0 0 0 0 0 1 5 0 0 0 0 0 0 2 6 0 0 0 0 0 5 2 0 0 0 0 5 3 0 2 6 0 0 0 0 2 5 1 7 1 3 3 2 6 0 0 0 0 2 8 3 6 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 8 2 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 5 2 0 0 0 5 9 1 0 0 0 1 4 0 0 0 0 0 0 0 8 2 0 0 0 0 0 7 1 0 0 0 2 5 0 0 0 0 0 0 0 0 0 0 4 3 0 0 1 7 1 0 0 0 0 5 2 0 0 0 0 0 0 7 1 0 0 0 0 0 1 7 1 2 9 1 1 7 1 0 0 3 9 9 9 9 9 9 9 3 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 5 9 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 8 2 8 1 3 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 5 0 0 0 0 0 0 0 0 3 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 9 9 9 9 9 9 9 2 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 6 0 0 0 0 0 0 0 0 3 9 1 0 0 0 0 0 0 0 0 0 0 2 9 2 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 5 0 0 0 0 0 0 0 0 0 0 0 0 4 9 5 0 0 0 0 0 0 0 8 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 3 9 1 0 0 0 3 5 0 0 0 2 8 1 0 0 0 0 1 7 1 0 3 5 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 5 2 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 1 7 1 0 0 0 0 2 8 1 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 8 2 4 5 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 5 2 0 0 7 1 0 1 7 1 0 0 5 2 0 0 0 1 7 1 0 0 5 2 0 0 0 0 0 2 6 0 0 2 8 1 0 0 0 0 1 7 1 1 7 1 0 0 0 0 0 5 2 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 2 0 0 0 0 7 1 0 0 0 0 0 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 4 5 0 3 6 0 0 0 0 0 7 1 8 4 8 1 7 1 0 0 0 0 2 8 1 8 2 0 0 0 0 0 0 2 8 1 2 8 1 0 0 0 0 0 0 5 2 0 0 0 0 0 0 2 9 9 9 9 9 9 9 1 0 0 0 5 2 0 0 0 0 0 7 1 0 5 2 0 0 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 7 1 0 0 7 1 0 3 3 0 2 6 0 0 0 1 7 1 0 4 2 0 0 0 0 5 1 0 0 0 0 0 2 6 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 4 3 0 0 0 0 3 5 0 0 0 0 5 2 0 0 0 5 2 0 0 0 0 0 4 2 0 0 0 0 7 1 0 7 1 0 2 9 2 0 2 6 0 0 2 6 0 0 0 8 2 5 2 0 0 8 2 0 0 0 0 0 1 7 1 0 0 0 7 1 0 0 0 0 0 0 0 5 1 0 0 0 0 0 1 7 1 0 0 7 1 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 1 5 0 0 0 0 0 0 2 6 0 0 0 0 0 5 2 0 0 0 0 3 6 0 5 3 0 0 0 0 2 6 3 5 0 2 6 3 5 0 0 0 0 7 1 0 4 5 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 4 5 0 0 0 5 2 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 1 8 2 0 0 0 0 0 0 0 0 0 0 0 0 0 4 2 0 0 1 8 9 9 9 9 9 8 1 0 0 0 0 0 0 0 0 0 5 2 0 0 0 4 6 0 0 0 0 2 6 0 0 0 0 0 0 2 8 1 0 0 0 0 1 7 1 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 7 1 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 7 1 0 3 9 9 9 2 0 0 0 0 2 6 0 5 2 0 0 0 0 2 6 0 0 0 0 1 7 1 0 0 0 0 0 4 3 0 1 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 2 0 4 5 5 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 6 0 0 0 0 0 0 0 0 4 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 1 8 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 3 0 0 0 0 0 0 0 0 3 9 6 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 5 2 0 0 0 0 3 5 0 0 0 2 9 3 0 0 0 0 3 5 0 0 2 8 1 0 0 0 0 0 0 0 0 4 2 0 0 0 0 2 9 2 0 0 4 2 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 5 2 0 0 0 0 4 8 1 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 7 1 0 5 3 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 5 2 0 0 7 1 0 1 7 1 0 0 5 2 0 0 0 1 7 1 0 0 3 5 0 0 0 0 0 4 3 0 0 2 9 2 0 0 0 0 2 5 0 0 5 2 0 0 0 0 2 9 2 0 0 0 0 2 6 0 0 0 0 0 0 0 2 6 0 0 0 0 0 5 2 0 0 0 0 7 1 0 0 0 0 0 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 1 7 1 5 3 0 0 0 0 0 5 3 8 1 7 3 6 0 0 0 0 1 8 1 0 0 8 2 0 0 0 0 0 0 5 3 5 3 0 0 0 0 0 0 5 3 0 0 0 0 0 0 0 4 5 0 0 0 0 0 5 3 0 0 0 5 2 0 0 0 0 0 7 1 0 2 6 0 0 0 0 0 1 8 1 0 0 4 3 0 0 0 0 2 6 0 0 0 7 1 0 0 0 0 2 6 0 0 0 1 7 1 0 0 0 0 0 0 0 3 5 0 0 0 0 0 2 6 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 4 3 0 0 0 0 5 3 0 0 0 0 5 2 0 0 0 2 6 0 0 0 0 0 4 2 0 0 0 0 7 1 0 7 1 0 0 0 0 0 2 6 0 0 2 6 0 0 0 3 6 5 2 0 0 3 6 0 0 0 0 0 5 5 0 0 0 0 7 1 0 0 0 0 0 0 0 3 5 0 0 0 0 0 4 5 0 0 0 7 1 0 0 0 1 7 1 0 0 3 5 0 0 0 0 0 4 3 0 0 0 0 0 1 5 0 0 0 0 0 0 1 7 1 0 0 0 0 7 1 0 0 0 0 1 8 2 8 1 0 0 0 0 1 7 5 2 0 0 7 4 3 0 0 0 5 3 0 0 0 5 3 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 3 6 0 0 0 0 5 2 0 0 0 0 0 0 7 1 0 0 0 0 0 0 2 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 1 8 1 0 0 0 1 4 0 0 0 0 0 0 4 5 0 0 0 0 0 0 7 1 0 0 0 1 5 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 4 2 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 0 2 5 0 5 2 0 0 0 0 2 9 2 0 0 0 4 5 0 0 0 0 0 0 5 1 0 0 4 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 2 0 0 8 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 8 1 0 0 0 0 0 0 0 5 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 2 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 9 9 2 0 0 0 0 0 0 0 0 4 9 6 0 0 0 0 0 0 0 3 6 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 5 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 2 0 0 0 0 1 8 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 4 5 0 0 0 5 9 5 0 0 0 2 7 8 2 0 0 3 8 1 0 0 0 4 8 1 0 0 0 4 8 1 0 1 8 2 0 0 2 9 6 2 0 0 0 8 3 0 0 0 0 4 5 0 0 0 0 0 7 1 0 0 0 0 0 0 1 8 1 0 0 3 7 7 1 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 7 1 0 0 5 2 0 0 0 0 0 0 0 7 1 0 0 0 0 0 5 2 0 0 7 1 0 1 7 1 0 0 5 2 0 0 0 1 7 1 0 0 0 5 3 0 0 0 3 6 0 0 0 2 7 8 2 0 0 1 8 1 0 0 1 7 1 0 0 2 8 6 2 0 0 0 0 2 6 0 0 0 0 0 0 0 2 9 6 0 0 0 3 6 0 0 0 0 0 5 5 0 0 0 8 6 0 0 0 5 2 0 0 1 8 8 1 0 0 0 0 0 5 5 7 1 0 0 0 0 0 4 9 5 0 4 6 5 0 0 0 1 8 1 0 0 0 1 8 1 0 0 0 0 0 2 9 8 1 0 0 0 0 0 4 3 0 0 0 0 5 2 0 0 8 2 0 0 0 0 0 3 6 0 0 0 5 2 0 0 0 0 4 6 0 0 0 3 6 0 0 0 2 9 3 0 0 0 4 3 0 0 0 1 8 1 0 0 0 7 1 0 0 0 0 2 6 0 0 0 1 7 1 0 0 0 0 0 0 0 0 5 3 0 0 0 0 3 6 0 0 0 7 1 0 0 0 1 7 1 0 0 0 0 0 0 7 1 0 0 0 0 0 1 8 3 0 0 3 8 1 0 0 0 0 5 2 0 0 0 0 7 1 0 0 0 0 4 2 0 0 0 0 7 1 0 7 1 0 0 0 0 0 2 6 0 0 2 6 0 0 0 0 8 9 2 0 0 0 5 8 1 0 0 5 6 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 4 6 0 0 0 5 8 1 0 0 0 7 1 0 0 0 0 3 5 0 0 3 9 3 0 0 0 1 7 1 0 0 0 0 0 1 5 0 0 0 0 0 0 0 4 6 0 0 0 4 5 0 0 0 0 0 0 5 6 6 0 0 0 0 0 0 8 9 1 0 0 4 9 3 0 0 4 5 0 0 0 0 1 8 1 0 0 0 0 0 0 7 1 0 0 0 0 0 1 8 1 0 0 0 0 5 2 0 0 0 0 0 0 7 1 0 0 0 0 0 2 8 1 0 0 0 0 5 2 0 0 2 9 2 0 0 0 8 5 0 0 0 0 0 0 0 0 2 6 0 0 0 0 2 9 2 0 0 1 8 3 0 0 0 0 0 3 6 0 0 1 8 1 0 0 0 0 0 0 8 2 0 0 0 0 0 0 3 5 0 0 0 5 2 0 0 0 0 0 0 0 0 4 6 0 0 0 0 0 0 7 1 0 0 5 1 0 0 0 0 0 0 3 9 5 0 0 0 0 0 0 4 5 0 0 0 0 0 0 0 0 0 0 3 5 0 7 1 0 0 0 0 2 7 8 9 9 9 5 0 0 0 0 0 0 0 4 3 0 1 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 8 1 0 8 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 2 0 0 0 0 0 0 1 8 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 4 5 0 0 0 0 0 0 4 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 6 0 0 0 0 0 0 0 0 0 8 9 9 1 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 8 9 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 6 0 0 8 9 1 0 0 0 0 0 0 0 0 0 0 0 4 9 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 5 9 9 9 3 3 9 8 1 4 9 6 0 8 9 9 8 1 0 0 0 0 0 3 9 9 9 9 5 0 0 0 0 0 8 9 9 8 1 5 9 5 0 0 0 5 9 9 9 9 5 0 0 0 1 8 9 9 9 9 9 8 1 0 0 0 1 8 9 9 6 1 7 1 0 2 9 9 9 3 0 3 9 9 9 2 0 3 9 9 9 9 9 9 9 3 0 0 0 0 0 0 0 3 5 0 0 0 0 1 8 9 1 0 2 9 9 9 2 0 3 9 9 9 9 9 9 9 3 1 8 9 9 5 0 8 9 3 1 8 9 3 8 9 9 5 0 3 9 9 9 2 0 0 0 5 9 9 9 6 0 0 0 0 2 6 0 8 9 9 9 1 0 0 0 0 2 9 9 9 8 1 5 2 0 0 4 9 9 9 9 9 9 5 0 0 0 2 6 3 9 9 9 6 0 0 0 0 0 0 0 8 9 9 9 3 0 0 0 0 1 8 9 9 9 2 8 9 2 0 0 0 0 2 9 5 0 0 0 0 0 0 3 9 2 0 2 9 2 0 0 1 8 9 9 3 0 3 9 9 9 2 0 0 0 0 0 5 5 0 0 0 0 0 0 8 9 9 9 9 9 9 2 2 9 9 9 9 1 0 1 8 9 9 9 4 9 9 9 9 9 9 9 6 0 0 0 0 0 3 9 9 9 9 1 0 0 1 8 9 9 9 9 9 9 1 0 0 2 9 9 9 9 9 9 9 9 6 0 0 3 9 9 9 9 9 1 0 0 0 0 0 0 5 9 9 9 9 6 0 0 2 9 9 9 5 0 4 9 9 9 2 0 1 8 9 9 9 9 9 9 1 0 0 0 0 8 9 9 8 1 0 0 0 2 9 9 9 9 1 0 0 4 9 6 1 8 9 9 9 9 9 9 9 9 3 9 9 9 9 1 0 2 9 9 9 8 5 9 9 9 6 0 0 3 9 2 0 0 0 0 3 9 9 9 5 0 0 0 0 3 9 9 9 9 9 1 0 0 0 0 0 0 3 9 9 9 5 0 0 0 3 9 9 9 9 1 0 0 0 8 8 1 3 5 5 9 9 9 9 1 0 0 0 0 3 9 9 9 9 9 1 0 0 0 0 0 3 9 9 9 5 0 0 0 0 0 0 0 3 9 3 0 0 0 0 0 0 8 6 0 0 0 3 9 2 0 4 9 9 9 1 0 2 9 9 9 2 0 0 2 9 9 9 9 9 3 0 0 0 1 8 9 9 9 9 9 9 2 0 0 0 8 9 9 9 9 9 9 2 0 0 3 9 9 9 9 9 9 9 2 0 0 0 0 8 9 9 9 3 0 0 0 0 0 0 0 2 9 9 9 6 0 0 0 0 0 8 9 9 9 3 0 0 0 0 0 0 0 3 9 9 9 1 0 0 0 0 0 0 2 8 1 0 0 0 0 0 0 0 4 9 9 9 3 0 0 0 0 0 4 9 9 9 5 0 0 0 0 0 0 0 2 9 9 9 3 0 0 0 0 0 0 0 3 9 5 0 0 0 0 0 0 1 8 3 0 0 4 5 0 0 0 0 0 3 5 0 7 1 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 5 9 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 9 3 4 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 5 0 0 0 0 0 0 3 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 8 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 9 2 0 0 0 0 0 0 0 0 0 4 9 6 0 0 0 0 0 0 3 6 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 4 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 9 6 0 0 0 0 0 0 4 3 0 7 1 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 4 5 0 0 0 0 2 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 1 7 1 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 9 9 3 0 8 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 5 0 0 0 0 3 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 9 9 3 0 0 0 0 3 9 9 9 1 0 0 0 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 9 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 2 5 0 0 0 0 0 0 0 0 0 0 7 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 3 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 8 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 9 2 0 0 8 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 8 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 9 5 0 0 0 0 0 0 4 9 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 2 9 9 9 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 9 9 9 9 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 4 9 9 9 9 1 0 0 0 0 0 0 0 0 0 0 1 8 9 9 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 9 9 9 6 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 8 9 9 9 9 9 9 9 9 9 9 5 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]);
character_images=double(character_images)/9;

function [x_2d,y_2d]=voxelposition_to_imageposition(x,y,z,data)
dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));

data.subwindow(data.axes_select).Mview=data.subwindow(data.axes_select).viewer_matrix;
switch (data.subwindow(data.axes_select).render_type)
    case {'slicex'}
        sizeIin=[size(data.volumes(dvs).volume_original,2) size(data.volumes(dvs).volume_original,3)];
        M=[data.subwindow(data.axes_select).Mview(1,2) data.subwindow(data.axes_select).Mview(1,3) data.subwindow(data.axes_select).Mview(1,4); data.subwindow(data.axes_select).Mview(2,2) data.subwindow(data.axes_select).Mview(2,3) data.subwindow(data.axes_select).Mview(2,4); 0 0 1];
    case {'slicey'}
        sizeIin=[size(data.volumes(dvs).volume_original,1) size(data.volumes(dvs).volume_original,3)];
        M=[data.subwindow(data.axes_select).Mview(1,1) data.subwindow(data.axes_select).Mview(1,3) data.subwindow(data.axes_select).Mview(1,4); data.subwindow(data.axes_select).Mview(2,1) data.subwindow(data.axes_select).Mview(2,3) data.subwindow(data.axes_select).Mview(2,4); 0 0 1];     % Rotate 90
    case {'slicez'}
        sizeIin=[size(data.volumes(dvs).volume_original,1) size(data.volumes(dvs).volume_original,2)];
        M=[data.subwindow(data.axes_select).Mview(1,1) data.subwindow(data.axes_select).Mview(1,2) data.subwindow(data.axes_select).Mview(1,4); data.subwindow(data.axes_select).Mview(2,1) data.subwindow(data.axes_select).Mview(2,2) data.subwindow(data.axes_select).Mview(2,4); 0 0 1];
end

switch (data.subwindow(data.axes_select).render_type)
    case {'slicex'}
        Tlocalx=y; Tlocaly=z;
    case {'slicey'}
        Tlocalx=x; Tlocaly=z;
    case {'slicez'}
        Tlocalx=x; Tlocaly=y;
end

% Calculate center of the input image
mean_in=sizeIin/2;

x_2d=zeros(1,length(Tlocalx)); y_2d=zeros(1,length(Tlocalx));

Tlocalx=Tlocalx-mean_in(1);
Tlocaly=Tlocaly-mean_in(2);

for i=1:length(x)
    vector=M*[Tlocalx(i);Tlocaly(i);1];
    x_2d(i)=vector(1);
    y_2d(i)=vector(2);
end

% Calculate center of the output image
mean_out=[data.config.ImageSizeRender data.config.ImageSizeRender]/2;

% Make center of the image coordinates 0,0
x_2d=x_2d+mean_out(1); 
y_2d=y_2d+mean_out(2);

function data=mouseposition_to_voxelposition(data)
dvs=structfind(data.volumes,'id',data.subwindow(data.axes_select).volume_id_select(1));
if(isempty(dvs)), return; end
data.subwindow(data.axes_select).Mview=data.subwindow(data.axes_select).viewer_matrix;
switch (data.subwindow(data.axes_select).render_type)
    case {'slicex'}
        sizeIin=[size(data.volumes(dvs).volume_original,2) size(data.volumes(dvs).volume_original,3)];
        M=[data.subwindow(data.axes_select).Mview(1,2) data.subwindow(data.axes_select).Mview(1,3) data.subwindow(data.axes_select).Mview(1,4); data.subwindow(data.axes_select).Mview(2,2) data.subwindow(data.axes_select).Mview(2,3) data.subwindow(data.axes_select).Mview(2,4); 0 0 1];
    case {'slicey'}
        sizeIin=[size(data.volumes(dvs).volume_original,1) size(data.volumes(dvs).volume_original,3)];
        M=[data.subwindow(data.axes_select).Mview(1,1) data.subwindow(data.axes_select).Mview(1,3) data.subwindow(data.axes_select).Mview(1,4); data.subwindow(data.axes_select).Mview(2,1) data.subwindow(data.axes_select).Mview(2,3) data.subwindow(data.axes_select).Mview(2,4); 0 0 1];     % Rotate 90
    case {'slicez'}
        sizeIin=[size(data.volumes(dvs).volume_original,1) size(data.volumes(dvs).volume_original,2)];
        M=[data.subwindow(data.axes_select).Mview(1,1) data.subwindow(data.axes_select).Mview(1,2) data.subwindow(data.axes_select).Mview(1,4); data.subwindow(data.axes_select).Mview(2,1) data.subwindow(data.axes_select).Mview(2,2) data.subwindow(data.axes_select).Mview(2,4); 0 0 1];
end
M=inv(M);
    
% Get the mouse position
x_2d=data.subwindow(data.axes_select).mouse_position(2);
y_2d=data.subwindow(data.axes_select).mouse_position(1); 

% To rendered image position
x_2d=x_2d*data.config.ImageSizeRender; y_2d=y_2d*data.config.ImageSizeRender;

% Calculate center of the input image
mean_in=sizeIin/2;

% Calculate center of the output image
mean_out=[data.config.ImageSizeRender data.config.ImageSizeRender]/2;

% Calculate the Transformed coordinates
x_2d=x_2d - mean_out(1); 
y_2d=y_2d - mean_out(2);

location(1)= mean_in(1) + M(1,1) * x_2d + M(1,2) *y_2d + M(1,3) * 1;
location(2)= mean_in(2) + M(2,1) * x_2d + M(2,2) *y_2d + M(2,3) * 1;

switch (data.subwindow(data.axes_select).render_type)
    case {'slicex'}
        data.subwindow(data.axes_select).VoxelLocation=[data.subwindow(data.axes_select).SliceSelected(1) location(1) location(2)];
    case {'slicey'}
        data.subwindow(data.axes_select).VoxelLocation=[location(1) data.subwindow(data.axes_select).SliceSelected(2) location(2)];
    case {'slicez'}
        data.subwindow(data.axes_select).VoxelLocation=[location(1) location(2) data.subwindow(data.axes_select).SliceSelected(3)];
end
data.subwindow(data.axes_select).VoxelLocation=round(data.subwindow(data.axes_select).VoxelLocation);

data.subwindow(data.axes_select).VoxelLocation(data.subwindow(data.axes_select).VoxelLocation<1)=1;
if(data.subwindow(data.axes_select).VoxelLocation(1)>size(data.volumes(dvs).volume_original,1)), data.subwindow(data.axes_select).VoxelLocation(1)=size(data.volumes(dvs).volume_original,1); end
if(data.subwindow(data.axes_select).VoxelLocation(2)>size(data.volumes(dvs).volume_original,2)), data.subwindow(data.axes_select).VoxelLocation(2)=size(data.volumes(dvs).volume_original,2); end
if(data.subwindow(data.axes_select).VoxelLocation(3)>size(data.volumes(dvs).volume_original,3)), data.subwindow(data.axes_select).VoxelLocation(3)=size(data.volumes(dvs).volume_original,3); end

% --- Executes on mouse motion over figure - except title and menu.
function brightness_contrast_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
dvs=data.volume_select;
if(~isempty(data.figurehandles.contrast)&&ishandle(data.figurehandles.contrast))
    handles_contrast=guidata(data.figurehandles.contrast);

    level=get(handles_contrast.slider_window_level,'value');
    width=get(handles_contrast.slider_window_width,'value');
        
    if((width~=data.volumes(dvs).WindowWidth)||(level~=data.volumes(dvs).WindowLevel))
        data.volumes(dvs).WindowWidth=width; 
        data.volumes(dvs).WindowLevel=level; 
        set(handles_contrast.edit_window_width,'String',num2str(data.volumes(dvs).WindowWidth));
        set(handles_contrast.edit_window_level,'String',num2str(data.volumes(dvs).WindowLevel));
        setMyData(data);
        allshow3d(false,false);
    end
end

function brightness_contrast_pushbutton_auto_Callback(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
dvs=data.volume_select;
handles_contrast=guidata(data.figurehandles.contrast);
data.volumes(dvs).WindowWidth=data.volumes(dvs).volumemax-data.volumes(dvs).volumemin;
data.volumes(dvs).WindowLevel=0.5*(data.volumes(dvs).volumemax+data.volumes(dvs).volumemin);     
set(handles_contrast.slider_window_level,'value',data.volumes(dvs).WindowLevel);
set(handles_contrast.slider_window_width,'value',data.volumes(dvs).WindowWidth);
setMyData(data);
allshow3d(false,false);



% --------------------------------------------------------------------
function menu_config_slicescolor_Callback(hObject, eventdata, handles)
% hObject    handle to menu_config_slicescolor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData();
data.axes_select=eventdata;
if(data.subwindow(data.axes_select).ColorSlice)
    data.subwindow(data.axes_select).ColorSlice=false;
else
    data.subwindow(data.axes_select).ColorSlice=true;
end    
setMyData(data);
set_menu_checks(data);
show3d(false,true);


% --------------------------------------------------------------------
function menu_measure_landmark_Callback(hObject, eventdata, handles)
% hObject    handle to menu_measure_landmark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.mouse.button='select_landmark';
data.mouse.action='measure_landmark';
setMyData(data);
set_mouse_shape('select_landmark',data)


% --------------------------------------------------------------------
function menu_data_info_Callback(hObject, eventdata, handles)
% hObject    handle to menu_data_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
dvs=eventdata;
viewer3d_dicominfo(data.volumes(dvs).info);

% --------------------------------------------------------------------
function menu_addseg_Callback(hObject, eventdata, handles)
% hObject    handle to menu_data_info (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
dvs=eventdata;
volumedata=data.volumes(dvs);
Info=[];
Scales=volumedata.Scales;
V=zeros(size(volumedata.volume_original),'uint8');
Editable=true;
addVolume(V,Scales,Info,Editable);
%viewer3d_dicominfo(data.volumes(dvs).info);


% --------------------------------------------------------------------
function menu_click_roi_Callback(hObject, eventdata, handles)
% hObject    handle to menu_click_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.mouse.button='click_roi';
data.mouse.action='click_roi';
setMyData(data);
set_mouse_shape('click_roi',data)


% --------------------------------------------------------------------
function load_filename1_Callback(hObject, eventdata, handles)
% hObject    handle to load_filename1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
load_view(data.history.filenames{1})


% --------------------------------------------------------------------
function load_filename2_Callback(hObject, eventdata, handles)
% hObject    handle to load_filename2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
load_view(data.history.filenames{2})

% --------------------------------------------------------------------
function load_filename3_Callback(hObject, eventdata, handles)
% hObject    handle to load_filename3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
load_view(data.history.filenames{3})

% --------------------------------------------------------------------
function load_filename4_Callback(hObject, eventdata, handles)
% hObject    handle to load_filename4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
load_view(data.history.filenames{4})

% --------------------------------------------------------------------
function load_filename5_Callback(hObject, eventdata, handles)
% hObject    handle to load_filename5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
load_view(data.history.filenames{5})

function showhistory(data)
for i=1:5
    filename=data.history.filenames{i};
    switch(i)
        case 1, h=data.handles.load_filename1;
        case 2, h=data.handles.load_filename2;
        case 3, h=data.handles.load_filename3;
        case 4, h=data.handles.load_filename4;
        case 5, h=data.handles.load_filename5;
    end    
    if(~isempty(filename))
        set(h,'Visible','on');
        set(h,'Label',['...' filename(max(end-40,1):end)]); 
    else
        set(h,'Visible','off');
    end
end


% --------------------------------------------------------------------
function menu_windows1_Callback(hObject, eventdata, handles)
% hObject    handle to menu_windows1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.NumberWindows=1;
data=deleteWindows(data);
data=addWindows(data);
setMyData(data);
allshow3d(false,true);

% --------------------------------------------------------------------
function menu_windows2_Callback(hObject, eventdata, handles)
% hObject    handle to menu_windows2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.NumberWindows=2;
data=deleteWindows(data);
data=addWindows(data);
setMyData(data);
allshow3d(false,true);


% --------------------------------------------------------------------
function menu_windows3_Callback(hObject, eventdata, handles)
% hObject    handle to menu_windows3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.NumberWindows=3;
data=deleteWindows(data);
data=addWindows(data);
setMyData(data);
allshow3d(false,true);

% --------------------------------------------------------------------
function menu_windows4_Callback(hObject, eventdata, handles)
% hObject    handle to menu_windows4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
data.NumberWindows=4;
data=deleteWindows(data);
data=addWindows(data);
setMyData(data);
allshow3d(false,true);

function menu_ChangeVolume_Callback(hObject, eventdata, handles)
data=getMyData(); if(isempty(data)), return, end
s=eventdata(2);
if(s>0);
    switch length(eventdata)
        case 2
            data.subwindow(eventdata(1)).volume_id_select=data.volumes(eventdata(2)).id;
        case 3
            data.subwindow(eventdata(1)).volume_id_select=[data.volumes(eventdata(2)).id; data.volumes(eventdata(3)).id];
        case 4
            data.subwindow(eventdata(1)).volume_id_select=[data.volumes(eventdata(2)).id; data.volumes(eventdata(3)).id; data.volumes(eventdata(4)).id];
    end
else
    data.subwindow(eventdata(1)).volume_id_select=0;
    data.subwindow(eventdata(1)).render_type='black';
end
data.axes_select=eventdata(1);
  
if(s>0)
    data.subwindow(eventdata(1)).Zoom=(sqrt(3)./sqrt(sum(data.volumes(s).Scales.^2)));
    data=set_initial_view_matrix(data);
    data.subwindow(data.axes_select).SliceSelected=round(data.volumes(s).Size/2);
end
setMyData(data);
show3d(false,true);
set_menu_checks(data);

function menu_ChangeRender_Callback(hObject, eventdata, handles) %#ok<*INUSD,*INUSL>
data=getMyData(); if(isempty(data)), return, end
if(data.subwindow(eventdata(1)).volume_id_select(1)>0)
    data.axes_select=eventdata(1);

    data.subwindow(data.axes_select).render_type=data.rendertypes(eventdata(2)).type;
    switch data.rendertypes(eventdata(2)).type
        case {'slicex','slicey','slicez'}
        data=set_initial_view_matrix(data);
    end
    set_menu_checks(data);
    data.subwindow(data.axes_select).first_render=true;
    setMyData(data);
    show3d(false,true);
end

function data=deleteWindows(data)
for i=(data.NumberWindows+1):length(data.subwindow)
    h=data.subwindow(i).handles.axes;
    if(~isempty(h)), 
        delete(data.subwindow(i).handles.axes), 
        set(data.subwindow(i).handles.uipanelmenu,'UIContextMenu',uicontextmenu);
        menubar
        delete(data.subwindow(i).handles.uipanelmenu), 
    end
    data.subwindow(i).handles.axes=[];
end
    
function data=addWindows(data)
for i=1:data.NumberWindows
    if(length(data.subwindow)>=i), h=data.subwindow(i).handles.axes; else h=[]; end
    if(isempty(h)),
        data.subwindow(i).click_roi=false;
        data.subwindow(i).tVolumemm=0;
        data.subwindow(i).VoxelLocation=[1 1 1];
        data.subwindow(i).first_render=true;
        data.subwindow(i).mouse_position_pressed=[0 0];
        data.subwindow(i).mouse_position=[0 0];
        data.subwindow(i).mouse_position_last=[0 0];
        data.subwindow(i).shading_material='shiny';
        data.subwindow(i).combine='rgb';
        data.subwindow(i).volume_id_select=0;
        data.subwindow(i).object_id_select=0;
        data.subwindow(i).first_render=true;
        data.subwindow(i).ColorSlice=false;
        data.subwindow(i).render_type='black';
        data.subwindow(i).ViewerVector = [0 0 1];
        data.subwindow(i).LightVector = [0.5 -0.5 -0.67];
        data.subwindow(i).handles.uipanelmenu=uipanel('units','normalized');
        data.subwindow(i).handles.axes=axes;
        set(data.subwindow(i).handles.axes,'units','normalized');
        data.subwindow(i).menu.Handle=[];
    end
end   
data=addWindowsMenus(data);

% Units Normalized Margin
switch(data.NumberWindows)
    case 1
        w=1; h=1;
        makeWindow(data,1,0,0,w,h);
    case 2
        w=0.5; h=1;
        makeWindow(data,1,0,0,w,h);
        makeWindow(data,2,0.5,0,w,h);
    case 3
        w=1/3; h=1;
        makeWindow(data,1,0,0,w,h);
        makeWindow(data,2,1/3,0,w,h);
        makeWindow(data,3,2/3,0,w,h);
    case 4
        w=0.5; h=0.5;
        makeWindow(data,1,0.5,0  ,w,h);
        makeWindow(data,2,0.5,0.5,w,h);
        makeWindow(data,3,0  ,0.5,w,h);
        makeWindow(data,4,0  ,0  ,w,h);
end
menubar

function data=makeWindow(data,id,x,y,w,h)
a=0.01;
set(data.subwindow(id).handles.axes,  'position', [(x+a/2) (y+a/2) (w-a) (h-0.07-a) ]);
set(data.subwindow(id).handles.uipanelmenu,  'position', [x y w h]);

function data=addWindowsMenus(data)
for i=1:data.NumberWindows
    % Attach a contextmenu (right-mouse button menu)
    if(ishandle(data.subwindow(i).menu.Handle))
        delete(data.subwindow(i).menu.Handle);
        data.subwindow(i).menu=[];
    end
    
    Menu(1).Label='Render';
    Menu(1).Tag='menu_render';
    Menu(1).Callback='';
    
    for f=1:length(data.rendertypes)
        Menu(1).Children(f).Label=data.rendertypes(f).label;
        Menu(1).Children(f).Callback=['viewer3d(''menu_ChangeRender_Callback'',gcbo,[' num2str(i) ' ' num2str(f) '],guidata(gcbo))'];
    end

    Menu(2).Label='Volume';

    hn=0;
    for f=0:length(data.volumes)
        if(f==0), 
            name='None'; 
            g=[];
        else
            name=data.volumes(f).name; 
            g=structfind(data.volumes(f+1:end),'Size_original',data.volumes(f).Size_original);
            if(~isempty(g)); g=g+f; g=g(1:min(end,2)); end
        end

        hn=hn+1; 
        Menu(2).Children(hn).Callback=['viewer3d(''menu_ChangeVolume_Callback'',gcbo,[' num2str(i) ' ' num2str(f) '],guidata(gcbo))'];
        Menu(2).Children(hn).Label=name;
        Menu(2).Children(hn).Tag=['wmenu-' num2str(i) '-' num2str(f)];

        if(~isempty(g))
            hn=hn+1; 
            Menu(2).Children(hn).Callback=['viewer3d(''menu_ChangeVolume_Callback'',gcbo,[' num2str(i) ' ' num2str(f)  ' ' num2str(g(1)) '],guidata(gcbo))'];
            Menu(2).Children(hn).Label=[name ' & ' data.volumes(g(1)).name];
            Menu(2).Children(hn).Tag=['wmenu-' num2str(i) '-' num2str(f) '-' num2str(g(1))];
            
            if(length(g)>1)
                hn=hn+1; 
                Menu(2).Children(hn).Callback=['viewer3d(''menu_ChangeVolume_Callback'',gcbo,[' num2str(i) ' ' num2str(f)  ' ' num2str(g(1)) ' ' num2str(g(2)) '],guidata(gcbo))'];
                Menu(2).Children(hn).Label=[name ' & ' data.volumes(g(1)).name ' & ' data.volumes(g(2)).name];
                Menu(2).Children(hn).Tag=['wmenu-' num2str(i) '-' num2str(f) '-' num2str(g(1)) '-' num2str(g(2)) ];
            end
        end
        
    end

    
    Menu(3).Label='Config';
    Menu(3).Tag='menu_config';
    Menu(3).Callback='viewer3d(''menu_measure_Callback'',gcbo,[],guidata(gcbo))';
    
    Menu(3).Children(1).Label='Light Vector';
    Menu(3).Children(1).Tag='menu_lightvector';
    Menu(3).Children(1).Callback=['viewer3d(''menu_lightvector_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];
    Menu(3).Children(2).Label='Shading Shiny';
    Menu(3).Children(2).Tag='menu_shiny';
    Menu(3).Children(2).Callback=['viewer3d(''menu_shiny_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];
    Menu(3).Children(3).Label='Shading Dull';
    Menu(3).Children(3).Tag='menu_dull';
    Menu(3).Children(3).Callback=['viewer3d(''menu_dull_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];
    Menu(3).Children(4).Label='Shading Metal';
    Menu(3).Children(4).Tag='menu_metal';
    Menu(3).Children(4).Callback=['viewer3d(''menu_metal_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];
    Menu(3).Children(5).Label='Slices Color';
    Menu(3).Children(5).Tag='menu_config_slicescolor';
    Menu(3).Children(5).Callback=['viewer3d(''menu_config_slicescolor_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];

    Menu(3).Children(6).Label='Combine Transparent';
    Menu(3).Children(6).Tag='menu_combine_trans';
    Menu(3).Children(6).Callback=['viewer3d(''menu_combine_Callback'',gcbo,[' num2str(i) ' 1],guidata(gcbo))'];
    Menu(3).Children(7).Label='Combine RGB';
    Menu(3).Children(7).Tag='menu_combine_rgb';
    Menu(3).Children(7).Callback=['viewer3d(''menu_combine_Callback'',gcbo,[' num2str(i) ' 2],guidata(gcbo))'];
   
    
    Menu(4).Label='Measure';
    Menu(4).Tag='menu_measure';
    Menu(4).Callback='viewer3d(''menu_measure_Callback'',gcbo,[],guidata(gcbo))';

    Menu(4).Children(1).Label='Distance (key D)';
    Menu(4).Children(1).Tag='menu_measure_distance';
    Menu(4).Children(1).Callback='viewer3d(''menu_measure_distance_Callback'',gcbo,[],guidata(gcbo))';

    Menu(4).Children(2).Label='Roi Selection (key R)';
    Menu(4).Children(2).Tag='menu_measure_roi';
    Menu(4).Children(2).Callback='viewer3d(''menu_measure_roi_Callback'',gcbo,[],guidata(gcbo))';

    Menu(4).Children(3).Label='LandMark (key L)';
    Menu(4).Children(3).Tag='menu_measure_landmark';
    Menu(4).Children(3).Callback='viewer3d(''menu_measure_landmark_Callback'',gcbo,[],guidata(gcbo))';

    Menu(5).Label='Segment';
    Menu(5).Tag='menu_segment';
    Menu(5).Callback='viewer3d(''menu_measure_Callback'',gcbo,[],guidata(gcbo))';

    Menu(5).Children(1).Label='Roi Selection (key C)';
    Menu(5).Children(1).Tag='menu_segment_roi';
    Menu(5).Children(1).Callback='viewer3d(''menu_segment_roi_Callback'',gcbo,[],guidata(gcbo))';

    handle_menu=uicontextmenu;
    Menu=addMenu(handle_menu,Menu);
    data.subwindow(i).menu.Handle=handle_menu;
    data.subwindow(i).menu.Children=Menu;
    
    set(data.subwindow(i).handles.uipanelmenu,'UIContextMenu',data.subwindow(i).menu.Handle);
end
menubar
set_menu_checks(data);




% --------------------------------------------------------------------
function menu_window_Callback(hObject, eventdata, handles)
% hObject    handle to menu_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function menu_volume_ws_Callback(hObject, eventdata, handles)
% hObject    handle to menu_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
volume_select=eventdata;

% Get variables in the workspace
assignin('base','VolumeData',data.volumes(volume_select).volume_original);
assignin('base','VolumeInfo',data.volumes(volume_select).info);
assignin('base','VolumeScales',data.volumes(volume_select).Scales);

% --------------------------------------------------------------------
function  menu_volume_close_Callback(hObject, eventdata, handles)
% hObject    handle to menu_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=getMyData(); if(isempty(data)), return, end
volume_select=eventdata;
data.volume_id_select(1)=data.volumes(volume_select).id;

for i=1:data.NumberWindows
    if(any(data.subwindow(i).volume_id_select==data.volume_id_select))
        data.subwindow(i).volume_id_select=0;
        data.subwindow(i).render_type='black';
                
    end
end

delete(data.MenuVolume(volume_select).Handle);
 
data.MenuVolume(volume_select)=[];
data.volumes(volume_select)=[];
data=addWindowsMenus(data);
setMyData(data);
addMenuVolume();
set_menu_checks(data);
allshow3d(false,true);


function Menu=showmenu(handle_figure)
Menu(1).Label='File';
Menu(1).Tag='menu_file';
Menu(1).Callback='viewer3d(''menu_file_Callback'',gcbo,[],guidata(gcbo))';

Menu(1).Children(1).Label='Load View';
Menu(1).Children(1).Tag='menu_load_view';
Menu(1).Children(1).Callback='viewer3d(''menu_load_view_Callback'',gcbo,[],guidata(gcbo))';

Menu(1).Children(2).Label='Load Workspace Variable';
Menu(1).Children(2).Tag='menu_load_worksp';
Menu(1).Children(2).Callback='viewer3d(''menu_load_worksp_Callback'',gcbo,[],guidata(gcbo))';

Menu(1).Children(3).Label='Open Medical 3D File';
Menu(1).Children(3).Tag='menu_load_data';
Menu(1).Children(3).Callback='viewer3d(''menu_load_data_Callback'',gcbo,[],guidata(gcbo))';

Menu(1).Children(4).Label='Save View';
Menu(1).Children(4).Tag='menu_save_view';
Menu(1).Children(4).Callback='viewer3d(''menu_save_view_Callback'',gcbo,[],guidata(gcbo))';

Menu(1).Children(5).Label='Save Picture';
Menu(1).Children(5).Tag='menu_save_picture';
Menu(1).Children(5).Callback='viewer3d(''menu_save_picture_Callback'',gcbo,[],guidata(gcbo))';

Menu(1).Children(6).Label='filename1';
Menu(1).Children(6).Tag='load_filename1';
Menu(1).Children(6).Callback='viewer3d(''load_filename1_Callback'',gcbo,[],guidata(gcbo))';

Menu(1).Children(7).Label='filename2';
Menu(1).Children(7).Tag='load_filename2';
Menu(1).Children(7).Callback='viewer3d(''load_filename2_Callback'',gcbo,[],guidata(gcbo))';

Menu(1).Children(8).Label='filename3';
Menu(1).Children(8).Tag='load_filename3';
Menu(1).Children(8).Callback='viewer3d(''load_filename3_Callback'',gcbo,[],guidata(gcbo))';

Menu(1).Children(9).Label='filename4';
Menu(1).Children(9).Tag='load_filename4';
Menu(1).Children(9).Callback='viewer3d(''load_filename4_Callback'',gcbo,[],guidata(gcbo))';

Menu(1).Children(10).Label='filename5';
Menu(1).Children(10).Tag='load_filename5';
Menu(1).Children(10).Callback='viewer3d(''load_filename5_Callback'',gcbo,[],guidata(gcbo))';

Menu(2).Label='Window';
Menu(2).Tag='menu_window';
Menu(2).Callback='viewer3d(''menu_window_Callback'',gcbo,[],guidata(gcbo))';

Menu(2).Children(1).Label='One Window';
Menu(2).Children(1).Tag='menu_windows1';
Menu(2).Children(1).Callback='viewer3d(''menu_windows1_Callback'',gcbo,[],guidata(gcbo))';

Menu(2).Children(2).Label='Two Windows';
Menu(2).Children(2).Tag='menu_windows2';
Menu(2).Children(2).Callback='viewer3d(''menu_windows2_Callback'',gcbo,[],guidata(gcbo))';

Menu(2).Children(3).Label='Three Windows';
Menu(2).Children(3).Tag='menu_windows3';
Menu(2).Children(3).Callback='viewer3d(''menu_windows3_Callback'',gcbo,[],guidata(gcbo))';

Menu(2).Children(4).Label='Four Windows';
Menu(2).Children(4).Tag='menu_windows4';
Menu(2).Children(4).Callback='viewer3d(''menu_windows4_Callback'',gcbo,[],guidata(gcbo))';


Menu(3).Label='Config';
Menu(3).Tag='menu_config';
Menu(3).Callback='viewer3d(''menu_config_Callback'',gcbo,[],guidata(gcbo))';

Menu(3).Children(1).Label='Quality v. Speed';
Menu(3).Children(1).Tag='menu_quality_speed';
Menu(3).Children(1).Callback='viewer3d(''menu_quality_speed_Callback'',gcbo,[],guidata(gcbo))';

Menu(3).Children(2).Label='Compile C Files';
Menu(3).Children(2).Tag='menu_compile_files';
Menu(3).Children(2).Callback='viewer3d(''menu_compile_files_Callback'',gcbo,[],guidata(gcbo))';


Menu(4).Label='Help';
Menu(4).Tag='menu_info';
Menu(4).Callback='viewer3d(''menu_info_Callback'',gcbo,[],guidata(gcbo))';

Menu(4).Children(1).Label='Help';
Menu(4).Children(1).Tag='menu_help';
Menu(4).Children(1).Callback='viewer3d(''menu_help_Callback'',gcbo,[],guidata(gcbo))';

Menu(4).Children(2).Label='About';
Menu(4).Children(2).Tag='menu_about';
Menu(4).Children(2).Callback='viewer3d(''menu_about_Callback'',gcbo,[],guidata(gcbo))';

Menu(4).Children(3).Label='Console';
Menu(4).Children(3).Tag='menu_console';
Menu(4).Children(3).Callback='viewer3d(''menu_console_Callback'',gcbo,[],guidata(gcbo))';

%set(figurehandles.figure,'Toolbar','none')
%set(figurehandles.figure,'MenuBar','none')
Menu=addMenu(handle_figure,Menu);

function addMenuVolume()
%data.MenuVolume=addMenuVolume(data.figurehandles.viewer3d,data.volumes);
data=getMyData(); if(isempty(data)), return, end
if(isempty(data.volumes)), return, end

% Delete existing volume menus
for i=1:length(data.MenuVolume)
    delete(data.MenuVolume(i).Handle);
end

MenuVolume=struct; 
for i=1:length(data.volumes)
    MenuVolume(i).Label=data.volumes(i).name;
    MenuVolume(i).Tag='menu_volume';
    if(data.volumes(i).Editable)
        MenuVolume(i).ForegroundColor=[0 0.5 0];
    else
        MenuVolume(i).ForegroundColor=[0 0 1];
    end
    
    MenuVolume(i).Callback='';

    MenuVolume(i).Children(1).Label='WindowLevel&Width';
    MenuVolume(i).Children(1).Tag='menu_config_contrast';
    MenuVolume(i).Children(1).Callback=['viewer3d(''menu_config_contrast_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];

    MenuVolume(i).Children(2).Label='Change Alpha&Colors';
    MenuVolume(i).Children(2).Tag='menu_change_alpha_colors';
    MenuVolume(i).Children(2).Callback=['viewer3d(''menu_change_alpha_colors_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];
  
    MenuVolume(i).Children(3).Label='Voxel Size';
    MenuVolume(i).Children(3).Tag='menu_voxelsize';
    MenuVolume(i).Children(3).Callback=['viewer3d(''menu_voxelsize_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];

    MenuVolume(i).Children(4).Label='Data Info';
    MenuVolume(i).Children(4).Tag='menu_data_info';
    MenuVolume(i).Children(4).Callback=['viewer3d(''menu_data_info_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];

    MenuVolume(i).Children(5).Label='Add Empty(Segment)Volume';
    MenuVolume(i).Children(5).Tag='menu_add_segvol';
    MenuVolume(i).Children(5).Callback=['viewer3d(''menu_addseg_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];
    
    
    MenuVolume(i).Children(6).Label='Volume to Workspace';
    MenuVolume(i).Children(6).Tag='menu_volume_ws';
    MenuVolume(i).Children(6).Callback=['viewer3d(''menu_volume_ws_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];
    
    
    MenuVolume(i).Children(7).Label='Close';
    MenuVolume(i).Children(7).Tag='menu_volume_close';
    MenuVolume(i).Children(7).Callback=['viewer3d(''menu_volume_close_Callback'',gcbo,' num2str(i) ',guidata(gcbo))'];
end
data.MenuVolume=addMenu(data.figurehandles.viewer3d,MenuVolume);
setMyData(data);

function Menu=addMenu(handle_figure,Menu)
Properties={'Label','Callback','Separator','Checked','Enable','ForegroundColor','Position','ButtonDownFcn','Selected','SelectionHighlight','Visible','UserData'};
for i=1:length(Menu)
    z2=Menu(i);
    z2.Handle=uimenu(handle_figure, 'Label',z2.Label);
    for j=1:length(Properties)
            Pr=Properties{j};
            if(isfield(z2,Pr))
                val=z2.(Pr);
                if(~isempty(val)), set(z2.Handle ,Pr,val); end
            end
    end
    if(isfield(z2,'Children')&&~isempty(z2.Children))
        Menu(i).Children=addMenu(z2.Handle,z2.Children);
    end
    Menu(i).Handle=z2.Handle;
end

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menubar('ResizeFcn',gcf);