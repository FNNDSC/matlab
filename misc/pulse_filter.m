function [av_out] =	pulse_filter(av_in, varargin) 
%
% NAME
%
%  function [av_out] =	pulse_filter(av_in <, a_pulseWidth, ab_strictFilter)
%
% ARGUMENTS
% INPUT
%	av_in		vector		Input vector
%       
% OPTIONAL
%       a_pulseWidth    int             Width of pulse filter -- default 1
%       a_strictFilter  int (bool)      If zero, turn off strict filtering.
%
% OUTPUTS
%	av_out		vector          Resultant after applying the pulse
%                                       filter.
%
% DESCRIPTION
%
%       'pulse_filter' filters a vector signal, removing any 'pulses'
%       of width <a_pulsewidth>, i.e. a signal represented as
%       
%               [ 0 0 1 0 0 1 1 1 1 0 0 0 1 0 ]
%
%       would be filtered to:
%       
%               [ 0 0 0 0 0 1 1 1 1 0 0 0 0 0 ]
%               
%      assuming <a_pulseWidth> is 1.
%      
%      For longer <a_pulseWidth>, the behaviour is more complex. In the
%      strictest sense, all pulses of width <a_pulseWidth> will
%      be filtered. However, consider a filter train
%      
%               [ 0 0 1 1 1 0 1 1 1 1 1 0 0 0 0 0 1 1 1 0 0 0 ]
%               
%      and <a_pulseWidth> of 3. It is possible that the '0' in position
%      6 is noise given that it appears in the middle of an otherwise long
%      square wave. Strict pulse filtering would result in
%      
%               [ 0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 ]
%
%       which might in fact be incorrect. To turn off strict filtering, pass
%       <ab_strictFilter = 0> which will only filter pulses if they are padded
%       on both sides by zeros of length <a_pulseWidth>. In such a case, the
%       above wave is filtered to
%       
%               [ 0 0 1 1 1 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 ]
%
% PRECONDITIONS
%
%       o <av_in> is a vector.
%       o Non-signal components of <av_in> are set to zero.
%
% POSTCONDITIONS
%
%       o <av_out> is a pulse filtered version of <av_in>.
%       o Note that for cases when padding between square trains is one less 
%         than <a_pulseWidth> and with strict filtering off, spurious pulses 
%         might result.
%
% SEE ALSO
%
% HISTORY
% 19 Aug 2009
% o Initial design and coding.
%
%

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

        function av_out = repulse(av_in, a_dir, a_width)
        %
        % DESCRIPTION
        % o This function 'restores' pulse width length that
        %   has been decimated due to the filter/shift operation
        %   
            av_out = av_in;
            for i = 1:numel(av_in)
                if av_in(i)
                    for j = 1:a_width
                        av_out(i+a_dir*j) = 1;
                    end
                end
            end
        end

%%%%%%%%%%%%%% 
%%% Nested functions :END
%%%%%%%%%%%%%% 

pulseWidth      = 1;
b_strictFilter  = 1;

if length(varargin) & isfloat(varargin{1})
    pulseWidth  = varargin{1};
    if length(varargin) >= 2
        b_strictFilter  = varargin{2};
    end
end

if ~is_vect(av_in)
    error_exit('Checking input', 'a non-vector was passed', '1');
end

v_signal        = av_in;
v_signal        = padarray(av_in, [0, numel(av_in)]);
for pass = 1:pulseWidth
    v_rightShift = v_signal;
    v_leftShift  = v_signal;
    for circpass = 1:pass
    % We shift and filter in steps of 1. This allows us to 
    % selectively apply strict or fuzzy filtering.
    %
      v_rightShift = circshift(v_rightShift, [1, +1]);
      v_leftShift  = circshift(v_leftShift, [1, -1]);
      if b_strictFilter
          v_rightShift = v_rightShift .* v_signal;
          v_leftShift  = v_leftShift .* v_signal;
      end
    end

    v_rightFilt  = v_rightShift .* v_signal;
    v_rightFilt  = repulse(v_rightFilt, -1, pass);
    v_leftFilt   = v_leftShift  .* v_signal;
    v_leftFilt   = repulse(v_leftFilt, +1, pass);

    v_signal     = v_rightFilt + v_leftFilt;
end

v_signal        = v_signal(numel(av_in)+1:numel(av_in)*2);
av_out          = av_in;
av_out(find(v_signal == 0)) = 0;
end