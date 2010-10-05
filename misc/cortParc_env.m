function [] =	cortParc_env(varargin)
%
% NAME
%
%  function [] =	cortParc_env()
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%
% OUTPUTS
%					connect the points of the polygon
%
% DESCRIPTION
%
%	'cortParc_env' constructs the base environment for developing
%	a candidate parcellation algorithm.
%
%	It essentially creates two synthetic surfaces (two simple
%	sinusoidal signals), defines some sample "sulcal" intersections
%	and constructs a "slice".
%
% PRECONDITIONS
%
%	o None
%
% POSTCONDITIONS
%
%	o The cortical parcellation "slice" is returned.
%
% NOTE:
%
% HISTORY
% 04 June 2007
% o Initial design and coding.
%
%

%%%%%%%%%%%%%% 
%%% Nested functions :START
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

    function [af] 	= distance(av_X1, av_X2)
	v_sqdiff 	= (av_X2 - av_X1).^2;
	af 		= sqrt(sum(sum(v_sqdiff)));
    end

    function [av_intersect]	= intersect_find(av_start, aM_curve, ... 
						av_slope, varargin)
	timeout		= 1000;
	i		= 0;
	if length(varargin)
	    timeout	= varargin{1};
	end
	av_intersect	= av_start ./ av_start * -1;
	t		= aM_curve(:, 1);
	ft		= aM_curve(:, 2);
	b_intersect	= 0;
	dt		= t(2) - t(1);
	T		= 0;
	f_dist		= 0.0;
	while ~b_intersect
    	    T 		= T + dt;
    	    v_endPoint	= av_start + T * av_slope;    
     	    gi		= dsearchn(aM_curve, v_endPoint);
    	    v_closest	= aM_curve(gi, :);
    	    f_distance	= distance(v_endPoint, v_closest);
    	    if f_distance < dt
	        b_intersect = 1;
	        f_k	= distance(av_start, v_endPoint) * 1.4;
		av_intersect	= v_closest;
	        v_final	= av_start + f_k*av_slope;  
	        plot( 	[v_meanPxy(:,1), v_final(:,1)] , ...
			[v_meanPxy(:,2), v_final(:,2)], 'k');
    	    end
	    i = i + 1;
	    if i>timeout
		break;
	    end
	end
    end

%%%%%%%%%%%%%% 
%%% Nested functions :END
%%%%%%%%%%%%%% 

t=	-pi/2:0.1:2*pi;

% "Surfaces"
figure(1);
hold off;
%  v_grayWhite	= 4*(cos(t) + 1) + 1;
v_grayWhite	= 2*(cos(t) + 1) + 8;
M_grayWhite	= [t' v_grayWhite'];
plot(t, v_grayWhite, 'k');
grid;
hold on;
%  v_grayCSF	= 2*(cos(t) + 1) + 8;
v_grayCSF	= 4*(cos(t) + 1) + 1;
M_grayCSF	= [t' v_grayCSF'];
plot(t, v_grayCSF, 'k');

% Sulcal Intersections
v_X1	= rand(3,1) + 2.5;
v_Y1	= rand(3,1) + 3.0;
P1	= [v_X1 v_Y1];

v_X2	= rand(5,1)*2 + 2;
v_Y2	= rand(5,1)*4 + 4;
P2	= [v_X2 v_Y2];

v_Pxy	= [P1' P2']';

plot(v_Pxy(:,1), v_Pxy(:,2), 'rd', 'MarkerFaceColor', 'r');

% Find the "mean" point
v_meanPxy	= mean(v_Pxy);
plot(v_meanPxy(:,1), v_meanPxy(:,2), 'go', 'MarkerFaceColor', 'b');

[rows cols]	= size(v_Pxy);
Kwhite		= zeros(rows, 1);	% Indices of closest points on gray/white surface
Kcsf		= zeros(rows, 1);	% Indices of closets points on gray/CSF surface
M_white		= zeros(rows, 2);	% Points on gray/white surface
M_csf		= zeros(rows, 2);	% Points on gray/CSF surface
M_edge		= zeros(rows, 2);	% Matrix of lines (edges) from CSF to white

for p=1:rows
    wi		= dsearchn(M_grayWhite, v_Pxy(p,:));
    Kwhite(p)	= wi;	
    M_white(p,:) = [t(wi), v_grayWhite(wi)];
    plot([v_Pxy(p,1), t(wi)], [v_Pxy(p,2), v_grayWhite(wi)], 'g')
    gi		= dsearchn(M_grayCSF, v_Pxy(p,:));
    Kcsf(p)	= gi;
    M_csf(p,:)	= [t(gi), v_grayCSF(gi)];
    plot([v_Pxy(p,1), t(gi)], [v_Pxy(p,2), v_grayCSF(gi)], 'g')
    plot( [t(wi), t(gi)], [v_grayWhite(wi), v_grayCSF(gi)], 'g')
end

M_edge		= M_csf - M_white;
v_slice		= sum(M_edge) / norm(sum(M_edge));

%
% Now, starting at the "centroid", extend the v_slice line until
% it intersects the outer and inner surfaces
%
intersect_find(v_meanPxy, M_grayCSF, 	v_slice);
intersect_find(v_meanPxy, M_grayWhite, -v_slice);

keyboard

end