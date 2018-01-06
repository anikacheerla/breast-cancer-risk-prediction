function [ newMask ] = layeredMask( mask, mode )
%mode = 1, closest to chest wall
%mode = 2, middle section
%mode = 3, closest to nipple
%mode = 0, entire breast

%detect whether the breast is on the left or right of the image
[~ , col] = find(mask);

qualifier = zeros(size(mask,1), size(mask,2));


strip_width = round((max(col) - min(col) )/3);

if(max(col) == size(mask,2))
% breast on the right side

    if(mode == 3)
        col1 = min(col);
        col2 = min(col) + strip_width;
    elseif(mode == 2)
        col1 = min(col) + strip_width;
        col2 = min(col) + 2*strip_width;
    elseif(mode == 1)
        col1 = min(col) + 2*strip_width;
        col2 = max(col);
    else col1 = min(col);
        col2 = max(col);
    end
else 
    if(mode == 3)
        col2 = max(col);
        col1 = max(col) - strip_width;
    elseif(mode == 2)
        col1 = max(col) - 2*strip_width;
        col2 = max(col) - strip_width;
    elseif(mode == 1)
        col1 = min(col);
        col2 = max(col) - 2*strip_width;
    else col1 = min(col);
        col2 = max(col);
    end
end

qualifier(:, col1:col2) = 1;
newMask = qualifier & mask;


end

