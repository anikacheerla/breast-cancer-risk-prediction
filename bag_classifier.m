function [tr_accuracy, ...
    tr_sensitivity, ...
    tr_specificity, ...
    test_accuracy, ...
    test_sensitivity, ...
    test_specificity, ...
    true_positive, ...
    true_negative, ...
    AUC, ...
    bag, ...
    false_negative_index, ...
    X, Y, scores, outp] = bag_classifier(Xtrain, Ytrain, Xtest, Ytest, pca, numTree)


% add principal component analysis

if (~pca) 
    bag = fitensemble(Xtrain',Ytrain,'Bag', numTree, 'Tree',...
    'Type','Classification', 'Prior', 'uniform')
    [outp, scores] = predict(bag, Xtrain');


else 
    [pn,ps1] = mapstd(Xtrain);
    [ptrans,ps2] = processpca(pn, 0.0001);
    bag = fitensemble(ptrans',Ytrain,'Bag', numTree, 'Tree',...
        'Type','Classification', 'Prior', 'uniform')
    [outp, scores] = predict(bag, ptrans');

end


%%%%%% train performance
cm = confusionmat(Ytrain, outp);

tr_sensitivity = cm(2,2)/(cm(2,2) + cm(2,1));
tr_specificity = cm(1,1)/(cm(1,1) + cm(1,2));
tr_accuracy = (cm(1,1) + cm(2,2))/sum(sum(cm));

%%%%%%%%% test performance

if (~pca) 
    [outp,scores] = predict(bag, Xtest');

else 
    pnewn = mapstd('apply',Xtest,ps1);
    pnewtrans = processpca('apply',pnewn,ps2);
    [outp, scores] = predict(bag, pnewtrans');
end

[X,Y,~,AUC] = perfcurve(Ytest,scores(:,2),1);

if (length(Ytest) ~= 1) 
    
    cm = confusionmat(Ytest, outp);
    true_positive = 0;
    true_negative = 0;
    test_sensitivity = cm(2,2)/(cm(2,2) + cm(2,1));
    test_specificity = cm(1,1)/(cm(1,1) + cm(1,2));
    test_accuracy = (cm(1,1) + cm(2,2))/sum(sum(cm));
    if (size(Ytest,1) ~= size(outp, 1)) 
        false_negative = (outp == 0) & (Ytest == 1)'; 
    else 
        false_negative = (outp == 0) & (Ytest == 1); 
    end
    
    false_negative_index = find(false_negative);
    
else
    
    true_positive = (outp == Ytest) & (outp == 1); 
    true_negative = (outp == Ytest) & (outp == 0);
    test_sensitivity = 0; 
    test_specificity = 0; 
    test_accuracy = 0; 
   
end

    true_positive = sum((outp == Ytest) & (outp == 1)); 
    true_negative = sum((outp == Ytest) & (outp == 0));
    false_positive = sum((Ytest == 0) & (outp == 1));
    false_negative = sum((Ytest == 1) & (outp == 0)); 
    
    odds_ratio = (true_positive * true_negative)/ (false_positive * false_negative);
    se_odds_ratio = sqrt( (1/true_positive) + (1/true_negative) + (1/false_positive) + (1/false_negative));
    
end

