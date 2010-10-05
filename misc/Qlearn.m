function [H, G] = Qlearn(alpha, gamma, delAlpha, baseLineReward)
%//
%// [H] = Qlearn(alpha, gamma, delAlpha, baseLineReward)
%//
%// ARGS
%// H               out             2D matrix of learning histories
%// alpha           in              alpha learning rate parameter
%// gamma           in              gamma discount factor
%// delAlpha        in              change in learning parameter
%// baseLineReward  in              base line reward return
%//
%// DESC
%// This function is used to study specific aspects of the Q-learning
%// algorithm - particularly the effect of learning rate and
%// reward values.
%//
%//
%// HISTORY
%// 20 March 2002
%// o Initial design and coding.
%//

episodeLength   = 100;
learningTrials  = 100;

H           = zeros(learningTrials, episodeLength);
G           = zeros(learningTrials, episodeLength);
Q           = zeros(episodeLength);
visits      = zeros(episodeLength);
Alpha       = ones(episodeLength) * alpha;
Gamma       = ones(episodeLength) * gamma;

for episode = 1:learningTrials
    for state = 1:episodeLength-1
        visits(state)       = visits(state) + 1;
        Q(state)            = Q(state) + Alpha(state)*(reward(state+1, episodeLength, baseLineReward) + Gamma(state)*Q(state+1) - Q(state));
        Alpha(state)        = Alpha(state)*delAlpha;
%        Gamma(state)        = 1-(1-gamma)*exp(-state/100);
%        Gamma(state)        = 0.9 + 0.1*exp(-state/10);
        H(episode, state)   = Q(state);
%        G(episode, state)   = Gamma(state);
    end
    sprintf('%d\t%d', visits(episodeLength-1), Gamma(episodeLength-1));
    H(episode, episodeLength) = -10;
    G(episode, episodeLength) = 0.9;
end

        
       