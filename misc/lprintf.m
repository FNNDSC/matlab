function [] = lprintf(aC, varargin)
%
% NAME
%
%  function [] = lprintf(aC, format, ...)
%
% ARGUMENTS
% INPUT
%       aC              class/col width         if class - queried for col 
%                                               width, otherwise interpreted
%                                               as width spec.
%       format, ...     string                  C-style format string to print
%                                               in right column.
%
% OPTIONAL
%
% DESCRIPTION
%
%       Prints formatted text in a left column
%
% NOTE:
%
% HISTORY
% 18 September 2009
% o Initial design and coding.
%
        LC              = 40;
        verbosity       = 1;

        if isobject(aC)
            LC          = aC.m_LC;
            verbosity   = aC.m_verbosity;
        else
            LC          = aC;
        end

        sfrmt   = sprintf(varargin{:});

        if length(sfrmt) & verbosity
            fprintf(1, '%s', sprintf('%*s', LC, sfrmt));
        end
end
