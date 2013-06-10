function menubar(varargin)
% This function MenuBar, allows the user to create menu's anywhere in a figure
% it replaces UIcontextmenu of UIpanels by real menu bars.
%
%   menubar(figure_handle)    or          menubar
%
% Mouse hover, and window-resize updates can be enabled by
%  
%   menubar('start',figure_handle)   or      menubar('start')
%
% Or alternatively by:
%
%   set(figure_handle,'ResizeFcn','menubar(''ResizeFcn'',gcf)');
%   set(figure_handle,'WindowButtonMotionFcn','menubar(''MotionFcn'',gcf)');
%
% Example,
%
%  % Creat figure with uipanel
%  figure,
%  uipanel1 = uipanel('Units','Pixels','Position',[10 200 400 200]);
%  
%  % Attach a contextmenu (right-mouse button menu)
%  menu_panel1=uicontextmenu;
%  set(uipanel1,'UIContextMenu',menu_panel1);
%
%  % Add menu-items to the context menu
%   hchild=uimenu(menu_panel1, 'Label', 'Random Pixels');
%   uimenu(hchild, 'Label', 'Red','Callback','disp(''Red callback'')');
%   uimenu(hchild, 'Label', 'Blue','Callback','disp(''Blue callback'')');
%
%  % Make form the context menu a real menubar
%   menubar
%   
%  % Add some other menu-buttons
%   hchild=uimenu(menu_panel1, 'Label', 'Clear','Callback','disp(''Clear'')');
%   hchild=uimenu(menu_panel1, 'Label', 'Help');
%   uimenu(hchild, 'Label', 'Info','Callback','disp(''Info callback'')');
%
%  % Update the menubar
%   menubar
%
%  % Enable the mouse over and resize effects
%   menubar('start');
%
% Function is written by D.Kroon University of Twente (December 2010)

% Get Figure Handle
figure_handle=gcf; 
if(nargin>0)
	if(isnumeric(varargin{1})), figure_handle=varargin{1}; end
    if(nargin==2), figure_handle=varargin{2}; end
    if(ischar(varargin{1}))
        switch lower(varargin{1})
            case 'resizefcn'
                menubar_ResizeFcn(figure_handle);
            case 'motionfcn'
                menubar_MotionFcn(figure_handle);
            case 'start'
                renewtimer(figure_handle);
        end
        return
    end
end

% There must be Motion Function otherwise the cursorpostion
% in the axis is not updated.
if(isempty(get(figure_handle,'WindowButtonMotionFcn')))
    set(figure_handle,'WindowButtonMotionFcn',@menubar_DummyFcn);
end

% Get the Children of the Figure which are UIpanels
C=get(figure_handle,'Children');
D=false(size(C));
for i=1:length(C), D(i)=strcmpi(get(C(i),'Type'),'uipanel'); end
C=C(D);

% Copy UIContextMenu of uipanels to real menubars
for i=1:length(C)
    % If the panel has a UIContextMenu it is processed    
    uimenuhandle=get(C(i),'UIContextMenu');
    if(isempty(uimenuhandle)||(~ishandle(uimenuhandle))), continue; end
    datahandle=C(i);
    UpdateMenu(datahandle,figure_handle);
end

figuredata.uipanels=C;
setMyData(figuredata,figure_handle)

function renewtimer(figure_handle)
figuredata=getMyData(figure_handle); if(isempty(figuredata)),return; end
if(isfield(figuredata,'timer'))
    stop(figuredata.timer); delete(figuredata.timer);
end
figuredata.timer = timer('TimerFcn',@(x,y)menubar_Timer(x,y,figure_handle), 'Period', 0.2,'ExecutionMode','fixedSpacing');

% Start the event-timer
start(figuredata.timer);
               
setMyData(figuredata,figure_handle);


function m=AddChildren(h,Properties)
% This function will create a Matlab Structure from the UICContextMenu
%
% The structure looks like :
% m(1).Label='File';
% m(1).Children(1).Label='New';
% m(1).Children(1).Children(1).Label='Script';
% m(1).Children(1).Children(2).Label='Function';
% m(1).Children(1).Children(2).Separator='on';
% m(1).Children(1).Children(3).Label='Class';
% m(1).Children(1).Children(3).Callback='disp(''callback'')';
% m(1).Children(2).Label='Open';
% m(1).Children(3).Label='Close';
% m(2).Label='Edit';
% m(2).Callback='disp(''callback'')';
% m(3).Label='View';
% m(4).Label='Insert';
%
m=struct;
% Get all children (menu-items) of the handle
hc=get(h,'Children');
% Sort the children by their tag position (menu-items)
p=zeros(1,length(hc)); 
for i=1:length(hc), p(i)=get(hc(i),'Position'); end; 
[t,i]=sort(p);
% Add the menu-item to the structure
hc=hc(i);
for i=1:length(hc)
    for j=1:length(Properties)
    m(i).(Properties{j})=get(hc(i),Properties{j});
    end
    % If the menu-item has also children (sub-menus), then use the current
    % function recursivly to get all sub-(sub)-(sub)-menus.
    C=get(hc(i),'Children');
    if(~isempty(C)), m(i).Children=AddChildren(hc(i),Properties); end
end

function CreatMenuBar(uimenuhandle,datahandle,Pos,figure_handle)
% Properties (Writeable) of a menu-item
Properties={'Label','Callback','Separator','Checked','Enable','ForegroundColor','Position','ButtonDownFcn','Selected','SelectionHighlight','Visible','UserData'};

% This will create a Matlab Structure from the UICContextMenu
data.menuitems=AddChildren(uimenuhandle,Properties);

% This variable will store the selected-menu button
data.sel=[];

% Store the handle to the current figure
data.figure_handle=figure_handle;

% This variable will store the menu button beneath the mouse 
% used for hover-animation
data.hov=[];

% Store position of uipanel
data.Pos=Pos;

% This Calculates the length and position of each menu-button
% related to the string-lenght of the label
tstr=zeros(length(data.menuitems),1);
for i=1:length(data.menuitems)
    tstr(i)=length(data.menuitems(i).Label)*7+16;
end
% Pos(1) and Pos(2), are the location of the UIpanel in the figure
xpositions=[0;cumsum(tstr)]+Pos(1)+1;
data.xpositions=xpositions;
data.yposition=Pos(2)+Pos(4)-26;

% Instead of .png files with the images, we store the pixels to make
% menubuttons inside the function loadbarimages
[data.IN,data.IS,data.IH]=loadbarimages();

% This function will paint all menu-buttons in the figure
for i=1:length(data.menuitems);
    w=tstr(i); 
    h=25;
    x=xpositions(i);
    [barimage,barimagehover,barimageselect]=getbarimage(w,data);
    data.menuitems(i).Handle=axes('Units','Pixels','Position',[x data.yposition w h],'Parent',figure_handle);
    data.menuitems(i).HandleImshow=imshow(barimage,'Parent',data.menuitems(i).Handle);
    set(data.menuitems(i).HandleImshow,'ButtonDownFcn',@(x,y)menubar_ButtonDownFcn(x,y,datahandle));
    if(strcmpi(data.menuitems(i).Enable,'on'))
        hc=text(8,25/2,data.menuitems(i).Label,'Parent',data.menuitems(i).Handle);
        set(hc,'ButtonDownFcn',@(x,y)menubar_ButtonDownFcn(x,y,datahandle));
    else
        hc=text(8,25/2,data.menuitems(i).Label,'Parent',data.menuitems(i).Handle);
        data.menuitems(i).Children=[];
        set(hc,'Color',[0.5 0.5 0.5]);
    end
    data.menuitems(i).barimage=barimage;
    data.menuitems(i).barimagehover=barimagehover;
    data.menuitems(i).barimageselect=barimageselect;
end

i=length(data.menuitems)+1;
w=round(Pos(3))-sum(tstr(1:end))-3; w(w<1)=1;
x=xpositions(i);
barimage=getbarimage(w,data);
data.menuitems(i).Handle=axes('Units','Pixels','Position',[x data.yposition w h],'Parent',figure_handle);
data.menuitems(i).HandleImshow=imshow(barimage,'Parent',data.menuitems(i).Handle);

% This function builds the sub-menus which will appear beneath the menubar 
% in the figure
z=data.menuitems;
for i=1:length(z)
    data.cMenu(i) = uicontextmenu('Parent',figure_handle);
    addMenuChilds(z(i),data.cMenu(i),Properties)
end

% Store all data (this structure is attached to the uipanel-handle
setMyData(data,datahandle);


function addMenuChilds(z,h,Properties)
% This function builds the sub-menus of the menubar 
% (adding sub-sub-menus recursively)
if(isfield(z,'Children')&&~isempty(z.Children))
    for i=1:length(z.Children)
        z2=z.Children(i);
        hchild=uimenu(h, 'Label', z2.Label);
        for j=1:length(Properties)
            Pr=Properties{j};
            if(isfield(z2,Pr))
                val=z2.(Pr);
                if(~isempty(val)), set(hchild ,Pr,val); end
            end
        end
        addMenuChilds(z2,hchild,Properties)
    end
end

function [barimage,barimagehover,barimageselect]=getbarimage(w,data)
% This function builds the whole menu-buttons from the few pixel-lines stored
% in loadbarimages
barimage=zeros(size(data.IN,1),w,'uint8');
barimage(:,:,1)=repmat(data.IN(:,1),1,w);
barimage(:,:,2)=repmat(data.IN(:,2),1,w);
barimage(:,:,3)=repmat(data.IN(:,3),1,w);
barimagehover=zeros(size(data.IN,1),w,'uint8');
barimagehover(:,:,1)=repmat(data.IH(:,4,1),1,w);
barimagehover(:,:,2)=repmat(data.IH(:,4,2),1,w);
barimagehover(:,:,3)=repmat(data.IH(:,4,3),1,w);
barimagehover(:,1:3,1)=data.IH(:,1:3,1);
barimagehover(:,1:3,2)=data.IH(:,1:3,2);
barimagehover(:,1:3,3)=data.IH(:,1:3,3);
barimagehover(:,end-2:end,1)=data.IH(:,5:7,1);
barimagehover(:,end-2:end,2)=data.IH(:,5:7,2);
barimagehover(:,end-2:end,3)=data.IH(:,5:7,3);
barimageselect=zeros(size(data.IN,1),w,'uint8');
barimageselect(:,:,1)=repmat(data.IS(:,4,1),1,w);
barimageselect(:,:,2)=repmat(data.IS(:,4,2),1,w);
barimageselect(:,:,3)=repmat(data.IS(:,4,3),1,w);
barimageselect(:,1:3,1)=data.IS(:,1:3,1);
barimageselect(:,1:3,2)=data.IS(:,1:3,2);
barimageselect(:,1:3,3)=data.IS(:,1:3,3);
barimageselect(:,end-2:end,1)=data.IS(:,5:7,1);
barimageselect(:,end-2:end,2)=data.IS(:,5:7,2);
barimageselect(:,end-2:end,3)=data.IS(:,5:7,3);

function menubar_ButtonDownFcn(hObject, eventdata,datahandle)
data=getMyData(datahandle); if(isempty(data)), return; end
% Get the handle of the axes, (which is a parant of the clicked image or text).
hp=hObject;
switch get(hp,'Type');
    case 'text', hp=get(hObject,'Parent');
    case 'image', hp=get(hObject,'Parent');
end

% Detect the number of the clicked button
sel=find([data.menuitems.Handle]==hp);

% If another button was selected, reset the image to normal
if(~isempty(data.sel))
    I=data.menuitems(data.sel).barimage;
    set(data.menuitems(data.sel).HandleImshow,'CData',I);
end

% Set the selected-button image to selected, and display menu if present
data.sel=sel;
setSelect(data);

% If this main menu-item has a callback executes it.
dm=data.menuitems(data.sel);
if(isfield(dm,'Callback')&&(~isempty(dm.Callback)))
     if(isa(dm.Callback,'function_handle'))
         feval(dm.Callback);
     else
         eval(dm.Callback);
     end
end

% Store the Data
setMyData(data,datahandle);

function setSelect(data)
% Set the selected-button image to selected, and display menu if present
cMenu=data.cMenu(data.sel);
I=data.menuitems(data.sel).barimageselect;
set(data.menuitems(data.sel).HandleImshow,'CData',I);
set(cMenu,'Visible','off');
u=get(data.menuitems(data.sel).Handle,'Units');
set(data.menuitems(data.sel).Handle,'Units','pixels');
pos=get(data.menuitems(data.sel).Handle,'Position');
set(data.menuitems(data.sel).Handle,'Units',u);
set(cMenu,'Position',[pos(1) pos(2)])
set(cMenu,'Visible','on'); drawnow

function menubar_DummyFcn(hObject, eventdata)



function menubar_MotionFcn(figurehandle)
figuredata=getMyData(figurehandle); if(isempty(figuredata)), return; end
arrayfun(@(x)ProcessMotion(x),figuredata.uipanels)

function menubar_ResizeFcn(figurehandle)
figuredata=getMyData(figurehandle); if(isempty(figuredata)), return; end
arrayfun(@(x)ProcessResize(x),figuredata.uipanels)

function menubar_Timer(hObject, eventdata,figurehandle)
% This function acts like a MotionFcn, (Used to animated hover effect
% on menu buttons)
if(ishandle(figurehandle))
    figuredata=getMyData(figurehandle); if(isempty(figuredata)), return; end
    arrayfun(@(x)ProcessResize(x),figuredata.uipanels)
    arrayfun(@(x)ProcessMotion(x),figuredata.uipanels)
else
    stop(hObject); delete(hObject);
end

function ProcessResize(datahandle)
% This function is responsible for the hover-effect of the menu-buttons.
data=getMyData(datahandle); if(isempty(data)), return; end

% Get Position of Panel in Pixels
U=get(datahandle,'Units'); set(datahandle,'Units','Pixels'); Pos=get(datahandle,'Position'); set(datahandle,'Units',U);

% Replace the menu-bar by a new one, if window resized.
if(any(abs(Pos-data.Pos)>1e-3))
    UpdateMenu(datahandle,data.figure_handle)
end

function UpdateMenu(datahandle,figure_handle)
% Get Position of Panel in Pixels
U=get(datahandle,'Units'); set(datahandle,'Units','Pixels'); Pos=get(datahandle,'Position'); set(datahandle,'Units',U);

% Remove old existing menubars of the panel
removeOldMenuBar(datahandle);
uimenuhandle=get(datahandle,'UIContextMenu');
% Create a real-menubar from the panel UICContextMenu
if(~isempty( get(uimenuhandle,'Children')))
    CreatMenuBar(uimenuhandle,datahandle,Pos,figure_handle)
end
drawnow('expose');
    
function ProcessMotion(datahandle)
% This function is responsible for the hover-effect of the menu-buttons.
data=getMyData(datahandle); if(isempty(data)), return; end
    
hover=false;
for i=1:length(data.menuitems),
    if(~ishandle(data.menuitems(i).Handle)), return; end
    % Detect mouseposition relative to axis coordinates
    p = get(data.menuitems(i).Handle, 'CurrentPoint');
    y= p(1,2); x= p(1,1);
    % The position must be inside the axis it self
    if(y<0||y>25||x<0), break; end
    if(x>0&&x<size( data.menuitems(i).barimage,2))
        % The Mouse is hovering over a menu-button
        hover=true;
        if(~isempty(data.hov)&&(data.hov~=i))
            % If another button is already in hover-modes, set
            % that button to normal-look
            I=data.menuitems( data.hov).barimage;
            set(data.menuitems( data.hov).HandleImshow,'CData',I);
        end
        data.hov=i;
        if(isempty(data.sel))
            % Set current button to hover look
            I=data.menuitems( data.hov).barimagehover;
            set(data.menuitems( data.hov).HandleImshow,'CData',I);
        else
            % If another button is selected, set that button
            % to normal look
            if(data.hov~=data.sel)
                I=data.menuitems( data.hov).barimagehover;
                set(data.menuitems( data.hov).HandleImshow,'CData',I);
            end
        end
        % If another button was already selected, disable the menu
        % beneath the button, enable the menu of the hover-button,
        % and set it to selected modus.
        if(~isempty(data.sel)&&(data.sel~=data.hov))
            cMenu=data.cMenu(data.sel);
            set(cMenu,'Visible','off');
            data.sel=data.hov;
            setSelect(data)
        end
        drawnow('expose');
        break;
    end
end
if(hover)
    setMyData(data,datahandle);
else
    % If the mouse isn't above a button reset any past hover-button to
    % normal
    if(~isempty(data.hov))
        I=data.menuitems( data.hov).barimage;
        set(data.menuitems( data.hov).HandleImshow,'CData',I);
        data.hov=[];
        setMyData(data,datahandle);
        drawnow('expose');
    end
end
% If there is an menubar in selected modus, but his sub-menu already
% disappeared, because the user clicked elsewhere in the figure
% reset also the button in the menubar.
if(~isempty(data.sel))
    cMenu=data.cMenu(data.sel);
    p=get(cMenu,'Visible');
    if(strcmpi(p,'off'))
        I=data.menuitems(data.sel).barimage;
        set(data.menuitems(data.sel).HandleImshow,'CData',I);
        data.sel=[];
        setMyData(data,datahandle);
        drawnow('expose');
    end
end

function [IN,IS,IH]=loadbarimages()
IN(:,:,1) = [254 252 249 246 242 239 235 232 229 211 211 211 212 212 213 214 215 217 218 219 220 222 223 224 225;
    254 253 250 248 245 242 239 236 234 218 218 218 219 219 220 221 222 223 224 225 226 227 228 229 230;
    255 254 253 252 250 249 248 246 245 237 237 237 237 238 238 239 240 240 241 242 243 243 244 245 245]';
IS(:,:,1) = [254  252  175  106   84   83   82   81   80   74   74   74   74   74   74   75   75   76   76   76   77   77   96  157  225;
    254  179   92  145  202  200  206  207  205  193  196  196  200  197  198  199  200  202  202  204  204  207  213  109  156;
    254  111  146  187  206  203  206  207  205  193  196  196  200  197  198  199  200  202  202  204  204  207  213  196   96;
    254   88  161  185  202  200  205  207  205  193  196  196  200  196  197  199  202  203  206  209  210  212  213  212   79;
    254  111  146  169  186  183  191  194  191  181  184  184  188  184  185  187  189  191  193  195  196  198  200  181   96;
    254  179  102  147  163  161  166  168  166  158  160  160  163  161  162  162  165  166  167  170  171  172  162  100  156;
    254  252  175  106   84   83   82   81   80   74   74   74   74   74   74   75   75   76   76   76   77   77   96  157  225]';
IS(:,:,2) = [254  253  175  107   86   84   83   82   82   76   76   76   76   76   77   77   77   78   78   79   79   79   98  161  230;
    254  180   92  146  205  202  209  211  209  199  203  203  206  204  204  205  206  207  207  209  210  212  217  111  160;
    254  111  147  189  208  206  210  211  209  199  203  203  206  204  204  205  206  207  207  209  210  212  217  200   98;
    254   88  161  186  205  202  208  211  209  199  203  203  206  203  204  205  208  209  212  214  215  216  218  217   80;
    254  111  147  171  188  186  195  197  195  187  190  190  194  190  191  193  195  196  198  200  201  202  204  185   98;
    254  180  102  148  164  163  168  170  169  162  165  165  167  166  166  167  169  170  171  174  175  175  165  102  160;
    254  253  175  107   86   84   83   82   82   76   76   76   76   76   77   77   77   78   78   79   79   79   98  161  230]';
IS(:,:,3) = [255  254  178  109   87   87   87   86   86   83   83   83   83   83   83   83   84   84   84   84   85   85  105  172  245;
    255  180   93  148  209  208  217  220  219  217  220  220  223  221  221  222  223  223  223  225  226  227  233  119  170;
    255  112  148  192  213  212  218  220  219  217  220  220  223  221  221  222  223  223  223  225  226  227  233  214  105;
    255   89  163  189  209  208  216  220  219  217  220  220  223  220  220  222  225  225  228  231  232  232  233  232   86;
    255  112  148  173  191  191  202  205  204  202  206  206  209  206  206  208  210  210  212  215  216  216  218  197  105;
    255  180  103  150  167  167  174  176  176  174  177  177  179  178  178  179  181  181  183  185  186  186  175  109  170;
    255  254  178  109   87   87   87   86   86   83   83   83   83   83   83   83   84   84   84   84   85   85  105  172  245]';
IH(:,:,1) = [254  252  215  181  169  167  164  162  160  147  147  147  148  148  149  149  150  151  152  153  154  155  164  193  225;
    254  218  192  242  251  250  248  246  244  235  234  234  233  210  211  214  218  219  223  229  229  233  226  176  193;
    254  187  242  252  244  242  237  231  229  214  211  211  209  193  194  197  201  203  208  213  214  219  233  228  165;
    254  176  252  248  244  242  237  231  229  214  211  211  209  193  194  197  201  203  208  213  214  219  223  238  157;
    254  187  242  252  244  242  237  231  229  214  211  211  209  193  194  197  201  203  208  213  214  219  233  228  165;
    254  218  192  242  251  250  248  246  244  235  234  234  233  210  211  214  218  219  223  229  229  233  226  176  193;
    254  252  215  181  169  167  164  162  160  147  147  147  148  148  149  149  150  151  152  153  154  155  164  193  225]';
IH(:,:,2) = [254  253  216  183  171  169  167  165  163  152  152  152  153  153  154  154  155  156  156  157  158  158  168  198  230;
    254  219  193  243  252  251  249  247  246  238  237  237  237  214  214  217  222  222  226  232  232  235  229  179  198;
    254  188  242  253  245  244  239  234  233  219  216  216  215  199  200  203  207  208  213  219  220  224  236  231  169;
    254  177  253  249  245  244  239  234  233  219  216  216  215  199  200  203  207  208  213  219  220  224  227  241  161;
    254  188  242  253  245  244  239  234  233  219  216  216  215  199  200  203  207  208  213  219  220  224  236  231  169;
    254  219  193  243  252  251  249  247  246  238  237  237  237  214  214  217  222  222  226  232  232  235  229  179  198;
    254  253  216  183  171  169  167  165  163  152  152  152  153  153  154  154  155  156  156  157  158  158  168  198  230]';
IH(:,:,3) = [255  254  218  186  175  174  173  172  171  165  165  165  165  166  166  167  168  168  168  169  170  170  180  211  245;
    255  220  195  244  253  253  252  251  251  247  246  246  246  222  222  226  230  230  234  240  240  243  237  189  210;
    255  188  243  254  248  248  245  241  240  233  231  231  229  215  215  218  222  222  228  234  234  238  246  240  180;
    255  177  253  251  248  248  245  241  240  233  231  231  229  215  215  218  222  222  228  234  234  238  242  249  171;
    255  188  243  254  248  248  245  241  240  233  231  231  229  215  215  218  222  222  228  234  234  238  246  240  180;
    255  220  195  244  253  253  252  251  251  247  246  246  246  222  222  226  230  230  234  240  240  243  237  189  210;
    255  254  218  186  175  174  173  172  171  165  165  165  165  166  166  167  168  168  168  169  170  170  180  211  245]';
IN=uint8(IN);
IH=uint8(IH);
IS=uint8(IS);

function w=removeOldMenuBar(datahandle)
% This function detects if the uipanel is replaced in the past by 
% a menubar, and removes the menubar in the figure, and the stored-data.
data=getMyData(datahandle); if(isempty(data)),return; end
for i=1:length(data.menuitems)
    if(ishandle(data.menuitems(i).Handle))
        delete(data.menuitems(i).Handle);
    end
    if(ishandle(data.cMenu(i)))
        delete(data.cMenu(i));
    end
end
remMyData(datahandle);
w=true;

function remMyData(datahandle)
% Get data struct stored in figure
rmappdata(datahandle,'menubar');
 
function setMyData(data,datahandle)
% Store data struct in figure
setappdata(datahandle,'menubar',data);

function data=getMyData(datahandle)
% Get data struct stored in figure
data=getappdata(datahandle,'menubar');