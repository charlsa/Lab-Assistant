function export_latex
% Controls for Latex figure export

    uicontrol('Style', 'text',...
        'string', 'Image name:',...
        'position', [50 200 100 20]);
    
    data.figure_name = uicontrol('Style', 'edit',...
        'string', 'fig',...
        'BackgroundColor', 'white',...
        'position', [150 200 50 25]);
    
    uicontrol('Style', 'text',...
        'string', 'Width [cm]:',...
        'position', [50 50 100 20]);
    
    data.figure_width = uicontrol('Style', 'edit',...
        'string', '5',...
        'BackgroundColor', 'white',...
        'position', [150 50 50 25]);


    uicontrol('Style', 'pushbutton',...
        'String', 'Export',...
        'position', [100 100 100 25],...
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
        '\\end{figure}\n',...
        '\\end{document}']);
    fclose(outFile);
end