function dist = find_ospa_metric(o, X, Y, c, p)

% This code is adapted from that by B. Vo.
% Compute Schumacher distance between two finite sets X and Y
% as described in the reference
% [1] D. Schuhmacher, B.-T. Vo, and B.-N. Vo, "A consistent metric for performance evaluation in multi-object
% filtering," IEEE Trans. Signal Processing, Vol. 56, No. 8 Part 1, pp. 3447?3457, 2008.

% Inputs: X,Y-   matrices of column vectors
%        c  -   cut-off parameter (see [1] for details)
%        p  -   p-parameter for the metric (see [1] for details)
% Output: scalar distance between X and Y
% Note: the Euclidean 2-norm is used as the "base" distance on the region

if isempty(X) && isempty(Y)
    dist = 0;
    return;
end

if isempty(X) || isempty(Y)
    dist = c;
    return;
end

%Calculate sizes of the input point patterns
n = size(X,2);
m = size(Y,2);

%Calculate cost/weight matrix for pairings - slow method with for loop
D= zeros(n,m);
for j=1:m
    D(:,j)= sqrt(sum((repmat(Y(:,j),[1 n]) - X).^2))';
end
D= min(c,D).^p;

%Compute optimal assignment and cost using the Hungarian algorithm
[~, cost]= o.hungarian_algorithm(D);

%Calculate final distance
dist= ( 1/max(m,n)*( c^p*abs(m-n)+ cost ) ) ^(1/p);