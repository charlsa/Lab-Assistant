function in_function_generator(in_panel)
% Controls for function generator
    parameters.wave = uicontrol('Style', 'popup',... 
        'String', 'Waveform|Sine|Square|Triangle|Sawtooth',...
        'parent', in_panel,...
        'Position', [50 650 100 20]); 

    uicontrol('Style', 'text',...
        'string', 'Frequency [Hz]:',...
        'position', [50 600 100 20]);
    
    parameters.frequency = uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '100',...
        'BackgroundColor', 'white',...
        'position', [150 600 50 25]);

    uicontrol('Style', 'text',...
        'string', 'Amplitude [V]:',...
        'position', [50 550 100 20]);
    
    parameters.amplitude = uicontrol('Style', 'edit',...
        'string', '3',...
        'BackgroundColor', 'white',...
        'position', [150 550 50 25]);

    uicontrol('Style', 'text',...
        'string', 'Offset [V]:',...
        'position', [50 500 100 20]);
    
    parameters.offset = uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '0',...
        'BackgroundColor', 'white',...
        'position', [150 500 50 25]);
    
    uicontrol('Style', 'text',...
        'string', 'GPIB-address:',...
        'position', [50 450 100 20]);
    
    parameters.gpibAddress = uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '0',...
        'BackgroundColor', 'white',...
        'position', [150 450 50 25]);
    
     parameters.gpibConnection = uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', '',...
        'position', [200 450 50 25]);
    
    uicontrol('Style', 'pushbutton',...
        'parent', in_panel,...
        'string', 'Set',...
        'position', [50 400 100 20],...
        'callback', {@set_callback,parameters});
end

function set_callback (~, ~, parameters)
fclose(instrfind);

address = str2num(get(parameters.gpibAddress,'string'));
gpibObj = gpib('ni', 0, address);

try 
    fopen(gpibObj);
    set(parameters.gpibConnection,'string' ,'GPIB Connected');
    set(parameters.gpibAddress,'BackgroundColor' ,'white');

    fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)
    
    %%% set waveform
     choice = get(parameters.wave,'Value');  
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
    %%%
     
    %%%% set frequeny
     Freq = ['FREQ ' get(parameters.frequency,'string')]; % Volt = 'VOLT value', from int to string 
     fprintf(gpibObj, Freq);
    %%%%
    
    %%%%% set amplitude
     Amp = ['VOLT ' get(parameters.amplitude,'string')]; % Volt = 'VOLT value', from int to string 
     fprintf(gpibObj, Amp);
    %%%%%
    
    %%%%%% set offset
     Offset = ['VOLT:OFFS ' get(parameters.offset,'string')]; % Volt = 'VOLT value', from int to string 
     fprintf(gpibObj, Offset);
    %%%%%% 
    
     fclose(gpibObj); 
 
catch err
    set(parameters.gpibConnection,'string' ,'GPIB Disconnected');
    set(parameters.gpibAddress,'BackgroundColor' ,'red');
end

end