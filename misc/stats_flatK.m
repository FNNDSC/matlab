function [aM] = 	...
			stats_flatK(varargin)
%
% NAME
%
%  function [aM] = stats_flatK(<av_thresholds>)
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
%	'stats_flatK' examines each numerical subdirectory from its
%	current working directory and processes the 'rh.smoothwm.K'
%	curvature.
%
%	The percentage a curvature values greater than a decreasing
%	threshold is returned.
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

av_thresholds=	[ 0.5 0.4 0.3 0.2 0.1 ];

if length(varargin)
	av_thresholds = varargin{1};
end

thresholds	= length(av_thresholds);

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
aM=		zeros(rows, thresholds+1);
cell_subj=	cell_dir(1:rows);

for subj=	1:rows
	str_curv	= sprintf('./%s/rh.smoothwm.K', cell_subj{subj});
	v_curv		= read_curv(str_curv);
	curvElements	= length(v_curv);
	for i		= 1:thresholds
		f_threshold	= av_thresholds(i);
		f_threshold2	= f_threshold^2;
		v_nz		= find(v_curv > av_thresholds(i));
		nz		= length(v_nz);
		f_nz		= nz / curvElements;
		f_z		= 1 - f_nz;
		aM(subj, 1)	= str2num(cell_subj{subj});
		aM(subj, i+1)	= f_z * 100;
	end
end

fid	= fopen('flatK.txt', 'w');
fprintf(fid, '%4.1f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n', aM');
fclose(fid);
