function [ pcaData, dictionary, all_patches_settings ] = createDictionary( ...
                                                            training, ...
                                                            patches_cell_array, ...
                                                            patches_count, ...
                                                            METHOD, ...
                                                            PCA_ON, ...
                                                            NUM_PCA_COMPONENTS, ...
                                                            KMEANSPLUS_ON, ...
                                                            NUM_CLUSTERS)

                                                        
% put together all the train patches
  clear('all_patches');

    for i = 1:length(patches_cell_array) 

                if (~exist('all_patches') && (patches_count(i) ~= 0) && training(i)) 
                   
                    all_patches = patches_cell_array{i};
                    all_patches_count  = patches_count(i);

                elseif ((patches_count(i) ~= 0) && training(i))
                  
                    all_patches = vertcat(all_patches, patches_cell_array{i});
                    all_patches_count = all_patches_count + patches_count(i);
                end        

    end
    
    
    [allPatches, all_patches_settings] = normalyze(double(all_patches), METHOD); 
    allPatches = allPatches';
    allPatches = double(allPatches);
    
                

 if (PCA_ON)
        pcaData = doPca(allPatches, 1);
        pcaCoeff = projectOntoEigenVectors(pcaData, allPatches, NUM_PCA_COMPONENTS);
    else 
        pcaCoeff = allPatches; 
 end
 

    % do the k-means algorithm
    
    if (KMEANSPLUS_ON)
        [~, dictionary] = kmeansandrew(NUM_CLUSTERS, pcaCoeff);
    else 
        [dictionary,~] = agloKmeans(NUM_CLUSTERS, pcaCoeff' , 2);
        dictionary = dictionary';
    end
    
    
end