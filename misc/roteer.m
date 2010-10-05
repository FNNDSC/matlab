function [M_R] = roteer(M_V, theta)
%%
%% NAME
%%
%%     roteer.m (rotate M_V by theta radians) 
%%
%% AUTHOR
%%
%%	Rudolph Pienaar
%%
%% VERSION
%%
%%	$Id$
%%
%% SYNOPSIS
%%
%%     [M_R] = roteer(M_V, theta)
%%
%% ARGUMENTS
%%
%%	M_V		in	3x3 matrix
%%      theta		in      radians to rotate
%%	M_R		out	rotated matrix
%%
%% DESCRIPTION
%%
%%	"roteer" (Afrikaans for rotate) rotates an input 3x3 matrix M_V 
%%	by theta radians about the third column.
%%
%% PRECONDITIONS
%%
%%	o M_V is 3x3
%%	o Rotation is about the third column.
%%
%% POSTCONDITIONS
%%
%%	o M_R is a rotated matrix.
%%
%% HISTORY
%%
%% 02 June 2004
%% o Initial design and coding.
%%

M3_Mu	= [	 cos(theta_f)	 sin(theta_f)	0
		-sin(theta_f)	 cos(theta_f)	0
		 	0		0	1];
			
M_R	= M_V * M3_Mu;
