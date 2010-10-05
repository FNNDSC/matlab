function [y, del, sum] = converge

%
% Convergence trajectory
%

i   = 0:0.001:1;
y   = exp(10*i);
y   = y * 2.88;

for k = 1:1001
    del(k)  = rand * y(k);
end

sum = y+del;




