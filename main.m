function main


    figure('Name','Lab Assistant',...
        'Position', [100 100 1000 700],...
        'ToolBar', 'none',...
        'MenuBar', 'none',...
        'Resize', 'off');

    gui.figure = subplot('Position', [0.33 0.2 0.35 0.35]);
    axis off;
    
    %Generate background image
    bg_axes = axes('units','normalized','position',[0 0 1 1]);
    uistack(bg_axes,'bottom');
    imagesc(imread('bg.png'));
    set(bg_axes, 'handlevisibility', 'off', 'visible','off');

    % Create output selector
    gui.out_panel = uipanel('Position',[0.26 0.01 0.48 0.94],...
        'BackgroundColor', 'w',...
        'BorderType', 'line',...
        'BorderWidth', 2,...
        'HighlightColor', [0 0.7 0.2]);
    
    %Put "choose"-text in panel
    none_chosen(gui.out_panel);
    
    gui.outMenu = uicontrol('Style', 'popup',...
           'String', 'Output|Oscilloscope|Multimeter|Transfer Function|Bode Graph',...
           'Position', [400 645 200 50],...
           'Callback', {@out_callback, gui}); 
    
    % Create Input selector
    gui.in_panel = uipanel('Position',[0.01 0.01 0.24 0.94],...
        'BackgroundColor', 'w',...
        'BorderType', 'line',...
        'BorderWidth', 2,...
        'HighlightColor', [0 0.7 0.2]);
    
    %Put "choose"-text in panel
    none_chosen(gui.in_panel);
       
    gui.inMenu = uicontrol('Style', 'popup',...
           'String', 'Input|Function Generator|Voltage Generator|Frequency Sweep',...
           'Position', [30 645 200 50],...
           'Callback', {@in_callback, gui});
   

    % Create export selector
    gui.export_panel = uipanel('Position',[0.75 0.01 0.24 0.94],...
        'BackgroundColor', 'w',...
        'BorderType', 'line',...
        'BorderWidth', 2,...
        'HighlightColor', [0 0.7 0.2]);
    
    %Put "choose"-text in panel
    none_chosen(gui.export_panel);

    gui.export = uicontrol('Style', 'popup',...
           'String', 'Export|Clipboard|Image|LaTeX|Word',...
           'Position', [770 645 200 50],...
           'Callback', {@export_callback, gui});

end

function in_callback(callback_object, ~, gui)
     remove_children(gui.in_panel);
     val = get(callback_object,'Value');
    
     switch (val)
         case 4 
             remove_children(gui.out_panel);
             set(gui.outMenu,'Value',5);
             set(gui.outMenu, 'Enable', 'off');
             out_bodegraph(gui.out_panel);
             in_frequency_sweep(gui);  
         case 3
             if(strcmp(get(gui.outMenu,'Enable'), 'off'))
                 set(gui.outMenu,'Enable', 'on')
             end
             in_voltage_generator(gui.in_panel);
         case 2
             if(strcmp(get(gui.outMenu,'Enable'), 'off'))
                 set(gui.outMenu,'Enable', 'on')
             end
             in_function_generator(gui.in_panel);
         case 1
            none_chosen(gui.in_panel);
     end 
end

function out_callback(callback_object, ~, gui)
    remove_children(gui.out_panel);
    
    val = get(callback_object,'Value'); 
    switch (val)
        case 1
            none_chosen(gui.out_panel);
        case 2
            out_oscilloscope(gui.out_panel);
        case 3
            
        case 4
            
        case 5
            out_bodegraph(gui.out_panel);
    end
%     if(val == 2)
%         out_oscilloscope(gui.out_panel);
%     end
end

function export_callback(callback_object, ~, gui)
    remove_children(gui.export_panel);
    
    val = get(callback_object,'Value');
	switch (val)
        case 1
            none_chosen(gui.export_panel);
        case 2
            export_clipboard(gui.export_panel);
        case 3
            export_image(gui.export_panel);
        case 4
            export_latex(gui.export_panel);
        case 5
            export_word(gui.export_panel);
	end
end

%Removes all the children of an object
function remove_children(object)
	set( get(object, 'Children') , 'Visible', 'off');
    %Will not work properly without a tiny pause
    pause(0.01);
    delete(get(object, 'Children'));
end