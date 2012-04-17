function export_latex
% Controls for Latex figure export
    
uicontrol('Style', 'pushbutton',...
        'String', 'Export',...
        'position', [100 100 100 25],...
        'callback', @save);
end
    
function save(~,~)
    [FileName,PathName] = uiputfile();
    
end