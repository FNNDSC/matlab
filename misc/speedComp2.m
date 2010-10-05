function [void] = speedComp(a_trials)
%//
%// SYNOPSIS
%//   speedComp(a_trials)
%//
%// ARGS
%//   a_trials        in      number of trials to run
%//   void            out     dummy output
%//
%// DESC
%//   Does a quick and dirty speed trial on matrix multiplication.
%//
%// HISTORY
%// 04 September 2002
%//   o Initial design and coding.
%//


M_A = rand(100) * 100;
M_B = rand(100) * 100;

disp('Number of trial multiplications of M_C = M_A * M_B:')
disp(num2str(a_trials))

for k=1:a_trials,
    M_C = M_A * M_B;
end

disp('**********')
disp('Mean of M_A:')
disp(num2str(mean2(M_A)))
disp('Standard deviation of M_A:')
disp(num2str(std2(M_A)))

disp('**********')
disp('Mean of M_B:')
disp(num2str(mean2(M_B)))
disp('Standard deviation of M_B:')
disp(num2str(std2(M_B)))

disp('**********')
disp('Mean of M_C:')
disp(num2str(mean2(M_C)))
disp('Standard deviation of M_C:')
disp(num2str(std2(M_C)))

