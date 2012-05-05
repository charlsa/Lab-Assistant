function out_oscilloscope(panel)

    parameters.measur = uicontrol('Style', 'popup',... 
        'String', 'Measurement|Picture',...
        'parent', panel,...
        'Position', [50 850 100 20]); 

    uicontrol('Style', 'text',...
            'parent', panel,...
            'string', 'GPIB address:',...
            'position', [50 800 100 20]);

    parameters.gpibAddress =  uicontrol('Style', 'edit',...
                'parent', panel,...
                'string', '13',...
                'BackgroundColor', 'white',...
                'position', [150 800 50 25]);
            
    parameters.gpibConnection = uicontrol('Style', 'text',...
        'parent', panel,...
        'string', '',...
        'position', [200 750 50 25]);
    
    uicontrol('Style', 'pushbutton',...
        'parent', panel,...
        'string', 'Start',...
        'position', [50 750 100 20],...
        'callback', {@measurement_callback,parameters,panel});
     
end

function measurement_callback(~,~,parameters,panel)

     choice = get(parameters.measur,'Value');
     
     switch (choice)
         case 1
             oscilloscope_data( panel ,parameters );
         case 2
             oscilloscope_picture(panel, parameters);
         case 3
             oscilloscope_trueRMS(panel, parameters);
     end

end

function oscilloscope_picture(panel ,parameters) 

address = str2num(get(parameters.gpibAddress,'string'));
gpibObj = gpib('ni', 0, address);

try
    gpibObj.InputBufferSize = 100000;    % specify the input buffer size. If the scanned image is not full then one may be required to increase this.
    gpibObj.TimeOut = 20;                % specify sufficient timeout so that read operations do not timeout.            
    fopen(gpibObj);

    fprintf(gpibObj,'HARDCOPY:PORT GPIB');pause(0.1); % SCPI COMMANDS FOR CAPTURING AN IMAGE.
    fprintf(gpibObj,'HARDCOPY:FORMAT BMP');pause(0.1);
    fprintf(gpibObj,'HARDCOPY START');pause(0.1);
    readasync(gpibObj);

    while(strcmp(gpibObj.TransferStatus, 'read')) % Loop that executes till the scope's transfer status is read.
    end
    out = fread(gpibObj,gpibObj.BytesAvailable,'uint8');% read the binary output from the scope .
    fclose(gpibObj);
    
catch err
    set(parameters.gpibConnection,'string' ,'GPIB Disconnected');
    set(parameters.gpibAddress,'BackgroundColor' ,'red');    
end

    fid = fopen('bild.bmp','w');
    fwrite(fid,out,'uint8');       % write the read data from the scope to the specified bmp file.
    fclose(fid);
    
    %figur=plot(out)
    
    imagesc(imread('bild.bmp','bmp'));
    axis off;
    colormap(bone);
    
    tmp_fig=figure(11);
    imagesc(imread('bild.bmp','bmp'));
    colormap(bone);
    axis off;
    
    saveas(tmp_fig, 'figur', 'fig');
    close(tmp_fig);
 
end

function oscilloscope_data( panel ,parameters )
clc;
address = str2num(get(parameters.gpibAddress,'string')); %get address
gpibObj = gpib('ni',0,address);      % define scope object
gpibObj.InputBufferSize = 10000;    % specify the input buffer size. If the scanned image is not full then one may be required to increase this.
gpibObj.TimeOut = 10;                % specify sufficient timeout so that read operations do not timeout.            
fopen(gpibObj);

fprintf(gpibObj, '*CLS');
fprintf(gpibObj, 'CH1:POSITION?');
pos1=fscanf(gpibObj) ;			
fprintf(gpibObj, 'HORIZONTAL:SCALE?'); %time scale		
tid=fscanf(gpibObj)
fprintf(gpibObj, 'HORIZONTAL:SCALE?'); %get time a second time because first time is crap sometimes
tid=fscanf(gpibObj)
fprintf(gpibObj, 'CH1:VOLTS?'); 	% voltage scale
amp=fscanf(gpibObj)
fprintf(gpibObj, 'Data:Source CH1'); 	%channel 1 is chosed
fprintf(gpibObj, 'Data:Encdg SRPbinary'); 		% Talformatet se vidare manual fÃ¶r oscilloskopet sid 2-69
fprintf(gpibObj, 'Data:Width 1'); % Antal bytes per datapunkt.
fprintf(gpibObj, 'Data:Start 1'); % Starta Ã¶verfÃ¶ringen med punkt 1 pÃ¥ kurvan.
fprintf(gpibObj, 'Curve?') 		% Ã–verfÃ¶r kurvan
data = (fread(gpibObj, 2500));	% LÃ¤s Ã¶verfÃ¶rd data

fprintf(gpibObj, '*CLS');%clear status data
fprintf(gpibObj, 'CH2:POSITION?');
pos2=fscanf(gpibObj) ;			%  slask, du behÃ¶ver enbart skriva fscan(g) hÃ¤r fÃ¶r att vÃ¤cka inst. ?! Bugg?
fprintf(gpibObj, 'CH2:VOLTS?'); 	
amp2=fscanf(gpibObj)
fprintf(gpibObj, 'Data:Source CH2'); 	% channel 2 is chosed
fprintf(gpibObj, 'Data:Encdg SRPbinary'); 		% Talformatet se vidare manual fÃ¶r oscilloskopet sid 2-69
fprintf(gpibObj, 'Data:Width 1'); % Number of bytes per data point.
fprintf(gpibObj, 'Data:Start 1'); % Start transfer at data point 1 om the curve.
fprintf(gpibObj, 'Curve?') 		% Ã–verfÃ¶r kurvan
data2 = (fread(gpibObj, 2500));	% LÃ¤s Ã¶verfÃ¶rd data

fclose(gpibObj);
delete(gpibObj);

t=str2double(tid(9:15));
t_vec=(t/250:t/250:t*10);

a=str2double(amp(9:16));
data=(data-127.5)*a/25;                 %delar med 25=200/8 som Ã¤r antalet pixlar per ruta (wigertz konstant)
a2=str2double(amp2(9:16));
data2=(data2-127.5)*a2/25;
         
if data2                            %check if data2 was measured correctly
    figure=plot(t_vec(15:2500),data2(15:2500)); 
    ylabel('Voltage [V]');
    xlabel('Time [t]');
    hold on
end

if data
    figure=plot(t_vec(15:2500),data(15:2500));
end

saveas(figure, 'figur.fig')
hold off
end