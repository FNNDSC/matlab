function [] = K_filter(str_hemi, str_curv, str_domain, str_region, varargin)
%
%  SYNOPSIS
%
%       function [] = K_filter(str_hemi, str_curv, str_domain, str_region, ...
%                               [b_save])
%
% DESC
%  Simple front end to generate per-unit 'pu', 'val' and 'perc' mean plots
%  for a given <hemi><curv><domain><region> data set.
%  
%  Will also save graphs as jpg/eps files.
%  
% ARGS
% INPUT
%       str_hemi... str_region          string          specifies the filter
% OPTIONAL
%       b_save                          bool            if specified, save
%                                                       jpg and eps images
%        
% 
% DEPENDS
% o function relies on the bash script 'curvFunc_perUnit.sh' for the
%   filtering.
%

b_save          = 0;
if length(varargin)>=1,         b_save  = varargin{1};  end

str_cmdPU       = sprintf('curvFunc_perUnit.sh %s %s %s %s pu 1',       ...
                            str_hemi, str_curv, str_domain, str_region);
str_cmdVal      = sprintf('curvFunc_perUnit.sh %s %s %s %s val 1',      ...
                            str_hemi, str_curv, str_domain, str_region);
str_cmdPerc     = sprintf('curvFunc_perUnit.sh %s %s %s %s perc 1',     ...
                            str_hemi, str_curv, str_domain, str_region);
str_title       = sprintf('%s-%s-%s-%s',                                ...
                            str_hemi, str_curv, str_domain, str_region);

[status, str_PU]        = unix(str_cmdPU);
[status, str_val]       = unix(str_cmdVal);
[status, str_perc]      = unix(str_cmdPerc);

M_PU    = str2num(str_PU);
M_val   = str2num(str_val);
M_perc  = str2num(str_perc);

% filter levels
X       = [1 2 3 4 5 6];

% PU
h1      = figure(1);
plot(X, M_PU(1,:), 'r', X, M_PU(2,:), 'g', X, M_PU(3,:), 'b');
grid;
title(str_title);
xlabel('Filter level');
ylabel('Per-Unit Integral');

% val
h2      = figure(2);
plot(X, M_val(1,:), 'r', X, M_val(2,:), 'g', X, M_val(3,:), 'b');
grid;
title(str_title);
xlabel('Filter level');
ylabel('Area Integral');

% perc
h3      = figure(3);
plot(X, M_perc(1,:), 'r', X, M_perc(2,:), 'g', X, M_perc(3,:), 'b');
grid;
title(str_title);
xlabel('Filter level');
ylabel('Area percentage');

if(b_save)
    saveas(h1, 'pu-integral.jpg');
    saveas(h1, 'pu-integral.eps');
    saveas(h2, 'val-integral.jpg');
    saveas(h2, 'val-integral.eps');
    saveas(h3, 'perc-integral.jpg');
    saveas(h4, 'perc-integral.eps');
end
