function in_frequency_sweep(gui)
%Put gui controls
    uicontrol('Style', 'text',...
                'parent', gui.in_panel,...
                'string', 'Waveform:',...
                'HorizontalAlignmen', 'right',...
                'BackgroundColor', 'w',...
                'position', [20 600 110 20]);

    parameters.wave = uicontrol('Style', 'popup',... 
                'String', 'Remote|Sine|Square|Triangle|Sawtooth',...
                'parent', gui.in_panel,...
                'Position', [140 600 60 20]); 

    uicontrol('Style', 'text',...
                'parent', gui.in_panel,...
                'string', 'Start frequency [Hz]:',...
                'HorizontalAlignmen', 'right',...
                'BackgroundColor', 'w',...
                'position', [20 550 110 20]);
    
    parameters.starting = uicontrol('Style', 'edit',...
                'parent', gui.in_panel,...
                'string', '100',...
                'BackgroundColor', 'white',...
                'position', [140 550 60 20]);

    uicontrol('Style', 'text',...
                'parent', gui.in_panel,...
                'string', 'End frequency [Hz]:',...
                'HorizontalAlignmen', 'right',...
                'BackgroundColor', 'white',...
                'position', [20 500 110 20]);
    
   parameters.ending = uicontrol('Style', 'edit',...
                'parent', gui.in_panel,...
                'string', '200',...
                'BackgroundColor', 'white',...
                'position', [140 500 60 20]);

   uicontrol('Style', 'text',...
                'parent', gui.in_panel,...
                'string', 'Step length:',...
                'HorizontalAlignmen', 'right',...
                'BackgroundColor', 'white',...
                'position', [20 450 110 20]);
    
   parameters.steplength =  uicontrol('Style', 'edit',...
                'parent', gui.in_panel,...
                'string', '5',...
                'BackgroundColor', 'white',...
                'position', [140 450 60 20]);
            
   uicontrol('Style', 'text',...
                'parent', gui.in_panel,...
                'string', 'Amplitude [V]:',...
                'HorizontalAlignment', 'right',...
                'BackgroundColor', 'white',...
                'position', [20 400 110 20]);
    
   parameters.amplitud =  uicontrol('Style', 'edit',...
                'parent', gui.in_panel,...
                'string', '2',...
                'BackgroundColor', 'white',...
                'position', [140 400 60 20]);
            
   uicontrol('Style', 'text',...
                'parent', gui.in_panel,...
                'string', 'GPIB address:',...
                'HorizontalAlignmen', 'right',...
                'BackgroundColor', 'white',...
                'position', [20 350 110 20]);
    
   parameters.gpibAddress =  uicontrol('Style', 'edit',...
                'parent', gui.in_panel,...
                'string', '0',...
                'BackgroundColor', 'white',...
                'position', [140 350 60 20]);
    
    uicontrol('Style', 'pushbutton',...
                'parent', gui.in_panel,...
                'string', 'Start sweep',...
                'position', [70 300 100 20],...
                'callback', {@sweepStart_callback,parameters, gui});
    
end

function sweepStart_callback(~,~, parameters, gui)

address = str2num(get(parameters.gpibAddress,'string'));
gpibObjF = gpib('ni', 0, address);  % function generator

[multimeterConnect gpibObjM] = connect_multimeter(); % Returns a string
 
freqgenConnect = connect_freqGenerator(parameters); % Returns a string
  
if(strcmp(multimeterConnect, 'OKEJ') && strcmp(freqgenConnect, 'OKEJ'))
    fopen(gpibObjF);
    fopen(gpibObjM);

    %%%% Start frequency-loop 
    start = str2double(get(parameters.starting,'string'));
    ending = str2double(get(parameters.ending,'string'));
    length = str2double(get(parameters.steplength,'string'));

    a = 1;
    time = (ending-start)/length;
    i = 0;
    H = waitbar(0);

    for n=start:length:ending 
        %Set frequency
        fprintf(gpibObjF,['FREQ ', num2str(n)]); 


        waitbar(mod(i,1),H,'Please wait while picture is loading!');
        i = i + 1/time;
        %Take measurment
        fprintf(gpibObjM,'MEAS:VOLT:AC?');
        VOLT(a) = fscanf(gpibObjM,'%e');
        FREQ(a) = n;
        a=a+1;
    end

    delete(H);

    fclose(gpibObjM);
    fclose(gpibObjF);

    print(VOLT, FREQ);

else
    fclose(instrfind);
end
  
end

function out = connect_freqGenerator(parameters)

try
    address = str2num(get(parameters.gpibAddress,'string'));
    gpibObj = gpib('ni', 0, address);

    fopen(gpibObj);
    fprintf(gpibObj, '*CLS');
    set(parameters.gpibAddress,'BackgroundColor' ,'white');
    pause(0.01);

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
    msgbox(err.getReport, 'Frequency Generator!', 'warn');
    set(parameters.gpibAddress,'BackgroundColor' ,'red');
    out = 'ERROR';
    fclose(instrfind);
    disp(err); % fel sÃ¶k
end

end

function [out gpibObj] = connect_multimeter()
global multimeter;

try
    address = str2num(get(multimeter.gpibAddress,'string'));
    gpibObj = gpib('ni', 0, address);
    
    fopen(gpibObj);
    fprintf(gpibObj, '*CLS');
    set(multimeter.gpibAddress,'BackgroundColor' ,'white');
    
    fprintf(gpibObj,'CONF:VOLT:AC');
    fclose(gpibObj);
    
    out = 'OKEJ';

catch err
    %msgbox(err.getReport, 'Multimeter!', 'warn');
    set(multimeter.gpibAddress,'BackgroundColor' ,'red');
    out = 'ERROR';
    fclose(instrfind);
    disp(err); % fel sÃ¶k
end

end

function print(volt, frequency)
    
semilogx(frequency, db(volt));
xlabel('Frequency [HZ]');
ylabel('Voltage [dB]');
grid on;

% save figure
tmp_figure = figure(10);
semilogx(frequency, db(volt));
xlabel('Frequency [HZ]');
ylabel('Voltage [dB]');
grid on;
saveas(tmp_figure, 'figure', 'fig');
close(tmp_figure);

% save data 
save 'data.mat' 'frequency' 'volt';
    
end