% Pansharpend all image
str = 'E:\Matlab\register';
addpath(str);
cd(str);
dataPath = '..\data\flower\p2';
cd(dataPath);

hyperlist = dir('hyper\*.mat');
rgblist = dir('rgb\*.jpg');
tformlist = dir('tform\*.mat');

for i = 43: min([length(hyperlist),length(rgblist),length(tformlist)])
    hyperfile = fullfile('hyper',hyperlist(i).name);
    rgbfile = fullfile('rgb',rgblist(i).name);
    tformfile = fullfile('tform',tformlist(i).name);
    fusedImg = Pansharpening(hyperfile, rgbfile, tformfile);
    filename = sprintf('%02d.mat', i);
    save(fullfile('fused',filename), 'fusedImg');
end
