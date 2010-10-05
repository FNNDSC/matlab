%
% NAME
%
%  function [] = colprintf(astr_LC, format, ...)
%
% ARGUMENTS
% INPUT
%       ac              class           hosting class
%       astr_LC         string          Left-column 'intro' text
%       format, ...     string          C-style format string to print
%                                         in right column.
%
% OPTIONAL
%
% DESCRIPTION
%
%       Prints two-tuple text inputs in two-columns, with column widths
%       defined in the hosting class <ac>
%
% NOTE:
%
% HISTORY
% 18 September 2009
% o Initial design and coding.
%

function [] = colprintf(astr_LC, varargin)
	
	LC = 40;
	RC = 40;

	sfrmt   = sprintf(varargin{:});

        if length(astr_LC) 
            fprintf(1, '%s', sprintf('%*s',   LC, astr_LC));
        end
        fprintf(1, '%s', sprintf('%*s', RC, sfrmt));
end
