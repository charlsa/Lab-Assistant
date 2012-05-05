function Guiexample3


 % Create the data to plot.
   peaks_data = peaks(35);
   membrane_data = membrane;
   [x,y] = meshgrid(-8:.5:8);
   r = sqrt(x.^2+y.^2) + eps;
   sinc_data = sin(r)./r;
   
 %H.gui=dialog('WindowStyle','normal','Resize','on','Name','MMGuiExample','Units','pixels','Position',[(Ssize(3)-ax1)/2 (Ssize(4)-ay1)/2 ax1 ay1]);
set(0,'units','pixels');
Ssize=get(0,'ScreenSize');

ax1=Ssize(3)*2/3;
ay1=Ssize(4)*2/3;

 H.gui=figure('Units','pixels','Position',[(Ssize(3)-ax1)/2 (Ssize(4)-ay1)/2 ax1 ay1]);
 
   %Create a plot in the axes.
   current_data = peaks_data;

hsurf = uicontrol('Style','pushbutton','Parent',H.gui,'String','Surf','Position',[250,(Ssize(4)-ay1)/2+190,70,25],'Callback',{@local_surfbutton,H}); 
hmesh = uicontrol('Style','pushbutton','Parent',H.gui,'String','Mesh','Position',[250,(Ssize(4)-ay1)/2+150,70,25],'Callback',{@local_meshbutton,H});
hcontour = uicontrol('Style','pushbutton','Parent',H.gui,'String','Countour','Position',[250,(Ssize(4)-ay1)/2+105,70,25],'Callback',{@local_contourbutton,H});
htext = uicontrol('Style','text','Parent',H.gui,'String','Select Data','Position',[250,(Ssize(4)-ay1)/2+60,60,15]);
hpopup = uicontrol('Style','popupmenu','Parent',H.gui,'String',{'Peaks','Membrane','Sinc'},'Position',[270,(Ssize(4)-ay1)/2+10,100,25],'Callback',{@local_popup_menu,H}); 

%ha=axes('Units','Pixels','Position',[50,60,200,185]); 
ha=axes('Units','Pixels','Position',[Ssize(1)+50 (Ssize(4)-ay1)/2+50 200 185]); 
align([hsurf,hmesh,hcontour,htext,hpopup],'Center','None'); 
set([H.gui,ha,hsurf,hmesh,hcontour,htext,hpopup],'Units','normalized');
 
 
  ha2=subplot(2,2,3);
  ha2size=get(ha2,'Position');
  set(ha2,'Position',[ha2size(1)-0.1 ha2size(2)+0.2 ha2size(3) ha2size(4)])
  surf(current_data);
  title('Sur-Mesh-Countour Plot')
  % Assign the GUI a name to appear in the window title.
  set(H.gui,'Name','My Gui Example')
   % Move the GUI to the center of the screen.
   %movegui(f,'center')
   % Make the GUI visible.
   set(H.gui,'Visible','on');

subplot(2,2,2);
plot(rand(1,30));
title('Rand(1,30) Plot')

DefOutPos=get(ha2,'Position');
set(H.gui,'UserData',DefOutPos)
Hm=uimenu('Parent',H.gui,'Label','MenuExample');
uimenu('Parent',Hm,'Label','Close','Callback','close(gcbf)');

H.Hslider=uicontrol('Style','slider','Parent',H.gui,'Units','pixels','Position',[Ssize(1)+5 Ssize(2)+5 ax1-40 20],'Value',DefOutPos(1),'Callback',{@local_Hslider,H});

H.Vslider=uicontrol('Style','slider','Parent',H.gui,'Units','pixels','Position',[ax1-30 Ssize(2)+5 20 ay1-40],'Value',DefOutPos(2),'Callback',{@local_Vslider,H});

H.Update=uicontrol('Style','pushbutton','Parent',H.gui,'Units','pixels','Position',[50 70 80 30],'String','Update','Callback',{@local_Update,H});

H.Default=uicontrol('Style','pushbutton','Parent',H.gui,'Units','pixels','Position',[145 70 80 30],'String','Default','Callback',{@local_Default,H});

   

  

function local_Hslider(cbo,eventdata,h)

SliderValue=get(cbo,'Value');
pos=get(ha2,'Position');
%pos=get(h.gui,'UserData');
set(ha2,'Position',[SliderValue pos(2:4)])
end


function local_Vslider(cbo,eventdata,h)

SliderValue=get(cbo,'Value');
pos=get(ha2,'Position');
set(ha2,'Position',[pos(1) SliderValue pos(3:4)])
end


function local_Update(cbo,eventdata,h)

Pos=get(h.gui,'OuterPosition');
set(h.Hslider,'Value',Pos(1))
set(h.Vslider,'Value',Pos(2))
end


function local_Default(cbo,eventdata,h)

Defoutpos=get(h.gui,'UserData');
set(ha2,'Position',Defoutpos)
set(h.Hslider,'Value',Defoutpos(1))
set(h.Vslider,'Value',Defoutpos(2))
end



      function local_popup_menu(cbo,eventdata,h) 
         % Determine the selected data set.
         str = get(cbo, 'String');
         val = get(cbo,'Value');
         % Set current data to the selected data set.
         switch str{val};
         case 'Peaks' % User selects Peaks.
             peaks_data = peaks(35);
            current_data=peaks_data;
            case 'Membrane' % User selects Membrane.
                membrane_data = membrane;
            current_data=membrane_data;
         case 'Sinc' % User selects Sinc.
             [x,y] = meshgrid(-8:.5:8);
             r = sqrt(x.^2+y.^2) + eps;
             sinc_data = sin(r)./r;
            current_data=sinc_data;
         end
      end
  
  
   % Push button callbacks. Each callback plots current_data in
   % the specified plot type.
 
   function local_surfbutton(source,eventdata,h) 
   % Display surf plot of the currently selected data.
   %PP=gco(ha2);
   ha2=subplot(2,2,3);
   ha2size=get(ha2,'Position');
   set(ha2,'Position',[ha2size(1)-0.1 ha2size(2)+0.2 ha2size(3) ha2size(4)])
      surf(current_data);
      title('Sur-Mesh-Countour Plot');
   end
 
 
   function local_meshbutton(source,eventdata,h) 
   % Display mesh plot of the currently selected data.
    ha2=subplot(2,2,3);
   ha2size=get(ha2,'Position');
   set(ha2,'Position',[ha2size(1)-0.1 ha2size(2)+0.2 ha2size(3) ha2size(4)])
   mesh(current_data);
   title('Sur-Mesh-Countour Plot')
   end

 
   function local_contourbutton(source,eventdata,h) 
   % Display contour plot of the currently selected data.
    ha2=subplot(2,2,3);
   ha2size=get(ha2,'Position');
   set(ha2,'Position',[ha2size(1)-0.1 ha2size(2)+0.2 ha2size(3) ha2size(4)])
   contour(current_data);
    title('Sur-Mesh-Countour Plot')
   end
end

 