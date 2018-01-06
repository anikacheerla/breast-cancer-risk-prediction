function pcaData = doPca(data, normalize_each_pca_flag, METHOD, NORM_COL)


%if normalizeFlag == 1, divide by variance as well

%data: each column is a different example

compWiseMean = mean(data, 2);

% Note: no need to divide by variance since the different components are 
% all on the same scale


% no normalization with method = 0. Normalization is done outside

X = data * data';

[pc,score,latent] = princomp(X);

pcaData.eVectors = pc;
pcaData.eValues = latent;
pcaData.meanVector = compWiseMean;

if (normalize_each_pca_flag)
%     eigenVectors => 1st col. is 1st eigen vector
% % TODO: normalize each pca compoent separately
end

end