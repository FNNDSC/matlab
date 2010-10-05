function [m, b] = line_solve2(X, Y)
%%
%% NAME
%%
%%     line_solve2.m
%%
%% SYNOPSIS
%%
%%     [m b] = line_solve2(X, Y)
%%
%% ARGUMENTS
%%      X		in      column vector specifying X
%%	Y		in	column vector specifying Y = f(X)
%%
%%      m		out     slope of fitted line
%%	b		out	y-intercept of fitted line
%%
%% DESCRIPTION
%%	
%%	line_solve1 finds a "fitted" line of the form
%%
%%		y = mx + b
%%
%%	that satisfies the input X and Y column vectors. Effectively, 
%%	the slopes (m) and intercepts (b) for all lines segments between
%%	adjacent points are determined and averaged.
%%
%% PRECONDITIONS
%%
%%	o X and Y are row vectors.
%%	o X and Y must be same size.
%%
%% POSTCONDITIONS
%%
%% HISTORY
%%
%% 24 May 2004
%% o Initial design and coding.
%%

[rows cols]	= size(X);

M		= zeros(1, cols-1);
B 		= zeros(1, cols-1);

for i=2:cols,
	M(i-1)	= (Y(i)-Y(i-1))/(X(i)-X(i-1));
	B(i-1)	= Y(i) - M(i-1)*X(i);
end

m 	= mean(M);
b 	= mean(B);
