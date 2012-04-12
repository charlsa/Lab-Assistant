function main

    screen_size = get(0,'ScreenSize');

    gui = figure('Name','Lab Assistant','Units','pixels','Position', screen_size);
    
    
    % Create Input selector
    uicontrol('Style', 'popup',...
           'String', 'Input|Function Generator|Voltage Generator',...
           'Position', [100 660 200 50],...
           'Callback', @in_callback); 

    in_panel = uipanel('Title','Input','Position',[0 0 0.25 0.95]);

    % Create output selector
    uicontrol('Style', 'popup',...
           'String', 'Output|Oscilloscope Screen|Multimeter|Transfer Function',...
           'Position', [500 660 200 50],...
           'Callback', @out_callback); 

    out_panel = uipanel('Title','Output','Position',[0.25 0 0.5 0.95]);   

    % Controls for oscilloscope picture
    %...
    
    % Create export selector
    uicontrol('Style', 'popup',...
           'String', 'Export|LaTeX|Dropbox|Facebook',...
           'Position', [1100 660 200 50],...
           'Callback', @export_callback);

    export_panel = uipanel('Title','Export','Position',[0.75 0 0.25 0.95]);          

    % Controls for Latex figure export
    
    a = uicontrol('Style', 'pushbutton',...
        'String', 'Export',...
        'position', [1000 100 100 25],...
        'callback', @save);

end

function save(~,~)
    [FileName,PathName] = uiputfile();
    
end

function in_callback(callback_object, ~)
     str = get(callback_object, 'String');
     val = get(callback_object,'Value');
     disp(str(val));
     
     if(val == 2)
         in_function_generator;
     end
end

function out_callback(callback_object, ~)
         str = get(callback_object, 'String');
         val = get(callback_object,'Value');
         disp(str(val));
end

function export_callback(callback_object, ~)
         str = get(callback_object, 'String');
         val = get(callback_object,'Value');
         disp(str(val));
end