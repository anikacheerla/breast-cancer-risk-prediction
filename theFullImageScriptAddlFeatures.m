
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
 SVM_METHOD = 0                 % don't use SVM
 
 EXTRACT_FEATURES_MODE = 4; % all the features except LBP and RIESZ
 USE_SAVED_FEATURES_ON = 1;
 LASSO_ENABLED = 1;
 

 if (USE_SAVED_FEATURES_ON) 
     load('preprocess.mat');
 else preprocess;
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
 

clear full_image_features; 
clear dense_image_features; 
clear normal_image_features;


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
        
        
            normal_mask = ~da & bw;
            dense_mask = da & bw;
            
            riesz_size = 256;
            full_image_features(i, :) = image_features(I, bw, 1, riesz_size); 

            if(sum(sum(normal_mask)) ~= 0)
            normal_image_features(i, :) = image_features(I, normal_mask, 1, riesz_size); 
            else 
            normal_image_features(i, :) = zeros(1, 99);
            display('err')
            end
            
            if(sum(sum(dense_mask)) ~= 0)
            dense_image_features(i, :) = image_features(I, dense_mask, 1, riesz_size); 
            else 
            dense_image_features(i, :) = zeros(1, 99);
            display('err')
            end
        
      
end

if(LASSO_ENABLED) 
[ importantClustersUnified, full_image_features ] = lasso_image_features( full_image_features(:, 29:99), image_cancer_class );
importantClustersUnified = importantClustersUnified + 28; % adjust the start

dense_image_features = dense_image_features(:, importantClustersUnified); 
normal_image_features = normal_image_features(:, importantClustersUnified);
end


[age_cat, ~] = normalyze(age_cat, 1);
                                            [race, ~] = normalyze(race, 1);
                                            [bmi, ~] = normalyze(bmi, 1);
                                            [cumulus_da, ~] = normalyze(cumulus_da, 1);
                                            all_features = horzcat(full_image_features, race, age_cat, bmi, parity, mens_status, cumulus_da, sqrt(cumulus_pd));
                                            dense_features = horzcat(dense_image_features, race, age_cat, bmi, parity, mens_status, cumulus_da, sqrt(cumulus_pd));
                                            normal_features = horzcat(normal_image_features, race, age_cat, bmi, parity, mens_status, cumulus_da, sqrt(cumulus_pd));
                                            
                                            
 [ ~, ~, unified_performance, model_all, unified_AUC, unified_scores, unified_outp, ] = classification( training, training, ...
                                                                all_features, ...
                                                                image_cancer_class, ...
                                                                SVM_METHOD, ...
                                                                0, ...
                                                                EQUAL_TRAIN_CLASSES_ON, ...
                                                                150, ...
                                                                1, ...
                                                                []);
                                                                                                  
                                                            
    [ ~, ~, dense_performance, model_dense, dense_AUC, dense_scores, dense_outp, ] = classification( training, training, ...
                                                                dense_features, ...
                                                                image_cancer_class, ...
                                                                SVM_METHOD, ...
                                                                0, ...
                                                                EQUAL_TRAIN_CLASSES_ON, ...
                                                                150, ...
                                                                1, ...
                                                                []);
                                                            
    [ ~, ~, normal_performance, model_normal, normal_AUC, normal_scores, normal_outp, ]= classification( training, training, ...
                                                                normal_features, ...
                                                                image_cancer_class, ...
                                                                SVM_METHOD, ...
                                                                0, ...
                                                                EQUAL_TRAIN_CLASSES_ON, ...
                                                                150, ...
                                                                1, ...
                                                                []);
        


  

                                                            
    
                
        
                
         

    
       