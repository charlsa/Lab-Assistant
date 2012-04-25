function in_frequency_sweep(in_panel)

AddressF = 1; % address to function generator
gpibObjF = gpib('ni', 0, AddressF);

AddressO = 11; % address to oscilloscope or voltmeter
gpibObjO = gpib('ni', 0, AddressO);

    uicontrol('Style', 'popup',... 
        'String', 'Waveform|Sine|Square|Triangle|Sawtooth',...
        'parent', in_panel,...
        'Position', [50 650 100 20],...
        'Callback', {@signal_callback,gpibObjF}); 

    uicontrol('Style', 'text',...
                'parent', in_panel,...
                'string', 'Start frequency [Hz]:',...
                'position', [50 600 100 20]);
    
    parameters.starting = uicontrol('Style', 'edit',...
                'parent', in_panel,...
                'string', '5',...
                'BackgroundColor', 'white',...
                'position', [150 600 50 25]);

    uicontrol('Style', 'text',...
                'parent', in_panel,...
                'string', 'End frequency [Hz]:',...
                'position', [50 550 100 20]);
    
   parameters.ending = uicontrol('Style', 'edit',...
                'parent', in_panel,...
                'string', '5',...
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
    
    uicontrol('Style', 'pushbutton',...
        'parent', in_panel,...
        'string', 'Start sweep',...
        'position', [50 450 100 20],...
        'callback', {@sweepStart_callback,gpibObjF,gpibObjO,parameters});
    
end

function signal_callback(callback_object,~, gpibObjF)

     choice = get(callback_object,'Value');
     
     fopen(gpibObjF);
     fprintf(gpibObjF, '*CLS');
     
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
     fprintf(gpibObjF, waveform);
     
     fclose(gpibObjF);
end

function sweepStart_callback(~,~,gpibObjF,gpibObjO, parameters)

    fopen(gpibObjO); % Oscilloscope
    fprintf(gpibObjO, '*CLS');
    fprintf(gpibObjO,'Data:Source CH1');
    fprintf(gpibObjO,'MEASU:IMM:TYP CRM');
 
    start = str2double(get(parameters.starting,'string'));
    ending = str2double(get(parameters.ending,'string'));
    length = str2double(get(parameters.steplength,'string'));
    
    fopen(gpibObjF); % Functiongenerator 
    fprintf(gpibObjF,'*CLS');
   
    a = 1;
   
    fprintf(gpibObjO,'MEASU:IMM:VAL?'); % utför mätning
    
    for n=start:length:ending 
        fprintf(gpibObjO,'MEASU:IMM:VAL?'); % utför mätning
        
        f=floor(num2str(n));
        fprintf(gpibObjF,['FREQ ',f]);
        
        pause(0.4);
        tRMS = fscanf(gpibObjO);
        
        disp(tRMS(16:(end-3)));
        m(a) = str2double(tRMS(16:(end-3)));
        a=a+1;
    end   
    disp(m);
    fclose(gpibObjO);
    fclose(gpibObjF);
     
end