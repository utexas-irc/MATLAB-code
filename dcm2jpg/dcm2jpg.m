function dcm2jpg(pathname)

if(~exist('pathname', 'var'))
    pathname = uigetdir(pwd, 'Specify DICOM Directory . . . ');
end
D=dir(pathname);

for ii = 3:numel(D)
    if(strcmp('mcd', strtok(fliplr(D(ii).name), '.')))
        if(~exist('temp', 'var'))
            temp=[];
            sliceOrder=[];
        end
        hdr=dicominfo([pathname '/' D(ii).name]);
        sliceOrder = [sliceOrder hdr.SliceLocation];
        temp=cat(3,temp,dicomread([pathname '/' D(ii).name]));
    end
end

sortedSliceOrder = sort(sliceOrder);
IM=int16(zeros(size(temp)));

for ii = 1:size(IM,3)
    IM(:,:,ii) = temp(:,:,sortedSliceOrder(ii)==sliceOrder);
end
clear temp

warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir([pathname '/JPEGs']);

for ii = 1:size(IM,3)
    temp=double(IM(:,:,ii));
    temp=temp-min(temp(:));
    temp=uint8(round(254*temp/max(temp(:))));
    filename=sprintf('IM%04d.jpg', ii);
    imwrite(temp, [pathname '/JPEGs/' filename], 'JPEG');
end
    