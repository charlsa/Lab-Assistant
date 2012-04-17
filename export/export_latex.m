function export_latex
% Controls for Latex figure export
    uicontrol('Style', 'text',...
        'string', 'Image name:',...
        'position', [50 300 100 20]);
    
    data.figure_name = uicontrol('Style', 'edit',...
        'string', 'fig',...
        'BackgroundColor', 'white',...
        'position', [150 300 100 20]);
    
    uicontrol('Style', 'text',...
        'string', 'Caption:',...
        'position', [50 250 100 20]);
    
    data.figure_caption = uicontrol('Style', 'edit',...
        'BackgroundColor', 'white',...
        'position', [150 250 100 20]);
    
    uicontrol('Style', 'text',...
        'string', 'Label:',...
        'position', [50 200 100 20]);
    
    data.figure_label = uicontrol('Style', 'edit',...
        'BackgroundColor', 'white',...
        'position', [150 200 100 20]);
    
    uicontrol('Style', 'text',...
        'string', 'Width [cm]:',...
        'position', [50 150 100 20]);
    
    data.figure_width = uicontrol('Style', 'edit',...
        'string', '5',...
        'BackgroundColor', 'white',...
        'position', [150 150 100 20]);


    uicontrol('Style', 'pushbutton',...
        'String', 'Export',...
        'position', [100 50 100 25],...
        'callback', {@save,data});
end
function save(~,~,data)
    [fileName,pathName] = uiputfile();
    outFile = fopen([pathName, fileName], 'wt');
    
    fprintf(outFile,...
        ['\\documentclass{article}\n\\begin{document}\n',...
        '\\begin{figure}\n\\centering\n',...
        '\\includegraphics[width=',...
        get(data.figure_width, 'string'),...
        'cm]{',...
        get(data.figure_name, 'string'),...
        '}\n',...
        '\\caption{',...
        get(data.figure_caption, 'string'),...
        '}\n',...
        '\\label{',...
        get(data.figure_label, 'string'),...
        '}\n',...
        '\\end{figure}\n',...
        '\\end{document}']);
    fclose(outFile);
end