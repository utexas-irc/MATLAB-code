function decompressdcm(dirname)

if(~exist('dirname', 'var'))
    dirname = uigetdir(pwd, 'Specify DICOM Directory . . . ');
end

updir = fileparts(dirname);
outdir = fullfile(updir, 'Converted');

warning('off', 'MATLAB:MKDIR:DirectoryExists');
mkdir(outdir);

addon = '';
newsyntax = '1.2.840.10008.1.2';
createmode = 'Copy';
x = dir(dirname);
nodir = ~[x.isdir]';
x = x(nodir);
x = {x.name}';
ifile = 1;
for ifile = 1:length(x)
    name = x{ifile};
    stub = regexprep(name, '(.*)[.].*', '$1');
    stub = [stub addon '.dcm'];
    name = fullfile(dirname, name);
    stub = fullfile(outdir, stub);
    dinfo = dicominfo(name);
    dinfo.TransferSyntaxUID = newsyntax;
    X = dicomread(name);
    dicomwrite(X, stub, dinfo, 'CreateMode', createmode);
end