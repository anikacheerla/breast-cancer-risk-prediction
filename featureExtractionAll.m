
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
 
 array = [5];
 
preprocessImpute;
             
 for x = 1:numel(array)
    
    N = array(x);
    
    EXTRACT_FEATURES_MODE = 4; % all the features except LBP and RIESZ
    featureExtraction;
    
     filename = sprintf('%s_%d','features',N);
    save(filename);
 end
 

                                                            
    
                
        
                
         

    
       