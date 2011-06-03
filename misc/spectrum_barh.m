function [fh] = spectrum_barh(astr_dataFile, varargin)
%
% NAME
%
%       function [fh] = spectrum_barh( 	astr_dataFile,   		...
%					[ab_probability,                ...
%                                        astr_title,                    ...
%                                        astr_xLabel,			...
%					 astr_yLabel])
%
% ARGUMENTS
%       
%       INPUT
%       astr_dataFile			string		file containing 
%                                                       + spectrum
%
%       OPTIONAL
%       ab_probablity                   int             if non-zero, express
%                                                       + bar values as c/N
%                                                       + where c is value and
%                                                       + N is total possible
%                                                       + observations
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

b_probability   = 0;
str_xLabel	= 'Spectrum';
str_yLabel	= 'Ordering enumeration';
str_title	= 'Probability of group ordering';

if length(varargin) >= 1, b_probability = varargin{1};  end
if length(varargin) >= 2, str_title     = varargin{2};  end
if length(varargin) >= 3, str_xlabel 	= varargin{3};	end
if length(varargin) >= 4, str_ylabel 	= varargin{4};	end

M_spect 	= load(astr_dataFile);
c_label		= num2cell(M_spect(:,1));
v_spectrum	= M_spect(:,2);
if b_probability
    v_spectrum  = v_spectrum / sum(v_spectrum);
    str_xLabel  = sprintf('%s probability', str_xLabel);
end
fh 		= barh(v_spectrum);
set(gca,'YTick',[1:length(c_label)],'YGrid','on'); 
set(gca,'YTickLabel',c_label);
set(gca,'FontSize',8);

xlabel(str_xLabel);
ylabel(str_yLabel);
title(str_title);

str_epsFile     = sprintf('%s.eps', astr_dataFile);
str_jpgFile     = sprintf('%s.jpg', astr_dataFile);
str_pdfFile     = sprintf('%s.pdf', astr_dataFile);
print('-depsc2', str_epsFile);
print('-djpeg',  str_jpgFile);
print('-dpdf',   str_pdfFile);

