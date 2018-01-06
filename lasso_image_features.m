function [ importantClusters, lasso_features ] = lasso_image_features( features, image_cancer_class )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

X = features; % take from feature # 29. ignore the first two groups
Y = image_cancer_class;

impClusters = cell(10,1);
for i = 1 : 10
    alpha = 0.1 * i;
    
    i
    [B, Stats] = lasso(X,Y, 'CV', 10, 'Alpha', alpha);
    Coeff_Num(i) = sum(B(:,Stats.IndexMinMSE) > 0);
    MSE(i) = Stats.MSE(:, Stats.IndexMinMSE);
    importantClusters = B(:,Stats.IndexMinMSE) > 0;
    importantClusters = find(importantClusters);
    impClusters{i} = importantClusters;
end
[~, ind] = min(MSE);
[B, Stats] = lasso(X,Y, 'CV', 5, 'Alpha', ind*0.1);
importantClusters = B(:,Stats.IndexMinMSE) > 0;
importantClusters = find(importantClusters);


lassoPlot(B,Stats, 'PlotType','CV');
% Do ensemble classification again


lasso_features = features(:, importantClusters); 

end

