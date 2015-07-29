function tforms = movementtracker(skipStep, varargin)

%version 0.1, Luci
getext = @(txt) fliplr(strtok(fliplr(txt), '.'));

loopKey = 3;
dicomExtention = 'dcm';


%get parameters of images from first DICOM in series
d = dir(varargin{1});
while(~strcmp(dicomExtention, getext(d(loopKey).name)))
    loopKey = loopKey+1;
end
baseDICOM = [varargin{1} '/' d(loopKey).name];
baseHdr = dicominfo(baseDICOM);
baseVol = mosaic23d(baseDICOM);


%configrure coreg type
[optimizer, metric] = imregconfig('monomodal');
%optimizer.InitialRadius = 0.004;
imParams = imref3d(size(baseVol), baseHdr.PixelSpacing(1), ...
                                  baseHdr.PixelSpacing(2), ...
                                  baseHdr.SliceThickness); 

%compile list of mosaics to track
fileList = [];
for ii = 1:length(varargin)
    dirStruct = dir(varargin{ii});
    dirCell = struct2cell(dirStruct);
    for jj = 1:size(dirCell,2) 
        dirCell(1,jj) = strcat(varargin{ii}, '/', dirCell(1,jj)); 
    end
    fileList = [fileList dirCell];
end

nonDicoms = [];
for ii = 1:size(fileList,2)
    if(~strcmp(dicomExtention, getext(fileList{1,ii})))
        nonDicoms = [nonDicoms ii]; %#ok<*AGROW>
    end
end
fileList(:,nonDicoms) = [];
%fileList = fileList(1:skipStep:numel(fileList));

                            
%begin to perform coregistrations
tforms = zeros(4,4,size(fileList,2));
waitbarfig = waitbar(0, 'Performing coregistrations . . .');
tic;
for ii = 1:size(fileList,2)
    curVol = mosaic23d(fileList{1,ii});
    tformMat = imregtform(curVol, imParams, baseVol, imParams, 'rigid', optimizer, metric);
    tforms(:,:,ii) = tformMat.T;
    waitbar(ii/size(fileList,2), waitbarfig);
end
toc;
close(waitbarfig);


%Plot the translation results
plot(squeeze(tforms(4,3,:)));
xlabel('Image Number', 'FontSize', 12)
ylabel('Affine Translation Element','FontSize', 12);
hold on
plot(squeeze(tforms(4,2,:)));
plot(squeeze(tforms(4,1,:)));
legend('x', 'y', 'z', 'Location', 'SouthEast') 


    function IM = mosaic23d(filename)
        disp(filename);
        hdr = dicominfo(filename);
        imgDIM = [hdr.AcquisitionMatrix(1) hdr.AcquisitionMatrix(4)];
        
        DICOM = dicomread(filename);
        tileDIM = [size(DICOM,1)/imgDIM(1) size(DICOM,2)/imgDIM(2)];
        
        IM=zeros(imgDIM(1), imgDIM(2), prod(single(tileDIM)));
        
        imno=1;
        for zz = 1:imgDIM(1):size(DICOM,1);
            for kk = 1:imgDIM(2):size(DICOM,2);
                IM(:,:,imno) = DICOM(zz:zz+imgDIM(1)-1, kk:kk+imgDIM(2)-1);
                imno=imno+1;
            end
        end
        IM = IM(:,:,1:hdr.Private_0019_100a);
    end




end
