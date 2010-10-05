function [aM_closest, aM_routing, ab_hit] = 				...
			dsearchn_image(aM_image, aM_seed, varargin)
%
% NAME
%
% function [aM_closest, aM_routing, ab_hit] = 				...
%			 dsearchn_image(aM_image, aM_seed[,		...
%					aintensity, 			...
%					avoidIntensity,			...
%					aroutings,			...
%					ah,				...
%					ab_wraparound])
%
% ARGUMENTS
% INPUT
%	aM_image	matrix		An n-by-n matrix denoting an image
%	aM_seed		matrix		A set of p-by-2 coordinates denoting
%					seed positions in the image.
%
% OPTIONAL
%	aintensity	int		If specified, search for closest
%					image pixel with <aintensity>, 
%					otherwise search for any non-zero
%					intensity.
%	avoidIntensity	int		If specified, attempt to route paths 
%					so that they do not cross any pixels 
%					with this value. Routing is simple
%					straight line. Implies that 
%					<aintensity> is also set.
%	aroutings	int		If specified, limit the maximum number
%					of routing attempts to <aroutings>.
%	ah		handle		handle to graphical axes on which to 
%					plot. This can also be a struct (see
%					the preconditions).
%	ab_wraparound	bool		If specified, and if true, wrap
%					around the edges of the images while
%					searching.
% OUTPUT
%	aM_closest	matrix		A set of p-by-2 coordinates denoting the
%					closest intersects on the image that
%					correspond to each seed coordinate.
%	aM_routing	matrix		A matrix that contains routing information
%					for each aM_seed vector. For each seed,
%					the number of routings attempted, and an
%					overall success measure are returned.
%					Note that a re-routing is only
%					performed if an <avoidIntensity> has
%					been specified and if the connecting
%					path crosses between a seed value
%					and its closest hit crosses an
%					pixel <avoidIntensity>.	
%	ab_hit		bool		If no "hits" were found in the image
%					given the starting seed point, then
%					this will contain 0, else 1.	
%
% DESCRIPTION
%
%	This function emulates the MatLAB 'dsearchn', i.e. returns the
%	closest points in an source matrix to each point in a seed matrix. 
%	While dsearchn assumes a *function* analogue as input, 
%	`dsearchn_image' works on an input *image*.
%
%	Simply stated, for each point in the aM_seed matrix, increasing
%	'windows' about the seed are extracted. The first extracted window
%	that contains a non-zero (or <aintensity>) pixel (in its edge border)
%	contains a solution. Of course, given the square nature of the 
%	extracted window, there might be more than one pixel 'hit' in the
%	border edge. Each 'hit' pixel's Euclidean distance to the seed point
%	is determined, and the pixel that has the shortest distance is
%	recorded in the corrsponding point in <aM_closest>.
%
%	Once determined, and if an <avoidIntensity> has been specified, a delta
%	region about each point in a straight line path between the seed and
%	the target is examined. If any <avoidIntensity> pixels are detected,
%	the target is 'erased' and a new closest found. Hopefully this will
%	(for simple shapes) route about regions along the path that contain
%	any <avoidIntensity> pixels.
%
% PRECONDITIONS
%
%	o The image is typically masked so that it only contains pixels of
%	  interest (be they target pixels or 'avoidance' pixels). 
%	  All other pixels are assumed to be zero.
%	o The optional <ah> argument can be either a handle to a graphics
%	  context inwhich to draw (i.e. a single Figure), or it can be
%	  a struct containing several fields:
%
%		hFigure: 	handle to the graphics context
%		b_searchLines:	toggle for drawing candidate routing lines
%		b_subplot:	toggle for drawing in a subplot of the 
%				graphics context
%		v_subplot:	the subplot logical coordinate pane
%		b_imageRefresh: toggle to force redraw of entire image
%
% POSTCONDITIONS
%
%	o <aM_closest> contains the image coordinates, in line-by-line (row)
%	  for each aM_seed row.
%	o <aM_routing> contains in line-by-line order the number of routings
%	  attempted for this seed, as well as a success measure, i.e.
%
%		[ 
%			routingsSeed1	successSeed1
%			routingsSeed2	successSeed2
%			     ...	    ...
%			routingsSeedM	successSeedM
%		]
%
%	  If, for a given seed, no routings were found within the <aroutings>
%	  limit that did not cross <avoidIntensity>, then the success value
%	  is set to 0, else if a routing was found, it is set to 1.
%
% NOTE:
%
% HISTORY
% 
% o Initial design and coding.
%
% 16 Aug 2007
% o More complete plotting argument handling.
%

%%%%%%%%%%%%%% 
%%% Nested functions :START
%%%%%%%%%%%%%% 
    function [ab_crossing, aM_image]	= intensityCrossing_check( aM_image, ...
							av_seed,	...
							av_closest,	...
							avoidIntensity,	...
							varargin)
    %
    % ARGUMENTS
    % INPUT
    %	aM_image		matrix		image matrix being processed
    %	av_center		vector		seed point, i.e. start position
    %	av_closest		vector		coords of the "hit" point
    %	avoidIntensity		int		pixel intensity to avoid
    %
    %  OPTIONAL
    %	awindowSize		int		window size to examine about
    %						the connecting path. Either 1
    %						or zero
    % 	ab_wraparound		bool		wraparound?
    %
    % OUTPUT
    %	ab_crossing		bool		Did a tissue crossing occur?
    %	aM_image		matrix		the image matrix, possibly
    %						editted to void the av_closest
    %						if a tissue crossing occurred.
    %
    % DESCRIPTION
    %	This function checks along a path connecting <av_seed> to <av_closest>
    %	in the <aM_image>. If any points along the path cross over any
    %	<avoidIntensity> pixels, the particular <av_closest> is set zero.
    % 
    % 	Two actual paths are constructed, each by interpolating first the rows
    %	and the column index of the path waypoints. Each path is examined for
    %	potential crossings.
    %
    %	By default, the pixels directly bordering the connecting path are
    %	also checked -- this catches cases where the connecting path crosses
    %	a tissue boundary, but does so by "slipping" between pixels and not
    %	directly crossing "over" one.
    %
    % 	This function is used to guide path routing such that paths do
    %	not cross <avoidIntensity> pixels. If <avoidIntensity> is found along
    %	the connecting path, the terminus pixel is set to zero. A subsequent
    %	call to 'closestToCenter_find(...)' will return a different connecting
    %	path. By iterating this process, the <av_closest> will eventually shift
    %	to a point such that the connecting path will not cross any 
    % 	<avoidIntensity> pixels, with buffer width <awindowSize>.
    %
    % PRECONDITIONS
    %	o <av_seed> and <av_closest> are valid.
    % 	o Typically called on successful 'closestToCenter_find(...)' hit.
    %
    % POSTCONDITIONS
    %	o points in <aM_image> up to <awindowSize> pixels wide from the
    %	  connecting path are searched for <avoidIntensity>. This is usually
    %	  a width of 1 to correctly detect pixel "slip through".
    %	o If <avoidIntensity> pixels are crossed, <ab_crossing> is set to 1
    %	  and the <av_closest> in <aM_image> is set to zero.
    %
	ab_crossing	= 0;
   	windowSize	= 1;
	if(length(varargin))
	    windowSize	= varargin{1};
	end
	M_pathPoly	= [
				av_seed
				av_closest
			];
	M_path		= cell(1, 2);
	M_path{1}	= poly_connect(M_pathPoly, 1);
	M_path{2}	= poly_connect(M_pathPoly, 2);
	% In some cases the sulcal intersect might be within one voxel of a
	% border region. In such an instance, the path connect might trigger a
	% crossing violation since the border voxel was within the one voxel
	% buffer window. To counter this, we remove the very first path point
	% from the M_path cells.
	M_path{1} 	= M_path{1}(2:end, :);
	M_path{2}	= M_path{2}(2:end, :);
	[rows cols]	= size(M_path);
	for path=1:2
	    [rows cols]	= size(M_path{path});
	    if(length(M_path{path}))	% double check to make sure that the
					% path contains elements
	        for i=1:rows
	    	    v_pathPoint		= round(M_path{path}(i,:));
	    	    if(windowSize)
	                M_neighbourhood	= window_remove(aM_image, 	...
					v_pathPoint, windowSize);
		        ab_crossing= length(				...
					find(M_neighbourhood==avoidIntensity));
	    	    else
		        if(aM_image(v_pathPoint(1), v_pathPoint(2)) == avoidIntensity)
		    	    ab_crossing	= 1;
		        end
	            end
	            if(ab_crossing)
		        aM_image(av_closest(1), av_closest(2))	= 0;
		        break;
	            end
	        end %row
	    end % pathlength check
	end %path
    end %function

    function [aM_window, b_ok] 	= window_remove(aM_image, av_seed, adistance, ...
						varargin)
    %
    % ARGUMENTS
    % INPUT
    %	aM_image		matrix		image to process
    %   av_seed			vector		seed point in the image
    %	adistance		int		window "size" to remove
    %
    %  OPTIONAL
    % 	ab_wraparound		bool		wraparound?
    %
    % OUTPUT
    %	aM_window		matrix		the extracted window
    %	b_ok			bool		is window valid?
    %
    % DESCRIPTION
    %	This function removes a square window of given size, centered about the
    %	seed point. The <adistance> denotes the number of pixels orthogonally
    %	away from the seed point to remove, i.e. the window "square radius".
    %
	aM_window	= zeros(2*adistance+1);
	b_ok		= 1;
	[rows, cols]	= size(aM_image);
	if((av_seed(1) - adistance)<1) || ((av_seed(1) + adistance)>rows)...
	||((av_seed(2) - adistance)<1) || ((av_seed(2) + adistance)>cols)
	    b_ok	= 0;
	    return;
	end
    	aM_window	= aM_image(					   ...
				av_seed(1)-adistance:av_seed(1)+adistance, ...
				av_seed(2)-adistance:av_seed(2)+adistance);	
    end

    function [af] 	= vector_distance(av_X1, av_X2)
	v_sqdiff 	= (av_X2 - av_X1).^2;
	af 		= sqrt(sum(sum(v_sqdiff)));
    end

    function [v_closest, b_hit]	= closestToCenter_find(aM_window, varargin)
    %
    % ARGUMENTS
    % INPUT
    %	aM_window		matrix		a window containing 'hits'
    %						in the border edge
    % OPTIONAL
    %	v_seed			vector		original seed point
    %	specificIntensity	int		search for hits on this
    %						intensity
    %
    % OUTPUT
    %	v_closest		vector		indices of the border hit
    %						closest to the center
    %	b_hit			bool		if true, indicates that
    %						a closest was found, else
    %						window was empty
    %
    % DESCRIPTION
    %	This function finds the indices of the ON border pixel that is closest
    %	to the center pixel.
    %
    % PRECONDITIONS
    %	o aM_window must contain some non-zero (or ON) pixels.
    %	o aM_window must be n-by-n where n is odd.
    %	o ON pixels are in the aM_window edge.
    %	o If an optional <v_seed> vector is provided, then <v_closest> is
    %	  translated by the logical distance to <v_seed> --  this places 
    %	  <v_closest> back in the image.
    %
	str_function	= 'dsearchn_image::closestToCenter_find';
    	[rows, cols]= size(aM_window);
	if(~mod(rows, 2))
	    error('In "%s", the window size must be odd.', str_function);
	end
	if(rows~=cols)
	    error('In "%s", the window must be square.', str_function);
	end
    	f_distance	= 0.0;
    	f_shortest	= rows;
    	v_closest	= zeros(1,2);
    	v_center	= zeros(1,2);
    	v_X1		= zeros(1,2);
    	v_center(1, 1)	= round(rows/2);
    	v_center(1, 2)	= round(cols/2);
	v_seed		= v_center;
	b_intensity	= 0;
	b_hit		= 0;
	if length(varargin)
	    v_seed	= varargin{1};
	    if(length(varargin)==2)
		b_intensity	= 1;
		intensity	= varargin{2};
	    end
	end
	if(b_intensity)
    	    [I, J]	= find(aM_window==intensity);
	else
    	    [I, J]	= find(aM_window>0);
	end
	if(~length(I))
	    b_hit = 0;
	    return;
	end
    	M		= [I J];
    	for i=1:length(I)
	    v_X1	= M(i, :); 
	    f_distance	= vector_distance(v_X1, v_center);
	    if(f_distance<f_shortest)
	    	f_shortest 	= f_distance;
	    	v_closest	= M(i,:);
	    end
    	end
 	v_del		= v_seed - v_center;
	v_closest	= v_closest + v_del;
	b_hit		= 1;
%  	fprintf('about to return from "closestToCenter_find"...\n');
%  	keyboard
    end

   function [] = searchProgress_plot(astr_color)
	if(b_imageRefresh)
	    image(M_editedImage');
	    drawnow;
	end
	if(b_searchLines)  
	    plot(	[aM_seed(seed,1), aM_closest(seed, 1)],	...
			[aM_seed(seed,2), aM_closest(seed, 2)], astr_color);
	end
   end

%%%%%%%%%%%%%% 
%%% Nested functions :END
%%%%%%%%%%%%%% 

str_function		= 'dsearchn_image';

LC			= 50;
RC			= 30;

b_wraparound		= 0;
b_specificIntensity	= 0;
b_avoidIntensity	= 0;
b_routings		= 0;
specificIntensity	= 255;
b_plot			= 0;
hFigure			= 0;
b_imageRefresh		= 0;
b_searchLines		= 1;
b_subplot		= 1;
v_subplot		= [2 2 2];

if(length(varargin))
    b_specificIntensity	= 1;
    specificIntensity	= varargin{1};
    if(length(varargin)>=2)
	b_avoidIntensity = 1;
	avoidIntensity	= varargin{2};
    end
    if(length(varargin)>=3)
	b_routings 	= 1;
	routings	= varargin{3};
    end
    if(length(varargin)>=4)
	if(isstruct(varargin{4}))
	    s		= varargin{4};
	    hFigure		= s.hFigure;
	    b_searchLines	= s.b_searchLines;
	    b_subplot		= s.b_subplot;
	    v_subplot		= s.v_subplot;
	    b_imageRefresh	= s.b_imageRefresh;
	else
	    hFigure	= varargin{4};
	end
	if(hFigure), b_plot = 1;, end
    end
end


[rows cols]		= size(aM_image);

if(b_plot)
    set(gca, 'YDir', 'reverse'); 
    hold on; colormap('gray');
    axis square; axis([0 cols 0 rows]);
    if(b_subplot)
	subplot(hFigure); 
	subplot(v_subplot(1), v_subplot(2), v_subplot(3));  
    else
	figure(hFigure);
    end
    if(b_imageRefresh)
	image(aM_image');
    	drawnow;
	b_imageRefresh	= 0;
    end
end

[seedRows seedCols]	= size(aM_seed);
aM_closest		= zeros(seedRows, seedCols); % coords of closest pixel
aM_routing		= zeros(seedRows, seedCols); % routing matrix
M_image			= aM_image;		     % copy of original image
M_imageIntersect	= zeros(rows, cols);	     % edited routing image and
						     % seed matrix

% Determine a default max number of routing attempts
%	if none have been specified
if(~b_routings && b_avoidIntensity)
    v_targetPixels	= find(aM_image == specificIntensity);
    routings		= length(v_targetPixels) / 8;
end

b_redoSearch	= 1;
currentSeed	= 1;
windowWidth	= 1;
while b_redoSearch
    b_redoSearch	= 0;
    for seed=currentSeed:seedRows
        b_ok 		= 1;
        ab_hit		= 0;
        distance	= windowWidth;	% Extract a window starting with size
					% of 1 initially. For subsequent
					% redos, we don't need to start at the
					% beginning again, but continue the
					% window expansion from where we left
					% off.
        while(b_ok && ~ab_hit)
            [M_window, b_ok]= window_remove(aM_image, aM_seed(seed,:), 	...
						distance); 
	    if(b_specificIntensity)
	        [aM_closest(seed,:), ab_hit]	= closestToCenter_find(	...
							M_window, 	...
							aM_seed(seed,:),...
							specificIntensity);
	    else
	        [aM_closest(seed,:), ab_hit]	= closestToCenter_find(	...
							M_window, 	...
							aM_seed(seed,:));
	    end
	    distance = distance + 1;
        end
	aM_routing(seed, 2)	= 1;
        if(ab_hit && b_avoidIntensity)
	    [b_crossing aM_image]	= intensityCrossing_check(	...
						aM_image, 		...
						aM_seed(seed,:), 	...
						aM_closest(seed,:),	...
						avoidIntensity);
	    if(b_crossing)
		if(aM_routing(seed, 1)<=routings)
	            M_imageIntersect(sub2ind(size(aM_image), 		...
					aM_seed(:,1), aM_seed(:,2)))	= 255;
	            M_editedImage	= M_imageIntersect + aM_image;
		    if(b_plot)
			searchProgress_plot('-g');
		    end
	            b_redoSearch 	= 1;
		    windowWidth		= distance - 1;
		    aM_routing(seed, 1)	= aM_routing(seed, 1) + 1;
		    aM_routing(seed, 2)	= 0;
	            break;
		else
		    % In this case, we have not been able to find a path that
		    % avoids any <avoidIntensity> pixels. We note the lack of
		    % success in the <aM_routing> matrix, restore the search
		    % image to its original state, toggle off the avoidance
		    % bit, and re-search. Essentially, if we can't find any
		    % paths about the <avoidIntensity> pixels, we give up
		    % on avoiding them altogether and return a closest point
		    % irrespective of the <avoidIntensity>.
		    % 
		    aM_routing(seed, 1)	= aM_routing(seed, 1) + 1;
		    aM_routing(seed, 2)	= 0;
		    b_avoidIntensity	= 0;
		    b_redoSearch	= 1;
		    aM_image		= M_image;	% restore the backup
		end
	    else
		% We found a successful routing for this seed. Record success,
		% restore the image, and move onto the next seed.
	        aM_routing(seed, 2)	= 1;
		windowWidth		= 1;
		aM_image		= M_image;
		currentSeed		= currentSeed+1;
		if(b_plot), searchProgress_plot('-m');, end
	    end
        end
        if(~ab_hit)
	    % No hits were found in the image (or expanded window). Return
	    % immediately to caller!
	    %error('In "%s", seed=%d: no hits were found!', str_function, seed);
	    return;
        end
    end
end
aM_image	= M_image; % restore the backup
end