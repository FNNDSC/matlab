function [r] = reward(state, episodeLength, baseLineReward)
%//
%// [r] = reward(state, episodeLength, baseLineReward)
%//
%// ARGS
%// r                   out         reward returned
%// state               in          state for which to return
%//                                     a reward
%// epsiodeLength       in          total length of absolute 
%//                                     episode
%// baseLineReward      in          reward value for non-terminal
%//                                     states
%//
%// DESC
%// This is a very simple function that returns the reward value
%// for a target state. If the state == episodeLength, then the
%// learning run has reached its terminal state, and a negative
%// reward (value = -10) is returned. Otherwise, the baseLineReward
%// value is returned.
%//
%// The purpose of this function is simple to serve as a test-bed
%// for examining the implications of learning rate on Q-algorithm
%// behaviour.
%//
%// HISTORY
%// 20 March 2002
%// o Initial design and coding.
%//

if(state == episodeLength)
    r   = -10;
else
    r   = baseLineReward;
end

