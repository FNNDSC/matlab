function [aM_hist] = histogram(av_image, varargin)
% NAME
%
%  function [M_hist] = histogram(	av_curv [,	...
%					a_bins,		...
%					ab_normalize,	...
%					af_leftBound,	...
%					af_rightBound, 	...
%					af_ymin,  	...
%					af_ymax]	...
%			)
%
% ARGUMENTS
%    INPUTS
%	av_image	vector		data to analyze.
%
%    OPTIONAL INPUTS 
%	a_bins		int 		histogram bins.
%	ab_normalize	bool		if true, normalize the histogram.
%	af_leftBound	double		an optional limit on the left bound
%					of the histogram plots.
%	af_rightBound	double		an optional limit on the right bound
%	af_ymin/af_ymax	double 		bounds on the y axis for each plot.
%
%    OUTPUTS
%	M_hist		cell		the normalised histogram.
%
% DESCRIPTION
%
%	'histogram' is a "high-end" wrapper around histogram plotting, adding
%	some useful additional functionality to the standard MatLAB hist()
%	function.
%
%	Specifically, it offers the ability to normalise the histogram data
%	as well as filter between specific x (left/right) and y bounds.
%
% PRECONDITIONS
%	
%	o av_curv is a vector of values to analyze.
%
% POSTCONDITIONS
%
%	o A histogram on <av_curv> is performed, and it is also
%	  returned in <aM_hist>.
%
% HISTORY
%
% 05 October 2006
% o Initial design and coding.
%

global str_histogramColor;

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

%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

bins		= 1000;
b_normalize	= 0;
b_leftBoundSet	= 0;
b_rightBoundSet	= 0;
b_yminSet	= 0;
b_ymaxSet	= 0;
b_drawPlots	= 1;
if length(varargin)
	if length(varargin) >= 1
		bins = varargin{1};
		if ~isnumeric(bins)
		    error_exit('checking on bins',		...
			   '<bins> must be numeric',		...
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
		ymin = varargin{5};
		b_yminSet	= 1;
		if ~isnumeric(ymin)
		    error_exit('checking on ymin',			...
			   '<ymin> must be numeric',			...
			   '60');
		end
	end
	if length(varargin) == 6
		ymax = varargin{6};
		b_ymaxSet	= 1;
		if ~isnumeric(ymax)
		    error_exit('checking on ymax',			...
			   '<ymax> must be numeric',			...
			   '61');
		end
		if (ymin >= ymax)
		    error_exit('checking on bounds', 	   		...
			'<ymin> >= <ymax>', 				...
			'31'); 
		end
	end
end

volumeSize	= prod(size(av_image));

if b_leftBoundSet & b_rightBoundSet
    av_image	= av_image(av_image>leftBound & av_image<rightBound);
    curvmin	= leftBound;
    curvmax	= rightBound;
else
    curvmin	= min(av_image);
    curvmax	= max(av_image);
end
dt		= (curvmax - curvmin) / bins;
t		= curvmin: dt : curvmax - dt;
fx		= hist(av_image, bins);
if b_normalize
    fx		= fx ./ volumeSize * bins;
    str_color	= 'b';
    if exist('str_histogramColor')
    	str_color	= str_histogramColor;
    end
%      bar(t, fx, str_color);
    bar(t, fx);
else
    hist(av_image, bins);
end

v 		= axis;
v(1)		= curvmin;
v(2)		= curvmax;
if b_yminSet & b_ymaxSet
    v(3)	= ymin;
    v(4)	= ymax;
end
axis(v);
aM_hist		= [t' fx'];

end