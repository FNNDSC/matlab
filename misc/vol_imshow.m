function [V] = vol_normalizeSlice(a_V, varargin)
%
% [V] = vol_imshow(a_V [, a_plane])
%
% ARGS
% INPUT
% a_V                   vol                     volume data to imshow
% 
% OPTIONAL
% a_startSlice		scalar			slice to start display
% a_plane               scalar                  plane to view:
%                                               1 - row
%                                               2 - column
%                                               3 - slice
% 
% DESC
% Runs imshow on extracted slices in a volume. Pauses for user keystroke
% before cycling to next image.
% 
% HISTORY
% 11 December 2008
% o Initial design and coding.
%
% 06 May 2009
% o Added a_startSlice.
% 

%%%%%%%%%%%%%%
%%% Nested functions
%%%%%%%%%%%%%%
        function error_exit(    str_action, str_msg, str_ret)
                fprintf(1, '\tFATAL:\n');
                fprintf(1, '\tSorry, some error has occurred.\n');
                fprintf(1, '\tWhile %s,\n', str_action);
                fprintf(1, '\t%s\n', str_msg);
                error(str_ret);
        end

        function vprintf(level, str_msg)
            if verbosity >= level
                fprintf(1, str_msg);
            end
        end
%%%%%%%%%%%%%%
%%%%%%%%%%%%%%


plane 		= 3;
b_userSlice	= 0;

if length(varargin)>=1
    slice   	= varargin{1}; 
    b_userSlice	= 1;
end
if length(varargin)>=2;	plane   = varargin{2}; end

sz = size(a_V);
if length(sz) ~= 3
    error_exit( 'examining input data',                         ...
                'data does not seem to be a volume',            ...
                '1');
end

format short
sliceMax        = sz(plane); 
if ~b_userSlice
    slice	= round(sz(plane)/2);
end
while 1==1
%  for slice   = 1:sz(plane)
    if slice < 1 ;              slice = sliceMax ;      end
    if slice > sliceMax ;       slice = 1 ;             end
    switch plane
      case 1,
        M       = squeeze(a_V(slice,:,:));
      case 2,
        M       = squeeze(a_V(:,slice,:));
      case 3,
        M       = squeeze(a_V(:,:,slice));
    end
    imshow(M, 'InitialMagnification', 'fit');
%      w = waitforbuttonpress;
    try
      [x, y, button]      = ginput(1);
    catch ME
      break;
    end
    if button == 1 ; slice = slice + 1; end
    if button == 3 ; slice = slice - 1; end
    fprintf('Displaying slice %d of %d (%3.0f%s ) x = %3.2f\ty = %3.2f\n',        ...
            slice, sliceMax, slice/sliceMax*100, '%', x, y);
end

end