function [H] = Qtest(baseLineReward, b_figures)
%//
%// [H] = Qtest(baseLineReward, b_figures)
%//
%// ARGS
%// H               out             table of test results
%// baseLineReward  in              baseLineReward for each Q state
%// b_figures       in              if true, draw figures
%//
%// DESC
%// This function is used to study specific aspects of the Q-learning
%// algorithm - particularly the effect of learning rate and
%// reward values.
%//
%// It basically loops over the Qlearn function with the following
%// values for
%//
%//     [alpha, gamma, delAlpha] = [0.9, 1.0],[0.9, 1.0],[0.9, 1.0]
%//
%//
%// HISTORY
%// 20 March 2002
%// o Initial design and coding.
%//

RMS     = zeros(1,8);
i       = 1;
Hstr    = '';

for alpha = 0.5:0.5:1.0
    for gamma = 0.9:0.1:1.0
        for delAlpha = 0.9:0.1:1.0
            h       = Qlearn(alpha, gamma, delAlpha, baseLineReward);
            rms     = sqrt(mean(mean((h).^2)));
            RMS(i)  = rms;
            status  = sprintf('%f\t%f\t%f\t%f', alpha, gamma, delAlpha, rms);
            str_title = sprintf('\\alpha = %f\t\\gamma = %f\t\\Delta\\alpha = %f\nbaseReward = %f', alpha, gamma, delAlpha, baseLineReward);
            Hstr    = char(Hstr, status);
            if(b_figures) 
                figure(i);
                mesh(h);
                xlabel('episodeLength');
                ylabel('iteration');
                zlabel('Q(S)');
                title(str_title);
            end
            i = i+1;
        end
    end
end

H = str2num(Hstr);


            