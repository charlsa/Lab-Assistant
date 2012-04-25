function main

    screen_size = get(0,'ScreenSize');
    top = screen_size(4);

    gui = figure('Name','Lab Assistant','Position', screen_size);
    
    
    % Create Input selector
    in_panel = uipanel('Title','Input','Position',[0 0 0.25 0.95]);

    uicontrol('Style', 'popup',...
           'String', 'Input|Function Generator|Voltage Generator',...
           'Position', [90 top-110 200 50],...
           'Callback', {@in_callback, in_panel})

       
    % Create output selector
    out_panel = uipanel('Title','Output','Position',[0.25 0 0.5 0.95]);
    
    uicontrol('Style', 'popup',...
           'String', 'Output|Oscilloscope Screen|Multimeter|Transfer Function',...
           'Position', [500 top-110 200 50],...
           'Callback', {@out_callback, out_panel}); 
   
       
    % Create export selector
    export_panel = uipanel('Title','Export','Position',[0.75 0 0.25 0.95]);          

    uicontrol('Style', 'popup',...
           'String', 'Export|Image|LaTeX|Dropbox|Facebook',...
           'Position', [1050 top-110 200 50],...
           'Callback', {@export_callback, export_panel});

end

function in_callback(callback_object, ~, in_panel)
    remove_children(in_panel);

    val = get(callback_object,'Value');     
    switch (val)
        case 3
            in_voltage_generator(in_panel);
        case 2
            in_function_generator(in_panel);
    end
end

function out_callback(callback_object, ~, out_panel)
    remove_children(out_panel);
    
    val = get(callback_object,'Value'); 
    if(val == 2)
        out_oscilloscope_picture(out_panel);
    end
end

function export_callback(callback_object, ~, export_panel)
    remove_children(export_panel);
    
    val = get(callback_object,'Value');
	switch (val)
        case 2
            export_image(export_panel);
        case 3
            export_latex(export_panel);
	end
end

%Removes all the children of an object
function remove_children(object)
	set( get(object, 'Children') , 'Visible', 'off');
    %Will not work properly without a tiny pause
    pause(0.01);
    delete(get(object, 'Children'));
end
