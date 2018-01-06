function [ curPatches ] = findPatchesInMask( curPatchesRaw , curCoords, mask )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    include = zeros(size(curPatchesRaw,1),1); 
    for i = 1:size(curPatchesRaw, 1)
            coordinate = curCoords(i, :);
    if (mask(coordinate(1), coordinate(2))) 
        include(i) = 1;
    end
    end
    
    
    curPatches = curPatchesRaw(find(include), :);
end



