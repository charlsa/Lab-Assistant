function snap_scope(address)

% The following function captures screen image from the oscilloscope.
% address specifies the gpib address of the oscilloscope.
% This function has been tested on Tektronix TDS2004 scope.
% A waveform that was captured has also been attached.

clc;
scope = gpib('ni',0,address);      % define scope object
scope.InputBufferSize = 100000;    % specify the input buffer size. If the scanned image is not full then one may be required to increase this.
scope.TimeOut = 60;                % specify sufficient timeout so that read operations do not timeout.            
fopen(scope);
h = msgbox1('Scanning Image','SNAP Utility');
fprintf(scope,'HARDCOPY:PORT GPIB');pause(0.1); % SCPI COMMANDS FOR CAPTURING AN IMAGE.
fprintf(scope,'HARDCOPY:FORMAT BMP');pause(0.1);
fprintf(scope,'HARDCOPY START');pause(0.1);
readasync(scope);
while(scope.TransferStatus == 'read') % Loop that executes till the scope's transfer status is read.
end
out = fread(scope,scope.BytesAvailable,'uint8');% read the binary output from the scope .
gpibclose(scope); % gpibclose cleans up for the gpib object.
delete(h);

op_file = inputdlg({'Please enter the filename for the image:'},'SNAP Utility',1,{'test'});

if exist([op_file{1} '.bmp'],'file');           % checking for existence of the specified file.
     h = msgbox1('Output File Exists','SNAp Utility');
     pause(1);
     delete(h);
     yn = questdlg('What do you want to do?','SNAP Utility','OverWrite','New','New');
     switch yn,
         case 'OverWrite',
             fid = fopen([op_file{1} '.bmp'],'w');
         case 'New',
             op_file = inputdlg({'Please enter another filename for the image:'},'SNAP Utility',1,{' '});
             fid = fopen([op_file{1} '.bmp'],'w');
     end
 else
        fid = fopen([op_file{1} '.bmp'],'w');  % Open a bitmap file
 end
 
 fwrite(fid,out,'uint8');       % write the read data from the scope to the specified bmp file.
 fclose(fid);
 
 viewchoice = questdlg('Do You want to see the scanned image?','SNAP Utility','Yes','No','Yes');
 switch viewchoice,
     case 'Yes'
         a = imread([op_file{1} '.bmp'],'bmp'); % If viewer wants to see image then scan the image and display it.
         imagesc(a);
         colormap(bone);
     case 'No'
         h = msgbox1(['See the ' op_file{1} ' image in paint']);
         pause(2.0);
         delete(h);
 end
 clear all;        

             
