function fusedImg = Pansharpening(hyperfile, rgbfile, tformfile)
%Pan-sharpening method
%PCA based, the PC1 is replaced by the gray Nikon image
%Jie Liang
%2015-4-21
addpath(genpath('E:\Matlab\tools\drtoolbox'));
dataCube = importdata(hyperfile);
% resize hyperspectral image and extract a clear slice;
dataCube = dataCube(:,:,11:10:end-9);% 1000, 1100, 1200, 1300, 1400, 1500, 1600 nm
[~, ~, b] = size(dataCube);
focus = zeros(b,1);
for i=1:b
    slice = squeeze(dataCube(:,:,i));
    focus(i) = fmeasure(slice, 'GDER',[]);   
end
[~,index] = max(focus);
anchor = squeeze(dataCube(:,:,index));
anchor = imadjust(anchor);
anchor = imresize(anchor, 4);
dataCube = imresize(dataCube, 4);
img = imread(rgbfile);
img = rgb2gray(img);
tform = importdata(tformfile);
register = imwarp(img, tform, 'OutputView', imref2d(size(anchor)));
figure, imshowpair(anchor, register, 'diff');

load('rect.mat');
Pan = register(round(rect(2)):round(rect(2)+rect(4)-1),round(rect(1)):round(rect(1)+rect(3)-1),:);
HI =  dataCube(round(rect(2)):round(rect(2)+rect(4)-1),round(rect(1)):round(rect(1)+rect(3)-1),:);
HI = normalise(HI, '',0.999);
HI = uint8(HI*255);

clear dataCube;
%PCA-based Pansharpenning
HI = double(HI);
Pan = double(Pan);
[m, n, b] = size(HI);
HI = reshape(HI, [m*n,b]);

%pca transform on ms bands
[PCAData, PCAMap] = pca(HI,b);
PCAData = reshape(PCAData, [m,n,b]); 
figure, imshow(PCAData(:,:,1), []);
clear HI,

Pan=(Pan-mean(Pan(:)))*std(PCAData(:))/std(Pan(:)) + mean(PCAData(:));
PCAData(:,:,1) = Pan;

vPCAData = reshape(PCAData, [m*n, b]);
M = repmat(PCAMap.mean, [ m*n,1]);
F =(vPCAData*transpose(PCAMap.M))+ M;
Pansharp = reshape(F, [m, n, b]);
Pansharp = normalise(Pansharp, '', 0.999);
fusedImg = uint8(Pansharp*255);
figure, imshow(Pansharp(:,:,3), []);
clear F;







