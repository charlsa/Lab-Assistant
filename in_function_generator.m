function in_function_generator(in_panel)
% Controls for function generator
    parameters.wave = uicontrol('Style', 'popup',... 
        'String', 'Waveform|Sine|Square|Triangle|Sawtooth',...
        'parent', in_panel,...
        'Position', [70 600 100 20]); 

    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Frequency [Hz]:',...
        'BackgroundColor', 'white',...
        'HorizontalAlignmen', 'right',...
        'position', [30 550 100 20]);
    
    parameters.frequency = uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '100',...
        'BackgroundColor', 'white',...
        'position', [140 550 50 25]);

    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Amplitude [V]:',...
        'BackgroundColor', 'white',...
        'HorizontalAlignmen', 'right',...
        'position', [30 500 100 20]);
    
    parameters.amplitude = uicontrol('Style', 'edit',...
		'parent', in_panel,...
        'string', '3',...
        'BackgroundColor', 'white',...
        'position', [140 500 50 25]);

    uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', 'Offset [V]:',...
        'BackgroundColor', 'white',...
        'HorizontalAlignmen', 'right',...
        'position', [30 450 100 20]);
    
    parameters.offset = uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '0',...
        'BackgroundColor', 'white',...
        'position', [140 450 50 25]);
    
    uicontrol('Style', 'text',...
		'parent', in_panel,...
        'string', 'GPIB-address:',...
        'BackgroundColor', 'white',...
        'HorizontalAlignmen', 'right',...
        'position', [30 400 100 20]);
    
    parameters.gpibAddress = uicontrol('Style', 'edit',...
        'parent', in_panel,...
        'string', '0',...
        'BackgroundColor', 'white',...
        'position', [140 400 50 25]);
    
    uicontrol('Style', 'pushbutton',...
        'parent', in_panel,...
        'string', 'Set',...
        'position', [70 350 100 20],...
        'callback', {@set_callback,parameters});
end

function set_callback (~, ~, parameters)

address = str2num(get(parameters.gpibAddress,'string'));
gpibObj = gpib('ni', 0, address);

try 
    fopen(gpibObj);
    set(parameters.gpibAddress,'BackgroundColor' ,'white');

    fprintf(gpibObj, '*CLS'); % FPRINTF(FID,FORMAT,A,...)
    
    %%%%% set waveform
    signal(parameters.wave, gpibObj);
    %%%%%
    
    %%%%% set offset
     Offset = ['VOLT:OFFS ' get(parameters.offset,'string')]; % Volt = 'VOLT value', from int to string 
     fprintf(gpibObj, Offset);
    %%%%% 
    
    %%%%% set amplitude
     Amp = ['VOLT ' get(parameters.amplitude,'string')]; % Volt = 'VOLT value', from int to string 
     fprintf(gpibObj, Amp);
    %%%%%
     
    %%%%% set frequeny
     Freq = ['FREQ ' get(parameters.frequency,'string')]; % Volt = 'VOLT value', from int to string 
     fprintf(gpibObj, Freq);
    %%%%%
   
     fclose(gpibObj); 
 
catch err
    set(parameters.gpibAddress,'BackgroundColor' ,'red');
end

end

function signal(wave, gpibObj)

choice = get(wave,'Value');
         
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
end