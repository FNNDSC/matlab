
clear all
close all

n = 8;

t = (0:100)';
y = rand(101, n);
muscles = {'TS', 'VM', 'VL', 'GM', 'FDL', 'FHL', 'SOL', 'TA'};

h = figure(1)
set(h, 'Position', [200 200 560 800])

for i = 1:n
    subplot(n,1,i)
    plot(t, y(:,i))
    if i < n
        set(gca, 'XTickLabel', [])
    end
    ylabel(muscles{i})
end

xlabel('time (sec)')