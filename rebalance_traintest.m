function [ new_training] = rebalance_traintest( training, image_cancer_class)

% This method rebalnces the training and testing sets. It makes the
% training set have 50% cancer and 50% non-cancer data. The remaining non
% cancer cases are assigned to the testing set.

new_training = training;
training_cancer = training & image_cancer_class;
training_normal = training & ~image_cancer_class; 

% indices of all the normal samples in training
normal_indices = find(training_normal); 

% indices of all cancer samples in training
cancer_indices = find(training_cancer); 

% move some to test
move_index = datasample(normal_indices, (length(normal_indices) - length(cancer_indices)), 'replace', false);
new_training(move_index) = 0;

end

