function [  patches_dense_coord_array,... 
            patches_normal_coord_array]     = coordinates(  ...
                                                            all_patches_coord_array, ...                                                     
                                                            patches_dense_count, ...
                                                            patches_normal_count)

% Take only a sub-field of the extracted feature

    patches_normal_coord_array = cell(numel(all_patches_coord_array), 1);
    patches_dense_coord_array = cell(numel(all_patches_coord_array), 1);
    
    for i=1:numel(all_patches_coord_array) 

      temp = all_patches_coord_array{i};
      if (patches_dense_count(i) + patches_normal_count(i) ~= size(temp, 1))
          i
          display('error dense and normal patches dont add up')
      end
      
                  
        if(patches_dense_count(i) == 0) patches_normal_coord_array{i} = all_patches_coord_array{i}; 
        elseif (patches_normal_count(i) == 0) patches_dense_coord_array{i} = all_patches_coord_array{i}; 
        else
              patches_dense_coord_array{i} = all_patches_coord_array{i}(1:patches_dense_count(i), :);
              patches_normal_coord_array{i} = ...
                  all_patches_coord_array{i}(patches_dense_count(i)+1:patches_dense_count(i)+patches_normal_count(i), :);

        end
    end
    
end


