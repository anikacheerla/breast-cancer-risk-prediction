
 % layer analysis script. Can be used for regular analysis as well
 rng(10);
 format short;
 
 EXTRACT_ON = 1;                % extract texture features from the patches
 
 METHOD = 2;                    % normalization method before PCA % mapminmax when METHOD = 2. 
 PCA_ON = 1;                    % for PCA before K-maeans clustering
 KMEANSPLUS_ON = 1;             % kmeansandrew function is used. if zero, aglokmeans is used
 HS_METHOD = 5;                 % normalization method for histogram feature. 5 = no normalization. 1 = mapminmax

 DRAW_PATCHES_ON = 0;           % saves the patches overlaid on images in figures
 USE_DENSE_CLASSIFIER = 0;      % when 0, use threshold for dense/non-dense patch classification. when 1, use classifier output
 MASK_MODE = 4;                 % entire breast features

 equal_classes_on = 0;          % use only equal canse and non-cancer images for all the analysis (when this is on)
 EQUAL_TRAIN_CLASSES_ON = 1;    % train with 50-50
 extract_full_features_on = 0;  % extract features from the full image. 
 SVM_METHOD = 0;                 % don't use SVM
 
 EXTRACT_FEATURES_MODE = 4; % all the features except LBP and RIESZ
 
 % new 
 USE_SAVED_FEATURES_ON = 1; % use patch features that are saved
 USE_SAVED_LASSO = 1;  % use saved importantclusters 
 USE_SAVED_PREPROCESS = 1; % use saved proprocessing values
 
 array = [5];
 
 if (USE_SAVED_PREPROCESS) 
     load('preprocess.mat');
 else preprocessImpute;
 end
 
 % do Lasso on full images and get the importantClusters
 
 if (USE_SAVED_LASSO) 
     load('importantClusters');
 else lassoFeatures; 
 end
 
 
 
 C_holdout = cvpartition(image_cancer_class,'HoldOut', 0.25);
 C_loo = cvpartition(length(image_cancer_class),'LeaveOut');
 C_kfold = cvpartition(image_cancer_class,'Kfold', 10);
 % pick the type of cross validation
 C = C_kfold; 
 
 clear training;
             
 % rebalnce train images. Do this outside of the two for loops
 % below to fix the training and testing indices for all the
 % iterations
for j = 1:C.NumTestSets
    if (EQUAL_TRAIN_CLASSES_ON)
        temp = C.training(j);
        training(:, j) = rebalance_traintest(temp, image_cancer_class);
    else 
        training(:, j) = C.training(j);
    end

end
 
    clear performance; 
    clear gray_features; 
    clear ext_features; 
    clear ring_performance;
    clear gray_performance;
    clear unified_performance;
    clear all_performance; 
    clear dense_performance; 
    clear normal_performance;
    clear unified_scores;
    clear unified_outp;
    clear dense_scores;
    clear dense_outp;
    clear normal_scores; 
    clear normal_outp;
    gray_features = cell(numel(image_name), 1);
    ext_features = cell(numel(image_name), 1);

    
    
    
for x = 1:numel(array)
    
    N = array(x);
    
    if (USE_SAVED_FEATURES_ON)
        filename = sprintf('%s_%d','features',N);
        load(filename);
       
    else
        featureExtraction;
        filename = sprintf('%s_%d','features',N);
        save(filename);
    end
    

    % pick a subfield for doing the classification
    
        num1 = N*N+29; 
        num2 = (N*N)+99; % for gray features
        
    

        % Anika_Cheerla: ImportantCluster (which is a misnomer here - it is
        % actually important lasso indices) should be right shifted by N*N
        % to avoid selecting the gray pixels. In the patches_cell_array,
        % the first N*N are gray pixels. Then, there are 99 image features
        
        % if you want, you could also try 
        % importantClusters = [N*N+29: N*N+99] to select all extracted
        % features from 29:99 (exclusing lesion stats and lesion histogram)
        % you could also try importatClusters = [N*N+1 : N*N+99] to include
        % all extracted image features
        
        index = importantClusters+ N*N; 
        
[           ext_equal_patches_cell_array, ...
            ext_all_patches_cell_array, ...
            ext_patches_dense_cell_array, ...
            ext_patches_normal_cell_array] = subFields_v1( index,...
                                                    equal_patches_cell_array, ...
                                                    all_patches_cell_array, ...
                                                    patches_dense_cell_array, ...
                                                    patches_normal_cell_array);
                                                
         [  patches_dense_coord_array,... 
            patches_normal_coord_array]     = coordinates(  ...
                                                            all_patches_coord_array, ...                                                     
                                                            patches_dense_count, ...
                                                            patches_normal_count);
                                                        

    for y = 1:7
        
        NUM_CLUSTERS = 50+10*y
        for z = 1:7
            x
            NUM_CLUSTERS
            NUM_PCA_COMPONENTS = 10 + z
     
            
            %%%%%%%%%%%%%%% for gray features
           
             % dictionary with number of patches from each image. Use
             % all images
             all_images = ones(numel(image_name));
             [ PcaData, Dictionary, all_patches_settings ] = createDictionary( ...
                                                            all_images, ...
                                                            ext_equal_patches_cell_array, ...
                                                            equal_patches_count, ...
                                                            METHOD, ...
                                                            PCA_ON, ...
                                                            NUM_PCA_COMPONENTS, ...
                                                            KMEANSPLUS_ON, ...
                                                            NUM_CLUSTERS);
                                                        
             [ densePcaData, denseDictionary, dense_patches_settings ] = createDictionary( ...
                                                            all_images, ...
                                                            ext_patches_dense_cell_array, ...
                                                            patches_dense_count, ...
                                                            METHOD, ...
                                                            PCA_ON, ...
                                                            NUM_PCA_COMPONENTS, ...
                                                            KMEANSPLUS_ON, ...
                                                            NUM_CLUSTERS);   
                                                        
                                                        
             [ normalPcaData, normalDictionary, normal_patches_settings ] = createDictionary( ...
                                                            all_images, ...
                                                            ext_patches_normal_cell_array, ...
                                                            patches_normal_count, ...
                                                            METHOD, ...
                                                            PCA_ON, ...
                                                            NUM_PCA_COMPONENTS, ...
                                                            KMEANSPLUS_ON, ...
                                                            NUM_CLUSTERS);                                            
                                                                       
                                                    
                 [all_features] = createHistogramFeatures( ...
                                                ext_all_patches_cell_array, ...
                                                all_patches_coord_array, ...
                                                image_mask, ...
                                                all_patches_count, ...
                                                PcaData, ....
                                                Dictionary, ...
                                                all_patches_settings, ...
                                                METHOD, ...
                                                PCA_ON, ...
                                                NUM_PCA_COMPONENTS,...
                                                NUM_CLUSTERS, ...
                                                HS_METHOD );  
                                            
                                            
                   [dense_features] = createHistogramFeatures( ...
                                                ext_patches_dense_cell_array, ...
                                                patches_dense_coord_array, ...
                                                image_mask, ...
                                                patches_dense_count, ...
                                                densePcaData, ....
                                                denseDictionary, ...
                                                dense_patches_settings, ...
                                                METHOD, ...
                                                PCA_ON, ...
                                                NUM_PCA_COMPONENTS,...
                                                NUM_CLUSTERS, ...
                                                HS_METHOD );
                                            
                                            
                        [normal_features] = createHistogramFeatures( ...
                                                ext_patches_normal_cell_array, ...
                                                patches_normal_coord_array, ...
                                                image_mask, ...
                                                patches_normal_count, ...
                                                normalPcaData, ....
                                                normalDictionary, ...
                                                normal_patches_settings, ...
                                                METHOD, ...
                                                PCA_ON, ...
                                                NUM_PCA_COMPONENTS,...
                                                NUM_CLUSTERS, ...
                                                HS_METHOD );                                    
                                                                    
                                            
                                            [age_cat, ~] = normalyze(age_cat, 1);
                                            [race, ~] = normalyze(race, 1);
                                            [bmi, ~] = normalyze(bmi, 1);
                                            [cumulus_da, ~] = normalyze(cumulus_da, 1);
                                            all_features = horzcat(all_features, age_cat, bmi, sqrt(cumulus_pd));
                                            dense_features = horzcat(dense_features, age_cat, bmi, sqrt(cumulus_pd));
                                            normal_features = horzcat(normal_features, age_cat, bmi,sqrt(cumulus_pd));
                                            
     [ ~, ~, unified_performance(x,y,z,:), model_all, unified_AUC(x, y, z, :), unified_scores(x, y, z, :), unified_outp(x, y, z, :), ] = classification( training, training, ...
                                                                all_features, ...
                                                                image_cancer_class, ...
                                                                SVM_METHOD, ...
                                                                0, ...
                                                                EQUAL_TRAIN_CLASSES_ON, ...
                                                                150, ...
                                                                1, ...
                                                                dense_area_grade);
                                                                                                  
                                                            
    [ ~, ~, dense_performance(x,y,z,:), model_all, dense_AUC(x, y, z, :), dense_scores(x, y, z, :), dense_outp(x, y, z, :), ] = classification( training, training, ...
                                                                dense_features, ...
                                                                image_cancer_class, ...
                                                                SVM_METHOD, ...
                                                                0, ...
                                                                EQUAL_TRAIN_CLASSES_ON, ...
                                                                150, ...
                                                                1, ...
                                                                dense_area_grade);
                                                            
    [ ~, ~, normal_performance(x,y,z,:), model_all, normal_AUC(x, y, z, :), normal_scores(x, y, z, :), normal_outp(x, y, z, :), ]= classification( training, training, ...
                                                                normal_features, ...
                                                                image_cancer_class, ...
                                                                SVM_METHOD, ...
                                                                0, ...
                                                                EQUAL_TRAIN_CLASSES_ON, ...
                                                                150, ...
                                                                1, ...
                                                                dense_area_grade);
                                                            
        end
    end
 end
 

                                                            
    
                
        
                
         

    
       