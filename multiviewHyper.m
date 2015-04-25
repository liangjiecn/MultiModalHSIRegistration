function multiviewHyper
%%abstract slice from datacube and put them into different folders
str = 'E:\Matlab\register';
addpath(str);
cd(str);
dataPath = '..\data\flower\p2';
cd(dataPath);
list=dir('fused\*.mat');
for i=44:44%length(list)
    filename = fullfile('fused', list(i).name);
    mat = importdata(filename);
    num = size(mat, 3);
    for b = 1:num
        slice = mat(:,:,b);
        slice = imadjust(slice);   
        %wl = 600 + 10*(j-1);    
        imgname= regexprep(list(i).name,'.mat','.jpg', 'ignorecase');
        fullname = fullfile('multiview', num2str(b),imgname);
        imwrite(slice,fullname);    
        disp(b);
    end
end