%% init
img = rand(10,10,10);
mask = img > 0.3;

%% lesion
% a lesion is defined as an area of an image in a mask
% lesion = img .* mask

% % croped lesion
[img_box,mask_box] = lesionBox(img, mask);

% histogram of the lesion
lesion_histogram = lesionHistogram(img_box, mask_box, 0, 1, 40);

%% features 
features = [];
features = [features lesionLbpStat(mask, 1:3)];
features = [features lesionWaveletStat(img_box, mask_box, 'db1', 7)];
features = [features lesionCoocurenceStat(img_box, mask_box, [1;2;4;8],...
    [0 1 -1; 0 0 -1; 0 -1 -1; -1 0 -1; 1 0 -1; -1 1 -1; 1 -1 -1;
           -1 -1 -1; 1 1 -1; 0 1 1; 0 0 1; 0 -1 1; -1 0 1; 1 0 1; -1 1 1; 1 -1 1;
           -1 -1 1; 1 1 1; 0 1 0; 0 0 0; 0 -1 0; -1 0 0; 1 0 0; -1 1 0; 1 -1 0;
               -1 -1 0; 1 1 0]...
)];

features = [features lesion_histogram];
features = [features histogramStats(lesion_histogram)];
