function out_oscilloscope(panel)

    parameters.measur = uicontrol('Style', 'popup',... 
        'String', 'Measurement|Picture',...
        'BackgroundColor', 'w',...
        'parent', panel,...
        'Position', [200 600 100 20]); 

    uicontrol('Style', 'text',...
            'parent', panel,...
            'BackgroundColor', 'w',...
            'string', 'GPIB address: ',...
            'horizontalalign', 'right',...
            'position', [30 598 100 20]);

    parameters.gpibAddress =  uicontrol('Style', 'edit',...
                'parent', panel,...
                'string', '',...
                'BackgroundColor', 'white',...
                'position', [130 600 50 20]);
            
    
    uicontrol('Style', 'pushbutton',...
        'parent', panel,...
        'string', 'Start',...
        'position', [320 600 75 20],...
        'callback', {@measurement_callback,parameters,panel});
     
end

function measurement_callback(~,~,parameters,panel)

     choice = get(parameters.measur,'Value');
     
     switch (choice)
         case 1
             oscilloscope_data( panel ,parameters );
         case 2
             oscilloscope_picture(panel, parameters);
     end

end

function oscilloscope_picture(panel ,parameters) 

address = str2num(get(parameters.gpibAddress,'string'));
gpibObj = gpib('ni', 0, address);

try
    gpibObj.InputBufferSize = 100000;    % specify the input buffer size. If the scanned image is not full then one may be required to increase this.
    gpibObj.TimeOut = 20;                % specify sufficient timeout so that read operations do not timeout.            
    fopen(gpibObj);
    
    set(parameters.gpibAddress,'BackgroundColor' ,'w');
    pause(0.1);
    
    fprintf(gpibObj,'HARDCOPY:PORT GPIB');pause(0.1); % SCPI COMMANDS FOR CAPTURING AN IMAGE.
    fprintf(gpibObj,'HARDCOPY:FORMAT BMP');pause(0.1);
    fprintf(gpibObj,'HARDCOPY START');pause(0.1);
    readasync(gpibObj);
    H=waitbar(0);%a waitbar while pic is loaded
    i=0;
    while(strcmp(gpibObj.TransferStatus, 'read')) % Loop that executes till the scope's transfer status is read.
        waitbar(mod(i,1),H,'Please wait while picture is loading!');
        pause(0.1);
        i=i+0.0065;
    end
    delete(H);
    out = fread(gpibObj,gpibObj.BytesAvailable,'uint8');% read the binary output from the scope .
    fclose(gpibObj);
 
catch err
    set(parameters.gpibAddress,'BackgroundColor' ,'red');   
    disp(err);
    fclose(instrfind);
end

    fid = fopen('bild.bmp','w');
    fwrite(fid,out,'uint8');       % write the read data from the scope to the specified bmp file.
    fclose(fid);
    
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
try
address = str2num(get(parameters.gpibAddress,'string')); %get address
gpibObj = gpib('ni',0,address);      % define scope object
gpibObj.InputBufferSize = 10000;    % specify the input buffer size. If the scanned image is not full then one may be required to increase this.
gpibObj.TimeOut = 10;                % specify sufficient timeout so that read operations do not timeout.            
fopen(gpibObj);
set(parameters.gpibAddress,'BackgroundColor' ,'w');
pause(0.1);

fprintf(gpibObj, '*CLS');
fprintf(gpibObj, 'CH1:POSITION?');
pos1=fscanf(gpibObj) ;			
fprintf(gpibObj, 'HORIZONTAL:SCALE?'); %time scale		
tid=fscanf(gpibObj);
fprintf(gpibObj, 'HORIZONTAL:SCALE?'); %get time a second time because first time is crap sometimes
tid=fscanf(gpibObj);
fprintf(gpibObj, 'CH1:VOLTS?'); 	% voltage scale
amp=fscanf(gpibObj);
fprintf(gpibObj, 'Data:Source CH1'); 	%channel 1 is chosed
fprintf(gpibObj, 'Data:Encdg SRPbinary'); 		% Talformatet se vidare manual fÃƒÆ’Ã‚Â¶r oscilloskopet sid 2-69
fprintf(gpibObj, 'Data:Width 1'); % Antal bytes per datapunkt.
fprintf(gpibObj, 'Data:Start 1'); % Starta ÃƒÆ’Ã‚Â¶verfÃƒÆ’Ã‚Â¶ringen med punkt 1 pÃƒÆ’Ã‚Â¥ kurvan.
fprintf(gpibObj, 'Curve?') 		% ÃƒÆ’Ã¢â‚¬â€œverfÃƒÆ’Ã‚Â¶r kurvan
data = (fread(gpibObj, 2500));	% LÃƒÆ’Ã‚Â¤s ÃƒÆ’Ã‚Â¶verfÃƒÆ’Ã‚Â¶rd data

fprintf(gpibObj, '*CLS');%clear status data
fprintf(gpibObj, 'CH2:POSITION?');
pos2=fscanf(gpibObj) ;			%  slask, du behÃƒÆ’Ã‚Â¶ver enbart skriva fscan(g) hÃƒÆ’Ã‚Â¤r fÃƒÆ’Ã‚Â¶r att vÃƒÆ’Ã‚Â¤cka inst. ?! Bugg?
fprintf(gpibObj, 'CH2:VOLTS?'); 	
amp2=fscanf(gpibObj);
fprintf(gpibObj, 'Data:Source CH2'); 	% channel 2 is chosed
fprintf(gpibObj, 'Data:Encdg SRPbinary'); 		% Talformatet se vidare manual fÃƒÆ’Ã‚Â¶r oscilloskopet sid 2-69
fprintf(gpibObj, 'Data:Width 1'); % Number of bytes per data point.
fprintf(gpibObj, 'Data:Start 1'); % Start transfer at data point 1 om the curve.
fprintf(gpibObj, 'Curve?') 		% ÃƒÆ’Ã¢â‚¬â€œverfÃƒÆ’Ã‚Â¶r kurvan
data2 = (fread(gpibObj, 2500));	% LÃƒÆ’Ã‚Â¤s ÃƒÆ’Ã‚Â¶verfÃƒÆ’Ã‚Â¶rd data

fclose(gpibObj);
delete(gpibObj);

catch err
    set(parameters.gpibAddress,'BackgroundColor' ,'red');   
    disp(err);
    fclose(instrfind);
    
end

t=str2double(tid(9:15));
t_vec=(t/250:t/250:t*10);

a=str2double(amp(9:16));
data=(data-127.5)*a/25;                 %delar med 25=200/8 som ÃƒÆ’Ã‚Â¤r antalet pixlar per ruta (wigertz konstant)
a2=str2double(amp2(9:16));
data2=(data2-127.5)*a2/25;
         
if data2                            %check if data2 was measured correctly
    plot(t_vec(15:2500),data2(15:2500)); 
    hold on
end

if data
    plot(t_vec(15:2500),data(15:2500));
end
ylabel('Voltage [V]');
xlabel('Time [t]');
grid on

% save figure
tmp_figure = figure(10);

if data2                            %check if data2 was measured correctly
    plot(t_vec(15:2500),data2(15:2500)); 
    hold on
end

if data
    plot(t_vec(15:2500),data(15:2500));
end
ylabel('Voltage [V]');
xlabel('Time [t]');
grid on

saveas(tmp_figure, 'figure', 'fig');
close(tmp_figure);

end