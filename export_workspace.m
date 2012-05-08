function export_workspace(parent)

uicontrol('Style', 'text',...
        'parent', parent,...
        'string', 'Save .mat file',...
        'BackgroundColor', 'white',...
        'position', [70 550 100 20]);

    uicontrol('Style', 'pushbutton',...
        'parent', parent,...
        'String', 'Save',...
        'position', [70 500 100 20],...
        'callback', @save);
end

function save(~,~)
  [fileName,pathName] = uiputfile('data.mat', 'Save data file');
    try     
        copyfile('data.mat', [pathName, fileName]);
    catch error
        msgbox(error.getReport, 'File not saved!', 'warn');
    end
end