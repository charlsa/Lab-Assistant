function in_frequency_sweep(in_panel, out_panel)
    parameters.print = out_panel;

    parameters.wave = uicontrol('Style', 'popup',... 
        'String', 'Waveform|Sine|Square|Triangle|Sawtooth',...
        'parent', in_panel,...
        'Position', [50 650 100 20]); 

    uicontrol('Style', 'text',...
                'parent', in_panel,...
                'string', 'Start frequency [Hz]:',...
                'position', [50 600 100 20]);
    
    parameters.starting = uicontrol('Style', 'edit',...
                'parent', in_panel,...
                'string', '100',...
                'BackgroundColor', 'white',...
                'position', [150 600 50 25]);

    uicontrol('Style', 'text',...
                'parent', in_panel,...
                'string', 'End frequency [Hz]:',...
                'position', [50 550 100 20]);
    
   parameters.ending = uicontrol('Style', 'edit',...
                'parent', in_panel,...
                'string', '200',...
                'BackgroundColor', 'white',...
                'position', [150 550 50 25]);

   uicontrol('Style', 'text',...
                'parent', in_panel,...
                'string', 'Step length:',...
                'position', [50 500 100 20]);
    
   parameters.steplength =  uicontrol('Style', 'edit',...
                'parent', in_panel,...
                'string', '5',...
                'BackgroundColor', 'white',...
                'position', [150 500 50 25]);
            
   uicontrol('Style', 'text',...
                'parent', in_panel,...
                'string', 'Amplitud [V]:',...
                'position', [50 450 100 20]);
    
   parameters.amplitud =  uicontrol('Style', 'edit',...
                'parent', in_panel,...
                'string', '2',...
                'BackgroundColor', 'white',...
                'position', [150 450 50 25]);
            
   uicontrol('Style', 'text',...
                'parent', in_panel,...
                'string', 'GPIB address:',...
                'position', [50 400 100 20]);
    
   parameters.gpibAddress =  uicontrol('Style', 'edit',...
                'parent', in_panel,...
                'string', '0',...
                'BackgroundColor', 'white',...
                'position', [150 400 50 25]);
            
   parameters.gpibConnection = uicontrol('Style', 'text',...
        'parent', in_panel,...
        'string', '',...
        'position', [200 400 50 25]);
    
    uicontrol('Style', 'pushbutton',...
        'parent', in_panel,...
        'string', 'Start sweep',...
        'position', [50 350 100 20],...
        'callback', {@sweepStart_callback,parameters});
    
end

function sweepStart_callback(~,~, parameters)

address = str2num(get(parameters.gpibAddress,'string'));
gpibObjF = gpib('ni', 0, address);  % function generator

  [multimeterConnect measure gpibObjM] = connect_multimeter(); % Returns a string
 
  freqgenConnect = connect_freqGenerator(parameters); % Returns a string
  

  if(strcmp(multimeterConnect, 'OKEJ') && strcmp(freqgenConnect, 'OKEJ'))
  fopen(gpibObjF);
  fopen(gpibObjM);
    
%%%% Start frequency-loop 
    start = str2double(get(parameters.starting,'string'));
   ending = str2double(get(parameters.ending,'string'));
   length = str2double(get(parameters.steplength,'string'));

    a = 1;  
    for n=start:length:ending 
        
        f = floor(num2str(n));
        fprintf(gpibObjF,['FREQ ',f]);   
        
        fprintf(gpibObjM,measure); % utför mätning
        VOLT(a) = fscanf(gpibObjM,'%e');
        FREQ(a) = n;
        a=a+1;
    end       
  else
     fclose(instrfind);
  end
    print(VOLT, FREQ, parameters.print);
  
    fclose(gpibObjM);
    fclose(gpibObjF);
end

function out = connect_freqGenerator(parameters)

try
    address = str2num(get(parameters.gpibAddress,'string'));
    gpibObj = gpib('ni', 0, address);
    
    fopen(gpibObj);
    fprintf(gpibObj, '*CLS');
    set(parameters.gpibConnection,'string' ,'GPIB Connected');
    set(parameters.gpibAddress,'BackgroundColor' ,'white');
    
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
     
     Amp = ['VOLT ' get(parameters.amplitud,'string')]; % Volt = 'VOLT value', from int to string 
     
     fprintf(gpibObj, Amp);
     fclose(gpibObj);
     out = 'OKEJ';
    
catch err
    set(parameters.gpibConnection,'string' ,'GPIB Disconnected');
    set(parameters.gpibAddress,'BackgroundColor' ,'red');
    out = 'ERROR';
    fclose(instrfind);
    disp(err); % fel sök
end

end

function [out voltORcurrent gpibObj] = connect_multimeter()
global multimeter;

try
    address = str2num(get(multimeter.gpibAddress,'string'));
    gpibObj = gpib('ni', 0, address);
    
    fopen(gpibObj);
    fprintf(gpibObj, '*CLS');
    set(multimeter.gpibConnection,'string' ,'GPIB Connected');
    set(multimeter.gpibAddress,'BackgroundColor' ,'white');
    
    out = 'OKEJ';
    
switch (get(multimeter.measur,'Value'))
    case 1
        disp('set measuring');
        out = 'ERROR';
    case 2 % Volt
        voltORcurrent = 'MEAS:VOLT:AC?';
        fprintf(gpibObj,'CONF:VOLT:AC');
    case 3 % Current
        voltORcurrent = 'MEAS:CURR:AC?';
        fprintf(gpibObj,'CONF:CURR:AC');   
end
    
    fclose(gpibObj);

catch err
    set(multimeter.gpibConnection,'string' ,'GPIB Disconnected');
    set(multimeter.gpibAddress,'BackgroundColor' ,'red');
    out = 'ERROR';
    fclose(instrfind);
    disp(err); % fel sök
end

end

% function print(volt, freqvency, out_panel)
% 
% figure
% grid on;
% log
% 
% 
% 
% 
% end