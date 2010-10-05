function [M_image] = rosePhantom_plot(varargin)
%
% NAME
%
%  function [x, y] =	rosePhantom_plot([<rows>, <cols>])
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%	rows		int		number of rows in output image
%	cols		int		number of columns in output image
%
% OUTPUTS
%	M_image		matrix		image representation of plot
%
% DESCRIPTION
%
%	'rosePhantom_plot' draws a "rose phantom". Actually, it looks
%	more like a slice through an orange.
%
%
% PRECONDITIONS
%
%	o None
%
% POSTCONDITIONS
%
%	o None.
%
% NOTE:
%
% HISTORY
% 04 June 2007 
% o Initial design and coding.
%
%

%%%%%%%%%%%%%% 
%%% Nested functions :START
%%%%%%%%%%%%%% 
    function error_exit(	str_action, str_msg, str_ret)
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
%%% Nested functions :END
%%%%%%%%%%%%%% 

rows=	256;
cols=	256;

if(length(varargin))
   rows=	varargin{1};
   cols=	varargin{2};
end

t=		0:0.01:2*pi;
M_image=	zeros(256,256);

figure(1);
petals= 	8;
x=		sin(t)+0.1*sin((petals+1)*t);
y=		cos(t)+0.1*cos((petals+1)*t);
x1=		(1.5*x+2)*rows/4;
y1=		(1.5*y+2)*cols/4;
x=		(x+2)*rows/4;
y=		(y+2)*cols/4;
d=1:rows;
for i=1:length(x)
    M_image(round(x(i)), round(y(i))) 	= 255;
    M_image(round(x1(i)), round(y1(i))) = 128;
end
%  M_image(round(x1), round(y1), 3)=	1;
plot(x1, y1);
hold on;
plot(x, y);
grid on;
axis equal

figure(2);
image(M_image);

%  for i=1:2
%      plot( [0 -cos(pi/petals)], [0 (-1)^i*sin(pi/petals)] )
%      plot( [0  cos(pi/petals)], [0 (-1)^i*sin(pi/petals)] )
%      plot( [0 -sin(pi/petals)], [0 (-1)^i*cos(pi/petals)] )
%      plot( [0  sin(pi/petals)], [0 (-1)^i*cos(pi/petals)] )
%  end


end