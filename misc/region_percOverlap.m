function [af_perc, af_A1, af_A2] = region_percOverlap(av_R1, av_R2)
%
% NAME
%
%       function [af_perc, af_A1, af_A2] = region_percOverlap( av_R1, av_R2)
%
% ARGUMENTS
%
%       INPUT
%       av_R1 = [X11 Y11 X12 Y12]       vector          corner points of the two
%       av_R2 = [X21 Y21 X22 Y22]                       rectangular regions
%       
%       OUTPUT
%       af_perc                         float           overlap percentage of
%                                                       the two regions (as
%                                                       a percentage of 
%                                                       smaller box)
%       af_A1                           float           area of first region
%       af_A2                           float           area of second region
%       
% DESCRIPTION
%
% 'region_percOverlap' returns the percentage overlap between two
% rectangular regions specified by the passed corner point vectors.
% The overlap is returned as a percentage of the smaller area of the
% two rectangles.
%
% The 'trick' with this function is catering for all the possible
% left/right top/bottom overlaps, as well as just-touching conditions
% and importantly, one box completely contained within another.
%
% The corner coordinates are interpreted as 
%
%       v_Rn    = [xn1, yn1, xn2, yn2]
%
% and are taken to be defined as:
%
%                 +---------------+<--(xn2, yn2)
%                 |               |          
%                 |               |          
%                 |               |          
%                 |               |          
%                 |               |          
%                 |               |          
%    (xn1, yn1)-->+---------------+
%
% PRECONDITIONS
%       o <av_R1> and <av_R2> should be 4 element vectors
%
% POSTCONDITIONS
%       o <af_perc> is a percentage (of the smaller region)
%         overlap.
%       o Areas of both regions.
%       o If there is no overlap, <af_perc> is zero.
%
% HISTORY
% 12-Nov-2010
% o Initial design and coding.
%

af_perc = 0.0;

if ~is_vect(av_R1) | length(av_R1)~=4
    error_exit('checking <v_R1>', 'a non 4-element vector was found', '1');
end
if ~is_vect(av_R2) | length(av_R2)~=4
    error_exit('checking <v_R2>', 'a non 4-element vector was found', '1');
end

x11     = av_R1(1);     x21     = av_R2(1);
y11     = av_R1(2);     y21     = av_R2(2);
x12     = av_R1(3);     x22     = av_R2(3);
y12     = av_R1(4);     y22     = av_R2(4);

% Determine left and right box order
if x12 <= x22
    % v_R1 is left and v_R2 is right
    x_la        = x11;          x_lb = x21;
    y_ba        = y11;          y_bb = y21;
    x_ra        = x12;          x_rb = x22;
    y_ta        = y12;          y_tb = y22;
else    
    % v_R2 is right and v_R2 is left
    x_la        = x21;          x_lb = x11;
    y_ba        = y21;          y_bb = y11;
    x_ra        = x22;          x_rb = x12;
    y_ta        = y22;          y_tb = y12;
end

% Overlap in the X-direction:
if x_la > x_lb
    % boxA completely within boxB in X-direction
    f_xo        = x_ra - x_la;
else
    f_xo        = x_ra - x_lb;
end

f_areaA         = (x_ra - x_la) * (y_ta - y_ba);
f_areaB         = (x_rb - x_lb) * (y_tb - y_bb);

if f_xo >= 0.0
    
    % Check for boxA "below" or "above" boxB
    if y_ba >= y_bb
        % boxA is "above" boxB (can also be wholly contained in boxB)
        % According to the assignment of boxA and boxB conditions, the
        % only possible definition for one within the other is boxA
        % in boxB.
        %
        % is boxA wholly within boxB?
        if y_tb > y_ta
            f_yo = y_ta - y_ba;
        else
            f_yo = y_tb - y_ba;
        end
    else
        % boxA is below boxB
        f_yo = y_ta - y_bb;
    end
    
    if f_yo < 0.0
        % There was no overlap in y...
        f_yo = 0.0;
    end

    f_overlapArea = f_xo * f_yo;
    if f_areaA <= f_areaB
        af_perc = f_overlapArea / f_areaA;
    else
        af_perc = f_overlapArea / f_areaB;
    end

end

af_perc = af_perc * 100;
af_A1   = f_areaA;
af_A2   = f_areaB;
end
