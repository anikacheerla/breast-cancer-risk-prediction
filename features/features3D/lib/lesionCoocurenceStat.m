function res = lesionCoocurenceStat(image, mask, distance, direction)

    lesion = image .* mask;

    cooc = cooc3d(lesion,...
        'distance',distance,...
        'direction',direction...
    );

    vect = cooc(:);
    
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
