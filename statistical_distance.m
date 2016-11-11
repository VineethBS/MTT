function d = statistical_distance(x, y, covariance_matrix)
    d = sqrt(sum((x - y).^2));
end