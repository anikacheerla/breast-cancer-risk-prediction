
function [ features , patches_index_array] = createHistogramFeatures( ...
                                                patches_cell_array, ...
                                                patchesCoordinates_cell_array, ...
                                                mask, ...
                                                patches_count, ...
                                                pcaData, ....
                                                dictionary, ...
                                                all_patches_settings, ...
                                                METHOD, ...
                                                PCA_ON, ...
                                                NUM_PCA_COMPONENTS,...
                                                NUM_CLUSTERS, ...
                                                HS_METHOD )


% create feature histogram from dictionary 
%  assign patches in an image to the closest cluster centroid
% The output array Image x Centrid-Histogram

patches_index_array = cell(numel(patches_cell_array), 1);

 features = zeros(length(patches_cell_array), NUM_CLUSTERS); % each patch in an image is assigned to a cluster centroid

            for i = 1:length(patches_cell_array)  %loop across images
                
                clear index_array;
                
                curPatchesRaw = double(patches_cell_array{i}); 
                curCoords = patchesCoordinates_cell_array{i};
                if((patches_count(i) ~= 0)) 
                    curPatches = findPatchesInMask( curPatchesRaw, curCoords, mask{i} );
                else curPatches = curPatchesRaw;
                end
                
                curPatches = curPatches';
                
                

                if ((METHOD == 1))
                    curPatches = mapstd('apply',curPatches,all_patches_settings);
                elseif (METHOD == 2)
                    curPatches = mapminmax.apply(curPatches,all_patches_settings);
                elseif (METHOD == 3)
                    for j=1:size(curPatches,1)
                        curPatches(j,:) = curPatches(j, :)/all_patches_settings(j);
                    end
                end


                if (PCA_ON)
                    pcaCoeff = projectOntoEigenVectors(pcaData, curPatches, NUM_PCA_COMPONENTS);
                else pcaCoeff = curPatches; 
                end


                if (patches_count(i) ~= 0) 
                    for j = 1 : size(pcaCoeff, 2)
                        cluster_idx = getNearestCluster(pcaCoeff(:,j), dictionary);
                        index_array(j) = cluster_idx;
                        features(i,cluster_idx) = features(i, cluster_idx) + 1;
                    end
                    
                    if (size(pcaCoeff, 2) ~= 0) 
                        patches_index_array{i} = index_array;
                    end
                    

                end
               
                
            end
    
    
            % normalization on the histogram
            if (HS_METHOD == 1)
              for i = 1:size(features, 2)
                 features(:, i) = (features(:, i) - mean(features(:, i)))/( std(features(:, i)));
              end

            elseif (HS_METHOD == 2)
                for i = 1:size(features, 1)
                 features(i, :) = (features(i, :) - mean(features(i,:)))/( std(features(i,:)));
                end
            elseif (HS_METHOD == 3) 
                features = mapminmax(features);
            elseif (HS_METHOD == 4) 
                features = mapminmax(features');
                features = features';
            end
            

            
end

