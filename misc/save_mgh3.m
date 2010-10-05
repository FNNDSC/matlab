function r = save_mgh3(vol, fname, M, mr_parms, varargin);
%
% NAME
%
%	function r = save_mgh3(vol, fname, M, mr_parms, ... <type>)
%
% ARGUMENTS
%
%	vol		in (3D struct)	the volume to save to disk
%	fname		in (string)	the filename to hold <vol>
%	M		in (matrix)	4x4 vox2ras transform matrix
%	mr_parms	in (vector)	some additional sequence params
%	<type>		varargin{1}	optional int denoting <type>
%					of data to save <vol> as
%
%	r		out (bool)	success (0); fail (1)
%
% DESCRIPTION
%
%	'save_mgh3' saves an image volume in mgh format.
% 	M is the 4x4 vox2ras transform such that
% 	y(i1,i2,i3), xyz = M*[i1 i2 i3 1] where the
% 	indicies are 0-based
%
% 	mr_parms = [tr flipangle te ti]
%
% SEE ALSO
%	o load_mgh, vox2ras_0to1
%
% $Id$
%

r = 1;

if(nargin < 2)
  msg = 'USAGE: save_mgh3(vol,fname,M)';
  return;
end

if(exist('mr_parms')~=1) mr_parms = []; end
if(isempty(mr_parms))   mr_parms = [0 0 0 0]; end
if(length(mr_parms) ~= 4)
  fprintf('ERROR: mr_parms length = %d, must be 4\n', ...
	  length(mr_parms));
  return;
end

% These don't appear to be used 
MRI_UCHAR 	= 0 ;	
MRI_INT 	= 1 ;	
MRI_LONG 	= 2 ;	
MRI_FLOAT 	= 3 ;	
MRI_SHORT 	= 4 ;	
MRI_BITMAP 	= 5 ;
MRI_TENSOR 	= 6 ;

MRI_TYPE	= MRI_FLOAT;
if length(varargin)
	MRI_TYPE	= varargin{1};
end

switch MRI_TYPE
    case 0 % MRI_UCHAR 
	precision = 'uchar';
    case 1 % MRI_INT 
	precision = 'int32';
    case 2 % MRI_LONG 
    	precision = 'int64';
    case 3 % MRI_FLOAT 
    	precision = 'float32';
    case 4 % MRI_SHORT 
    	precision = 'int8';
    otherwise
    	precision = 'float32';
end

fid = fopen(fname, 'wb', 'b') ;
if(fid == -1)
  fprintf('ERROR: could not open %s for writing\n',fname);
  return;
end


[ndim1,ndim2,ndim3,rows,cols] = size(vol) ;
fwrite(fid, 1, 'int') ;		% magic #
fwrite(fid, ndim1, 'int') ; 
fwrite(fid, ndim2, 'int') ; 
fwrite(fid, ndim3, 'int') ; 
fwrite(fid, 1, 'int') ;		% # of frames
if (ndims(vol) == 5)
  is_tensor = 1 ;
  fwrite(fid, MRI_TENSOR, 'int') ; % type = MRI_TENSOR
else
  is_tensor = 0 ;
  fwrite(fid, MRI_TYPE, 'int') ;  % type = <type>
end

%%?????????????%%%
fwrite(fid, 1, 'int') ;          % dof (not used)
dof = fread(fid, 1, 'int') ; 

UNUSED_SPACE_SIZE= 256;
USED_SPACE_SIZE = (3*4+4*3*4);  % space for ras transform

MdcD = M(1:3,1:3);
delta = sqrt(sum(MdcD.^2));

Mdc = MdcD./repmat(delta,[3 1]);
Pcrs_c = [ndim1/2 ndim2/2 ndim3/2 1]'; %'
Pxyz_c = M*Pcrs_c;
Pxyz_c = Pxyz_c(1:3);

fwrite(fid, 1,      'short') ;       % ras_good_flag = 1
fwrite(fid, delta,  'float32') ; 
fwrite(fid, Mdc,    'float32') ; 
fwrite(fid, Pxyz_c, 'float32') ; 

unused_space_size = UNUSED_SPACE_SIZE-2 ;
unused_space_size = unused_space_size - USED_SPACE_SIZE ;
fwrite(fid, zeros(unused_space_size,1), 'char') ;

fwrite(fid,vol, precision);

fwrite(fid, mr_parms, 'float32') ; 
fclose(fid) ;

r = 0;

return;

