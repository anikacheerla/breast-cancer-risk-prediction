function [  patch,...
            patch_classification, ... % dense or not-dense
            counter, ...
            densePatchOutput, ...
            dense_counter, ...
            normalPatchOutput, ...
            normal_counter, ...
            patch2, ...
            patch2Coordinates, ...
            new_mask, patch2Class] = extractPatches_equal(image,...
                                                      N, ...
                                                      thresh, ...
                                                      EXTRACT_FEATURES_MODE, ...
                                                      DRAW_PATCHES_ON, ...
                                                      MASK_MODE, ...
                                                      USE_DENSE_CLASSIFIER, ...
                                                      dense_patch_classifier)
        
        

% This function extracts patches from the image
% image. Outputs are
% patch : array of equal number of dense and normal patches from the image
% patch_classification: classification (dense or normal) for each of the
% patches in the 'patch' array
% counter: number of patches in the 'patch' array
% densePatchOutput : array of all the dense patches from the image
% dense_counter : number of dense patches
% normalPatchOutput: array of all normal patches
% normal_counter: Number of normal patches
% patch2: array of all the patches from the image

% EXTRACT_FEATURES_MODE 
%   = 0 (only gray pixels)
%   = 1 (only extracted LBP & wavelet features)
%   = 2 (al extracted features)
%   = 3 (combined gray and extracted but with only LBP and gabor features) 
%   = 4  (combined gray and extracted but with all the extracted features)

% DRAW_PATCHES_ON : a fugure with patches overlaid on the breast image is
% saved

% MASK_MODE : 
%   1: region 1
%   2: region 2
%   3: region 3
%   4: all of the breast

% USE_DENSE_CLASSIFIER: when this is on, use the dense_patch_classifier
% model for predircing the dense tissue. Don't use thresholds
% 


% create mask image. Erode the mask a bit so that the border areas are not
% picked as dense patches

mask = image/(max(image(:)));
se = strel('disk',2);
mask1 = imerode(mask, se);
mask = mask1;

mask = layeredMask(mask, MASK_MODE); 
new_mask = mask;

% find all valid indices inside the breast region
[row col] = find(mask);

validIndices = find( row > (N-1)/2 & (row + (N-1)/2 <= size(mask, 1)) ... % describe the allowed borders of the patches inside the image
                &    col > (N-1)/2 & (col + (N-1)/2 <= size(mask, 2)) );


% taking only the valid rows and columns which are within the allowed
% borders of the image
row = row(validIndices);
col = col(validIndices);

counter = 0;
dense_counter = 0;
normal_counter = 0;
clear patch;
clear patch2;

sz = size(image);
new_image = zeros(sz(1), sz(2));
dense_mask =  new_image;
new_image_color = zeros(sz(1), sz(2), 3);
gnum = 1;
rnum = 1;
bnum  = 1;

riesz_size = 8;

for i = 1:min(numel(row),numel(col))
    
    
    % choosing the current patch
    curPatch = image(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2);
    curMask = mask(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2);
    
    
    
    
    if(numel(find(mask(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2))) >= 0.80*N*N)
        
        
        % mask out the current patch from the breast mask so it does not
        % get picked again
        mask(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2) = 0;
        
        % apply threshold and find the dense area percentage and it
        % classification when USE_DENSE_CLASSIFIER ids off. when
        % USE_DENSE_CLASSIFIER is on, use
        
        da = imquantize(curPatch,thresh);
        da = da-1;
        dense_area = sum(sum(da));
        dense_percentage = dense_area/(N*N);
        %imshow(curPatch, [])
        
        if (USE_DENSE_CLASSIFIER)
            
            if (dense_percentage > 0.51) patch_class = 1;
            else patch_class = 0;
            end
            
            features = reshape(curPatch, [1, N*N]);
            features = double(features);
            dense_class = predict(dense_patch_classifier, features);
            if (dense_class > 0.51)
                dense_class = 1;
            else
                dense_class = 0;
            end
        else
            if (dense_percentage > 0.51)
                dense_class = 1;
                patch_class = 1;
            else
                dense_class = 0;
                patch_class = 0;
            end
        end
        
        
        
        %% update either dense or normal patch counters/arrays
        if (dense_class)
            
            switch EXTRACT_FEATURES_MODE
                case 0
                    dense_counter = dense_counter +1;
                    densePatch(dense_counter, :) =  reshape(curPatch, [1, N*N]);
                    densePatchCoordinates(dense_counter, :) = [row(i), col(i)];
                case 1
                    features = image_features(curPatch, curMask, 0, riesz_size);
                    if (~isnan(sum(features)))
                        dense_counter = dense_counter +1;
                        densePatch(dense_counter, :) = features;
                        densePatchCoordinates(dense_counter, :) = [row(i), col(i)];
                        
                    end
                case 2
                    features = image_features(curPatch, curMask, 1, riesz_size);
                    if (~isnan(sum(features)))
                        dense_counter = dense_counter +1;
                        densePatch(dense_counter, :) = features;
                        densePatchCoordinates(dense_counter, :) = [row(i), col(i)];
                        
                    end
                case 3
                    features = image_features(curPatch, curMask, 0, riesz_size);
                    if (~isnan(sum(features)))
                        dense_counter = dense_counter +1;
                        densePatch(dense_counter, :) = horzcat(reshape(curPatch, [1, N*N]), features);
                        densePatchCoordinates(dense_counter, :) = [row(i), col(i)];
                        
                    end
                case 4
                    features = image_features(curPatch, curMask, 1, riesz_size);
                    
                    if (~isnan(sum(features)))
                        dense_counter = dense_counter +1;
                        densePatch(dense_counter, :) = horzcat(reshape(curPatch, [1, N*N]), features);
                        densePatchCoordinates(dense_counter, :) = [row(i), col(i)];
                        
                    end
            end
            
            
        else
            
            switch EXTRACT_FEATURES_MODE
                case 0
                    normal_counter = normal_counter +1;
                    normalPatch(normal_counter, :) =  reshape(curPatch, [1, N*N]);
                    normalPatchCoordinates(normal_counter, :) = [row(i), col(i)];
                case 1
                    features = image_features(curPatch, curMask, 0, riesz_size);
                    if (~isnan(sum(features)))
                        normal_counter = normal_counter +1;
                        normalPatch(normal_counter, :) = features;
                        normalPatchCoordinates(normal_counter, :) = [row(i), col(i)];
                    end
                case 2
                    features = image_features(curPatch, curMask, 1, riesz_size);
                    if (~isnan(sum(features)))
                        normal_counter = normal_counter +1;
                        normalPatch(normal_counter, :) = features;
                        normalPatchCoordinates(normal_counter, :) = [row(i), col(i)];
                    end
                case 3
                    features = image_features(curPatch, curMask, 0, riesz_size);
                    if (~isnan(sum(features)))
                        normal_counter = normal_counter +1;
                        normalPatch(normal_counter, :) = horzcat(reshape(curPatch, [1, N*N]), features);
                        normalPatchCoordinates(normal_counter, :) = [row(i), col(i)];
                    end
                case 4
                    features = image_features(curPatch, curMask, 1, riesz_size);
                    if (~isnan(sum(features)))
                        normal_counter = normal_counter +1;
                        normalPatch(normal_counter, :) = horzcat(reshape(curPatch, [1, N*N]), features);
                        normalPatchCoordinates(normal_counter, :) = [row(i), col(i)];
                    end
            end
        end
        
        
        if (DRAW_PATCHES_ON == 1)
            new_image_color(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2, 2) = 1; % green
            new_image_color(row(i) - (N-3)/2 : row(i) + (N-3)/2 , col(i) - (N-3)/2 : col(i) + (N-3)/2, 2) = 0; % green
            green_row(gnum) = row(i);
            green_col(gnum) = col(i);
            gnum = gnum +1;
        elseif (DRAW_PATCHES_ON == 2)
            
            if ((dense_class == patch_class) && (dense_class == 1))
                new_image_color(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2, 2) = 1; % green
                new_image_color(row(i) - (N-3)/2 : row(i) + (N-3)/2 , col(i) - (N-3)/2 : col(i) + (N-3)/2, 2) = 0; % green
                green_row(gnum) = row(i);
                green_col(gnum) = col(i);
                gnum = gnum +1;
                
            elseif ((dense_class == 0) && (patch_class == 1) )
                new_image_color(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2, 1) = 1; % red
                new_image_color(row(i) - (N-3)/2 : row(i) + (N-3)/2 , col(i) - (N-3)/2 : col(i) + (N-3)/2, 1) = 0; % red
                red_row(rnum) = row(i);
                red_col(rnum) = col(i);
                rnum = rnum+1;
                
            elseif ((dense_class == 1) && (patch_class == 0) )
                new_image_color(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2, 3) = 1; % blue
                new_image_color(row(i) - (N-3)/2 : row(i) + (N-3)/2 , col(i) - (N-3)/2 : col(i) + (N-3)/2, 3) = 0; % blue
                blue_row(bnum) = row(i);
                blue_col(bnum) = col(i);
                bnum = bnum +1;
            end
        elseif (DRAW_PATCHES_ON == 3)
            if (patch_class == 1)
                new_image_color(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2, 2) = 1; % green
                new_image_color(row(i) - (N-3)/2 : row(i) + (N-3)/2 , col(i) - (N-3)/2 : col(i) + (N-3)/2, 2) = 0; % green
                green_row(gnum) = row(i);
                green_col(gnum) = col(i);
                gnum = gnum +1;
                
            else
                new_image_color(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2, 3) = 1; % blue
                new_image_color(row(i) - (N-3)/2 : row(i) + (N-3)/2 , col(i) - (N-3)/2 : col(i) + (N-3)/2, 3) = 0; % blue
                blue_row(bnum) = row(i);
                blue_col(bnum) = col(i);
                bnum = bnum +1;
            end
            
        elseif (DRAW_PATCHES_ON == 4)
            if (patch_class == 1)
                new_image_color(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2, 2) = 1; % green
                new_image_color(row(i) - (N-3)/2 : row(i) + (N-3)/2 , col(i) - (N-3)/2 : col(i) + (N-3)/2, 2) = 0; % green
                red_row(rnum) = row(i);
                red_col(rnum) = col(i);
                rnum = rnum +1;
            end
            
        elseif (DRAW_PATCHES_ON == 5)
            if (patch_class == 0)
                new_image_color(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2, 3) = 1; % blue
                new_image_color(row(i) - (N-3)/2 : row(i) + (N-3)/2 , col(i) - (N-3)/2 : col(i) + (N-3)/2, 3) = 0; % blue
                blue_row(bnum) = row(i);
                blue_col(bnum) = col(i);
                bnum = bnum +1;
            end
            
        end
        
        
        if (dense_class ==1)
            dense_mask(row(i) - (N-1)/2 : row(i) + (N-1)/2 , col(i) - (N-1)/2 : col(i) + (N-1)/2) = 1;
        end
        
        
    end
    
    
    
    
end
        
% width of the patches features array
 switch EXTRACT_FEATURES_MODE
     
     case 0 
         Y = N*N; 
     case 1
         Y = 16;
     case 2 
         Y = 99;
     case 3
         Y = 16 + (N*N);
     case 4 
         Y = 99 + (N*N);
 end
 

 clear densePatchRandom
% extract same number of dense and normal pacthes to output to patch cell
% array
% whenever one of the counters is zero, dont create any patches
if ((dense_counter ==0) || (normal_counter ==0))
      patch = zeros(1, Y);
      patch_classification(1) = 0;
      counter = 0;

elseif (dense_counter >= normal_counter) 
       
       
       patch = zeros(2*normal_counter, Y);
       if(dense_counter ~= normal_counter)
       densePatchRandom = datasample(densePatch, normal_counter);
       else densePatchRandom = densePatch;
       end
       
      
      
       patch(1:2*normal_counter, :) = vertcat(densePatchRandom, normalPatch(1:normal_counter, :));
       
       
       patch_classification = [ ones(1,normal_counter), zeros(1,normal_counter)];
       counter = 2*normal_counter;
 
       
else 
       patch = zeros(2*dense_counter, Y);
       if (normal_counter ~= dense_counter)
       normalPatchRandom = datasample(normalPatch, dense_counter);
       else normalPatchRandom = normalPatch;
       end
       
       patch(1:2*dense_counter, :)  = vertcat(densePatch(1:dense_counter, :), normalPatchRandom);
       patch_classification = [ ones(1, dense_counter), zeros(1, dense_counter)];
       counter = 2*dense_counter;
             
end


 %%%%%%%%%%% just get all the dense patches, normal patches and all patches
 %%%%%%%%%%% seperately 
 
 if (dense_counter == 0) 
      densePatchOutput = zeros(1, Y);
 else densePatchOutput = densePatch;
 end
 
 if (normal_counter == 0) 
      normalPatchOutput = zeros(1, Y);
 else normalPatchOutput = normalPatch;
 end
 
 if ( (dense_counter == 0) && (normal_counter == 0))
         display('ERROR - no dense or normal patches')
 elseif(dense_counter == 0)
     patch2 = normalPatchOutput;
     patch2Coordinates = normalPatchCoordinates;
     patch2Class = zeros(1,normal_counter);
 elseif(normal_counter == 0)
     patch2 = densePatchOutput;
     patch2Coordinates = densePatchCoordinates;
     patch2Class = ones(1,dense_counter);
 else
     patch2 = vertcat(densePatchOutput, normalPatchOutput);
     patch2Coordinates = vertcat(densePatchCoordinates, normalPatchCoordinates);
     patch2Class = [ ones(1,dense_counter), zeros(1,normal_counter)];
     
 end
     
 %% draw patches
 
 if(DRAW_PATCHES_ON == 1)
     
     figure;
     I1 = (imadjust(image));
     imshow(I1, []);
     
     hold on;
     
     for i = 1:gnum-1
         
         row_bot = green_col(i) - (N-1)/2;
         row_top = green_col(i) + (N-1)/2;
         col_bot = green_row(i) - (N-1)/2;
         col_top = green_row(i) + (N-1)/2;
         
         plot (row_bot*ones(N,1), col_bot:col_top,'m');
         plot (row_top*ones(N,1), col_bot:col_top,'m');
         plot ( row_bot:row_top,col_bot*ones(N,1), 'm');
         plot ( row_bot:row_top,col_top*ones(N,1), 'm');
     end
     
     
     hold off;
     
     
 elseif (DRAW_PATCHES_ON ~= 0)
     
     figure;
     I = imadjust(image);
     imshow(I, []);
     
     hold on;
     
     for i = 1:rnum-1
         
         row_bot = red_col(i) - (N-1)/2
         row_top = red_col(i) + (N-1)/2
         col_bot = red_row(i) - (N-1)/2
         col_top = red_row(i) + (N-1)/2
         
         plot (row_bot*ones(N,1), col_bot:col_top,'r')
         plot (row_top*ones(N,1), col_bot:col_top,'r')
         plot ( row_bot:row_top,col_bot*ones(N,1), 'r')
         plot ( row_bot:row_top,col_top*ones(N,1), 'r')
     end
     
     for i = 1:gnum-1
         
         row_bot = green_col(i) - (N-1)/2
         row_top = green_col(i) + (N-1)/2
         col_bot = green_row(i) - (N-1)/2
         col_top = green_row(i) + (N-1)/2
         
         plot (row_bot*ones(N,1), col_bot:col_top,'g')
         plot (row_top*ones(N,1), col_bot:col_top,'g')
         plot ( row_bot:row_top,col_bot*ones(N,1), 'g')
         plot ( row_bot:row_top,col_top*ones(N,1), 'g')
     end
     
     for i = 1:bnum-1
         
         row_bot = blue_col(i) - (N-1)/2
         row_top = blue_col(i) + (N-1)/2
         col_bot = blue_row(i) - (N-1)/2
         col_top = blue_row(i) + (N-1)/2
         
         plot (row_bot*ones(N,1), col_bot:col_top,'b')
         plot (row_top*ones(N,1), col_bot:col_top,'b')
         plot ( row_bot:row_top,col_bot*ones(N,1), 'b')
         plot ( row_bot:row_top,col_top*ones(N,1), 'b')
     end
     
     hold off;
     
 end
 
 savefig('GSF_patches')
 
     
 
 if (DRAW_PATCHES_ON == 2) 
    figure; 
    imshow(dense_mask, []);
    savefig('GSF_dense_only_patches')
  
    figure;
     I1 = (imadjust(image));
     [B,L] = bwboundaries(dense_mask);
     imshow(I1, [])
     hold on
     for k = 1:length(B)
         boundary = B{k};
         plot(boundary(:,2), boundary(:,1), 'b','LineWidth', 1)
     end
     hold off
     savefig('GSF_dense_only_patches_contour')
 end
 


end

