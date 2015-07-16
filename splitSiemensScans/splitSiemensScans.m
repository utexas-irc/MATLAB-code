function splitSiemensScans(dirname)
%splitSiemensScans(D)  Split unstructured siemens DICOM directory into named series
%   This function accepts as the only argument, D, a string that contains
%   the full path to a directory containing bulk DICOM files from many
%   series in a single scan session.  If D is unspecified, a user interface
%   is provided for the user to browse to such a directory.
%
%   Each DICOM file contained in the specified directory will be moved to a
%   newly-created subdirectory (within the same DICOM direcoty) that will
%   be named with a three digit series number and series name.  Any
%   non-DICOM files contained in the parent directory will be left
%   untouched.
%
%   Example:  splitSiemensScans('/Users/joe/Data/Scan 23') 
%             or, just:  splitSiemensScans
%
%   VERSION: 0.1, 10 July 2015, Jeffrey Luci
%
%   WARNING: Very little error checking is performed in this version.  Any
%   unusual directory formats or mixed-mode files might be treated
%   improperly.  In such a case, the data should be intact, but the file's
%   location might be in any subdirectory created.

getext = @(txt) fliplr(strtok(fliplr(txt), '.'));

if ~exist('dirname', 'var')
    dirname = uigetdir(pwd, 'Specify DICOM Directory . . . ');
end
if(dirname == 0)
    error('User clicked cancel . . .');
end
d=dir(dirname);

seriesList = [];

waitbarFig = waitbar(0, 'Sorting DICOM files');

for ii = 3:numel(d)
    ext=getext([dirname '/' d(ii).name]);
    if (strcmp(ext, 'dcm') || strcmp(ext, 'IMA') || ...
            strcmp(ext, 'DCM') || strcmp(ext, 'ima'))
        
        hdr = dicominfo([dirname '/' d(ii).name]);
        seriesNum = hdr.SeriesNumber;
        seriesName = hdr.ProtocolName;
        
        if isempty(find(seriesList==seriesNum))
            dicomDir = sprintf('%03d-%s', seriesNum, seriesName);
            mkdir(dirname, dicomDir);
            seriesList = [seriesList seriesNum];
        end
        
        movefile([dirname '/' d(ii).name], [dirname '/' dicomDir]);
    end
    waitbar(ii/(numel(d)-2));
end
close(waitbarFig);

end