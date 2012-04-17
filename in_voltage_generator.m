function VoltaqeGenerator
% Addrss Voltage generator
Addrss = 3;
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
        'string', 'Amplitude [V]:',...
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


function voltage_callback (callback_object, votage, gpibObj)
fopen(gpibObj);

fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)

Volt = ['VOLT ' num2str(V)]; % Volt = 'VOLT value', from int to string 


fprintf(gpibObj, Output);
fclose(gpibObj); 

end

function current_callback (callback_object, current, gpibObj)
fopen(gpibObj);

fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)
Current = ['CURR ' num2str(current)]; % to string 

fprintf(gpibObj, Output);
fclose(gpibObj);
end

function output_callback (callback_object, gpibObj)
fopen(gpibObj);
fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)

if(strcmp(get(callback_object,'string'), 'Output On'))
   Output = 'OUTP OFF' ;
   set(callback_object,'string', 'Output Off');

elseif(strcmp(get(callback_object,'string'), 'Output Ooff'))
   Output = 'OUTP OFF' ;
   set(callback_object,'string', 'Output On');
   
end

fprintf(gpibObj, Output);
fclose(gpibObj); 
end
