
% this script preprocesses the images. Finds the duplicate ones from the
% cumulus table to remove 

table1 = dataread('file', 'cumulus_results_with_classification.csv', '%s', 'delimiter', '\n'); %name of image, breast area, dense area
table2 = dataread('file', 'libra_density_results_for_assaf_2016-06-27.csv', '%s', 'delimiter', '\n'); % with clinical  information

image_class = zeros(numel(table1), 1); %dense or normal class  (>50% dense)
image_cancer_class = zeros(numel(table1), 1); %case = 1 means cancer
remove_image = zeros(numel(table1),1); %duplicate image indeces for "table1"
libra_dense_area =  zeros(numel(table1),1);
libra_breast_area =  zeros(numel(table1),1);
libra_breast_density =  zeros(numel(table1),1);

for i = 1:numel(table1)
    i
        % read image
    filestring = table1(i);
    filestring = char(filestring);
    temp = strsplit(filestring, ',');
    image = temp(1);
    image = char(image);
    image_name{i} = image; 
    
    if (i > 1)  %getting the previous image
        image_previous = image_name(i-1);
        if(strcmp(image_previous, image)) 
            remove_image(i) = 1;
            continue;
        else remove_image(i) = 0;
        end
    else remove_image(i) = 0;
    end
    
    % do all the processing only if the image is not duplicate
    if (~remove_image(i))
        
        % find the age/race/mens status of this sample from table 2
        match = 0;
        for j = 2: numel(table2)
            table2_temp = char(table2(j)); 
            table2_temp = strsplit(table2_temp, ','); 
            table2_temp1 = strsplit(table2_temp{1}, {'.', '_'});
            table1_temp2 = strsplit(image, {'.', '_'});
            if (strcmp(table2_temp1(1), table1_temp2(1)))
                libra_breast_area(i) = str2double(table2_temp(2)); 
                libra_dense_area(i) = str2double(table2_temp(3)); 
                libra_breast_density(i) = str2double(table2_temp(4)); 
                match = 1;
                break;
            end
        end
        
        % if there is no match for this image in table2, remove this image
        % as it has no clinical data
        if (~match) 
            remove_image_no_clinical_table2(i) = 1;
            image
            table2_temp1(1)
            table1_temp2(1)
        end
        
    end
    
        
end


% removing duplicate image properties
remove_index = find(remove_image);
image_class(remove_index) = [];
image_cancer_class(remove_index) = [];
image_name(remove_index) = [];
libra_breast_area(remove_index) = [];
libra_dense_area(remove_index) = []; 
libra_breast_density(remove_index) = [];

save('preprocess_libra.mat', 'libra_breast_area', 'libra_dense_area', 'libra_breast_density');

