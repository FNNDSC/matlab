function [av_out] =	compress(av_in, varargin)
%
% NAME
%
%  function [av_out] =	compress(av_in  <, af_threshold  = 0    ...
%                                          astr_inequ    = 'gt'>)
%
% ARGUMENTS
% INPUT
%	av_in		        vector          input vector
%
% OPTIONAL
%       af_threshold            float           threshold value
%       astr_inequ              string          string describing inequality
%       
% OUTPUTS
%       av_out                  vector          compressed version of av_in
%
% DESCRIPTION
%
%       'compress' accepts an input <av_in> and returns <av_out> that
%       contains only the elements of <av_in> that satisfy the inequality
%       constraint based on <af_threshold>.
%       
%       The default inequality constraint is 'gt', or 'greater than'. Valid
%       constraints are:
%       
%             <astr_inequ>      Meaning
%               'lt'            'less than'
%               'lte'           'less than or equal to'
%               'gt'            'greater than'
%               'gte'           'greater than or equal to'
%               'eq'            'equal to'
%
% PRECONDITIONS
%
%	o <av_in> must be a vector.
%
% POSTCONDITIONS
%
%	o <av_out>
%
% SEE ALSO
%
% HISTORY
% 20 Aug 2009
% o Initial design and coding.
%
% 15 October 2009
% o Expanded inequality handling.
%

f_threshold     = 0.0;
str_inequ       = 'gt';
v_hits          = [];

if length(varargin) & isfloat(varargin{1}), f_threshold = varargin{1};  end
if length(varargin) >=2,                    str_inequ   = varargin{2};  end

if strcmp(str_inequ, 'gt'),     v_hits  = find(av_in >  f_threshold);   end
if strcmp(str_inequ, 'gte'),    v_hits  = find(av_in >= f_threshold);   end
if strcmp(str_inequ, 'lt'),     v_hits  = find(av_in <  f_threshold);   end
if strcmp(str_inequ, 'lte'),    v_hits  = find(av_in <= f_threshold);   end
if strcmp(str_inequ, 'eq'),     v_hits  = find(av_in == f_threshold);   end

if numel(v_hits)
    av_out  = zeros(1, numel(v_hits));
    for i   = 1:numel(v_hits)
        av_out(i)       = av_in(v_hits(i));
    end
else
    av_out  = [];
end

end
