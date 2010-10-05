function [aM] = 	...
			stats_flatK2(varargin)
%
% NAME
%
%  function [aM] = stats_flatK2(<av_thresholds>)
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%	av_thresholds	vector		a vector of thresholds that
%					define the limit of "flat"
%					K curvature measures.
%
% OUTPUTS
%	aM		matrix		table of percentage values for
%					decreasing "flat" curvature
%					threshold.
%
% DESCRIPTION
%
%	'stats_flatK2' examines each numerical subdirectory from its
%	current working directory and processes the 'rh.smoothwm.K'
%	curvature.
%
%	The percentage a curvature values greater than a decreasing
%	threshold is returned. This threshold is derived from a set
%	of descending radii of osculating circles. Since the 'K'
%	is assumed to be a Gaussian, the area of a circular patch
%	subtended by the given radii is returned.
%
%	The core purpose of this script is to provide supporting 
%	evidence that the majority of K curvature values are in fact
%	quite low. Since there is a measurement noise threshold beneath
%	which K curvatures can be considered "flat" this function
%	demonstrates what percentage of a given surface is "flat".
%
% PRECONDITIONS
%
%	o A set of directories branching from the working directory. These
%	  directories denote specific subjects and must be 'numeric' named -
%	  a good strategy is to use the subject age as a name.
%
%	o 'rh.smoothwm.K'
%
% POSTCONDITIONS
%
%	o Table of thresholds and "flat" percentages are returned.
%
% SEE ALSO
%
% HISTORY
% 15 March 2007
% o Initial design and coding.
%
%

%%%%%%%%%%%%%% 
%%% Nested functions
%%%%%%%%%%%%%% 
	function error_exit(	str_action, str_msg, str_ret)
		fprintf(1, '\tFATAL:\n');
		fprintf(1, '\tSorry, some error has occurred.\n');
		fprintf(1, '\tWhile %s,\n', str_action);
		fprintf(1, '\t%s\n', str_msg);
		error(str_ret);
	end

	function vprintf(level, str_msg)
	    if verbosity >= level
		fprintf(1, str_msg);
	    end
	end

	function [f_scale]		= scaleFactor_lookup(astr_dirName)
		%
		% ARGS
		% 		input
		% astr_dirName		name of directory containing file
		%
		%		output
		% f_scale		scale factor
		%
		% DESCRIPTION
		% This function is a simple lookup-table that returns the scale
		% factor associated with a given <astr_dirName>.
		%
		% PRECONDITIONS
		% o <astr_dirName> must be a name defined in the lookup table
		%
		% POSTCONDITIONS
		% o The scale factor corresponding to <astr_dirName> is
		%   returned.
		%
		switch astr_dirName
		   case '30.4'
			f_scale = 2.32727;
			f_scale = 1.5;
		   case '31.1'
			f_scale = 2.00000;
		   case '34.0'
			f_scale = 2.50000;
		   case '36.7'
			f_scale = 1.60000;
		   case '37.5'
			f_scale = 1.55151;
		   case '38.1'
			f_scale = 2.00000;
		   case '38.4'
			f_scale = 2.00000;
		   case '39.7'
			f_scale = 2.00000;
		   case '40.3'
			f_scale = 1.66667;
		   case '104'
			f_scale = 1.25000;
		   case '156'
			f_scale = 1.25000;
		   case '365'
			f_scale = 1.25000;
		   case '801'
			f_scale = 1.00000;
		   case '2054'
			f_scale = 1.00000;
		   otherwise
			f_scale = 1.0;
		end
		f_scale = 1.0;
  		f_scale = f_scale^2;
	end

	function [av_curv, fnum]	= read_curvScale(astr_curvFile, astr_dirName)
		%
		% ARGS
		% 		input
		% astr_curvFile		name of curvature file to open
		% astr_dirName		name of directory containing file
		%
		%		output
		% av_curv		curvature vector
		% fnum			fnum from file		
		%
		% DESCRIPTION
		% This function "scales" the curvature values in the passed
		% <astr_curvFile> based on a lookup table of <astr_dirName>.
		%
		% PRECONDITIONS
		% o <astr_dirName> must be a name defined in the lookup table
		%
		% POSTCONDITIONS
		% o <av_curv> is scaled by a factor defined by <astr_dirName>
		% o if no lookup if found, the scale reverts to 1.0
		%

  		f_scale 	= scaleFactor_lookup(astr_dirName);
		[av_curv, fnum]	= read_curv(astr_curvFile);
		fprintf(1, '%60s', sprintf('Reading %s: scaling curvatures by %f', astr_dirName, f_scale));
		av_curv		= av_curv * f_scale;
		fprintf(1, '%20s\n', '[ ok ]');
	end


	function [L] = flen(R)
		L = atan(1./R) .* R;
	end

	function [A] = fsa(R)
		L = flen(R);
		A = L.^2;
	end

	function [A] = fsa2(R)
		A = 2*pi*R.^2.*(1-cos(1/2*atan(1./R)));
	end

	function [A] = fsa3(R)
		A = R.^2.*atan(1./R).*(1-cos(atan(1./R)));
	end


av_r		= 1:10;

if length(varargin)
	av_r	= varargin{1};
end
radii		= length(av_r);
av_thresholds	= 1./(av_r.^2);

[status,str_dirAll]= system('/bin/ls -d [0-9]* | sort -n');
str_start= pwd;
% Create a cell array of the directory names
ndir= 1;
[str_dir str_rem]= strtok(str_dirAll);
cell_dir{ndir}= str_dir;
while length(str_rem)
	[str_dir str_rem]= strtok(str_rem);
	ndir= ndir + 1;
	cell_dir{ndir}= str_dir;
end

rows=		ndir - 1;
aM=		zeros(rows+6, radii+1);	% 4 intro + 2 tail
aM(1,1)		= 0;
aM(2,1)		= 0;
aM(3,1)		= 0;
aM(4,1)		= 0;
aM(rows+5,1)	= 0;
aM(rows+6,1)	= 0;
aM(1,2:radii+1)	= av_r;
aM(2,2:radii+1)	= av_thresholds;
aM(3,2:radii+1)	= flen(av_r); 
%  aM(4,2:radii+1)	= fsa(av_r); 
aM(4,2:radii+1)	= fsa2(av_r) / pi / (0.5)^2;
cell_subj=	cell_dir(1:rows);

for subj=	1:rows
	str_curv	= sprintf('./%s/rh.smoothwm.K', cell_subj{subj});
	[v_curv, fnum]	= read_curvScale(str_curv, cell_subj{subj});
	v_curv		= abs(v_curv);
	curvElements	= length(v_curv);
	i		= 1;
	for r		= av_r
%  		f_threshold	= 1/av_r(i);
		f_threshold2	= av_thresholds(i);
		v_nz		= find(v_curv > f_threshold2);
		nz		= length(v_nz);
		f_nz		= nz / curvElements;
		f_z		= 1 - f_nz;
		aM(subj+4, 1)	= str2num(cell_subj{subj});
		aM(subj+4, i+1)	= f_z * 100;
		i		= i+1;
	end
end

[rows cols]		= size(aM);
M_data			= aM(5:rows-2, 2:cols);
v_mean			= mean(M_data);
v_std			= std(M_data);
aM(rows-1,2:cols)	= v_mean;
aM(rows,2:cols)		= v_std;
str_format	= '';
for col	= 1:cols-1
	str_format	= sprintf('%s%st%s2.2f', str_format, char(92), char(37));
end
str_format	= sprintf('%s4.1f%s%sn', char(37), str_format, char(92));
fid	= fopen('flatK.txt', 'w');
fprintf(fid, str_format, aM');
fclose(fid);

end