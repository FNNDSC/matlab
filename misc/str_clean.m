function [astr_out] = str_clean(astr_in, varargin)
%
% NAME
%
%  function [astr_out] = str_clean(astr_in [,           ...
%                                       astr_rep,       ...
%                                       acstr_dirty,    ...
%                                       ab_replaceList])
%
% ARGUMENTS
% INPUT
%       astr_in         string                  Input string
%
% OPTIONAL INPUT
%       astr_rep        string                  Replacement string
%       acstr_dirty     cell of string          List of 'dirty' characters
%       ab_replaceList  bool                    If true, replace the 
%                                               cell array of dirty characters
%                                               otherwise append.
%       
% OUTPUT
%       astr_out        string                  Cleaned string
%
% DESCRIPTION
%
%       'str_clean' replaces 'dirty' characters in <astr_in> with <astr_rep>.
%       By default, the 'dirty' characters are white space and the replacement
%       string is a simple empty string.
%       
%       The replacement string can be overriden by specifying the <astr_rep>.
%       Passing an additional cell of strings in <acstr_dirty> will append
%       these 'dirty' strings to the internal white-space string list. If 
%       <ab_replaceList> is passed and is TRUE, then the <acstr_dirty> will
%       replace the interal list.
%
% NOTE:
%
% HISTORY
% 26 October 2009
% o Initial design and coding.
%

    cstr_dirty  = { ' ', char(10), char(11), char(13) };
    str_rep     = '';
    astr_out    = astr_in;

    if length(varargin) >= 1, str_rep    = varargin{1};                 end;
    if length(varargin) >= 2, cstr_dirty = [cstr_dirty varargin{2}];    end;
    if length(varargin) >= 3 & varargin{3}, cstr_dirty = varargin{2};   end;

    astr_out    = regexprep(astr_out, cstr_dirty, str_rep);

end
