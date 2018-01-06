
% classifier 
% EQUAL_TRAIN_CLASSES_ON is set, then training is done with 50-50 train and
% test samples
% PCA_ON : do further PCA on the features before classification
% SVM_METHOD - pick the type of SVM classifier


function [  fn_dense_grade, ...
            fn_image_indices, ...
            performance, ...
            model, ...
            raw_AUC, ...
            raw_scores, ...
            raw_outp] = classification( training, training1, ...
                                                                                    features, ...
                                                                                    image_cancer_class, ...
                                                                                    SVM_METHOD, ...
                                                                                    PCA_ON, ...
                                                                                    EQUAL_TRAIN_CLASSES_ON, ...
                                                                                    numTree, ...
                                                                                    repeats, ...
                                                                                    dense_area_grade)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here


    fn_dense_grade = [0,0,0,0];
    fn_image_indices = zeros(numel(image_cancer_class), 1);
    raw_scores = zeros(numel(image_cancer_class), 1);
    raw_outp = zeros(numel(image_cancer_class), 1);
    
    for i=1:repeats

    for j = 1:size(training, 2)
        
        if (i ==1)
            trainIndex = training(:,j); 
            testIndex = ~training(:,j);
        else 
            trainIndex = training1(:,j); 
            testIndex = ~training1(:,j);
        end
        
        
        trainIndex = find(trainIndex);
        testIndex = find(testIndex);
        
        train_features = features(trainIndex, :);
        train_class = image_cancer_class(trainIndex, :);
        
        test_features = features(testIndex, :);
        test_class = image_cancer_class(testIndex, :);
  
         Xtrain = train_features';
         Xtest = test_features';

         Ytrain = train_class;
         Ytest = test_class;

            tr_accuracy(i,j) = 0;
            tr_sensitivity(i,j) = 0;
            tr_specificity(i,j) = 0;
            test_accuracy(i,j) = 0;
            test_sensitivity(i,j) = 0;
            test_specificity(i,j) =0;
            true_positive(i,j) =0;
            true_negative(i,j) =0;
            test_AUC(i,j) = 0;
            model = 0;
            
      
              [  bag_tr_accuracy(i,j), ...
                 bag_tr_sensitivity(i,j), ...
                 bag_tr_specificity(i,j), ...
                 bag_test_accuracy(i,j), ...
                 bag_test_sensitivity(i,j), ...
                 bag_test_specificity(i,j), ...
                 bag_true_positive(i,j), ...
                 bag_true_negative(i,j), ...
                 bag_test_AUC(i,j), ...
                 model, ...
                 false_negative_index,~, ~, scores, outp] = bag_classifier(Xtrain, Ytrain, Xtest, Ytest, PCA_ON, numTree);
             
             raw_scores(testIndex) = scores(:, 1); 
             raw_outp(testIndex) = outp; 
             
                 
%                 % add histogram for FN dense_area_grade to see if there is
%                 % any pattern
%                   Not needed. Some random experiment 
%                 
%                 for k = 1:numel(false_negative_index)
%                     grade = dense_area_grade(false_negative_index(k));
%                     fn_dense_grade(grade) = fn_dense_grade(grade) +1;
%                     fn_image_indices(false_negative_index(k)) = fn_image_indices(false_negative_index(k))+1;
%                 end
                
                
           
    end
    
    end
    
    
    % Mean AUC
    raw_AUC = bag_test_AUC(1,:);
    performance(1) = mean(mean(bag_test_AUC));

    % Standard Deviation
    if (repeats == 2)
        performance(2) = std(horzcat(bag_test_AUC(1,:), bag_test_AUC(2, :)));
    else 
        performance(2) = std(horzcat(bag_test_AUC(1,:))); % standard deviation of the AUC
    end
    
    
    % standard error
    performance(3) =  performance(2)/sqrt(repeats * size(training, 2)); % Standard error of the AUC
 
end

