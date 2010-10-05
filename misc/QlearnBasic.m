function [H] = QlearnBasic(alpha, gamma, delAlpha, baseLineReward, learningTrials)
%//
%// [H] = QlearnBasic(alpha, gamma, delAlpha, baseLineReward,learningTrials)
%//
%// ARGS
%// H               out             vector of single episode
%// alpha           in              alpha learning rate parameter
%// gamma           in              gamma discount factor
%// delAlpha        in              change in learning parameter
%// baseLineReward  in              base line reward return
%// learningTrials  in              number of episodes to run
%//
%// DESC
%// This function is used to study specific aspects of the Q-learning
%// algorithm - particularly the effect of learning rate and
%// reward values.
%//
%//
%// HISTORY
%// 29 April 2002
%// o Initial design and coding.
%//

episodeLength   = 100;

H           = zeros(1, episodeLength);
Q           = zeros(1, episodeLength);
visits      = zeros(1, episodeLength);
Alpha       = ones(1, episodeLength) * alpha;
Gamma       = ones(1, episodeLength) * gamma;

for episode = 1:learningTrials
    for state = 1:episodeLength-1
%        visits(state)       = visits(state) + 1;
        Q(state)            = Q(state) + Alpha(state)*(reward(state+1, episodeLength, baseLineReward) + Gamma(state)*Q(state+1) - Q(state));
        Alpha(state)        = Alpha(state)*delAlpha;
%        Gamma(state)        = 1-(1-gamma)*exp(-state/100);
%        Gamma(state)        = 0.9 + 0.1*exp(-state/10);
        H(1, state)   = Q(state);
%        G(episode, state)   = Gamma(state);
    end
    H(1, episodeLength) = -10;
    if ~rem(episode, 1e3)
        sprintf('Episode %d', episode)
        Q(1:7)
    end
end

        
       
