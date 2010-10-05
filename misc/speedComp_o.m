function [void] = speedComp_o(a_trials, a_size)
% 
% OCTAVE FILE
% 
% SYNOPSIS
%  	[void] = speedComp_o(a_trials, a_size)
% 
% ARGS
% 	a_trials        in      number of trials to run
% 	a_size		in	size of square matrix edge
%   	void            out     dummy output
% 
% DESC
%   	Does a quick and dirty speed trial on matrix multiplication.
% 
% HISTORY
% 04 September 2002
%   o Initial design and coding.
% 
% 05 March 2003
%  o Added a_size
%  o Changed contents of matrices A and B so that cells
%  	are a causal function of indices


M_A = zeros(a_size, a_size);
M_B = zeros(a_size, a_size);
M_C = zeros(a_size, a_size);

disp('**********')
disp('Setting up matrices M_A and M_B')
for i=1:a_size,
    for j=1:a_size,
        M_A(i,j) = i+j;
        M_B(i,j) = i-j;
    end
end

txt = sprintf('Number of trial multiplications of M_C = M_A * M_B:\t%d', a_trials); disp(txt)
txt = sprintf('Size of square matrix edge:\t\t\t\t%d', a_size); disp(txt)
startTime   = cputime;
for k=1:a_trials,
    M_C = M_A * M_B;
end
totalTime    = cputime - startTime;
txt = sprintf('Total time for MatLAB matrix multiplication:\t\t%f seconds', totalTime); disp(txt)

disp('**********')
txt = sprintf('Max of M_A:\t\t\t%f', max(max(M_A))); disp(txt)
txt = sprintf('Max of M_B:\t\t\t%f', max(max(M_B))); disp(txt)

disp('**********')
txt = sprintf('Mean of M_A:\t\t\t%f', mean(mean(M_A))); disp(txt)
txt = sprintf('Standard deviation of M_A:\t%f', std(std(M_A))); disp(txt)

disp('**********')
txt = sprintf('Mean of M_B:\t\t\t%f', mean(mean((M_B)))); disp(txt)
txt = sprintf('Standard deviation of M_B:\t%f', std(std(M_B))); disp(txt)

disp('**********')
txt = sprintf('Mean of M_C:\t\t\t%f', mean(mean(M_C))); disp(txt)
txt = sprintf('Standard deviation of M_C:\t%f', std(std(M_C))); disp(txt)


