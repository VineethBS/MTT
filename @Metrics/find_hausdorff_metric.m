function dist = find_hausdorff_metric(o, X, Y)
% This code is adapted from that by B. Vo.
% Compute Hausdorf Metric between two finite sets X and Y
% as described in the reference
% [1] D. Schuhmacher, B.-T. Vo, and B.-N. Vo, "A consistent metric for performance evaluation in multi-object
% filtering," IEEE Trans. Signal Processing, Vol. 56, No. 8 Part 1, pp. 3447?3457, 2008.
%
% Inputs: X,Y--   matrices of column vectors
% Output: scalar Hausdorf distance between X and Y
%        The matched pair index with these elements whose distance is less than cut-off distance.
% Note: the Euclidean 2-norm is used as the "base" distance on the region

if isempty(X) && isempty(Y)
    dist = 0;
    return;
end

if isempty(X) || isempty(Y)
    if isempty(X)  % If any set between X and Y is empty,
        % return the mean distance of the noempty set.
        dist = mean(sqrt(sum(Y.^2)));
    end
    if isempty(Y)
        dist = mean(sqrt(sum(X.^2)));
    end
    return;
end


%Calculate sizes of the input point patterns
n = size(X,2);
m = size(Y,2);

%Calculate cost/weight matrix for pairings - slow method with for loop
D= zeros(n,m);
for j=1:m
    D(:,j)= sqrt(sum( ( repmat(Y(:,j),[1 n])- X ).^2 )');
end

%Compute optimal assignment and cost using the Hungarian algorithm
[assignment,cost]= o.hungarian_algorithm(D); %#ok<*NASGU,*ASGLU>

%Calculate final distance
dist = max([max(min(D,[],2)),max(min(D,[],1))]);
