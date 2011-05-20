function [fh] = spectrum_barh(astr_dataFile, varargin)
%
% NAME
%
%       function [fh] = spectrum_barh( 	astr_dataFile,   		...
%					[astr_xLabel,			...
%					 astr_yLabel,			...
%					 astr_title])
%
% ARGUMENTS
%       
%       INPUT
%       astr_dataFile			string		file containing spectrum
%
%       OPTIONAL
%	astr_xLabel			string		x label text
%	astr_yLabel			string		y label text
%       astr_title              	string          plot title
%
%       OUTPUT
%       fh				handle		figure handle
%
% DESCRIPTION
%
%	Plots horizontal bar plots for spectrum data. The <astr_dataFile>
%	contains 2 columns with the 1st column denoting the spectrum
%	(text) ordering, and the 2nd column the spectrum corresponding to that
%	ordering index.
%
% PRECONDITIONS
% 
%       o None.
%
% POSTCONDITIONS
% 
%       o None.
%
% HISTORY
% 19 May 2011
% o Initial design and coding.
%

str_xLabel	= 'Spectrum';
str_yLabel	= 'Ordering enumeration';
str_title	= 'Permutation spectrum';

if length(varargin) >= 1, str_xlabel 	= varargin{1};	end
if length(varargin) >= 2, str_ylabel 	= varargin{1};	end
if length(varargin) >= 3, str_title 	= varargin{1};	end

M_spect 	= load(astr_dataFile);
c_label		= num2cell(M_spect(:,1));
v_spectrum	= M_spect(:,2);
fh 			= barh(v_spectrum);
set(gca,'YTick',[1:length(c_label)],'YGrid','on'); 
set(gca,'YTickLabel',c_label);
set(gca,'FontSize',8);

xlabel(str_xLabel);
ylabel(str_yLabel);
title(str_title);

