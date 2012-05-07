function out_multimeter(out_panel)
    global takeValue;
    takeValue = false;
        
    multi.measur = uicontrol('Style', 'popup',... 
            'String', 'Measurement|Voltage [DC]|Voltage [AC]|Current[DC]|Current[AC]',...
            'parent', out_panel,...
            'Position', [160 600 100 20]); 

    uicontrol('Style', 'text',...
            'parent', out_panel,...
            'string', 'GPIB address:',...
            'horizontalalign', 'right',...
            'BackgroundColor', 'white',...
            'position', [30 598 70 20]);

    multi.gpibAddress =  uicontrol('Style', 'edit',...
            'parent', out_panel,...
            'string', '0',...
            'BackgroundColor', 'white',...
            'position', [100 600 40 20]);
    
    multi.display = uicontrol('Style', 'text',...
            'parent', out_panel,...
            'string', '...',...
            'BackgroundColor', 'black',...
            'ForegroundColor', [0 1 0.5],...
            'fontname', 'BankGothic Md BT',...
            'fontsize', 23,...
            'position', [30 300 415 40]);    
        
    multi.stop = uicontrol('Style', 'pushbutton',...
            'parent', out_panel,...
            'string', 'Stop',...
            'position', [380 600 75 20],...
            'callback', {@multimeter_stop, multi});

    set(multi.stop, 'Enable', 'off');

    multi.start = uicontrol('Style', 'pushbutton',...
            'parent', out_panel,...
            'string', 'Start',...
            'position', [285 600 75 20],...
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
    set(multi.gpibAddress,'BackgroundColor' ,'white');
    
        switch (get(multi.measur,'Value'))
        case 1
            disp('set measuring');
            
        case 2 % Volt DC
            voltORcurrent = 'MEAS:VOLT:DC?';
            fprintf(gpibObj,'CONF:VOLT:DC');
            unit = ' V';
           
        case 3 % Volt AC
            voltORcurrent = 'MEAS:VOLT:AC?';
            fprintf(gpibObj,'CONF:VOLT:AC');
            unit = ' V';
          
        case 4 % Current DC
            voltORcurrent = 'MEAS:CURR:DC?';
            fprintf(gpibObj,'CONF:CURR:DC'); 
            unit = ' A';
          
        case 5 % Current AC
            voltORcurrent = 'MEAS:CURR:AC?';
            fprintf(gpibObj,'CONF:CURR:AC');
            unit = ' A';
    
        end
        
    fclose(gpibObj);
    set(outMenu, 'Enable', 'off');
    set(multi.measur, 'Enable', 'off');
    set(multi.stop, 'Enable', 'on');
    pause(0.5);
    set(multi.display,'BackgroundColor', 'black');

    while takeValue
        fopen(gpibObj);
        pause(0.01);
        fprintf(gpibObj,voltORcurrent);
        temp = fscanf(gpibObj);
        set(multi.display,'string',[temp(1:15), unit]);
        pause(0.5);
        fclose(gpibObj);
    end
   
    catch err
        msgbox(err.getReport, 'Multimeter!', 'warn');
        set(multi.gpibAddress,'BackgroundColor' ,'red');
        fclose(instrfind);
        disp(err);
    end

end