function [] = overView_plot(str_P, str_title, trials)
%
% SYNOPSIS
%   [] = overView_plot(str_P, str_title)
%
% ARGS
%   str_P       in      top-level directory name
%   str_title   in      title for plot
%   trials	in	number of trials to plot
%
% DESC
%   The basic purpose of this function is to produce a set
%   of superimposed plots of the time/performance behaviour
%   of a set of learning experiments.
%
%   This function acts more like a script file, traversing
%   a directory to perform specific text processing on 
%   some log files.
%
%   These log files are produced by runs of the reinforcement
%   learning system, and adhere to a strict format (not discussed
%   here). The most important columns in these log files are the
%   7th and 9th, denoting the time and performance values for
%   a particular experimental run.
%
%   This MatLAB script extracts these columns by escaping
%   to the (UNIX) shell, and reads the numerical data into 
%   MatLAB, keeping independent track of each experiment.
%
%   Once all data of all trials have been read in, this
%   function produces a stairstep plot of all the trials
%   superimposed into one figure.
%   
% POSTCONDITIONS
% o This script might require some source-tweaking depending on how
%   many directories for a given run contain results.
%
% HISTORY
% 10 January 2005
% o Time labels modified to hours and not raw iterations - more readable
%   for paper/publishing purposes.
%
% o Structured core graphs in 'cell' format.
%

homeDir=pwd;
cd(str_P)

raw_p	= cell(trials, 1);
raw_t	= cell(trials, 1);
stair_t	= cell(trials, 1);
stair_p	= cell(trials, 1);

for DIR = 1:trials
    cd(num2str(DIR))
    fprintf('Parsing and preparing performance results in directory... %s\n', ...
    		num2str(DIR));
    !cat improve.log | awk '{print $7'} > raw_t$(basename $(pwd)).log
    !cat improve.log | awk '{print $9'} > raw_p$(basename $(pwd)).log
    str_time 				= sprintf('raw_t%d.log', DIR);
    str_performance 			= sprintf('raw_p%d.log', DIR);
    raw_t{DIR}				= load(str_time);
    raw_p{DIR}				= load(str_performance);
    raw_t{DIR}				= raw_t{DIR} ./ 72000;
    raw_p{DIR}				= raw_p{DIR} ./ 72000;
    [stair_t{DIR}, stair_p{DIR}]	= stairs(raw_t{DIR}, raw_p{DIR});
    cd ../
end
cd(homeDir)


fprintf('Plotting...\n');
figure(1);
hold on;
% plot(tt1, pp1, tt2, pp2, tt3, pp3, tt4, pp4, tt5, pp5, tt6, pp6, tt7, pp7, tt8, pp8, tt9, pp9, tt10, pp10, tt11, pp11, tt12, pp12, tt13, pp13);
%plot(tt1, pp1, tt2, pp2, tt3, pp3, tt4, pp4, tt5, pp5, tt6, pp6, tt7, pp7, tt8, pp8, tt9, pp9, tt10, pp10);
for DIR = 1:trials
    plot(stair_t{DIR}, stair_p{DIR});
end
grid on
title(str_title);
xlabel('time (hours)');
ylabel('Best episode length (hours)');
fprintf('Done...\n');
