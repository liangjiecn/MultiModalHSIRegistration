I1 = rgb2gray(imread('yellowstone_left.png'));
I2 = rgb2gray(imread('yellowstone_right.png'));
imshowpair(I1, I2,'montage');
title('I1 (left); I2 (right)');
figure; imshowpair(I1,I2,'ColorChannels','red-cyan');
title('Composite Image (Red - Left Image, Cyan - Right Image)');
blobs1 = detectSURFFeatures(I1, 'MetricThreshold', 2000);
blobs2 = detectSURFFeatures(I2, 'MetricThreshold', 2000);
figure; imshow(I1); hold on;
plot(blobs1.selectStrongest(30));
title('Thirty strongest SURF features in I1');
figure; imshow(I2); hold on;
plot(blobs2.selectStrongest(30));
title('Thirty strongest SURF features in I2');
[features1, validBlobs1] = extractFeatures(I1, blobs1);
[features2, validBlobs2] = extractFeatures(I2, blobs2);
indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD', ...
'MatchThreshold', 5);
matchedPoints1 = validBlobs1(indexPairs(:,1),:);
matchedPoints2 = validBlobs2(indexPairs(:,2),:);
figure; showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2);
legend('Putatively matched points in I1', 'Putatively matched points in I2');

[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'RANSAC', ...
  'NumTrials', 10000, 'DistanceThreshold', 0.1, 'Confidence', 99.99);

if status ~= 0 || isEpipoleInImage(fMatrix, size(I1)) ...
  || isEpipoleInImage(fMatrix', size(I2))
  error(['Either not enough matching points were found or '...
         'the epipoles are inside the images. You may need to '...
         'inspect and improve the quality of detected features ',...
         'and/or improve the quality of your images.']);
end

inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

figure; showMatchedFeatures(I1, I2, inlierPoints1, inlierPoints2);
legend('Inlier points in I1', 'Inlier points in I2');

[t1, t2] = estimateUncalibratedRectification(fMatrix, ...
  inlierPoints1.Location, inlierPoints2.Location, size(I2));
tform1 = projective2d(t1);
tform2 = projective2d(t2);

I1Rect = imwarp(I1, tform1, 'OutputView', imref2d(size(I1)));
I2Rect = imwarp(I2, tform2, 'OutputView', imref2d(size(I2)));

% transform the points to visualize them together with the rectified images
pts1Rect = transformPointsForward(tform1, inlierPoints1.Location);
pts2Rect = transformPointsForward(tform2, inlierPoints2.Location);

figure; showMatchedFeatures(I1Rect, I2Rect, pts1Rect, pts2Rect);
legend('Inlier points in rectified I1', 'Inlier points in rectified I2');

Irectified = cvexTransformImagePair(I1, tform1, I2, tform2);
figure, imshow(Irectified);
title('Rectified Stereo Images (Red - Left Image, Cyan - Right Image)');

