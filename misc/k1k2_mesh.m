function [aM_mesh] = k1k2_mesh(varargin)
%
% NAME
%
%  	function [aM_mesh] = k1k2_mesh([	a_min  = -10,
%						a_max  =  10,
%						af_inc = 0.1])
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%	a_min			int		minimum range extent
%	a_max			int		maximum range extent
%	af_int			float		increment
%
% OUTPUTS
%	aM_mesh			matrix		F(Z) defined on the mesh
%						domain.
%
% DESCRIPTION
%
%	'k1k2_mesh' builds a mesh with Y=X=-a_min:af_inc:a_max and
%	Z = [X Y] with fZ defined on each mesh point.
%
% PRECONDITIONS
%
%
% POSTCONDITIONS
%
%	o Some function of k1 and k2 is applied to each vertex
%	  of the created mesh. This resultant is saved
%	  to <aM_mesh>.
%
% SEE ALSO
%
% HISTORY
% 09 October 2006
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

	function [Z] = F(K1, K2)
%  	    singularity	= find(K1.^2 == K2.^2);
%  	    if length(singularity)
%  		fprintf(1, '\n\tSingularity points: %d\t\t', singularity);
%  	    end
	    Z = zeros(length(K1), 1);
	    Z = ((K1 .* K2)) ./ (K1  - K2).^2;
%      	    Z = (K1  - K2).^2;
%  	    Z = (K1.*K2);
	end


%%%%%%%%%%%%%% 
%%%%%%%%%%%%%% 

imin		= -10;
imax		= 10;
f_inc		= 0.1;


if length(varargin)
	imin	= varargin{1};
	if length(varargin) >= 2
		imax	= varargin{2};
	end
	if length(varargin) >= 3
		f_inc	= varargin{3};
	end
end

sideLength	= (imax - imin)/f_inc;
aM_mesh		= zeros(sideLength, sideLength);

v_X		= imin:f_inc:imax-f_inc;
v_Y		= v_X';
M_X		= repmat(v_X, sideLength, 1);
M_Y		= repmat(v_Y, 1, sideLength);

size(M_X);

K1		= reshape(M_X, 1, sideLength*sideLength);
K2		= reshape(M_Y, 1, sideLength*sideLength);

v_mesh		= F(K1, K2);

aM_mesh		= reshape(v_mesh, sideLength, sideLength);

end