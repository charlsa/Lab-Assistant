function export_image(export_panel)
% Controls for image export

    uicontrol('Style', 'pushbutton',...
        'parent', export_panel,...
        'String', 'Save',...
        'position', [100 top-400 100 25],...
        'callback', @save);
end

function save(~,~)
	[fileName,pathName] = uiputfile('image.bmp', 'Save image');
    try
        %Image is stored in application folder as image.bmp
        copyfile('figure.bmp',[pathName, fileName]);
    catch error
        msgbox(error.getReport, 'File not saved!', 'warn');
    end
end