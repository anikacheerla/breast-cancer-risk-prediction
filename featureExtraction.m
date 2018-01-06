
% Get features from the images. Creates three cell arrays as the output
% equal_patches_cell_array :    equal dense and normal patches from each
% image
% patches_dense_cell_array:     all dense patches from each image
% patches_normal_cell_array :   all normal patches from each image
% all_patches_cell_array:       all patches from each image 


% cell arrays to store the patches from each image


clear equal_patches_cell_array;
clear equal_patches_class_cell_array;

clear all_patches_cell_array;
clear all_patches_coord_array;
clear patches_dense_cell_array;
clear patches_normal_cell_array;

equal_patches_cell_array = cell(numel(image_name),1);
equal_patches_class_cell_array = cell(numel(image_name),1);

all_patches_cell_array = cell(numel(image_name),1);
all_patches_coord_array = cell(numel(image_name),1);
all_patches_class_array = cell(numel(image_name),1);

patches_dense_cell_array = cell(numel(image_name),1);
patches_normal_cell_array = cell(numel(image_name),1);
image_mask = cell(numel(image_name),1);

equal_patches_count = zeros(numel(image_name),1);
patches_dense_count = zeros(numel(image_name),1);
patches_normal_count = zeros(numel(image_name),1);
all_patches_count = zeros(numel(image_name),1);

dense_area_grade = zeros(numel(image_name), 1);
nan_array = zeros(numel(image_name), 1);

equal_classes_on = 0;

clear full_image_features; 
clear dense_image_features; 
clear normal_image_features;

if(equal_classes_on) % this mode is not used. In this mode, only equal number of cancer and non-cancer are kept in the data set and rest are discarded
    num_cancer = sum(image_cancer_class); 
    normal_indices = find(~image_cancer_class); 
    cancer_indices = find(image_cancer_class);
    remove_index = datasample(normal_indices, ...
                            (length(image_cancer_class) - 2*num_cancer), ...
                            'replace', false);
    image_cancer_class(remove_index) = [];
    image_class(remove_index) = [];
    image_name(remove_index) = [];
    % also need to remove these from age_cat, mens_status and race. 
end



for i = 1:numel(image_name)
    
        image = char(image_name(i));  
        I = dicomread(image);    
        I = imresize(I, 0.25);
        i

        %breast mask
        bw = I/(max(I(:)));
              
        %dense area
        da = imquantize(I,thresh(i));
        da = da-1;
        
        dense_area = sum(sum(da));
        breast_area = sum(sum(bw));
        
        if (dense_area/breast_area > 0.75)
            dense_area_grade(i) = 4;
        elseif (dense_area/breast_area > 0.5) 
            dense_area_grade(i) = 3;
        elseif (dense_area/breast_area > 0.25) 
            dense_area_grade(i) = 2;
        else dense_area_grade(i) = 1;
        end
        
            
               
        % extract features from the full image as well
        if(extract_full_features_on)
            normal_mask = ~da & bw;
           
            riesz_size = 256;
            full_image_features(i, :) = image_features(I, bw, 1, riesz_size); 

            if(sum(sum(normal_mask)) ~= 0)
            normal_image_features(i, :) = image_features(I, normal_mask, 1, riesz_size); 
            else 
            normal_image_features(i, :) = zeros(1, 99);
            display('err')
            end
        end
        
       
        % clear the arrays before creating the patches for each image so
        % previous size does not stick around
        
        clear patch; 
        clear patch2; 
        clear patch_classification
        clear patch2Coordinates;
        clear densePatch; 
        clear normalPatch;
        clear counter;
        clear normal_counter;
        clear dense_counter;
        
        
        % extracting patches
        [   patch, ...
            patch_classification, ...
            counter, ...
            densePatch, ...
            dense_counter, ...
            normalPatch, ...
            normal_counter, ...
            patch2, ...
            patch2Coordinates, ...
            image_mask{i}, patch2Class] = extractPatches_equal(I,...
                                                        N, ...
                                                        thresh(i), ...
                                                        EXTRACT_FEATURES_MODE, ...
                                                        DRAW_PATCHES_ON, ...
                                                        MASK_MODE, ...
                                                        USE_DENSE_CLASSIFIER,[] ...
                                                        );
        
        [temp1, temp1] = find(isnan(densePatch));
        if(numel(temp1) ~= 0) nan_array(i) = 1;
            i
           
        end
        
        patches_dense_cell_array{i} = densePatch;
        patches_normal_cell_array{i} = normalPatch;
        equal_patches_cell_array{i} = patch;
        all_patches_cell_array{i} = patch2;
        all_patches_coord_array{i} = patch2Coordinates;
        all_patches_class_array{i} = patch2Class; 
        
        equal_patches_class_cell_array{i} = patch_classification;
        equal_patches_count(i) = counter;
        patches_dense_count(i) = dense_counter;
        patches_normal_count(i) = normal_counter; 
        all_patches_count(i) = dense_counter + normal_counter;
      
        
end
        

%%% make the cancer and non-cancer the same number

all_patches_count = patches_dense_count + patches_normal_count;

% Below mostly for debug
sum_patches_count = 0;
sum_dense_patches_count = 0;
sum_normal_patches_count = 0;

for i = 1:numel(equal_patches_cell_array)
    sum_patches_count  = patches_dense_count(i) + patches_normal_count(i);
    if (equal_patches_count(i) ~= 0) 
        sum_normal_patches_count = sum_normal_patches_count + sum(~equal_patches_class_cell_array{i});
    end
    
    
    if (equal_patches_count(i) ~= 0) 
        sum_dense_patches_count = sum_dense_patches_count + sum(equal_patches_class_cell_array{i});
    end
    
end

average_patches_in_an_image = sum_patches_count/numel(image_name);



        
         
           
