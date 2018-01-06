
function index = getNearestCluster(vector, set)
% each row of set represents a cluster (vector)

    num_clusters = size(set, 2);
%     change vector to a row vector
    vector = repmat(vector, [1, num_clusters]);
    distance = (vector - set) .* (vector - set);
    distance = sum (distance, 1);
    [a index] = min(distance);

end
