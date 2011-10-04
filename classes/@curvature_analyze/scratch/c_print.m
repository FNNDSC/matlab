%
% NAME
%
%	Generic text output functions, based on class design
%
% ARGUMENTS
%
% OPTIONAL
%	
%
% DESCRIPTION
%
% PRECONDITIONS
%
%	o Assumes class <c> exists in current scope.
%	o Assumes class <c> has:
%		- vprintf
%		- RC / LC
%
%
% POSTCONDITIONS
%
% NOTE:
%
% HISTORY
% 18 September 2007
% o Initial design and coding.
%

RC	= c.m_marginLeft;
LC	= c.marginRight;

    function sys_print(astr)
        vprintf(c, 1, sprintf('%s %s', syslog_prefix(), astr));
    end

    function [] = cprint(astr_LC, astr_RC)
        vprintf(c, 3, sprintf('%*s', LC, astr_LC));
        vprintf(c, 3, sprintf('%*s\n', RC, sprintf('%s', astr_RC)));
    end

    function [] = tuple_print(astr_LC, av_tuple)
        vprintf(c, 3, sprintf('%*s', LC, astr_LC));
        vprintf(c, 3, sprintf('%*s\n', RC, sprintf('[ %d %d ]',         ...
                                av_tuple(1,1), av_tuple(1,2))));
    end

