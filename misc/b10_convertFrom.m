function [num_r] = b10_convertFrom(num_10, radix, varargin)
%
% function [num_r] = b10_convertFrom(num_10, radix <, forcelength>)
%
% ARGS
%     num_10            in      number in base 10
%     radix             in      radix to convert to
%     forcelength       in      if nonzero, indicates the length
%                               + of the returned vector
%
% DESC
%     Converts a scalar from base 10 to base radix. Return
%     is a "vector".
%
% HISTORY
% 21 September 2001
% o Added forcelength;

i = 0;
k = 1;
forcelength = 0;

if length(varargin)
    forcelength = varargin{1};
end
    
% Cycle up in powers of radix until the largest exponent is found.
while (radix^i) <= num_10,
  i = i+1;
end

if(forcelength & (forcelength < i))
    error('forcelength is too small')
end

numm = num_10;
if(forcelength)
    num_r = zeros(1, forcelength);
    if(i)
        k = forcelength - i + 1;
    else
        k = forcelength;
    end
end
if(num_10==1) 
    num_r(k) = 1;
    return;
end
for j=i:-1:1,
  num_r(k) = fix(numm / radix^(j-1));
  numm = rem(numm, radix^(j-1));
  k = k+1;
end
