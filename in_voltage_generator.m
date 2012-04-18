function in_voltage_generator(in_panel)
% Addrss Voltage generator
Addrss = 1;
gpibObj = 0;
gpibObj = gpib('ni', 0, Addrss); % GPIB('VENDOR',BOARDINDEX,PRIMARYADDRESS)

%textruta 1... 'callback', @voltage_callback;) 

    % Controls for function generator
    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Voltage [V]:',...
        'position', [50 600 100 20]);
    
    uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '5',...
        'BackgroundColor', 'white',...
        'position', [150 600 50 25],...
        'callback', {@voltage_callback,gpibObj});

    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Current limit [A]:',...
        'position', [50 550 100 20]);
    
    uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '5',...
        'BackgroundColor', 'white',...
        'position', [150 550 50 25],...
        'callback', {@current_callback,gpibObj});

    uicontrol('Style', 'pushbutton',...
        'parent', in_panel,...
        'string', 'Output On',...
        'position', [50 500 100 20],...
        'callback', {@output_callback,gpibObj});
    
end


function voltage_callback (callback_object, ~, gpibObj)
fopen(gpibObj);

fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)

Volt = ['VOLT ' get(callback_object,'string')]; % Volt = 'VOLT value', from int to string 


fprintf(gpibObj, Volt);
fclose(gpibObj); 

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
