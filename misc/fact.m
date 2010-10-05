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

if(n==1)
    f = 1;
else 
    f = n * fact(n-1);
end
