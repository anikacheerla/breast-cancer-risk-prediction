
% create lasso features

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



% Lasso regression 

X = full_image_features(:, 29:99); % take from feature # 29. ignore the first two groups
Y = image_cancer_class;

impClusters = cell(10,1);
for i = 1 : 10
    alpha = 0.1 * i;
    
    i
    [B Stats] = lasso(X,Y, 'CV', 10, 'Alpha', alpha);
    Coeff_Num(i) = sum(B(:,Stats.IndexMinMSE) > 0);
    MSE(i) = Stats.MSE(:, Stats.IndexMinMSE);
    importantClusters = B(:,Stats.IndexMinMSE) > 0;
    importantClusters = find(importantClusters);
    impClusters{i} = importantClusters;
end
[~, ind] = min(MSE);
[B Stats] = lasso(X,Y, 'CV', 5, 'Alpha', ind*0.1);
importantClusters = B(:,Stats.IndexMinMSE) > 0;
importantClusters = find(importantClusters);


lassoPlot(B,Stats, 'PlotType','CV')
% Do ensemble classification again

importantClusters = importantClusters+28 %( to go back to the 1:99 index)



