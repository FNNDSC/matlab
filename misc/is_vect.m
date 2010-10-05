function [ab_trueFalse] =	is_vect(av_in, varargin) 
%
% NAME
%
%  function [ab_trueFalse] =	is_vect(av_in <,ab_type>) 
%
% ARGUMENTS
% INPUT
%	av_in		vector		Input vector
%
% OPTIONAL
%	ab_type		scalar (bool)	If exists, specify the type
%					of vector: 
%					    0 : row vector
%					    1 : col vector
%
%       
% OUTPUTS
%	ab_trueFalse	scalar (bool)	True, i.e. 1, if <av_in> is
%					a vector; False, i.e. 0
%					otherwise
%
% DESCRIPTION
%
%	'is_vect' returns logical true (1) if its input is a vector,
%	otherwise returns logical false (0). The vector type can be
%	specified with the <ab_type> argument.
%
% PRECONDITIONS
%
%	o <av_in> must be passed.
%
% POSTCONDITIONS
%
%	o return a 1 or 0.
%
% SEE ALSO
%
% HISTORY
% 19 Aug 2009
% o Initial design and coding.
%
%

b_vectTypeSpec	= 0;
ab_trueFalse	= 0;

if length(varargin) & isfloat(varargin{1})
	b_vectTypeSpec	= 1;
	b_vectType	= varargin{1};
end

[rows cols] 	= size(av_in);
if rows*cols == rows | rows*cols == cols
    ab_trueFalse = 1;
    if b_vectTypeSpec
	switch b_vectType
	    case 0
		if rows ~= 1, ab_trueFalse = 0; end
	    case 1
		if cols ~= 1, ab_trueFalse = 0; end	
	end
    end
end

end
