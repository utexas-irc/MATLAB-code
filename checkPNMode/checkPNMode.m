function checkPNMode()
%checkPNMode - Determine the Prescan Normalize Mode for a Siemens DICOM
%   Navigate to a DICOM directory, and the function will parse the 
%   proprietary header of the first DICOM it finds.  The encoded
%   Prescan Normalize Mode will be reported on the MATLAB command line.


%Function handle for getting a file extension
getext = @(txt) fliplr(strtok(fliplr(txt), '.'));

%Prompt user to navigate to DICOM directory
pathname = uigetdir(pwd, 'Specify DICOM Directory . . . ');

if(pathname == 0)
    error('User clicked cancel . . .');
end
D=dir(pathname);

%Use first DICOM you find and read the header
for ii = 3:numel(D)
   if(     strcmp(getext(D(ii).name), 'dcm') || ...
           strcmp(getext(D(ii).name), 'ima') || ...
           strcmp(getext(D(ii).name), 'DCM') || ...
           strcmp(getext(D(ii).name), 'IMA'))
       hdr = dicominfo([pathname '/' D(ii).name]);
   end
   if(exist('hdr', 'var'))
       break;
   end
end

%Extract proprietary header and report the finding
propHdr = char(hdr.Private_0029_1020)';
hdrLocation = strfind(propHdr, 'sPreScanNormalizeFilter.ucMode');
disp(propHdr(hdrLocation:hdrLocation+35));

    
end