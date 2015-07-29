function nameLikeXnat(dirname, safemode)
%nameLikeXnat(D)  Rename all DICOM files in a directory using XNAT's naming convention
%   This function accepts as the first argument, D, a string that contains
%   the full path to a directory containing bulk DICOM files.  If D is 
%   unspecified, a user interface is provided for the user to browse to 
%   such a directory.  The second argument, safemode, may take on the
%   string values of 'safe' or 'nosafe'.  In safe mode, the files are
%   copied, in nosafe mode, they are simply renamed.
%
%   Each DICOM file contained in the specified directory will be copied or 
%   renamed using the XNAT naming convention.  Any non-DICOM files 
%   contained in the parent directory will be left untouched.
%
%   Example:  nameLikeXnat('/Users/joe/Data/Scan 23') 
%             or, just:  nameLikeXnat
%
%   VERSION: 0.1, 16 July 2015, Jeffrey Luci
%
%   WARNING: Very little error checking is performed in this version.  Any
%   unusual directory formats or mixed-mode files might be treated
%   improperly.  In such a case, the data should be intact, but the file's
%   location might be in any subdirectory created.

getext = @(txt) fliplr(strtok(fliplr(txt), '.'));

if ~(exist('dirname', 'var'))
    dirname = uigetdir(pwd, 'Browse to DICOM directory');
    if dirname == 0
        return;
    end
end

if ~(exist('safemode', 'var'))
    safemode = true;
elseif strcmp(safemode, 'nosafe')
    safemode = false;
else
    safemode = true;
end

d=dir(dirname);

for ii = 3:numel(d)
    if isdicom(d(ii).name)
        hdr = dicominfo(d(ii).name);
        nameString = [hdr.PatientName.FamilyName '.' hdr.RequestedProcedureDescription '.' ...
                      num2str(hdr.SeriesNumber) '.' num2str(hdr.InstanceNumber) '.' hdr.StudyDate '.' ...
                      strtok(hdr.StudyTime, '.') '.' randStr(7) '.dcm'];
        nameString = strrep(nameString, ' ', '_');
        disp(nameString);
        if safemode
            copyfile([dirname '/' d(ii).name], [dirname '/' nameString]);
        else
            movefile([dirname '/' d(ii).name], [dirname '/' nameString]);
        end
    end
end


    function result = isdicom(filename)
        ext = getext(filename);
        if (strcmp(ext, 'dcm') || strcmp(ext, 'DCM') || strcmp(ext, 'ima') || strcmp(ext, 'IMA'))
            result = true;
        else
            result = false;
        end
    end

    function rndStr = randStr(numChar)
        set = char(['a':'z' '0':'9']) ;
        nset = length(set) ;
        setStr = ceil(nset*rand(1,numChar)) ; % with repeat
        rndStr = set(setStr) ;
        
    end

end