function res = lesionLbpStat(mask,radius)

    [X, Y, Z]  = size(mask);
    res = [];
    
    for r=radius
        
        lbp = zeros(X - 2*r, Y - 2*r, Z - 2*r);

        for i=1+r:X-r
            for j=1+r:Y-r            
                for k=1+r:Z-r            
                    center = mask(i,j,j);
                    circle = circleMask(X, Y, Z, i, j, k, r);
                    circle_val = mask(1 == circle) > center;
                    circle_power = linspace(size(circle_val,1),1,size(circle_val,1))';
                    lbp(i,j,k) = sum(circle_val.^circle_power);
                end
            end
        end

        % vectorize
        vect = lbp(lbp(:) > 0);
                
        res = [res ...
            min(vect),...
            max(vect),...
            median(vect),...
            mean(vect),...
            std(vect),...
            skewness(vect),...
            kurtosis(vect),...
            entropy(vect)...
        ];
    
    end

end
