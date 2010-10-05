function  [y] = sigmoidal(x)
%%
%% NAME
%%
%%     sigmoidal
%%
%% SYNOPSIS
%%
%%     [y] = function sigmoidal(x)
%%
%% ARGS
%%
%%     y       out         return value of function
%%     x       in          dependent variable
%%
%% DESC
%%
%%     This function is a simple test of sigmoidal bias weighting.
%%
%% HISTORY
%%
%%     26 July 2003
%%     o Initial design and coding
%%

dim = size(x);
for i=1:dim(2)
%%    y(i) = 1 / (1+exp(-x(i)/30));
    y(i) = abs(-1 + 2/ (1+exp(-x(i)/30)));
end