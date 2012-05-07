function export_latex(parent)

% Controls for Latex figure export
    uicontrol('Style', 'text',...
        'parent', parent,...
        'string', 'Image name:',...
        'HorizontalAlignmen', 'right',...
        'BackgroundColor', 'white',...
        'position', [30 600 60 20]);
    
    data.name = uicontrol('Style', 'edit',...
        'parent', parent,...
        'string', 'fig.png',...
        'BackgroundColor', 'white',...
        'position', [100 600 100 20]);
    
    
    uicontrol('Style', 'text',...
        'parent', parent,...
        'string', 'Caption:',...
        'HorizontalAlignmen', 'right',...
        'BackgroundColor', 'white',...
        'position', [30 550 60 20]);
    
    data.caption = uicontrol('Style', 'edit',...
        'parent', parent,...
        'BackgroundColor', 'white',...
        'position', [100 550 100 20]);
    
    uicontrol('Style', 'text',...
        'parent', parent,...
        'string', 'Label:',...
        'HorizontalAlignmen', 'right',...
        'BackgroundColor', 'white',...
        'position', [30 500 60 20]);
    
    data.label = uicontrol('Style', 'edit',...
        'parent', parent,...
        'BackgroundColor', 'white',...
        'position', [100 500 100 20]);
    
    uicontrol('Style', 'text',...
        'parent', parent,...
        'string', 'Width [cm]:',...
        'HorizontalAlignmen', 'right',...
        'BackgroundColor', 'white',...
        'position', [30 450 60 20]);
    
    data.width = uicontrol('Style', 'edit',...
        'parent', parent,...
        'string', '5',...
        'BackgroundColor', 'white',...
        'position', [100 450 100 20]);

        uicontrol('Style', 'text',...
        'parent', parent,...
        'string', 'Title:',...
        'HorizontalAlignmen', 'right',...
        'BackgroundColor', 'white',...
        'position', [30 400 60 20]);
    
    data.title = uicontrol('Style', 'edit',...
        'parent', parent,...
        'BackgroundColor', 'white',...
        'position', [100 400 100 20]);
    
    uicontrol('Style', 'text',...
        'parent', parent,...
        'string', 'X-label:',...
        'HorizontalAlignmen', 'right',...
        'BackgroundColor', 'white',...
        'position', [30 350 60 20]);
    
    data.xlabel = uicontrol('Style', 'edit',...
        'parent', parent,...
        'BackgroundColor', 'white',...
        'position', [100 350 100 20]);
    
    uicontrol('Style', 'text',...
        'parent', parent,...
        'string', 'Y-label:',...
        'HorizontalAlignmen', 'right',...
        'BackgroundColor', 'white',...
        'position', [30 300 60 20]);
    
    data.ylabel = uicontrol('Style', 'edit',...
        'parent', parent,...
        'BackgroundColor', 'white',...
        'position', [100 300 100 20]);%

    uicontrol('Style', 'pushbutton',...
        'parent', parent,...
        'String', 'Export',...
        'position', [70 250 100 25],...
        'callback', {@save,data});
        
end
function save(~,~,data)
    [fileName,pathName] = uiputfile('Report.tex', 'Choose location...');
    try
        outFile = fopen([pathName, fileName], 'wt');

        fprintf(outFile,...
            ['\\documentclass{article}\n\\begin{document}\n',...
            '\\begin{figure}\n\\centering\n',...
            '\\includegraphics[width=',...
            get(data.width, 'string'),...
            'cm]{',...
            get(data.name, 'string'),...
            '}\n',...
            '\\caption{',...
            get(data.caption, 'string'),...
            '}\n',...
            '\\label{',...
            get(data.label, 'string'),...
            '}\n',...
            '\\end{figure}\n',...
            '\\end{document}']);
        fclose(outFile);
    catch error
        msgbox(error.getReport, 'TeX-file not saved!', 'warn');
    end
    
    %Copy the image to same directory
    try
        tmp_figure = open('figure.fig');
        set(tmp_figure,'Visible', 'Off');
        title(get(data.title, 'String'));
        xlabel(get(data.xlabel, 'String'));
        ylabel(get(data.ylabel, 'String'));
        saveas(tmp_figure,[pathName, get(data.name, 'string')]);
    catch error
        msgbox(error.getReport, 'Image not saved!', 'warn');
    end
end