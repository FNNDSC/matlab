function [] = rprintf(aC, varargin)
%
% NAME
%
%  function [] = rprintf(aC, format, ...)
%
% ARGUMENTS
% INPUT
%       aC              class/col width         if class - queried for col
%                                               widths, else parsed for 
%                                               width spec
%       format, ...     string                  C-style format string to print
%                                               in right column.
%
% OPTIONAL
%
% DESCRIPTION
%
%       Prints formatted text in the right column.
%
% NOTE:
%
% HISTORY
% 18 September 2009
% o Initial design and coding.
%

	LC              = 40;
	RC              = 40;
        verbosity       = 1;
        verbosityLevel  = 1;

        if isobject(aC)
            LC                  = aC.m_LC;
            RC                  = aC.m_RC;
            verbosity           = aC.m_verbosity;
            verbosityLevel      = aC.m_verbosityLevel;
        else
            [str_LC, str_RC]    = strtok(aC, '.');
            LC                  = str2num(str_LC);
            RC                  = str2num(str_RC);
        end

        sfrmt   = sprintf(varargin{:});

        if length(sfrmt)   & verbosity >= verbosityLevel
            fprintf(1, '%s', sprintf('%*s', RC, sfrmt));
        end
end
