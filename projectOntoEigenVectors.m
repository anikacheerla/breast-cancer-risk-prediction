function pcaCoeff = projectOntoEigenVectors(pcaData, featureVectors, K)

% taking only the vectors with the top K eigen vectors

%featureVectors: r x c : r = dimension of a vector, c = no. of
%input examples (data)
%pcaData.eVectors : r x r : each column is an eigen vector


pcaCoeff = pcaData.eVectors(:, 1:K)' * featureVectors; 

%pcaCoeff = diag(1./(sqrt(pcaData.eValues(1:K)))) * pcaData.eVectors(:,1:K)' * featureVectors;

end