function main

    screen_size = get(0,'ScreenSize');

    gui = figure('Name','Lab Assistant','Units','pixels','Position', screen_size);
    
    
    % Create Input selector
    in_panel = uipanel('Title','Input','Position',[0 0 0.25 0.95]);

    uicontrol('Style', 'popup',...
           'String', 'Input|Function Generator|Voltage Generator',...
           'Position', [100 660 200 50],...
           'Callback', {@in_callback, in_panel}); 

       
    % Create output selector
    out_panel = uipanel('Title','Output','Position',[0.25 0 0.5 0.95]);
    
    
    uicontrol('Style', 'popup',...
           'String', 'Output|Oscilloscope Screen|Multimeter|Transfer Function',...
           'Position', [500 660 200 50],...
           'Callback', {@out_callback, out_panel}); 
   
    % Create export selector
    export_panel = uipanel('Title','Export','Position',[0.75 0 0.25 0.95]);          

    uicontrol('Style', 'popup',...
           'String', 'Export|LaTeX|Dropbox|Facebook',...
           'Position', [1000 660 200 50],...
           'Callback', {@export_callback,export_panel});


    

end

function save(~,~)
    [FileName,PathName] = uiputfile();
    
end

function in_callback(callback_object, ~, in_panel)
     str = get(callback_object, 'String');
     val = get(callback_object,'Value');
     disp(val);
     
     switch (val)
         case 3
             in_voltage_generator(in_panel);
         case 2
             in_function_generator;
     end
end

function out_callback(callback_object, ~, out_panel)
         str = get(callback_object, 'String');
         val = get(callback_object,'Value');
         disp(str(val));
         
         if(val == 2)
         out_oscilloscope_picture(out_panel);
         end
end

function export_callback(callback_object, ~, export_panel)
         str = get(callback_object, 'String');
         val = get(callback_object,'Value');
         disp(str(val));
         
         if(val == 2)
         export_latex(export_panel);
         end
end