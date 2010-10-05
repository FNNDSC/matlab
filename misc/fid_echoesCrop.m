function [acropCount] = fid_echoesCrop(	astr_targetVolList,	...
					astr_cropDir,		...
					av_newDim,		...
					varargin)
%
% NAME
%
%  function [cropCount] = fid_echoesCrop(	astr_targetVolList,	...
%  						astr_cropDir,		...
%  						av_newDim [,
%						averbosity])
%
% ARGUMENTS
%	INPUT	
%	astr_targetVolList	string		a target string that is
%						fed to the system 'find'
%						process to flag a list
%						of volumes to crop
%	astr_cropDir		string		a directory to store the
%						cropped volumes
%	av_newDim		row vector	the dimensions to crop the
%						volume to
%				OPTIONAL
%	averbosity		int		verbosity level
%			
%	OUTPUT
%	acropCount		boolean		return - 
%						Number of volumes cropped.
%
% DESCRIPTION
%
%	'fid_echoesCrop' examines each volume identified in the 'find'
%	string <astr_targetVolList> and compares its volume size to the
%	dimensions passed in <av_newDim>. If the original size is larger
%	than <av_newDim>, the original volume is "centre-cropped" to
%	the <av_newDim> size. The resultant is saved to the directory
%	<astr_cropDir>.
%
% PRECONDITIONS
%
%	o volumes identified by <astr_targetVolList> are MGH format volumes.
%
% POSTCONDITIONS
%
%	o Any volumes larger than <av_newDim> are cropped to <av_newDim> and
%	  saved to the directory <astr_cropDir>.
%
% HISTORY
% 29 June  2006
% o Initial design and coding.
%

%%%%%%%%%%%%%% 
%%% Nested functions
%%%%%%%%%%%%%% 
	function vprintf(level, str_msg)
	    if verbosity >= level
		fprintf(1, str_msg);
	    end
	end
%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

%
% Create the string list of target volumes
%

verbosity	= 1;
if length(varargin)
	verbosity	= varargin{1};
end

if ~prod(+(size(av_newDim) == [ 1 3 ]))
	error_exit(	'checking on input dimension vector',	...
			'vector *must* be size [1 3].',		...
			'1');
end

str_findCMD		= sprintf('find . -name %s', astr_targetVolList);
[ret str_targetFiles]	= system(str_findCMD);
if ~sum(size(str_targetFiles))
	str_action  = sprintf('No hits were found with search token "%s".', ...
				astr_targetVolList);
	str_message = sprintf('searching for target volumes');
	error_exit(str_message, str_action, '-1');
end
str_findNumCMD		= sprintf('find . -name %s | wc -l', astr_targetVolList);
[ret str_numHits]	= system(str_findNumCMD);
str_numHits		= strtok(str_numHits, char(10));

[str_targetVolPath str_rem] = strtok(str_targetFiles, char(10));
str_pathStart=cd;
cd(astr_cropDir); astr_cropDir=cd;
acropCount	= 0;
while length(str_rem)
	cd(str_pathStart);
	str_dirnameCMD		= sprintf('dirname %s', str_targetVolPath);
	[ret str_targetVolDir]	= unix(str_dirnameCMD);
	str_targetVolFile	= basename(str_targetVolPath);
	str_targetVolStem	= strtok(str_targetVolFile, '.');
	vprintf(1, sprintf('%-6s', sprintf('%d/%s', acropCount+1, str_numHits)));
	vprintf(1, sprintf('%-50s', sprintf('Reading %s', 	...
						str_targetVolFile)));
	[V_mgh, M_vox2ras, v_mrParams]	= load_mgh2(str_targetVolPath);
	v_sizeOrig		= size(V_mgh);
	if ~prod(+(size(v_sizeOrig) == [ 1 3 ]))
	    error_exit(	'checking on orig dimension vector',	...
			'vector *must* be size [1 3].',		...
			'1');
	end
	v_Delta			= v_sizeOrig - av_newDim;
	v_d2			= v_Delta ./ 2;
	vprintf(1, sprintf('%10s', 'Cropping'));
	V_mghCrop		= V_mgh( 1+v_d2(1):v_sizeOrig(1)-v_d2(1), ...
					 1+v_d2(2):v_sizeOrig(2)-v_d2(2), ...
					 1+v_d2(3):v_sizeOrig(3)-v_d2(3));	
	str_mghCrop = sprintf('%s/%s', astr_cropDir, str_targetVolFile);
	vprintf(1, sprintf('%8s', 'Saving'));
	save_mgh2(V_mghCrop, str_mghCrop, M_vox2ras, v_mrParams);
	vprintf(1, sprintf('%7s\n', '[ ok ]'));
	acropCount = acropCount + 1;
	[str_targetVolPath str_rem] = strtok(str_rem, char(10));
end

end

