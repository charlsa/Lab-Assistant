function out_oscilloscope(panel)

    parameters.measur = uicontrol('Style', 'popup',... 
        'String', 'Measurement|Picture|True RMS|...|....',...
        'parent', panel,...
        'Position', [50 850 100 20]); 

    uicontrol('Style', 'text',...
            'parent', panel,...
            'string', 'GPIB address:',...
            'position', [50 800 100 20]);

    parameters.gpibAddress =  uicontrol('Style', 'edit',...
                'parent', panel,...
                'string', '0',...
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
        'callback', {@measurement_callback});
     
end

function measurement_callback(~,panel)

     choice = get(panel.parameters.measur,'Value');
     
     switch (choice)
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
    
    a = imread('bild.bmp','bmp'); % If viewer wants to see image then scan the image and display it.
    %a = imrotate(a,-90);
    
    tmp_figure = figure('Visible', 'OFF', 'position', [1 1 480 640]);
    imagesc(a);
    axis off;
    copyobj(get(tmp_figure,'Children'),panel);
    close(tmp_figure);
    colormap(bone);
    disp('klar');
 
end

function datatrans( address )
clc;
scope = gpib('ni',0,address);      % define scope object
scope.InputBufferSize = 10000;    % specify the input buffer size. If the scanned image is not full then one may be required to increase this.
scope.TimeOut = 5;                % specify sufficient timeout so that read operations do not timeout.            
fopen(scope);

fprintf(scope, '*CLS');
fprintf(scope, 'CH1:POSITION?');
pos1=fscanf(scope) ;			
fprintf(scope, 'HORIZONTAL:SCALE?'); %time scale		
tid=fscanf(scope)
fprintf(scope, 'HORIZONTAL:SCALE?'); %get time a second time because first time is crap sometimes
tid=fscanf(scope)
fprintf(scope, 'CH1:VOLTS?'); 	% voltage scale
amp=fscanf(scope)
fprintf(scope, 'Data:Source CH1'); 	%channel 1 is chosed
fprintf(scope, 'Data:Encdg SRPbinary'); 		% Talformatet se vidare manual för oscilloskopet sid 2-69
fprintf(scope, 'Data:Width 1'); % Antal bytes per datapunkt.
fprintf(scope, 'Data:Start 1'); % Starta överföringen med punkt 1 på kurvan.
fprintf(scope, 'Curve?') 		% Överför kurvan
data = (fread(scope, 2500));	% Läs överförd data

fprintf(scope, '*CLS');%clear status data
fprintf(scope, 'CH2:POSITION?');
pos2=fscanf(scope) ;			%  slask, du behöver enbart skriva fscan(g) här för att väcka inst. ?! Bugg?
fprintf(scope, 'CH2:VOLTS?'); 	
amp2=fscanf(scope)
fprintf(scope, 'Data:Source CH2'); 	% channel 2 is chosed
fprintf(scope, 'Data:Encdg SRPbinary'); 		% Talformatet se vidare manual för oscilloskopet sid 2-69
fprintf(scope, 'Data:Width 1'); % Number of bytes per data point.
fprintf(scope, 'Data:Start 1'); % Start transfer at data point 1 om the curve.
fprintf(scope, 'Curve?') 		% Överför kurvan
data2 = (fread(scope, 2500));	% Läs överförd data

gpibclose(scope);

t=str2double(tid(9:15));
t_vec=(t/250:t/250:t*10);

a=str2double(amp(9:16));
data=(data-127.5)*a/25;                 %delar med 25=200/8 som är antalet pixlar per ruta (wigertz konstant)
a2=str2double(amp2(9:16));
data2=(data2-127.5)*a2/25;
         
if data2                            %check if data2 was measured correctly
    figure=plot(t_vec(15:2500),data2(15:2500)); 
    hold on
end

if data
figure=plot(t_vec(15:2500),data(15:2500));
end

saveas(figure, 'figur.fig')
hold off
end