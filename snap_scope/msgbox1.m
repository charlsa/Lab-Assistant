function varargout=msgbox(varargin)
%MSGBOX Message box.
%  msgbox(Message) creates a message box that automatically wraps
%  Message to fit an appropriately sized Figure.  Message is a string
%  vector, string matrix or cell array.
%
%  msgbox(Message,Title) specifies the title of the message box.
%
%  msgbox(Message,Title,Icon) specifies which Icon to display in
%  the message box.  Icon is 'none', 'error', 'help', 'warn', or
%  'custom'. The default is 'none'.
%
%  msgbox(Message,Title,'custom',IconData,IconCMap) defines a 
%  customized icon.  IconData contains image data defining the icon;
%  IconCMap is the colormap used for the image.
%
%  msgbox(Message, ... ,CreateMode) specifies whether the message box is modal
%  or non-modal and if it is non-modal, whether to replace another
%  message box with the same Title.  Valid values for CreateMode are
%  'modal', 'non-modal','replace'.  'non-modal' is the default.
%
%  CreateMode may also be a structure with fields WindowStyle and
%  Interpreter.  WindowStyle may be any of the values above.
%  Interpreter may be 'tex' or 'none'.  The default value for the
%  Interpreter is 'none';
%
%  h = msgbox(...) returns the handle of the box in h.
%
%  To make msgbox block execution until the user responds, include the
%  string 'modal' in the input argument list and wrap the call to
%  msgbox with UIWAIT.
%
%  An example which blocks execution until the user responds:
%    uiwait(msgbox('String','Title','modal'));
%
%  An example using a custom Icon is:
%    Data=1:64;Data=(Data'*Data)/64;
%    h=msgbox('String','Title','custom',Data,hot(64))
%
%  An example which reuses the existing msgbox window:
%    CreateStruct.WindowStyle='replace';
%    CreateStruct.Interpreter='tex';
%    h=msgbox('X^2 + Y^2','Title','custom',Data,hot(64),CreateStruct);
%  
%  See also DIALOG, ERRORDLG, HELPDLG, TEXTWRAP, WARNDLG, UIWAIT.

%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.57 $


error(nargchk(1,6,nargin));
error(nargoutchk(0,1,nargout));

BodyTextString=varargin{1};
if ~iscell(BodyTextString),BodyTextString=cellstr(BodyTextString);end

if strcmp(BodyTextString{1},'#FigKeyPressFcn'),
  AsciiVal= abs(get(get(0,'CurrentFigure'),'CurrentCharacter'));
  if ~isempty(AsciiVal),
      if AsciiVal==32 | AsciiVal==13,
      delete(get(0,'CurrentFigure'));
    end %if abs
  end
  return
end

%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%

Interpreter='none';
switch nargin,
  case 1,
    TitleString=' ';
    IconString='none';IconData=[];IconCMap=[];
    CreateMode='non-modal';
  case 2,
    [Flag,CreateMode,Interpreter]=InternalCreateFlag(varargin{2});
    if Flag, % CreateMode specified
      TitleString=' ';
      IconString='none';IconData=[];IconCMap=[];
    else,
      TitleString=varargin{2};
      IconString='none';IconData=[];IconCMap=[];
    end      
  case 3,
    [Flag,CreateMode,Interpreter]=InternalCreateFlag(varargin{3});
    if Flag, % CreateMode specified
      TitleString=varargin{2};
      IconString='none';IconData=[];IconCMap=[];
    else,
      TitleString=varargin{2};
      IconString=varargin{3};IconData=[];IconCMap=[];
    end      
  case 4,
    TitleString=varargin{2};
    IconString=varargin{3};IconData=[];IconCMap=[];
    [Flag,CreateMode,Interpreter]=InternalCreateFlag(varargin{4});
    
  case 5,
    [Flag,CreateMode,Interpreter]=InternalCreateFlag(varargin{5});
    if Flag, % CreateMode specified
      error(['A Colormap must be specified when calling MSGBOX with 5 ', ...
             'input arguments.']);
    else,
      TitleString=varargin{2};
      IconString=varargin{3};IconData=varargin{4};
      IconCMap=varargin{5};
      if ~strcmp(lower(IconString),'custom'),
        warning(['Icon must be ''custom'' when specifying icon data ' ...
                 'in MSGBOX']);
        IconString='custom';
      end        
    end      
  case 6,
    [Flag,CreateMode,Interpreter]=InternalCreateFlag(varargin{6});
    TitleString=varargin{2};
    IconString=varargin{3};IconData=varargin{4};
    IconCMap=varargin{5};
    
end  

CreateMode=lower(CreateMode);
if ~strcmp(CreateMode,'non-modal')& ~strcmp(CreateMode,'modal') & ...
   ~strcmp(CreateMode,'replace'),
    warning('Invalid string for CreateMode in MSGBOX.');
    CreateMode='non-modal';
end    

IconString=lower(IconString);
if ~(strcmp(IconString,'none')|strcmp(IconString,'help')  ...
    |strcmp(IconString,'warn')|strcmp(IconString,'error') ...
    |strcmp(IconString,'custom')),
    warning('Invalid string for Icon in MSGBOX.');
    IconString='none';
end

%%%%%%%%%%%%%%%%%%%%%
%%% General Info. %%%
%%%%%%%%%%%%%%%%%%%%%
Black      =[0       0        0      ]/255;
LightGray  =[192     192      192    ]/255;
LightGray2 =[160     160      164    ]/255;
MediumGray =[128     128      128    ]/255;
White      =[255     255      255    ]/255;

%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
DefFigPos=get(0,'DefaultFigurePosition');

MsgOff=20;
%IconWidth=32;
IconWidth=38;

if strcmp(IconString,'none'),
  FigWidth=100;
  MsgTxtWidth=FigWidth-2*MsgOff;
else,
  FigWidth=190;
  MsgTxtWidth=FigWidth-2*MsgOff-IconWidth;
end
FigHeight=50;
DefFigPos(3:4)=[FigWidth FigHeight];

MsgTxtXOffset=MsgOff;
MsgTxtYOffset=MsgOff;
MsgTxtHeight=FigHeight-MsgOff-MsgTxtYOffset;
MsgTxtForeClr=Black;

%IconHeight=32;
IconHeight=38;
IconXOffset=MsgTxtXOffset;
IconYOffset=FigHeight-MsgOff-IconHeight;

%%%%%%%%%%%%%%%%%%%%%
%%% Create MsgBox %%%
%%%%%%%%%%%%%%%%%%%%%

CreateModeFlag=1;

% See if a modal or replace dialog already exists and delete all of its 
% children
MsgboxTag = ['Msgbox_', TitleString];
if ~strcmp(CreateMode,'non-modal'),
  TempHide=get(0,'ShowHiddenHandles');
  set(0,'ShowHiddenHandles','on');
  OldFig=findobj(0,'Type','figure','Tag',MsgboxTag,'Name',TitleString);
  if ~isempty(OldFig),
    CreateModeFlag=0;
    if length(OldFig)>1,
      BoxHandle=OldFig(1);
      close(OldFig(2:end));
      OldFig(2:end)=[];
    end % if length
    BoxHandle=OldFig;
    CurPos=get(BoxHandle,'Position');
    CurPos(3:4)=[FigWidth FigHeight];
    set(BoxHandle,'Position',CurPos);
    BoxChildren=get(BoxHandle,'Children');
    delete(BoxChildren);
    figure(BoxHandle);
  end
  set(0,'ShowHiddenHandles',TempHide);
end

if strcmp(CreateMode,'modal'),
  WindowStyle='modal';
else,
  WindowStyle='normal';
end

if CreateModeFlag,
  BoxHandle=dialog(                                            ...
                  'Name'            ,TitleString             , ...
                  'Pointer'         ,'arrow'                 , ...
                  'Units'           ,'points'                , ...
                  'Visible'         ,'off'                   , ...
                  'KeyPressFcn'     ,'msgbox #FigKeyPressFcn', ...
                  'WindowStyle'     ,WindowStyle             , ...
                  'HandleVisibility','callback'              , ...
                  'Toolbar'         ,'none'                  , ...
                  'Tag'             ,MsgboxTag                 ...
                  );
else,
  set(BoxHandle,   ...
     'WindowStyle'     ,WindowStyle, ...
     'HandleVisibility','on'         ...
     );
end %if strcmp

FigColor=get(BoxHandle,'Color');

MsgTxtBackClr=FigColor;

Font.FontUnits='points';
Font.FontSize=get(0,'FactoryUIControlFontSize');
Font.FontName=get(0,'FactoryUIControlFontName');

MsgHandle=uicontrol(BoxHandle           , Font          , ...
                   'Style'              ,'text'         , ...
                   'Units'              ,'points'       , ...
                   'Position'           ,[MsgTxtXOffset ...
                                          MsgTxtYOffset ...
                                          MsgTxtWidth   ...
                                          MsgTxtHeight  ...
                                         ]              , ...
                   'String'             ,' '            , ...
                   'Tag'                ,'MessageBox'   , ...
                   'HorizontalAlignment','left'         , ...    
                   'BackgroundColor'    ,MsgTxtBackClr  , ...
                   'ForegroundColor'    ,MsgTxtForeClr    ...
                   );

               
[WrapString,NewMsgTxtPos]=textwrap(MsgHandle,BodyTextString,75);
NumLines=size(WrapString,1);

MsgTxtWidth=max(MsgTxtWidth,NewMsgTxtPos(3));
MsgTxtHeight=max(MsgTxtHeight,NewMsgTxtPos(4));

if ~strcmp(IconString,'none'),
  MsgTxtXOffset=IconXOffset+IconWidth+MsgOff;
  FigWidth=MsgTxtXOffset+MsgTxtWidth+MsgOff;  
  % Center Vertically around icon  
  if IconHeight>MsgTxtHeight,
    IconYOffset=MsgOff;
    MsgTxtYOffset=IconYOffset+(IconHeight-MsgTxtHeight)/2;
    FigHeight=IconYOffset+IconHeight+MsgOff;    
  % center around text    
  else,
    MsgTxtYOffset=MsgOff;
    IconYOffset=MsgTxtYOffset+(MsgTxtHeight-IconHeight)/2;
    FigHeight=MsgTxtYOffset+MsgTxtHeight+MsgOff;    
  end    
  
else,
  FigWidth=MsgTxtWidth+2*MsgOff;  
  MsgTxtYOffset=MsgOff;
  FigHeight=MsgTxtYOffset+MsgTxtHeight+MsgOff;
end % if ~strcmp

 
DefFigPos(3:4)=[FigWidth FigHeight];

if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','points');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    DefFigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    DefFigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','points');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    DefFigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                      (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end

set(BoxHandle,'Position',DefFigPos);
 
delete(MsgHandle);
AxesHandle=axes('Parent',BoxHandle,'Position',[0 0 1 1],'Visible','off');

MsgHandle=text( ...
    'Parent'              ,AxesHandle                        , ...
    'Units'               ,'points'                          , ...
    Font                  , ...
    'HorizontalAlignment' ,'left'                            , ...
    'VerticalAlignment'   ,'bottom'                          , ...
    'HandleVisibility'    ,'callback'                        , ...
    'Position'            ,[ MsgTxtXOffset MsgTxtYOffset+5 0], ...
    'String'              ,WrapString                        , ...
    'Interpreter'         ,Interpreter                       , ...
    'Tag'                 ,'MessageBox'                        ...
    );


if ~strcmp(IconString,'none'),
  IconAxes=axes(                                            ...
               'Parent'          ,BoxHandle               , ...
               'Units'           ,'points'                , ...
               'Position'        ,[IconXOffset IconYOffset ...
                                   IconWidth IconHeight]  , ...
               'HandleVisibility','on'                    , ...
               'Tag'             ,'IconAxes'                ...
               );         
 

  if ~strcmp(IconString,'custom'),IconCMap=[Black;FigColor];end
 
 load dialogicons.mat
 if strcmp('warn',IconString),
            IconData=warnIconData;
            warnIconMap(256,:)=get(BoxHandle,'color');
            IconCMap=warnIconMap;
    
  elseif strcmp('help',IconString),
            IconData=helpIconData;
            helpIconMap(256,:)=get(BoxHandle,'color');
            IconCMap=helpIconMap;

  elseif strcmp('error',IconString),
            IconData=errorIconData;
            errorIconMap(146,:)=get(BoxHandle,'color');
            IconCMap=errorIconMap;
  end
  
  Img=image('CData',IconData,'Parent',IconAxes);  
  set(BoxHandle, 'Colormap', IconCMap);
  set(IconAxes          , ...
      'XLim'            ,get(Img,'XData')+[-0.5 0.5], ...
      'YLim'            ,get(Img,'YData')+[-0.5 0.5], ...
      'Visible'         ,'off'                      , ...
      'YDir'            ,'reverse'                  , ...      
      'HandleVisibility','callback'                   ...
      );
  
end % if ~strcmp
set(BoxHandle,'HandleVisibility','callback','Visible','on');
% make sure the window gets drawn even if we are in a pause
drawnow


if nargout==1,varargout{1}=BoxHandle;end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% InternalCreateFlag %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Flag,CreateMode,Interpreter]=InternalCreateFlag(String)

Flag=0;
CreateMode='non-modal';
Interpreter='none';

if iscell(String),String=String{:};end
if isstr(String),
  if strcmp(String,'non-modal') | strcmp(String,'modal') | ...
     strcmp(String,'replace'),
    Flag=1;
    CreateMode=String;
  end
elseif isstruct(String),
  Flag=1;
  CreateMode=String.WindowStyle;
  Interpreter=String.Interpreter;
end  
