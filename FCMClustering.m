function [center, U, obj_fcn] = FCMClustering(data, cluster_n)
% FCMClust.m   
%  
% input：
%   data        - nxm
%   N_cluster   - C
% output：
%   center      - centroid
%   U           - membership matrix
%   obj_fcn     - Xie-Beni index

data_n = size(data, 1); % row - count of channels
in_n = size(data, 2);   % column - data length

default_options = [2;   % membership U index
    100;                % max iteration
    1e-5;               % min membership, iteration stop condition
    1];                 % iteration output or not

options = default_options;

expo = options(1);          
max_iter = options(2);  
min_impro = options(3);  
display = options(4);  

obj_fcn = zeros(max_iter, 1); % initialize obj_fcn

U = initfcm(cluster_n, data_n);     % initialize fcm
% Main loop  
for i = 1:max_iter,
    
 [U, center, obj_fcn(i)] = stepfcm(data, U, cluster_n, expo);
 if display,
  fprintf('FCM:Iteration count = %d, obj. fcn = %f\n', i, obj_fcn(i));
 end
 % determine stop condition
 if i > 1,
  if abs(obj_fcn(i) - obj_fcn(i-1)) < min_impro,
            break;
        end,
 end
end

iter_n = i; % act no. of iter
obj_fcn(iter_n+1:max_iter) = [];

% subfunction
function U = initfcm(cluster_n, data_n)
% initialize fcm membership matrix U
% input:
%   cluster_n 
%   data_n    
% output：
%   U
U = rand(cluster_n, data_n);
col_sum = sum(U);
U = U./col_sum(ones(cluster_n, 1), :);

% subfunction
function [U_new, center, obj_fcn] = stepfcm(data, U, cluster_n, expo)
% fcm iteration step
% input：
%   data        
%   U           
%   cluster_n   
%   expo        - membership matrix exponent                   
% output：
%   U_new       - new membership matrix 
%   center      - new centroid
%   obj_fcn     - XB index
mf = U.^expo;       % exponential computation of membership matrix 
center = mf*data./((ones(size(data, 2), 1)*sum(mf'))'); 
dist = distfcm(center, data);       
obj_fcn = sum(sum((dist.^2).*mf));  
tmp = dist.^(-2/(expo-1));    
U_new = tmp./(ones(cluster_n, 1)*sum(tmp));  

% subfunction
function out = distfcm(center, data)
% compute distance
% input：
%   center     
%   data       
% output：
%   out        - distance
out = zeros(size(center, 1), size(data, 1));
for k = 1:size(center, 1), 
    % distance between sample point to center
    out(k, :) = sqrt(sum(((data-ones(size(data,1),1)*center(k,:)).^2)',1));
end