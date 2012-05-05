function out_bodegragh(panel)
% Controls for multimeter
    global multimeter;
  
    multimeter.measur = uicontrol('Style', 'popup',... 
        'String', 'Measurement|Voltage|Current',...
        'parent', panel,...
        'Position', [50 850 100 20]); 

    uicontrol('Style', 'text',...
            'parent', panel,...
            'string', 'GPIB address:',...
            'position', [50 800 100 20]);

    multimeter.gpibAddress =  uicontrol('Style', 'edit',...
                'parent', panel,...
                'string', '0',...
                'BackgroundColor', 'white',...
                'position', [150 800 50 25]);
            
    multimeter.gpibConnection = uicontrol('Style', 'text',...
        'parent', panel,...
        'string', '',...
        'position', [200 800 100 20]);

end