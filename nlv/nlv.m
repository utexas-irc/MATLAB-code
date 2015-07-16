function nlv()

if(isdeployed)
    baseDir = pwd;
    cd(ctfroot);
end

getext = @(txt) fliplr(strtok(fliplr(txt), '.'));

IM=double(zeros(128));
fig = figure;
pos=get(fig, 'Position');

set(fig,'Position',    [pos(1) pos(2) 1100 600], ...
    'Name',        ['NEU366L MR Image Viewer v.3.1' char(169) ' 2013-15 Jeffrey Luci, ' ...
    'The University of Texas at Austin'], ...
    'ToolBar',     'none', ...
    'MenuBar',     'none', ...
    'NumberTitle', 'off', ...
    'Resize',      'off');
movegui(fig, 'center');
imagesc(IM, [0 1]), colormap gray;
axisHandle = gca;
set(axisHandle, 'Units', 'Pixels', ...
    'Position', [230 30 550 550], ...
    'Visible', 'off');
colorbarHandle = colorbar;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% global Vaiables                                        %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pathname = '/';
%pathname = 'C:\Users\lucijj\Documents\Data\BIO366L\BIO366L-protocol_check\SCANS';
numImages = uint16(1);
curImage = 1;
tempImage = true;
globalIntMax = 1;
globalIntMin = 0;
curIntMax = 1;
curIntMin = 0;
cmap = 'gray';
hdr = [];
roi = [];
firstSave = true;

warning('off', 'images:removing:function');  %ignore roipolyold warnings
warning('off', 'stats:nlinfit:IllConditionedJacobian');  %ignore nlinfit condition warnings


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Add/Remove Image UI Panel                              %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imageControlPanel=uipanel('Title',             'Add/Remove Images', ...
    'FontSize',          11, ...
    'BackgroundColor',   [0.94, 0.94, 0.94], ...
    'Units',             'Pixels', ...
    'Position',          [10 440 200 155]);

openImageButton=uicontrol(fig,'Style',           'pushbutton', ...
    'Parent',          imageControlPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          'Load Image', ...
    'Units',           'Pixels', ...
    'Position',        [10 95 175 30], ...
    'Callback',        @addImage);

removeImageButton=uicontrol(fig,'Style',           'pushbutton', ...
    'Parent',          imageControlPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          'Remove Image', ...
    'Units',           'Pixels', ...
    'Position',        [10 65 175 30], ...
    'Enable',          'off', ...
    'Callback',        @removeImage);

sortImageLabel=uicontrol(fig,'Style',              'text', ...
    'Parent',             imageControlPanel, ...
    'BackgroundColor',    [0.94, 0.94, 0.94], ...
    'String',             'Sort images by:', ...
    'Units',              'Pixels', ...
    'Position',           [10 2 175 50]);

sortImagesPulldown=uicontrol(fig,'Style',           'popup', ....
    'Parent',          imageControlPanel, ...
    'BackgroundColor', [1.0 1.0 1.0], ...
    'String',          ' |TR|TE|Flip Angle|Slice Number|Receive Bandwidth', ...
    'Units',           'Pixels', ...
    'Visible',         'on', ...
    'Position',        [10 -15 175 50], ...
    'Enable',          'off', ...
    'Callback',        @sortImages);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Image View Control UI Panel                            %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


imageViewPanel=uipanel('Title',                'Image Viewing', ...
    'FontSize',          11, ...
    'BackgroundColor',   [0.94, 0.94, 0.94], ...
    'Units',             'Pixels', ...
    'Position',          [10 280 200 155]);

imageIncrementButton=uicontrol(fig,'Style',      'pushbutton', ...
    'Parent',          imageViewPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          '>', ...
    'Units',           'Pixels', ...
    'Position',        [114 95 30 30], ...
    'Enable',          'off', ...
    'Callback',        @incrementImage);

goToLastImageButton=uicontrol(fig,'Style',      'pushbutton', ...
    'Parent',          imageViewPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          '|>', ...
    'Units',           'Pixels', ...
    'Position',        [145 95 30 30], ...
    'Enable',          'off', ...
    'Callback',        @goToLastImage);

imageNumberEdit=uicontrol(fig,'Style',           'edit', ...
    'Parent',          imageViewPanel, ...
    'String',          '', ...
    'BackgroundColor', [1 1 1], ...
    'Units',           'Pixels', ...
    'Enable',          'off', ...
    'Position',        [87 95 20 30], ...
    'Callback',        @imageNumberSet);

imageDecrementButton=uicontrol(fig,'Style',      'pushbutton', ...
    'Parent',          imageViewPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          '<', ...
    'Units',           'Pixels', ...
    'Position',        [50 95 30 30], ...
    'Enable',          'off', ...
    'Callback',        @decrementImage);

goToFirstImageButton=uicontrol(fig,'Style',      'pushbutton', ...
    'Parent',          imageViewPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          '<|', ...
    'Units',           'Pixels', ...
    'Position',        [19 95 30 30], ...
    'Enable',          'off', ...
    'Callback',        @goToFirstImage);

imageContrastLabel=uicontrol(fig,'Style',              'text', ...
    'Parent',             imageViewPanel, ...
    'BackgroundColor',    [0.94, 0.94, 0.94], ...
    'String',             ['M' char([10 10]) 'F'], ...
    'Units',              'Pixels', ...
    'Position',           [5 50 20 40]);

maxIntSlider=uicontrol(fig,'Style',           'slider', ...
    'Parent',          imageViewPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'Units',           'Pixels', ...
    'Position',        [23 70 162 20], ...
    'Enable',          'off', ...
    'Value',           65535, ...
    'Max',             65535, ...
    'Min',             0, ...
    'Callback',        @changeMaxIntSlider);

minIntSlider=uicontrol(fig,'Style',           'slider', ...
    'Parent',          imageViewPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'Units',           'Pixels', ...
    'Position',        [23 50 162 20], ...
    'Enable',          'off', ...
    'Value',           0, ...
    'Max',             65535, ...
    'Min',             0, ...
    'Callback',        @changeMinIntSlider);

minIntEdit=uicontrol(fig,'Style',           'edit', ...
    'Parent',          imageViewPanel, ...
    'String',          '0', ...
    'BackgroundColor', [1 1 1], ...
    'Units',           'Pixels', ...
    'Enable',          'off', ...
    'Position',        [43 25 50 20], ...
    'Callback',        @changeMinIntEdit);

maxIntEdit=uicontrol(fig,'Style',           'edit', ...
    'Parent',          imageViewPanel, ...
    'String',          '0', ...
    'BackgroundColor', [1 1 1], ...
    'Units',           'Pixels', ...
    'Enable',          'off', ...
    'Position',        [135 25 50 20], ...
    'Callback',        @changeMaxIntEdit);

imageFloorLabel=uicontrol(fig,'Style',              'text', ...
    'Parent',             imageViewPanel, ...
    'BackgroundColor',    [0.94, 0.94, 0.94], ...
    'String',             'Floor:', ...
    'Units',              'Pixels', ...
    'Position',           [12 22 27 20]);

imageMaxLabel=uicontrol(fig,'Style',              'text', ...
    'Parent',             imageViewPanel, ...
    'BackgroundColor',    [0.94, 0.94, 0.94], ...
    'String',             'Max:', ...
    'Units',              'Pixels', ...
    'Position',           [106 22 25 20]);

autoIntCheckbox=uicontrol(fig,'Style',             'checkbox', ...
    'Parent',            imageViewPanel, ...
    'BackgroundColor',   [0.94, 0.94, 0.94], ...
    'String',            'Automatic Intensity', ...
    'Value',             1, ...
    'Position',          [40 5 120 20], ...
    'Callback',          @toggleAutoInt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Image Information UI Panel                             %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

imageInfoPanel=uipanel('Title',                'Image Info', ...
    'FontSize',          11, ...
    'BackgroundColor',   [0.94, 0.94, 0.94], ...
    'Units',             'Pixels', ...
    'Position',          [10 10 200 265]);

imageInfoText=uicontrol(fig,'Style',               'text', ...
    'Parent',              imageInfoPanel, ...
    'BackgroundColor',     [1 1 1], ...
    'String',              ['TR:' char(10) 'TE:' char(10) 'TI:' char(10) 'Flip Angle:'], ...
    'Units',               'Pixels', ...
    'HorizontalAlignment', 'Left', ...
    'FontSize',            9, ...
    'Position',            [8 10 180 227]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Region of Interest UI Panel                            %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

roiPanel=uipanel('Title', 'ROI', ...
    'FontSize',          11, ...
    'BackgroundColor',   [0.94, 0.94, 0.94], ...
    'Units',             'Pixels', ...
    'Position', [830 305 200 275]);

polygonRoiButton=uicontrol(fig,'Style',          'pushbutton', ...
    'Parent',          roiPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          'Draw Polygon ROI', ...
    'Units',           'Pixels', ...
    'Position',        [10 215 175 30], ...
    'Enable',          'off', ...
    'Callback',        @drawPolygonRoi);

threshRoiButton=uicontrol(fig,'Style',          'pushbutton', ...
    'Parent',          roiPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          'Select Threshold ROI', ...
    'Units',           'Pixels', ...
    'Position',        [10 185 175 30], ...
    'Enable',          'off', ...
    'Callback',        @createThresholdRoi);

deleteRoiButton=uicontrol(fig,'Style',          'pushbutton', ...
    'Parent',          roiPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          'Delete ROI', ...
    'Units',           'Pixels', ...
    'Position',        [10 155 175 30], ...
    'Enable',          'off', ...
    'Callback',        @deleteRoi);

showRoiCheckbox=uicontrol(fig,'Style',             'checkbox', ...
    'Parent',            roiPanel, ...
    'BackgroundColor',   [0.94, 0.94, 0.94], ...
    'String',            'Show ROI', ...
    'Value',             1, ...
    'Position',          [62 130 75 20], ...
    'Enable',            'off', ...
    'Callback',          @updateImage);

alphaEdit=uicontrol(fig,'Style',           'edit', ...
    'Parent',          roiPanel, ...
    'String',          '0.5', ...
    'BackgroundColor', [1 1 1], ...
    'Units',           'Pixels', ...
    'Enable',          'on', ...
    'Position',        [120 108 50 20], ...
    'Enable',          'off', ...
    'Callback',        @updateImage);


alphaLabel=uicontrol(fig,'Style',              'text', ...
    'Parent',             roiPanel, ...
    'BackgroundColor',    [0.94, 0.94, 0.94], ...
    'String',             'ROI Transparency:', ...
    'Units',              'Pixels', ...
    'Position',           [20 106 100 20]);

roiLabel=uicontrol(fig,'Style',              'text', ...
    'Parent',             roiPanel, ...
    'BackgroundColor',    [0.94, 0.94, 0.94], ...
    'FontSize',           10, ...
    'String',             'ROI Information:', ...
    'Units',              'Pixels', ...
    'HorizontalAlignment','Left', ...
    'Position',           [10 76 104 20]);

roiInfoText=uicontrol(fig,'Style',               'text', ...
    'Parent',              roiPanel, ...
    'BackgroundColor',     [.92 .92 .92], ...
    'String',              ['Mean:' char(10) 'Median:' char(10) 'Standard dev:'], ...
    'Units',               'Pixels', ...
    'HorizontalAlignment', 'Left', ...
    'FontSize',            9, ...
    'Position',            [10 6 175 70]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Data Analysis UI Panel                                 %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

analysisPanel=uipanel('Title', 'Analysis', ...
    'FontSize',          11, ...
    'BackgroundColor',   [0.94, 0.94, 0.94], ...
    'Units',             'Pixels', ...
    'Position', [830 82 200 217]);

drawProfileButton=uicontrol(fig,'Style',           'pushbutton', ...
    'Parent',          analysisPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          'Draw Profile', ...
    'Units',           'Pixels', ...
    'Position',        [10 160 175 30], ...
    'Enable',          'off', ...
    'Callback',        @drawProfile);

plotRoiButton=uicontrol(fig,'Style',           'pushbutton', ...
    'Parent',          analysisPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          'Plot ROI Mean Intensities', ...
    'Units',           'Pixels', ...
    'Position',        [10 130 175 30], ...
    'Enable',          'off', ...
    'Callback',        @plotRoi);

exportROIButton=uicontrol(fig,'Style',        'pushbutton', ...
    'Parent',          analysisPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          'Export ROI Data to MATLAB', ...
    'Units',           'Pixels', ...
    'Position',        [10 100 175 30], ...
    'Enable',          'off', ...
    'Callback',        @exportData);

t2AnalysisButton=uicontrol(fig,'Style',        'pushbutton', ...
    'Parent',          analysisPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          'T2 Calculation of ROI', ...
    'Units',           'Pixels', ...
    'Position',        [10 70 175 30], ...
    'Enable',          'off', ...
    'Callback',        @calcT2);

t1AnalysisButton=uicontrol(fig,'Style',        'pushbutton', ...
    'Parent',          analysisPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          'T1 Calculation of ROI', ...
    'Units',           'Pixels', ...
    'Position',        [10 40 175 30], ...
    'Enable',          'off', ...
    'Callback',        @calcT1);

saveImageButton=uicontrol(fig,'Style',        'pushbutton', ...
    'Parent',          analysisPanel, ...
    'BackgroundColor', [0.94, 0.94, 0.94], ...
    'String',          'Save Image as PNG', ...
    'Units',           'Pixels', ...
    'Position',        [10 10 175 30], ...
    'Enable',          'off', ...
    'Callback',        @saveCurrentImage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Callback Functions                                     %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function addImage(~,~)
        
        [filename, pathname] = uigetfile({'*.dcm;*.dicom;*.ima', 'DICOM files (*.dcm, *.dicom, *.ima)'; ...
            '*.*',                 'All Files (*.*)'}, ...
            'Browse to DICOM file', ...
            pathname);
        if(filename == 0)
            if(isdeployed)
                baseDir = pwd;
                cd(ctfroot);
            end
            return;
        end
        
        dcmExt = getext(filename);
        dcmFileListing = dir(pathname);
        fileList = [];
        for ii = 3:numel(dcmFileListing)
            if(strcmp(getext(dcmFileListing(ii).name), dcmExt))
                fileList(numel(fileList)+1).name = dcmFileListing(ii).name;
            end
        end
        
        if(numel(dcmFileListing) > 1)
            importAllAnswer = questdlg('Import all images in this directory?', 'Import all?', 'Yes', 'No', 'Yes');
            if(strcmp(importAllAnswer, 'No'))
                fileList = [];
                fileList.name = filename;
            end
        end
        
        for ii = 1:numel(fileList)
            if(tempImage)
                clear('IM');
                clear('hdr');
                hdr(1) = dicominfo([pathname fileList(ii).name]);
                IM(:,:,1)=dicomread([pathname fileList(ii).name]);
                set(imageNumberEdit, 'String', '1', 'Enable', 'on');
                tempImage=false;
                set(maxIntSlider,      'Value',  max(IM(:)));
                set(minIntSlider,      'Value',  min(IM(:)));
                set(polygonRoiButton,  'Enable', 'on'      );
                set(threshRoiButton,   'Enable', 'on'      );
                set(drawProfileButton, 'Enable', 'on');
                set(saveImageButton,   'Enable', 'on');
                curImage = 1;
            else
                hdr = [hdr(1:curImage) dicominfo([pathname fileList(ii).name]) hdr(curImage+1:end)];
                IM = cat(3,IM(:,:,1:curImage), dicomread([pathname fileList(ii).name]), IM(:,:,curImage+1:end));
                curImage=curImage+1;
                set(removeImageButton,  'Enable', 'on');
                set(goToFirstImageButton, 'Enable', 'on');
                set(goToLastImageButton, 'Enable', 'on');
                set(sortImagesPulldown, 'Enable', 'on');
                set(polygonRoiButton,   'Enable', 'on');
                set(threshRoiButton,    'Enable', 'on');
            end
        end
        globalIntMax = max(IM(:));                %Update global image intensities
        globalIntMin = min(IM(:));
        set(maxIntSlider, 'Max', globalIntMax);   %Update slider ranges based on new global ranges
        set(maxIntSlider, 'Min', 0);              %
        set(minIntSlider, 'Max', globalIntMax);   %
        set(maxIntSlider, 'Min', 0);              %
        numImages = uint16(size(IM,3));
        set(imageNumberEdit, 'String', int2str(curImage));
        if(curImage == numImages)
            set(imageIncrementButton, 'Enable', 'off');
        end
        if(curImage > 1)
            set(imageDecrementButton, 'Enable', 'on');
        end
        updateImage;
    end


    function updateImage(~,~)
        
        if(get(autoIntCheckbox, 'Value'))
            curIntMax = max(max(IM(:,:,curImage)));
            curIntMin = min(min(IM(:,:,curImage)));
            set(maxIntEdit, 'String', int2str(curIntMax));
            set(minIntEdit, 'String', int2str(curIntMin));
        end
        imshow(IM(:,:,curImage), [curIntMin curIntMax]) %, colormap(cmap);
        set(gca, 'Units', 'Pixels', ...
            'Position', [230 30 550 550], ...
            'Visible', 'off');
        if((~isempty(roi)) && get(showRoiCheckbox, 'Value'))  %overlay ROI if it exists
            
            roi=double(roi);
            strAlpha = get(alphaEdit, 'String');
            alpha = str2num(strAlpha);
            if((alpha>1) || (alpha<0))
                set(alphaEdit, 'String', '0.5')
                alpha = 0.5;
            end
            roi3 = cat(3, roi, ...
                double(zeros(size(IM,1), size(IM,2))), ...
                double(zeros(size(IM,1), size(IM,2))));
            hold on;
            roiHandle = imshow(roi3);
            set(roiHandle, 'AlphaData', alpha*roi);
            hold off;
        end
        displayHeaderInfo;
        colorbarHandle = colorbar;
        if(numel(roi)>0)
            logicalROI = logical(roi);
            temp=double(IM(:,:,curImage));
            roiMean   = num2str(mean(temp(logicalROI)));
            roiMedian = num2str(median(temp(logicalROI)));
            roiSTD    = num2str(std(temp(logicalROI)));
            set(roiInfoText, 'String', ...
                ['Mean: ' roiMean char(10) 'Median: ' roiMedian char(10) 'Standard dev: ' roiSTD char(10) 'Size: ' num2str(numel(find(roi))) ' pixels'], ...
                'BackgroundColor', [1 1 1]);
        else
            set(roiInfoText, 'String', ['Mean:' char(10) 'Median:' char(10) 'Standard dev:' char(10) 'Size:'], ...
                             'BackgroundColor', [0.92 0.92 0.92]);
        end
    end

    function incrementImage(~,~)
        curImage = curImage+1;
        if(curImage == numImages)
            set(imageIncrementButton, 'Enable', 'off');
        end
        set(imageDecrementButton, 'Enable', 'on');
        set(imageNumberEdit, 'String', int2str(curImage));
        updateImage;
    end

    function goToLastImage(~,~)
        curImage = numImages;
        set(imageIncrementButton, 'Enable', 'off');
        set(imageDecrementButton, 'Enable', 'on');
        set(imageNumberEdit, 'String', int2str(curImage));
        updateImage;
    end

    function decrementImage(~,~)
        curImage = curImage-1;
        if(curImage == 1)
            set(imageDecrementButton, 'Enable', 'off');
        end
        set(imageIncrementButton, 'Enable', 'on');
        
        set(imageNumberEdit, 'String', int2str(curImage));
        updateImage;
    end

function goToFirstImage(~,~)
        curImage = 1;
        set(imageIncrementButton, 'Enable', 'on');
        set(imageDecrementButton, 'Enable', 'off');
        set(imageNumberEdit, 'String', int2str(curImage));
        updateImage;
    end

    function imageNumberSet(~,~)
        if(uint16(str2double(get(imageNumberEdit, 'String')))>numImages)
            set(imageNumberEdit, 'String', int2str(curImage));
        elseif(uint16(str2double(get(imageNumberEdit, 'String')))<1)
            set(imageNumberEdit, 'String', int2str(curImage));
        else
            curImage = uint16(str2double(get(imageNumberEdit, 'String')));
        end
        if(curImage == 1)
            set(imageDecrementButton, 'Enable', 'off');
            if(numImages>1)
                set(imageIncrementButton, 'Enable', 'on');
            end
        end
        if(curImage == numImages)
            set(imageIncrementButton, 'Enable', 'off');
            if(numImages>1)
                set(imageDecrementButton, 'Enable', 'on');
            end
        end
        updateImage;
    end


    function toggleAutoInt(~,~)
        
        if(get(autoIntCheckbox, 'Value'))
            set(maxIntSlider, 'Enable', 'off');
            set(minIntSlider, 'Enable', 'off');
            set(maxIntEdit  , 'Enable', 'off');
            set(minIntEdit  , 'Enable', 'off');
        else
            set(maxIntSlider, 'Enable', 'on');
            set(minIntSlider, 'Enable', 'on');
            set(maxIntEdit  , 'Enable', 'on');
            set(minIntEdit  , 'Enable', 'on');
        end
        updateImage;
        
    end


    function changeMaxIntSlider(~,~)
        
        if(get(maxIntSlider, 'Value') < get(minIntSlider, 'Value'))
            set(maxIntSlider, 'Value', curIntMax);
        else
            curIntMax = floor(get(maxIntSlider, 'Value'));
            set(maxIntEdit, 'String', int2str(curIntMax));
        end
        updateImage;
        
    end


    function changeMinIntSlider(~,~)
        
        if(get(minIntSlider, 'Value') > get(maxIntSlider, 'Value'))
            set(minIntSlider, 'Value', curIntMin);
        else
            curIntMin = ceil(get(minIntSlider, 'Value'));
            set(minIntEdit, 'String', int2str(curIntMin));
        end
        updateImage;
        
    end


    function changeMaxIntEdit(~,~)
        
        if((str2double(get(maxIntEdit, 'String')) < str2double(get(minIntEdit, 'String'))) ...
                || isempty(str2double(get(maxIntEdit, 'String'))))
            set(maxIntEdit, 'String', num2str(round(curIntMax)));
        else
            curIntMax = floor(uint16(str2double(get(maxIntEdit, 'String'))));
            set(maxIntSlider, 'Value', curIntMax);
        end
        updateImage;
        
    end


    function changeMinIntEdit(~,~)
        
        if((str2double(get(minIntEdit, 'String')) > str2double(get(maxIntEdit, 'String'))) ...
                || isempty(str2double(get(minIntEdit, 'String'))))
            set(minIntEdit, 'String', num2str(round(curIntMin)));
        else
            curIntMin = ceil(uint16(str2double(get(minIntEdit, 'String'))));
            set(minIntSlider, 'Value', curIntMin);
        end
        updateImage;
        
    end


    function displayHeaderInfo(~,~)
        
        str = ['Subject: '         hdr(curImage).PatientID               char(10) ...
            'Series: '          hdr(curImage).SeriesDescription       char(10) ...
            'Date: '    num2str(hdr(curImage).StudyDate)              char(10) ...
            'TR: '      num2str(hdr(curImage).RepetitionTime)   ' ms' char(10) ...
            'TE: '      num2str(hdr(curImage).EchoTime)         ' ms' char(10)];
        
        if(isfield(hdr, 'InversionTime'))
            str = [str 'TI: ' num2str(hdr(curImage).InversionTime*1000) ' ms' char(10)];
        end
        if(isfield(hdr, 'EchoNumber'))
            str = [str 'Echo #: ' num2str(hdr(curImage).EchoNumber)      char(10) ...
                'ETL: '    num2str(hdr(curImage).EchoTrainLength) char(10)];
        end
        
        str = [str ...
            'Flip: '         num2str(hdr(curImage).FlipAngle)      ' degrees'      char(10) ...
            'Thickness: '    num2str(hdr(curImage).SliceThickness) ' mm'           char(10) ...
            'Position: '     num2str(hdr(curImage).SliceLocation)  ' mm'           char(10) ...
            'PE Direction: '         hdr(curImage).InPlanePhaseEncodingDirection   char(10) ...
            'Pixel RBW: '    num2str(hdr(curImage).PixelBandwidth) ' Hz'           char(10) ...
            'Matrix: '       num2str(hdr(curImage).Width)          ' x '                    ...
            num2str(hdr(curImage).Height)                         char(10) ...
            'NEX: '         num2str(hdr(curImage).NumberOfAverages)];
        
        set(imageInfoText, 'String', str);
        
    end


    function removeImage(~,~)
        
        if(curImage == 1)
            IM = IM(:,:,2:end);
            hdr = hdr(2:end);
        else
            IM = circshift(IM, [0 0 -curImage]);
            IM = IM(:,:,1:numImages-1);
            IM = circshift(IM, [0 0 curImage-1]);
            
            hdr = [hdr(1:curImage-1) hdr(curImage+1:end)];
        end
        
        if(curImage == numImages)
            curImage = numImages-1;
            set(imageIncrementButton, 'Enable', 'off');
            set(imageNumberEdit, 'String', curImage);
        end
        numImages = numImages-1;
        if(numImages == 1)
            set(removeImageButton,    'Enable', 'off');
            set(imageDecrementButton, 'Enable', 'off');
            set(sortImagesPulldown,   'Enable', 'off');
        end
        if(curImage == numImages)
            set(imageIncrementButton, 'Enable', 'off');
        end
        updateImage;
        
    end

    function sortImages(~,~)
        
        switch(get(sortImagesPulldown, 'Value'))
            case 1
                
                return
                
            case 2 %TR
                
                [~,sortedIDX] = sort([hdr.RepetitionTime]);
                
            case 3 %TE
                
                [~,sortedIDX] = sort([hdr.EchoTime]);
                
            case 4 %Flip
                
                [~,sortedIDX] = sort([hdr.FlipAngle]);
                
            case 5 %Slice position
                
                [~,sortedIDX] = sort([hdr.SliceLocation]);
                
            case 6 %Bandwidth
                
                [~,sortedIDX] = sort([hdr.PixelBandwidth]);
                
        end
        
        IM = IM(:,:,sortedIDX);
        hdr = hdr(sortedIDX);
        updateImage;
        
    end


    function drawPolygonRoi(~,~)
        
        roi = roipoly;
        set(deleteRoiButton, 'Enable', 'on');
        set(showRoiCheckbox, 'Enable', 'on');
        set(alphaEdit,       'Enable', 'on');
        set(plotRoiButton,   'Enable', 'on');
        if(numImages > 1)
            set(exportROIButton, 'Enable', 'on');
            set(t2AnalysisButton, 'Enable', 'on');
            set(t1AnalysisButton, 'Enable', 'on');
        end
        updateImage;
        
    end


    function createThresholdRoi(~,~)
        
        thresh=inputdlg({'Enter minimum threshold ROI value (% of max)'}, ...
            'Theshold ROI', ...
            1, ...
            {'75'});
        thresh = str2double(thresh)/100;
        if((thresh<0.01) || (thresh>99.99) || isnan(thresh) || isempty(thresh))
            return;
        end
        temp = IM(:,:,curImage);
        roi = temp>thresh*double(max(temp(:)));
        clear temp;
        set(deleteRoiButton, 'Enable', 'on');
        set(showRoiCheckbox, 'Enable', 'on');
        set(alphaEdit,       'Enable', 'on');
        set(plotRoiButton,   'Enable', 'on');
        if(numImages > 1)
            set(exportROIButton, 'Enable', 'on');
            set(t2AnalysisButton, 'Enable', 'on');
            set(t1AnalysisButton, 'Enable', 'on');
        end
        updateImage;
        
    end


    function deleteRoi(~,~)
        
        roi = [];
        %set(polygonRoiButton, 'Enable', 'on');   %probably not needed
        %set(threshRoiButton,  'Enable', 'on');   % <----
        set(deleteRoiButton,  'Enable', 'off');
        set(showRoiCheckbox,  'Enable', 'off');
        set(alphaEdit,        'Enable', 'off');
        set(plotRoiButton,    'Enable', 'off');
        set(exportROIButton, 'Enable', 'off');
        set(t2AnalysisButton, 'Enable', 'off');
        set(t1AnalysisButton, 'Enable', 'off');
        set(roiInfoText, 'string', ['Mean:' char(10) 'Median:' char(10) 'Standard dev:'], ...
                         'BackgroundColor', [.92 .92 .92]);
        updateImage;
        
    end


    function drawProfile(~,~)
        
        set(showRoiCheckbox, 'Value', 0);
        updateImage;
        if(exist('proFig', 'var'))
            close(proFig);
        end
        [px, py, pro] = improfile;
        set(showRoiCheckbox, 'Value', 1);
        updateImage;
        dx = abs(px(1)-px(end))*hdr(1).PixelSpacing(1);
        dy = abs(py(1)-py(end))*hdr(1).PixelSpacing(2);
        distance = sqrt( dx^2 + dy^2 );
        xDim = 0:distance/(numel(px)-1):distance;
        proFig = figure;
        plot(xDim, pro);
        title('User-Drawn Profile', 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Distance along profile (mm)', 'FontSize', 12);
        ylabel('Image intensity (a.u.)', 'FontSize', 12);
        
    end


    function plotRoi(~,~)
        
        logicalROI = logical(roi);
        for ii = 1:size(IM,3)
            temp=double(IM(:,:,ii));
            value(ii) = mean(temp(logicalROI));
            bar(ii)   = std(temp(logicalROI));
        end
        clear temp
        datFig = figure;
        errorbar(1:ii, value, bar, '-bo');
        set(gca, 'XTick', 1:ii);
        title('ROI Data', 'FontSize', 12, 'FontWeight', 'bold');
        xlabel('Image Number', 'FontSize', 12);
        ylabel('Mean ROI Intensity (a.u.)', 'FontSize', 12);
        
    end


    function exportData(~, ~)
        
        logicalROI = logical(roi);
        for ii = 1:size(IM,3)
            temp=double(IM(:,:,ii));
            ROI_data(ii).mean_signal = mean(temp(logicalROI));
            ROI_data(ii).TE = hdr(ii).EchoTime/1000;
            ROI_data(ii).TR = hdr(ii).RepetitionTime/1000;
            ROI_data(ii).flip = hdr(ii).FlipAngle;
        end
        ROI_data(1).units = 'mean_signal->a.u., TE->seconds, TR->seconds, flip->degrees';
        
        assignin('base', 'ROI_data', ROI_data);
    end


    function calcT2(~,~)
        
        logicalROI = logical(roi);
        for ii = 1:size(IM,3)
            temp=double(IM(:,:,ii));
            decay(ii) = mean(temp(logicalROI));
            bar(ii)=std(temp(logicalROI));
            TE(ii) = hdr(ii).EchoTime/1000;
        end
        clear temp
        options=statset('FunValCheck', 'off');
        guesses=[max(decay), 0.2, 0.0];
        [beta, R]=nlinfit(TE, decay, @t2model, guesses, options);
        TERange = 0.07*(TE(end)-TE(1));
        modelTE = TE(1)-TERange:(TE(end)-TE(1)+(2*TERange))/99:TE(end)+TERange;
        modelS = t2model(beta, modelTE);
        
        t2Fig = figure;
        errorbar(TE, decay, bar, 'bo');
        hold on;
        plot(modelTE, modelS, '-r');
        hold off;
        legend('ROI Data Points', ['Fitted Curve' char(10) 'of T_2 =' num2str(beta(2)) ' s'], 'Location', 'NorthEast');
        title('T_2 Measurement', 'FontSize', 14, 'FontWeight', 'bold');
        xlabel('TE (s)', 'FontSize', 12);
        ylabel('ROI Mean Intensity (a.u.)', 'FontSize', 12);
        
        
    end


    function Y = t2model(beta, X)
        
        Y = beta(1).*exp(-X/beta(2))+beta(3);
        
    end

    function calcT1(~,~)
        
        logicalROI = logical(roi);
        for ii = 1:size(IM,3)
            temp=double(IM(:,:,ii));
            decay(ii) = mean(temp(logicalROI));
            bar(ii)=std(temp(logicalROI));
            flip(ii) = hdr(ii).FlipAngle;
            flipRadians(ii) = flip(ii)*pi/180;
        end
        disp(flipRadians);
        disp(decay);
        clear temp
        options=statset('FunValCheck', 'off');
        guesses=[4*(min(decay)+((max(decay)-min(decay))/2)), .75, 100];
        [betaPar, R]=nlinfit(flipRadians, decay, @t1flipmodel, guesses, options);
        flipRange = 0.07*(flipRadians(end)-flipRadians(1));
        modelFlip = flipRadians(1)-flipRange:(flipRadians(end)-flipRadians(1)+(2*flipRange))/99:flipRadians(end)+flipRange;
        modelS = t1flipmodel(betaPar, modelFlip);
        
        t1Fig = figure;
        errorbar(flipRadians, decay, bar, 'bo');
        hold on;
        plot(modelFlip, modelS, '-r');
        hold off;
        legend('ROI Data Points', ['Fitted Curve' char(10) 'of T_1 =' num2str(betaPar(2)) ' s'], 'Location', 'NorthEast');
        title('T_1 Measurement', 'FontSize', 14, 'FontWeight', 'bold');
        xlabel('flip angle (rad)', 'FontSize', 12);
        ylabel('ROI Mean Intensity (a.u.)', 'FontSize', 12);
        
        
    end

    function Y = t1flipmodel(betaPar, X)
        TR = hdr(1).RepetitionTime/1000;
        %Y = (beta(1)*(1 - exp(-TR/beta(2)))*sin(X)./(1-cos(X)*exp(-TR/beta(2))))+beta(3);
        Y = betaPar(1)*((sin(X)*(1-exp(-TR/betaPar(2)))) ./ (1 - (cos(X)*exp(-TR/betaPar(2)))))+betaPar(3);
    end

    function saveCurrentImage(~,~)
        
        axisPos = get(axisHandle, 'Position');
        axisPos(3) = axisPos(3) + 82;
        temp = getframe(fig, axisPos);
        temp = frame2im(temp);
        if(firstSave)
            warnFig=warndlg(['WARNING: Images saved this way will NOT retain quantitative ', ...
                'dynamic range.  Use these files for presentation ONLY.'], ...
                'Loss of Dynamic Range');
            uiwait(warnFig);
        end
        [imFilename, imPathname, ~] = uiputfile('*.png', 'Save image as PNG');
        if(imFilename == 0)
            return;
        end
        if(strcmpi(imFilename(end-3:end), '.png'))
            imFilename(end-3:end) = '.png';
        else
            imFilename = [imFilename '.png'];
        end
       imwrite(temp, [imPathname imFilename], 'PNG', ...
               'Author', 'Jeffrey Luci, Ph.D.', ...
               'Software', 'BLV v3.1, by Jeffrey Luci');
       firstSave = false;
       clear temp;
        
    end


%disp('breakpoint');
if(isdeployed)
    cd(baseDir);
end
end