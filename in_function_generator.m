function in_function_generator(in_panel)
Addrss = 12;
gpibObj = gpib('ni', 0, Addrss);
    
    % Controls for function generator
    uicontrol('Style', 'popup',... 
        'String', 'Waveform|Sine|Square|Triangle|Sawtooth',...
        'parent', in_panel,...
        'Position', [50 650 100 20],...
        'Callback', {@signal_callback,gpibObj}); 

    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Frequency [Hz]:',...
        'position', [50 600 100 20]);
    
    uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '5',...
        'BackgroundColor', 'white',...
        'position', [150 600 50 25],...
        'callback', {@frequency_callback,gpibObj});

    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Amplitude [V]:',...
        'position', [50 550 100 20]);
    
    uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '5',...
        'BackgroundColor', 'white',...
        'position', [150 550 50 25],...
        'callback', {@amplitude_callback,gpibObj});

    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Offset [V]:',...
        'position', [50 500 100 20]);
    
    uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '5',...
        'BackgroundColor', 'white',...
        'position', [150 500 50 25],...
        'callback', {@offset_callback,gpibObj});
    
    uicontrol('Style', 'pushbutton',...
        'parent', in_panel,...
        'string', 'Output On',...
        'position', [50 450 100 20],...
        'callback', {@output_callback,gpibObj});
    
end

function signal_callback(callback_object, ~, gpibObj)
     choice = get(callback_object,'Value');
     
     fopen(gpibObj);
     
     fprintf(gpibObj, '*CLS');
     
     switch (choice)
         case 1
             waveform = 'nothing';
         case 2
             waveform = 'FUNC SIN';
         case 3
             waveform = 'FUNC SQU';
         case 4
             waveform = 'FUNC TRI';
         case 5
             waveform = 'FUNC RAMP';
     end
     fprintf(gpibObj, waveform);
     
     fclose(gpibObj);
end

function frequency_callback (callback_object, ~, gpibObj)
fopen(gpibObj);

fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)

Freq = ['FREQ ' get(callback_object,'string')]; % Volt = 'VOLT value', from int to string 


fprintf(gpibObj, Freq);
fclose(gpibObj); 
end

function amplitude_callback (callback_object, ~, gpibObj)
fopen(gpibObj);

fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)

Amp = ['VOLT ' get(callback_object,'string')]; % Volt = 'VOLT value', from int to string 


fprintf(gpibObj, Amp);
fclose(gpibObj); 
end

function output_callback (callback_object, ~, gpibObj)
fopen(gpibObj);
fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)

if(strcmp(get(callback_object,'string'), 'Output On'))
   Output = 'ON' ;
   set(callback_object,'string', 'Output Off');

elseif(strcmp(get(callback_object,'string'), 'Output Off'))
   Output = 'OFF' ;
   set(callback_object,'string', 'Output On');
   
end

fprintf(gpibObj, Output);
fclose(gpibObj); 
end

function offset_callback (callback_object, ~, gpibObj)
fopen(gpibObj);

fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)

Offset = ['VOLT:OFFS ' get(callback_object,'string')]; % Volt = 'VOLT value', from int to string 


fprintf(gpibObj, Offset);
fclose(gpibObj); 
end

