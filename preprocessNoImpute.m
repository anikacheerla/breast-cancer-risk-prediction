
% this script preprocesses the images. Finds the duplicate ones from the
% cumulus table to remove 

table1 = dataread('file', 'cumulus_results_with_classification.csv', '%s', 'delimiter', '\n'); %name of image, breast area, dense area
table3 = dataread('file', 'cumulus_results_with_extra_info.csv', '%s', 'delimiter', '\n'); % with clinical  information
table2 = dataread('file', 'cumulus_results_with_extra_info.csv', '%s', 'delimiter', '\n'); % with clinical  information

image_class = zeros(numel(table1), 1); %dense or normal class  (>50% dense)
image_cancer_class = zeros(numel(table1), 1); %case = 1 means cancer
breast_area_deviation = zeros(numel(table1), 1); %diff between computed and table values for breast area
dense_area_deviation = zeros(numel(table1), 1); %same as above for dense area
remove_image = zeros(numel(table1),1); %duplicate image indeces for "table1"
race = zeros(numel(table1), 1); %feature from second table
age_cat = zeros(numel(table1), 1); %feature from second table
mens_status = zeros(numel(table1), 1); %feature from second table
birads = zeros(numel(table1), 1); %feature from second table
cumulus_pd = zeros(numel(table1), 1); %feature from second table
cumulus_da = zeros(numel(table1), 1); 
volpara_pd = zeros(numel(table1), 1); %feature from second table
volpara_dv = zeros(numel(table1), 1);
parity = zeros(numel(table1), 1);
bmi = zeros(numel(table1), 1);

remove_image_no_clinical_data  = zeros(numel(table1), 1); 
thresh = zeros(numel(table1), 1);

for i = 1:numel(table1)
        % read image
    
        i
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
            table2_temp1 = strsplit(table2_temp{1}, '.');
            table1_temp2 = strsplit(image, {'.', '_'});
            
            table3_temp = char(table3(j)); 
            table3_temp = strrep(table3_temp,',,',', ,');
            table3_temp = strrep(table3_temp,',,',', ,');

            table3_temp = strsplit(table3_temp, ','); 
            
            
            if (strcmp(table2_temp1(1), table1_temp2(1)))
                race(i) = str2double(table3_temp(4)); 
                age_cat(i) = str2double(table3_temp(5)); 
                mens_status(i) = str2double(table3_temp(9));
                birads(i) = str2double(table3_temp(8));
                volpara_dv(i) = str2double(table3_temp(28));
                volpara_pd(i) = str2double(table3_temp(29));
                bmi(i) = str2double(table3_temp(13));
                parity(i) = str2double(table3_temp(10));

                match = 1;
                break;
            end
        end
        
        % if there is no match for this image in table2, remove this image
        % as it has no clinical data
        if (~match) 
            remove_image_no_clinical_table2(i) = 1;
            image
        end
        
 
    % threshold, dense aream breast area and image cancer risk classification from table 1
    thresh(i) = str2double(temp(2));
    golden_dense_area = str2double(temp(3)); 
    golden_breast_area = str2double(temp(4));
    image_cancer_class(i) = str2double(temp(5));

    cumulus_pd(i) = golden_dense_area/golden_breast_area;
    cumulus_da(i) = golden_dense_area;
    % read the image
    image = char(image);
                

        I = dicomread(image);    
        
        % resize so it is manageable size
        I = imresize(I, 0.25);

        %bw is mask - black and white image
        bw = I/(max(I(:)));
        breast_area = sum(sum(bw));
        
        % deviation from table 1
        breast_area_deviation(i) = (breast_area*16 - golden_breast_area)/(16*breast_area);


        %dense area with threshold checking
        da = imquantize(I,thresh(i));
        da = da-1;
        dense_area = sum(sum(da));
        
        % deviation from table 1
        dense_area_deviation(i) = (dense_area*16 - golden_dense_area)/(16*dense_area);

        % global dense or no-dense classification for the image. This is used to partition
        % train/test using stratification (same percentage of both
        % classes in train and test
        dense_percentage = dense_area/breast_area; 
        if (dense_percentage > 0.51) 
            image_class(i) = 1;
        else
            image_class(i) = 0;

        end
        
    end
    
        
end


% removing duplicate image properties
remove_index = find(remove_image);
image_class(remove_index) = [];
image_cancer_class(remove_index) = [];
image_name(remove_index) = [];
breast_area_deviation(remove_index) = [];
dense_area_deviation(remove_index) = [];
race(remove_index) = [];
age_cat(remove_index) = []; 
mens_status(remove_index) = [];
parity(remove_index) = [];
bmi(remove_index) = [];


birads(remove_index) = [];
cumulus_pd(remove_index) = [];
cumulus_da(remove_index) = [];
volpara_pd(remove_index) = [];
volpara_dv(remove_index) = [];

thresh(remove_index) = [];

csvwrite('image_class.csv', image_class);

save('preprocess.mat', ...
    'remove_index', ...
    'image_class', ...
    'image_cancer_class', ...
    'image_name', ...
    'race', ...
    'age_cat', ...
    'mens_status', ...
    'thresh', ...
    'remove_image', ...
    'birads', ...
    'cumulus_pd', ...
    'cumulus_da', ...
    'parity', ...
    'volpara_pd', ...
    'volpara_dv', ...
    'bmi');

