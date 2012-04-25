function in_voltage_generator(in_panel)
% Addrss Voltage generator
%Addrss = 1;
%gpibObj = 0;
%gpibObj = gpib('ni', 0, Addrss); % GPIB('VENDOR',BOARDINDEX,PRIMARYADDRESS)

%textruta 1... 'callback', @voltage_callback;) 

    % Controls for function generator
    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Voltage [V]:',...
        'position', [50 600 100 20]);
    
    parameters.voltage = uicontrol('Style', 'edit',...
                                   'parent', in_panel,...
                                   'string', '5',...
                                   'BackgroundColor', 'white',...
                                   'position', [150 600 50 25]);

                               
    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Current limit [A]:',...
        'position', [50 550 100 20]);
    
    parameters.current = uicontrol('Style', 'edit',...
                                    'parent', in_panel,...
                                    'string', '5',...
                                    'BackgroundColor', 'white',...
                                    'position', [150 550 50 25]);
    
                                
    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'GPIB-address:',...
        'position', [50 500 100 20]);
    
    parameters.gpibAddress = uicontrol('Style', 'edit',...
                                        'parent', in_panel,...
                                        'string', '5',...
                                        'BackgroundColor', 'white',...
                                        'position', [150 500 50 25]);
                                    
    parameters.gpibConnection = uicontrol('Style', 'text',...
                                            'parent', in_panel,...
                                            'string', '',...
                                            'position', [200 500 100 25]);

    uicontrol('Style', 'pushbutton',...
        'parent', in_panel,...
        'string', 'Output On',...
        'position', [50 450 100 20],...
        'callback', {@output_callback,parameters});
    
     uicontrol('Style', 'pushbutton',...
        'parent', in_panel,...
        'string', 'Set',...
        'position', [50 400 100 20],...
        'callback', {@set_callback,parameters});
     
end


function set_callback (~, ~, parameters)

gpibOpen = 0;
address = get(parameters.gpibAddress,'string');

try 
    gpibObj = gpib('ni', 0, address);
    gpibOpen = 1;
    set(parameters.gpibConnection,'string' ,'GPIB Connected');
    set(parameters.gpibAddress,'BackgroundColor' ,'red');
catch err 
    gpibOpen = 0;
    set(parameters.gpibConnection,'string' ,'GPIB NOT Connected');
    set(parameters.gpibAddress,'BackgroundColor' ,'red');
end


if gpibOpen

    fopen(gpibObj);

    fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)

    Volt = ['VOLT ' get(callback_object,'string')]; % Volt = 'VOLT value', from int to string 


    fprintf(gpibObj, Volt);
    fclose(gpibObj); 
end

end

function current_callback (callback_object, ~, gpibObj)

fopen(gpibObj);

fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)
Current = ['CURR ' get(callback_object,'string')]; % to string 

fprintf(gpibObj, Current);
fclose(gpibObj);
end

function output_callback (callback_object, ~, gpibObj)
fopen(gpibObj);
fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)

if(strcmp(get(callback_object,'string'), 'Output On'))
   Output = 'OUTP ON' ;
   set(callback_object,'string', 'Output Off');

elseif(strcmp(get(callback_object,'string'), 'Output Off'))
   Output = 'OUTP OFF' ;
   set(callback_object,'string', 'Output On');
   
end

fprintf(gpibObj, Output);
fclose(gpibObj); 
    
end

