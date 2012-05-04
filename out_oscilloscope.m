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