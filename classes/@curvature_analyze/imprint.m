function C = imprint(C, astr_epsFile, astr_imgFile, varargin)
%
% NAME
%
%  function C = imprint(C, astr_epsFile, astr_imgFile [, imgFormat])
%
% ARGUMENTS
% INPUT
%	C		class		class that contains a verbosity value
%       astr_epsFile    string          filename of eps file
%       astr_imgFile    string          filename of imgage file (usually jpg)
%
% OPTIONAL
%	imgFormat       string          typically '-djpeg', i.e. the device spec
%                                       to print the image to.
%
% DESCRIPTION
%
%	This function method prints the current image buffer.
%
% PRECONDITIONS
%
%
% POSTCONDITIONS
%
% NOTE:
%
% HISTORY
% 5 November 2012
% o Initial design and coding.
%

C.mstack_proc 	= push(C.mstack_proc, 'imprint');

imgFormat       = '-djpeg';
if length(varargin)
    imgFormat   = varargin{1};
end

print('-depsc2', astr_epsFile);
try
    print(imgFormat,  astr_imgFile);
catch
    lprintf(C, 'Caught: %s generation error on %s', imgFormat, astr_imgFile);
end


[C.mstack_proc, element]= pop(C.mstack_proc);
