function [cell_curv, cell_n, cell_processedDir]	= ...
		curvs_plot(astr_curvFile, varargin)
%
% NAME
%
%	function [cell_curv, cell_n, cell_processedDir] = 	...
%  				curvs_plot(astr_curvFile [, 	...
%					  a_bins,		...
%					  ab_normalize,		...
%					  af_leftBound,		...
%					  af_rightBound, 	...
%					  ab_drawPlots,		...
%  					  ab_animate,		...
%					  af_ymin, 	 	...
%					  af_ymax]		...
%					  )
%
% ARGUMENTS
%    INPUTS
%	astr_curvFile	string		the FreeSurfer-type curvature file.
%					All files with this name in the first
%					level subdirectories are processed by
%					this function.
%
%    OPTIONAL INPUTS 
%	a_bins		int 		histogram bins.
%	ab_normalize	bool		if true, normalize the histogram to the
%					number of elements in the curvature
%					file.
%	af_leftBound	double		an optional limit on the left bound
%					of the histogram plots.
%	af_rightBound	double		an optional limit on the right bound
%	ab_drawPlots	bool		if not true, the function will not 
%					actually display any plots, and will 
%					only return the curvature and histogram 
%					cell arrays. This is useful for quick
%					display-free analysis.
%	ab_animate	bool		if true, plot all the figures onto the
%					same screen figure object. This has the
%					effect of creating a 'pseudo' animated
%					result.
%	af_ymin/af_ymax	double 		bounds on the y axis for each plot.
%
%    OUTPUTS
%	cell_curv	cell		a cell array of the individual
%					curvatures ('ls' ordered).
%	cell_n		cell		a cell array of the histograms
%					for each curvature.
%	cell_processedDir cell		a cell array of the actual directory
%					names that were processed.
%
% DESCRIPTION
%
%	'curvs_plot' walks down a first level of directories branching off
%	the current, and processes all FreeSurfer files called 'astr_curvFile'.
%	These are then plotted.
%
%	The idea really is that a series of subject curves are stored in a 
%	set of subdirectories. Each curve for each subject has the same
%	name, <astr_curvFile>, which is then captured and plotted by
%	this function.
%
%	The behaviour of this function is therefore implicitly dependent on
%	the directory structure of the working directory in which is it run. 
%	To some extent this can be modified by different specification of
%	the <astr_curvFile> argument. Such options are beyond the scope of
%	this document. By default it has been assumed that the directory
%	structure specifies the curves to process.
%
% PRECONDITIONS
%
%	o Display is optimised for 6 subjects.
%	o af_leftBound and af_rightBound can be turned off by passing a 
%	  char argument, say '0'.
%
% POSTCONDITIONS
%
%	o Each <astr_curvFile> is plotted, and returned.
%
%
% HISTORY
% 20 December 2005
% o Initial design and coding.
%
% 09 January 2006
% o Added cell_n
%
% 14 July 2006
% o Fixed dir handling if non-integer dir names
%
% 10 November 2006
% o Added 'f_scale' to curvature file reading
%
% 21 September 2007
% o Generalisation refactoring design.
%
% 15 October 2007
% o Consider possible K curvature filtering
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
                   case '107'
                        f_scale = 1.25000;
                   case '160'
                        f_scale = 1.25000;
                   case '208'
                        f_scale = 1.25000;
		   case '801'
			f_scale = 1.00000;
		   case '2054'
			f_scale = 1.00000;
		   otherwise
			f_scale = 1.0;
		end
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
		% Some of the curvs, viz. the K and S need a quadratic scale factor
		str_CMD1	= sprintf('echo %s | xargs -i%s basename %s |', 	...
						astr_curvFile, char(37), char(37));
		str_CMD		= sprintf('%s awk -F %s. %s{printf("%ss", $(NF))}%s',	...
						str_CMD1, char(92), char(39), 		...
						char(37), char(39));
		[ret str_curv]	= system(str_CMD);
		b_square	= 0;
		if strcmp(str_curv, 'K')
			b_square	= 1;
		end
		if strcmp(str_curv, 'S')
			b_square	= 1;
		end
		if b_square
			f_scale = f_scale * f_scale;
		end		
		fprintf(1, '%60s', sprintf('Reading %s: scaling curvatures by %f', astr_dirName, f_scale));
		av_curv		= av_curv * f_scale;
		fprintf(1, '%20s\n', '[ ok ]');
	end


%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

b_animate	= 1;
bins		= 100;
b_leftBoundSet	= 0;
b_rightBoundSet	= 0;
b_yminSet	= 0;
b_ymaxSet	= 0;
b_normalize	= 0;
b_drawPlots	= 1;
if length(varargin)
	if length(varargin) >= 1
		bins = varargin{1};
		if ~isnumeric(bins)
		    error_exit('checking on bins',		...
			   '<bins> must be numeric',	...
			   '10');
		end
	end
	if length(varargin) >= 2
		b_normalize = varargin{2};
		if ~isnumeric(b_normalize)
		    error_exit('checking on normalize flag',	...
			   '<ab_normalize> must be bool',	...
			   '20');
		end
	end
	if length(varargin) >= 3
		leftBound	= varargin{3};
		if isnumeric(leftBound)
			b_leftBoundSet	= 1;
			rightBound	= leftBound;
		end
	end
	if length(varargin) >= 4
		rightBound   = varargin{4};
		if isnumeric(rightBound)
			b_rightBoundSet = 1;
		    if (leftBound >= rightBound)
			error_exit('checking on bounds', 	   	...
				'<leftBound> >= <rightBound>', 		...
				'30'); 
		    end
		end
	end
	if length(varargin) >= 5
		b_drawPlots = varargin{5};
		if ~isnumeric(b_drawPlots)
		    error_exit('checking on drawPlots flag',	...
			   '<ab_drawPlots> must be bool',	...
			   '40');
		end
	end
	if length(varargin) >= 6
		b_animate = varargin{6};
		if ~isnumeric(b_drawPlots)
		    error_exit('checking on animate flag',	...
			   '<ab_animate> must be bool',	...
			   '50');
		end
	end
	if length(varargin) >= 7
		ymin = varargin{7};
		b_yminSet	= 1;
		if ~isnumeric(ymin)
		    error_exit('checking on ymin',		...
			   '<ymin> must be numeric',	...
			   '60');
		end
	end
	if length(varargin) == 8
		ymax = varargin{8};
		b_ymaxSet	= 1;
		if ~isnumeric(ymax)
		    error_exit('checking on ymax',		...
			   '<ymax> must be numeric',	...
			   '61');
		end
		if (ymin >= ymax)
		    error_exit('checking on bounds', 	   	...
			'<ymin> >= <ymax>', 		...
			'31'); 
		end
	end
end

[status,str_dirAll]	= system('/bin/ls -d [0-9]*');
if status
	error_exit(	'accessing subject dirs', ...
	'no subject dirs were found! Are you in the subject root dir?',...
			 '1');
end
[status,str_dirAll]	= system('/bin/ls -d [0-9]* | sort -n');
str_start		= pwd;
[status, str_subjDir]	= system('echo $SUBJECTS_DIR');

% Create a cell array of the directory names
ndir			= 1;
[str_dir str_rem]	= strtok(str_dirAll);
cell_dir{ndir}		= str_dir;
while length(str_rem)
	[str_dir str_rem]	= strtok(str_rem);
	ndir			= ndir + 1;
	cell_dir{ndir}		= str_dir;
end

% Create string array from results - each directory will be a separate element:
cols			= ndir - 1;
cell_curv		= cell(1, cols);
cell_n			= cell(1, cols);
if b_drawPlots
    scrsz = get(0,'ScreenSize');
%      h = figure('Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);
%      h = figure('Position',[1 1000 1500 1000]);
    h = figure('Position',[1 1 850 550]);
end
for dir = 1:cols
	%str_dir		= num2str(a_dirAll(dir));
	cell_processedDir{dir}	= cell_dir{dir};
	str_dir			= cell_dir{dir};
	cd(str_dir);
%  	[cell_curv{dir}, fnum]	= read_curv(astr_curvFile);
	[cell_curv{dir}, fnum]	= read_curvScale(astr_curvFile, cell_dir{dir});
	[curvrows curvcols]	= size(cell_curv{dir});
	if b_leftBoundSet & b_rightBoundSet
	    cell_curv{dir} = cell_curv{dir}(cell_curv{dir}>=leftBound & ...
					    cell_curv{dir}<=rightBound);
	    curvmin	= leftBound;
	    curvmax	= rightBound;
	else
	    curvmin	= min(cell_curv{dir});
	    curvmax	= max(cell_curv{dir});
	end
	dt		= (curvmax - curvmin) / bins;
	t		= curvmin: dt : curvmax - dt;
		
	if b_drawPlots & ~b_animate
	    if cols == 6
		subplot(2, 3, dir);
	    elseif cols == 4
		subplot(2, 2, dir);
	    elseif cols == 7
		subplot(2, 4, dir)
	    elseif cols == 8
		subplot(2, 4, dir)
	    elseif cols == 9
		subplot(3, 3, dir)
	    elseif cols == 10
		subplot(5, 2, dir)
	    elseif cols == 12
		subplot(3, 4, dir)
	    elseif cols == 13
		subplot(5, 3, dir)
	    elseif cols == 15
		subplot(5, 3, dir)
	    elseif cols == 20
		subplot(5, 4, dir)
	    else
		figure(dir);
	    end
	end
	[fx, xout]	= hist(cell_curv{dir}, bins);
	if size(fx) ~= size(xout)
	    fprintf(1, 'Warning! Size mismatch detected fx, xout.\n');
	    fprintf(1, 'Warning! This probably means you should not trust this set.\n');
	    fprintf(1, 'Warning! Attempting a hack by transposing xout\n');
	    xout = xout';
	end
	if b_normalize
	    fx		= fx ./ curvrows * bins;
	    if b_drawPlots
		if b_animate
		    figure(h)
		end
  		bar(xout, fx);
		v 	= axis;
		v(1)	= curvmin;
		v(2)	= curvmax;
		axis(v);
	    end
	else
	    if b_drawPlots
		hist(cell_curv{dir}, bins);
	    end
	end
	try
	    fX		= [xout' fx'];
  	catch
	    fprintf('An error was caught: fX = [xout fx]\n');
	    fprintf('size xout (transposed):');
	    disp(size(xout'))
	    fprintf('size fx   (transposed):');
	    disp(size(fx'))
      	end
	% Delta line: (backward compat)
	cell_n{dir} 	= fX;
	if b_drawPlots
	    title(str_dir);
	    if b_yminSet & b_ymaxSet
		axis([ leftBound rightBound ymin ymax ])
	    end
	    grid;
	    str_epsFile= sprintf('hist-%s-%s.eps', str_dir, astr_curvFile);
	    print('-depsc2', str_epsFile);	    
	end
	cd(str_start);
end

end