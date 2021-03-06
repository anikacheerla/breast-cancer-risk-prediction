function res = lesionWaveletStat(image, mask, w_name, w_level)

    data = image .* mask;
    WT = wavedec3(data,w_level,w_name);

    vect = [];
    for i=1:size(WT.dec,1)
        LL = WT.dec(i);
        temp = cell2mat(LL);
        vect = [vect; temp(:)];
    end
    
    res = [...
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