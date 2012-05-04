function export_word()

parent = uipanel();

% Controls for MS Word export
    uicontrol('Style', 'text',...
        'parent', parent,...
        'string', 'Caption:',...
        'position', [50 450 100 20]);
    
    data.figure_caption = uicontrol('Style', 'edit',...
        'parent', parent,...
        'BackgroundColor', 'white',...
        'position', [150 450 100 20]);
    
    uicontrol('Style', 'pushbutton',...
        'parent', parent,...
        'String', 'Export',...
        'position', [100 250 100 25],...
        'callback', {@save,data});
    
function save(~,~,data)
[fileName,pathName] = uiputfile('report.doc', 'Choose location...');
    try
  	word = actxserver('Word.Application');
		set(word,'Visible',1);
		outFile = invoke(word.Documents,'Add');

        %Copy figure to clipboard
		figure = open('pic.bmp');
		print(figure, '-dmeta');
		close(figure);
        
        %Paste to document
		invoke(word.Selection, 'Paste');
        
        %Insert caption
        invoke(word.Selection, 'TypeParagraph');
		set(word.Selection, 'Text',get(data.figure_caption, 'String'));
		set(word.Selection.ParagraphFormat,'Alignment',1);
        
        %Save
		%invoke(outFile,'SaveAs',[pathName '\' fileName]);
		%invoke(Doc,'Quit');
		delete(word);

    catch error
        msgbox(error.getReport, 'Word-file not saved!', 'warn');
    end