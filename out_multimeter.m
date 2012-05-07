function out_multimeter(out_panel)
    global takeValue;
    takeValue = false;
        
    multi.measur = uicontrol('Style', 'popup',... 
        'String', 'Measurement|Voltage [DC]|Voltage [AC]|Current[DC]|Current[AC]',...
        'parent', out_panel,...
        'Position', [50 850 100 20]); 

    uicontrol('Style', 'text',...
            'parent', out_panel,...
            'string', 'GPIB address:',...
            'position', [50 800 100 20]);

    multi.gpibAddress =  uicontrol('Style', 'edit',...
                'parent', out_panel,...
                'string', '0',...
                'BackgroundColor', 'white',...
                'position', [150 800 50 25]);
    
    multi.display = uicontrol('Style', 'text',...
            'parent', out_panel,...
            'string', 'Value',...
            'position', [250 800 100 20]);    
   
    multi.unit = uicontrol('Style', 'text',...
            'parent', out_panel,...
            'string', 'Value',...
            'position', [300 800 100 20]); 
        
    multi.stop = uicontrol('Style', 'pushbutton',...
        'parent', out_panel,...
        'string', 'Stop',...
        'position', [200 750 100 20],...
        'callback', {@multimeter_stop, multi});
    
    set(multi.stop, 'Enable', 'off');
        
    multi.start = uicontrol('Style', 'pushbutton',...
        'parent', out_panel,...
        'string', 'Start',...
        'position', [50 750 100 20],...
        'callback', {@multimeter_callback, multi});
        
end

function multimeter_stop(~,~,multi)
    global takeValue;
    global outMenu;
    set(outMenu, 'Enable', 'on');
    set(multi.measur, 'Enable', 'on');
    takeValue = false; 
    
end

function multimeter_callback(~,~,multi)
global takeValue;
global outMenu;
takeValue = true;

try
    address = str2num(get(multi.gpibAddress,'string'));
    gpibObj = gpib('ni', 0, address);
    
    fopen(gpibObj);
    fprintf(gpibObj, '*CLS');
    set(multi.gpibConnection,'string' ,'GPIB Connected');
    set(multi.gpibAddress,'BackgroundColor' ,'white');
    
switch (get(multi.measur,'Value'))
    case 1
        disp('set measuring');
    case 2 % Volt DC
        voltORcurrent = 'MEAS:VOLT:DC?';
        fprintf(gpibObj,'CONF:VOLT:DC');
        set(multi.unit,'string','V');
       
    case 3 % Volt AC
        voltORcurrent = 'MEAS:VOLT:AC?';
        fprintf(gpibObj,'CONF:VOLT:AC');
        set(multi.unit,'string','V');
         
    case 4 % Current DC
        voltORcurrent = 'MEAS:CURR:DC?';
        fprintf(gpibObj,'CONF:CURR:DC'); 
        set(multi.unit,'string','A');
        
    case 5 % Current AC
        voltORcurrent = 'MEAS:CURR:AC?';
        fprintf(gpibObj,'CONF:CURR:AC'); 
        set(multi.unit,'string','A');
        
end
fclose(gpibObj);
set(outMenu, 'Enable', 'off');
set(multi.measur, 'Enable', 'off');
set(multi.stop, 'Enable', 'on');
pause(0.5);

while takeValue
    fopen(gpibObj);
    pause(0.01);
    fprintf(gpibObj,voltORcurrent);
    set(multi.display,'string',fscanf(gpibObj));
    pause(0.5);
    fclose(gpibObj);
end
   
catch err
    msgbox(err.getReport, 'Multimeter!', 'warn');
    set(multi.gpibAddress,'BackgroundColor' ,'red');
    fclose(instrfind);
    disp(err); % fel sök
end

end