function [f]    = fact(n)
%//
%// ARGS
%//   f         out         factorial value: f=n!
%//   n         in          argument
%//
%// DESC
%//   This method determines the factorial of n.
%//
%// PRECONDITIONS
%// o This is a recursive algorithm, so heap space for
%//   large n might be a problem.
%//
%// POSTCONDITIONS
%// o The factorial is ultimately returned
%//
%// HISTORY
%// 21 September 2001
%// o Intial design and coding.
%//

if(n==0)
    f = 0;
else 
    f = n + rsum(n-1);
end
