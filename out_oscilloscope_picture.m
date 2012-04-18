function out_oscilloscope_picture(out_panel)
scope = gpib('ni',0,4);

scope.InputBufferSize = 100000;    % specify the input buffer size. If the scanned image is not full then one may be required to increase this.
scope.TimeOut = 20;                % specify sufficient timeout so that read operations do not timeout.            
fopen(scope);

fprintf(scope,'HARDCOPY:PORT GPIB');pause(0.1); % SCPI COMMANDS FOR CAPTURING AN IMAGE.
fprintf(scope,'HARDCOPY:FORMAT BMP');pause(0.1);
fprintf(scope,'HARDCOPY START');pause(0.1);
readasync(scope);

while(strcmp(scope.TransferStatus, 'read')) % Loop that executes till the scope's transfer status is read.
end
out = fread(scope,scope.BytesAvailable,'uint8');% read the binary output from the scope .
fclose(scope);

 fid = fopen('bild.bmp','w');
 
 fwrite(fid,out,'uint8');       % write the read data from the scope to the specified bmp file.
 fclose(fid);
 
    a = imread('bild.bmp','bmp'); % If viewer wants to see image then scan the image and display it.
    %a = imrotate(a,-90);
    
    
tmp_figure = figure('Visible', 'Off', 'position', [1 1 480 640]);
imagesc(a);
axis off;
copyobj(get(tmp_figure,'Children'),out_panel);
close(tmp_figure);
colormap(bone);
        
end