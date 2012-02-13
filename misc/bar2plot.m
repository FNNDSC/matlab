function [h] = bar2plot(M_X, s_Y)
%
% NAME
%
%    function [h] = bar2plot(M_X, s_Y)
%
%
% ARGUMENTS
%    INPUTS
%    M_X                Matrix               The x-axis "values"
%                                            for the two groups
%    s_Y                struct               holder for plot values
%                                            bar width, and colors
% 
%    OPTIONAL
%
%    OUTPUTS
%    h			handle               pointer to bar graph object
%    
% DESCRIPTION
%
%        'bar2plot' is a simple 2-group-with-error values plotter
%        designed with only two input arguments. This constraint
%        arises since 'bar2plot' is designed to be called from
%        'plotyy'. 
%
%        M_X denotes the x-axis values for the two groups with
%        M_X(:,1) for the 1st group and M_X(:,2) for the second.
%
%        s_Y is struct of following form:
%
%            s_Y.v_y1           first set of y-values
%            s_Y.v_e1           error values for group 1
%            s_Y.v_y2           second set of y-values
%            s_Y.v_e2           error values for group 2
%            s_Y.M_C            color matrix denoting bar and error
%                               plot colors
%            s_Y.width          vector containing width of plot for
%                               each group
%            s_Y.legendLocation location of legend
%            s_Y.legendNames    string cell of names for each
%                               component
%            s_Y.YTicks         number of "ticks" on the y axis
%            s_Y.YLim           vector of limits on the Y-axis

% PRECONDITIONS
%
%       o 'e' and 'y' are 2m-by-n matrices of 2 sets of 'm' samples and 'n'
%       groups. 'y' are the group values and 'e' the error (std
%       deviation) values.
%
% POSTCONDITIONS
%
%	o The handle to the bar plot is returned.
%
%
% HISTORY
% 24 October 2011
% o Initial design and codi

v_x1 = M_X(:,1);
v_x2 = M_X(:,2);

v_y1 = s_Y.v_y1;
v_e1 = s_Y.v_e1;
v_y2 = s_Y.v_y2;
v_e2 = s_Y.v_e2;

% h = figure;
b1 = bar(v_x1, [v_y1 v_e1], s_Y.width(1), 'stacked');
hold on;
b2 = bar(v_x2, [v_y2 v_e2], s_Y.width(2), 'stacked');

set(b1(1), 'FaceColor', s_Y.M_C{1,1});
set(b1(2), 'FaceColor', s_Y.M_C{1,2});
set(b2(1), 'FaceColor', s_Y.M_C{2,1});
set(b2(2), 'FaceColor', s_Y.M_C{2,2});

legend(s_Y.legendNames, 'Location', s_Y.legendLocation);

h = b2;
