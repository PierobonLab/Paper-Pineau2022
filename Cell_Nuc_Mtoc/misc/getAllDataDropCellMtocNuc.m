% call
%   list=dir('Final.txt');
%   data=getAllDataDropCellMtocNuc(list);

function data=getAllDataDropCellMtocNuc(list)

for i=1:length(list)
    data(i).name=list(i).name;
    data(i).folder=list(i).folder;
    fn=data(i).name;
    i
    [VarName1,data(i).x0,data(i).y0,data(i).z0,data(i).V0,...
        data(i).x1,data(i).y1,data(i).z1,data(i).V,R1,R2,R3,XY0,XZ0,YZ0,...
        data(i).xDrop,data(i).yDrop,data(i).zDrop,data(i).Rmean, R1Drop,R2Drop,R3Drop,...
        left,right,ratio,data(i).xNuc,data(i).yNuc,data(i).zNuc,data(i).VNuc,R1Nuc,R2Nuc,R3Nuc,XY0Nuc,XZ0Nuc,YZ0Nuc,XY1Nuc,XZ1Nuc,YZ1Nuc,...
         data(i).MeanDist,data(i).Xcen,data(i).Ycen,data(i).Zcen] = DropCellMtocNucIMPORTFILE([list(i).folder '/' fn]);
    fn1=[fn(1:end-14) '.tif_nuc_NucDropShape.mat'];
    nuc=getNUC(fn1);
    data(i).nucSh=nuc.nucSh;
    data(i).dropSh=nuc.dropSh;
    data(i).comp=nuc.comp;
    data(i).flagdone=0;
    
end


end


function data=getNUC(fn)
a=load(fn);
data.nucSh=a.nucSh;
data.dropSh=a.dropSh;
data.comp=a.data;
end



function [VarName1,x0,y0,z0,V0,x,y,z,V,R1,R2,R3,XY0,XZ0,YZ0,xDrop,yDrop,zDrop,Rmean,R1Drop,R2Drop,R3Drop,...
    left,right,ratio,xNuc,yNuc,zNuc,VNuc,R1Nuc,R2Nuc,R3Nuc,XY0Nuc,XZ0Nuc,YZ0Nuc,XY1Nuc,XZ1Nuc,YZ1Nuc,...
    MeanDist,Xcen,Ycen,Zcen] = DropCellMtocNucIMPORTFILE(filename, startRow, endRow)

%IMPORTFILE Import numeric data from a text file as column vectors.
% Auto-generated by MATLAB on 2021/09/09 01:57:04

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 2;
    endRow = inf;
end

%% Format for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: double (%f)
%   column9: double (%f)
%	column10: text (%s)
%   column11: text (%s)
%	column12: text (%s)
%   column13: text (%s)
%	column14: text (%s)
%   column15: text (%s)
%	column16: double (%f)
%   column17: double (%f)
%	column18: double (%f)
%   column19: text (%s)
%	column20: double (%f)
%   column21: double (%f)
%	column22: double (%f)
%   column23: double (%f)
%	column24: double (%f)
%   column25: double (%f)
%	column26: double (%f)
%   column27: double (%f)
%	column28: double (%f)
%   column29: double (%f)
%	column30: double (%f)
%   column31: double (%f)
%	column32: double (%f)
%   column33: double (%f)
%	column34: double (%f)
%   column35: double (%f)
%	column36: double (%f)
%   column37: double (%f)
%	column38: double (%f)
%   column39: double (%f)
%	column40: double (%f)
%   column41: double (%f)
%	column42: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%f%f%f%f%f%f%s%s%s%s%s%s%f%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(block)-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
        
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
VarName1 = dataArray{:, 1};
x0 = dataArray{:, 2};
y0 = dataArray{:, 3};
z0 = dataArray{:, 4};
V0 = dataArray{:, 5};
x = dataArray{:, 6};
y = dataArray{:, 7};
z = dataArray{:, 8};
V = dataArray{:, 9};
R1 = dataArray{:, 10};
R2 = dataArray{:, 11};
R3 = dataArray{:, 12};
XY0 = dataArray{:, 13};
XZ0 = dataArray{:, 14};
YZ0 = dataArray{:, 15};
xDrop = dataArray{:, 16};
yDrop = dataArray{:, 17};
zDrop = dataArray{:, 18};
Rmean = dataArray{:, 19};
R1Drop = dataArray{:, 20};
R2Drop = dataArray{:, 21};
R3Drop = dataArray{:, 22};
left = dataArray{:, 23};
right = dataArray{:, 24};
ratio = dataArray{:, 25};
xNuc = dataArray{:, 26};
yNuc = dataArray{:, 27};
zNuc = dataArray{:, 28};
VNuc = dataArray{:, 29};
R1Nuc = dataArray{:, 30};
R2Nuc = dataArray{:, 31};
R3Nuc = dataArray{:, 32};
XY0Nuc = dataArray{:, 33};
XZ0Nuc = dataArray{:, 34};
YZ0Nuc = dataArray{:, 35};
XY1Nuc = dataArray{:, 36};
XZ1Nuc = dataArray{:, 37};
YZ1Nuc = dataArray{:, 38};
MeanDist = dataArray{:, 39};
Xcen = dataArray{:, 40};
Ycen = dataArray{:, 41};
Zcen = dataArray{:, 42};

end
