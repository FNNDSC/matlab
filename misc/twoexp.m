function y=twoexp(n)

% y=twoexp(n). This is a recursive program for computing
% y=2^n. The program halts only if n is a nonnegative integer.

if n==0, y=1;
   else y=2*twoexp(n-1);
end

