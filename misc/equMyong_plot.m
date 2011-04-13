function [ret] = equMyong_plot(av_coeff1, aM_D1, av_coeff2, aM_D2, varargin)
%
% NAME
%
%       function [ret] = equMyong_plot( av_coeff1,              ...
%                                       aM_D1,                  ...
%                                       av_coeff2,              ...
%                                       aM_D2,                  ...
%                                       [astr_title,            ...
%                                        ab_logPlot])
%
% ARGUMENTS
%       
%       INPUT
%       av_coeff1               vector          [a b c g] coefficients 1
%       aM_D1                   matrix          (boy)  table of male data 
%       av_coeff2               vector          [a b c g] coefficients 2 
%       aM_D2                   matrix          (girl) table of female data
%
%       OPTIONAL
%       astr_title              string          plot title -- any underscores
%						+ in the title string are 
%						+ replaced by spaces
%	ab_logPlot		bool		if true, do a log plot
%
%       OUTPUT
%       ret                     bool            true: OK; false: error
%
% DESCRIPTION
%
%       equMyong_plot simply "plots" or draws an equation based on the
%       coefficient values in av_coeff. aM_D1 and aM_D2 contain the data
%       table values for male and female subjects, and are of three columns
%       with form: [X Y G]. G is the "gender" toggle and is either 1 for
%       boys, 0 for girls.
%
% PRECONDITIONS
% 
%       o None.
%
% POSTCONDITIONS
% 
%       o None.
%
% HISTORY
% 17 December 2009
% o Initial design and coding.
%

% ---------------------------------------------------------

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
        
        function [av_Y] = func(av_coeff, av_X, av_G)
            av_Y        =       av_coeff(1)*av_X.*av_X  + ...
                                av_coeff(2)*av_X        + ...
                                av_coeff(3)             + ...
                                av_coeff(4)*av_G;
	    if b_logPlot
               av_Y     =       av_coeff(1)*av_X.*av_X  + ...
                                av_coeff(2)*log(av_X)   + ...
                                av_coeff(3)             + ...
                                av_coeff(4)*av_G;
            end
        end

%%%%%%%%%%%%%% 
%%% Nested functions :END
%%%%%%%%%%%%%% 

sys_print('equMyong_plot: START\n');

ret             = 1;
 
b_logPlot	= 0;
str_title       = 'Equation plot';
str_xlabel      = 'age (weeks)';
str_ylabel      = 'vol (cc)';

% Parse optional arguments
if length(varargin) >= 1, str_title     = varargin{1};  	end
if length(varargin) >= 2, b_logPlot     = 1;  		end


% process
M_allData       = [ aM_D1' aM_D2'];
M_allData       = M_allData';

f_minX          = min(M_allData(:,1));
f_maxX          = max(M_allData(:,1));
f_range         = f_maxX - f_minX;

t               = f_minX-0.1*f_range:0.01:f_maxX+0.1*f_range;

% Display:
hf              = figure;
plot(aM_D1(:,1), aM_D1(:,2), 'bo', 'MarkerFaceColor', 'b');
hold on;
plot(aM_D2(:,1), aM_D2(:,2), 'ro', 'MarkerFaceColor', 'r');
g1              = 1*aM_D1(1,3);
g2              = 1*aM_D2(1,3);
v_f1            = func(av_coeff1, t, g1);
v_f2            = func(av_coeff2, t, g2);
plot(t, v_f1, '-b');
plot(t, v_f2, '-r');

%  grid;
str_titlerep	= strrep(str_title, '_', ' ');
title(str_titlerep);
xlabel(str_xlabel);
ylabel(str_ylabel);
lh = legend('male', 'female', 'male interpolation', 'female interpolation');
legend('Location', 'NorthWest');
set(gca, 'Box', 'off');
set(hf, 'color', 'white');

str_epsFile     = sprintf('%s.eps', str_title);
str_jpgFile     = sprintf('%s.jpg', str_title);

print('-depsc2', str_epsFile);
print('-djpeg',  str_jpgFile);

sys_print('equMyong_plot: END\n');



end
% ---------------------------------------------------------


