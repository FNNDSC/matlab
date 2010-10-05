function [Thr, f, F] = nicd_drive(varargin)
%
% NAME
%
%  	function [Thr, f, F] = nicd_drive([analysis_type])
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%	analysis_type	int		One of 1,2,3,4 indicating
%					which data set to process.
%	saveExt		string		The suffix string (extension
%					type) for image saving (an eps
%					file is also saved regardless
%					of this <saveExt>).
%					
%
%
% OUTPUT
%	Thr		vector		Period time in hours
%	f		vector		frequencies in Hz
%	F		vector		signal amplitude at each f	
%
% DESCRIPTION
%
%	This function is a scratch space for exploring the frequency components
%	of Verne's NiCD data.
%
% PRECONDITIONS
%
%
% POSTCONDITIONS
%
%	o Returns <F> the mag FFT of the internal signal and <f> the frequency
%	  components.
%
% NOTE:
%
% EXAMPLE:
%
%	[Thr f F] = nicd_drive(2);	% Analyze nicd
% 
% HISTORY
% 17 July 2007
% o Initial design and coding.
%
% 12 September 2007
% o Split off separate nicd_analyze component.
%


LC		= 50;
RC		= 30;

q		= 1;
str_saveExt	= 'jpg';

if(length(varargin) >=1), q 		= varargin{1};, end
if(length(varargin) >=2), str_saveExt 	= varargin{2};, end

p27 = [
0.54
0.53
0.62
1
0.61
0.82
0.6
0.73
0.64
0.58
0.74
0.57
0.45
0.68
0.74
0.72
0.67
0.42
0.25
];

nicd = [
0.4
0.59
1
0.64
0.66
0.66
1.04
0.98
1.09
1.24
1.06
1.09
1.01
0.74
0.92
1.29
0.85
1.11
0.35
];

p27inp27nicd = [
0.75
0.6
1.27
1
0.61
0.7
0.71
0.69
0.51
0.59
0.66
0.65
0.81
0.52
0.51
0.66
0.51
0.53
0.59
];

nicdinp27nicd = [
0.1
0.15
1
0.34
0.14
0.41
0.83
0.92
2.2
2.02
1.67
1.6
1.07
1.19
2.52
2.77
1.62
1.83
2.2
];

str_titleTD	= 'Time domain plot';
str_xlabelTD	= 'Time (hours)';
str_ylabelTD	= 'Concentration';
str_titleFD	= 'Oscillation profile';
str_xlabelFD	= 'Oscillation (hours)';
str_ylabelFD	= 'Relative oscillation contribution';
str_saveFile	= 'p27';

switch(q)
    case {1}
	v_q 		= p27;
	str_titleTD 	= sprintf('%s of Transfection of p27^K^i^p^1', str_titleTD);
	str_titleFD 	= sprintf('%s of Transfection of p27^K^i^p^1', str_titleFD);
	str_saveFile	= 'p27';
    case {2}
	v_q 		= nicd;
	str_titleTD 	= sprintf('%s of Transfection of NIDC', str_titleTD);
	str_titleFD 	= sprintf('%s of Transfection of NIDC', str_titleFD);
	str_saveFile	= 'nicd';
    case {3}
	v_q 		= p27inp27nicd;
	str_titleTD 	= sprintf('%s of Co-Transfection of p27^K^i^p^1 + NICD', str_titleTD);
	str_titleFD 	= sprintf('%s of Co-Transfection of p27^K^i^p^1 + NICD', str_titleFD);
	str_saveFile	= 'p27inp27nicd';
    case {4}
	v_q 		= nicdinp27nicd;
	str_titleTD 	= sprintf('%s of Co-Transfection of NICD + p27^K^i^p^1', str_titleTD);
	str_titleFD 	= sprintf('%s of Co-Transfection of NICD + p27^K^i^p^1', str_titleFD);
	str_saveFile	= 'nicdinp27nicd';
end
str_imageFile		= sprintf('%s.%s', str_saveFile, str_saveExt);
v_t		= 0.0:0.5:9.0;
[f F]		= nicd_analyze(v_t, v_q',			...
					str_titleTD,		...
					str_xlabelTD,		...
					str_ylabelTD,		...
					str_titleFD,		...
					str_xlabelFD,		...
					str_ylabelFD,		...
					str_imageFile);

Thr		= 1 ./ ( f*3600);