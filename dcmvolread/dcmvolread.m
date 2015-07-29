function [IM hdr]=dcmvolread(pathname)

getext = @(txt) fliplr(strtok(fliplr(txt), '.'));

if(~exist('pathname', 'var'))
    pathname = uigetdir(pwd, 'Specify DICOM Directory . . . ');
end
if(pathname == 0)
    error('User clicked cancel . . .');
end
D=dir(pathname);

for ii = 3:numel(D)
    if(strcmp('dcm', getext(D(ii).name)))
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