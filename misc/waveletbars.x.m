#!/usr/bin/octave -qH

function [] = waveletbars(varargin)
%
% NAME
%
%	function [] = waveletbars([astr_hemi])
%
% ARGUMENTS
%
%	INPUT
%	astr_hemi	string (optional)	a string denoting the 
%						hemisphere to process: 
%						either 'lh' or 'rh'.
%						Default: 'lh'. 
%
% DESCRIPTION
%
%	'waveletbars' simply runs through the wavelet principle curvature
%	analysis for a given hemisphere, ending with a table of values
%	in the command window. In addition the 'k1' plots and a bar graph
%	of the negative curvature fraction are also generated.
%
% PRECONDITIONS
%
%	o Sub directories contain the curvature files that are read.
% 
% SEE ALSO
%
% HISTORY
% 07 July 2006
% o Initial design and coding.
%
%

str_hemi	= 'lh';
if length(varargin)
	str_hemi	= varargin{1};
end

fprintf(1, '%s.smoothwm.K\n', str_hemi);
[cell_curv, cell_n]= curvs_plot('lh.smoothwm.K', 1000, -1, 1);
[M_table] = lzg_summary(cell_curv, cell_n, 1);
K=M_table(:,1);
fprintf(1, '\n')

fprintf(1, '%s.smoothwm.H\n', str_hemi);
[cell_curv, cell_n]= curvs_plot('lh.smoothwm.H', 1000, -1, 1);
[M_table] = lzg_summary(cell_curv, cell_n, 1);
H=M_table(:,1);
fprintf(1, '\n')

fprintf(1, '%s.smoothwm.K2\n', str_hemi);
[cell_curv, cell_n]= curvs_plot('lh.smoothwm.K2', 1000, -1, 1);
[M_table] = lzg_summary(cell_curv, cell_n, 1);
k2=M_table(:,1);
fprintf(1, '\n')

fprintf(1, '%s.smoothwm.K1\n', str_hemi);
[cell_curv, cell_n]= curvs_plot('lh.smoothwm.K1', 1000, -1, 1);
[M_table] = lzg_summary(cell_curv, cell_n, 1);
k1=M_table(:,1);
fprintf(1, '\n')

figure;

T = [K H k2 k1];
t=0:7;
bar(t, T);
legend('K', 'H', 'k1', 'k2');
title('Percentage negative curvature as function of wavelet spectral power');
xlabel('Wavelet spectral power');
ylabel('Fraction negative curvature');


