function [ features ] = image_features( img, mask , type, riesz_size)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

img = double(img); 
mask = double(mask);
[img_box,mask_box] = lesionBox(img, mask);
img1 = imresize(img, [riesz_size riesz_size]); 
mask1 = img1/max(img1(:));


% histogram of the lesion
lesion_histogram = lesionHistogram(img, mask, 100, 2700, 20);

%% features 
features = [];

if (type == 1)
    
    % 8 elements (1:8)
    features = [features lesionStat(img, mask)]; % lesion statistical features

    % 20 elements (1:28)
    features = [features lesion_histogram]; % lesion histogram

    % 8 elements (1:36)
    features = [features histogramStats(lesion_histogram)];

    % 7 elements (1:43)
    features = [features lesionMoments(img, mask)];

    % 44 elements (1:87)
    features = [features lesionCoocurenceStat(img_box, mask_box, 0, 1, 10, [0 1; -1 1])];
end

% not using below:
%features = [features lesionRieszEnergies(img1, mask1, 2, 5)]; % riesz features
%features = [features lesionLbpStat(img, 2)];

% 8 elements
features = [features lesionGaborStat(img_box, mask_box, 5, 8, 39, 39, 4, 4)];

% 8 elements
features = [features lesionWaveletStat(img_box, mask_box, 'db2', 4)];

% getting NaN values for some fields in lesionCoocurance. Removing these for now. Need to debug later.
if(type==1)
    features(48:51) = [];
end


end

