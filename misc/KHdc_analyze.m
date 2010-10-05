function [] = KHdc_analyze(varargin)
%
% NAME
%
%  function [] = KHdc_analyze([<astr_volname>])
%
% ARGUMENTS
% INPUT
%
% OPTIONAL
%	
%
% DESCRIPTION
%
%	This function is a scratch pad for analyzing the discrete and
%	continuous curvatures - K and H.
%
% PRECONDITIONS
%
%
% POSTCONDITIONS
%
% NOTE:
%
% HISTORY
% 13 July 2007
% o Initial design and coding.
%


LC		= 50;
RC		= 30;

[Kc, fnum]	= read_curv('rh.smoothwm.curv.K.crv');
[Kd, fnum]	= read_curv('rh.smoothwm.K.crv');

 Kcf 		= Kc(find(Kc<1.5 & Kc>-1.5));
 Kdf 		= Kd(find(Kd<1.5 & Kd>-1.5));

[Hc, fnum]	= read_curv('rh.smoothwm.curv.H.crv');
[Hd, fnum]	= read_curv('rh.smoothwm.H.crv');

 Hcf 		= Hc(find(Hc<2.0 & Hc>-2.0));
 Hdf 		= Hd(find(Hd<2.0 & Hd>-2.0));


keyboard

