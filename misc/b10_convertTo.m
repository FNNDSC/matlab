function [num_10] = b10_convertTo(num_r, radix)

num_10 = 0;

[row,col] = size(num_r);

for i=1:col,
  num_10 = num_10 + (num_r(col-i+1) * radix^(i-1));
end
