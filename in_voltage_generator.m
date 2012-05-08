function in_voltage_generator(in_panel)
% Controls for function generator

    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Voltage [V]:',...
        'BackgroundColor', 'white',...
        'HorizontalAlignmen', 'right',...
        'position', [20 600 80 20]);
    
    parameters.voltage = uicontrol('Style', 'edit',...
       'parent', in_panel,...
       'string', '5',...
       'BackgroundColor', 'white',...
       'position', [110 600 50 25]);

                               
    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Current limit [A]:',...
        'HorizontalAlignmen', 'right',...
        'BackgroundColor', 'white',...
        'position', [20 550 80 20]);
    
    parameters.current = uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '5',...
        'BackgroundColor', 'white',...
        'position', [110 550 50 25]);

                                
    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'GPIB-address:',...
        'HorizontalAlignmen', 'right',...
        'BackgroundColor', 'white',...
        'position', [20 500 80 20]);
    
    parameters.gpibAddress = uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '0',...
        'BackgroundColor', 'white',...
        'position', [110 500 50 25]);

    uicontrol('Style', 'pushbutton',...
        'parent', in_panel,...
        'string', 'Output On',...
        'position', [70 450 100 20],...
        'callback', {@output_callback,parameters});
    
     uicontrol('Style', 'pushbutton',...
        'parent', in_panel,...
        'string', 'Set',...
        'position', [70 400 100 20],...
        'callback', {@set_callback,parameters});
     
end

function set_callback (~, ~, parameters)

address = str2num(get(parameters.gpibAddress,'string'));
gpibObj = gpib('ni', 0, address);

try 
    fopen(gpibObj);
    set(parameters.gpibAddress,'BackgroundColor' ,'white');

    fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)

    Volt = ['VOLT ' get(parameters.voltage,'string')]; % Volt = 'VOLT value', from int to string
    fprintf(gpibObj, Volt);
    
    Current = ['CURR ' get(parameters.current,'string')]; % to string 
    fprintf(gpibObj, Current);

    fclose(gpibObj); 
    
catch err
    set(parameters.gpibAddress,'BackgroundColor' ,'red');
end

end

function output_callback (callback_object, ~, parameters)
fclose(instrfind);

address = str2num(get(parameters.gpibAddress,'string'));
gpibObj = gpib('ni', 0, address);

try
    fopen(gpibObj);
    fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)
    
    set(parameters.gpibAddress,'BackgroundColor' ,'white');

    if(strcmp(get(callback_object,'string'), 'Output On'))
       Output = 'OUTP ON' ;
       set(callback_object,'string', 'Output Off');

    elseif(strcmp(get(callback_object,'string'), 'Output Off'))
       Output = 'OUTP OFF' ;
       set(callback_object,'string', 'Output On');   
    end

    fprintf(gpibObj, Output);
    fclose(gpibObj); 
    
catch err
    msgbox(err.getReport, 'Voltage Generator!', 'warn');
    set(parameters.gpibAddress,'BackgroundColor' ,'red');
end
    
end