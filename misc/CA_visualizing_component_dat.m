
function CA_visualizing_component_dat(str_folderName, f_at, str_color)
%
% NAME
%
%   function CA_visualizing_component_dat(str_folderName, f_at)
%
% ARGS
%
%   str_folderName              Name of folder containing *.dat files
%                               created by an earlier run of 
%                               'features_determine.py'
%   f_at                        Angle threshold to process
%   str_color                   The color 'species' to load. One of
%                               'r', 'g', or 'b'.
%
%

str_startDir  = pwd;
cd(str_folderName);

str_fileName = sprintf('evolved_AT%d_%s.dat', f_at, str_color);

M_dat = load(str_fileName);
M_dat = M_dat ./ max(M_dat(:));
dummyPlane=zeros(size(M_dat));
[rows cols]=size(dummyPlane);
C=zeros(rows, cols, 3);

colorPlane = 1;
switch str_color
    case 'r'
        colorPlane = 1;
    case 'g'
        colorPlane = 2;
    case 'b'
        colorPlane = 3;
end

figure(colorPlane);
C(:,:,colorPlane)    = M_dat;

image(C);
print('-dpsc','-r1200',sprintf('%s.eps', str_fileName));
print('-djpeg',sprintf('%s.jpg', str_fileName));

cd(str_startDir);
end