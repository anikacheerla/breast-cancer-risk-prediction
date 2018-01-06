function [ Y, settings] = normalyze( X, METHOD)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here



    if (METHOD == 0) 
        Y = X; 
        settings = 0;

    elseif (METHOD == 1) 

        [Y, settings] = mapstd(X');
        Y = Y';

    elseif (METHOD == 2) 

        [Y, settings] = mapminmax(X');
        Y = Y';

    elseif (METHOD == 3) 
        for i = 1:size(X, 2)
            
            if (std(X(:, i)) ~= 0)
             Y(:, i) = (X(:, i))/std(X(:, i));  
             settings(i) = std(X(:,i));
            else 
                Y(:,i) = X(:, i); 
                settings(i) = 1;
            end
            
        
        end
    end
    
    

    

  

 
    
end

