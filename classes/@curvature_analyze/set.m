function C = set(C, varargin)
%
% NAME
%
%  function C = set(C, 	  <astr_property1>, <val1> 	...
%			[,<astr_property2>, <val2>	...
%			 ,<astr_propertyN>, <valN>
%			])
%
% ARGUMENTS
% INPUT
%	astr_propertM	string		Property string name
%	astr_valM	<any>		Property value
%
% OUTPUT
%	C		class		modified class
%
% OPTIONAL
%
% DESCRIPTION
%
%	'set' changes named internals of the class.
%
% NOTE:
%
% HISTORY
% 03 November 2009
% o Initial design and coding.
%

persistent b_hemiFilter;
persistent b_subjFilter;
if isempty(b_hemiFilter),       b_hemiFilter    = 0; end;
if isempty(b_subjFilter),       b_subjFilter    = 0; end;

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val  = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
    case        'b_curvFuncClear'
        C.mcstr_curvFunc                = {};
    case        'curvFuncFilter'
        if isempty(find(ismember(C.mcstr_curvFunc, val)==1))
            C.mcstr_curvFunc{end+1} = val;
        end
    case        'b_hemiFilter'
        if val
            C.mcstr_brainHemi           = {};
            b_hemiFilter                = 1;
        end
    case        'hemiFilter'
        if b_hemiFilter
            if isempty(find(ismember(C.mcstr_brainHemi, val)==1))
                C.mcstr_brainHemi{end+1} = val;
            end
        end
    case        'b_subjFilter'
            b_subjFilter                = val;
    case        'subjFilter'
        if b_subjFilter
            C.mstr_lsSubjArgs           = val;
        end
    case        'b_regionFilter'
        C.mb_regionFilter               = val;
    case        'regionFilter'
        if isempty(find(ismember(C.mcstr_regionFilter, val)==1))
            C.mcstr_regionFilter{end+1} = val;
        end
    case        'verbosity'
        C.m_verbosity                   = val;
    case        'b_curvaturesPostScale'
        C.mb_curvaturesPostScale        = val;
    case        'b_drawHistPlots'
        C.mb_drawHistPlots              = val;
    case        'b_lowerLimit'
        C.mb_lowerLimitSet              = val;
    case        'f_lowerLimit'
        C.mf_lowerLimit                 = val;
    case        'b_upperLimit'
        C.mb_upperLimitSet              = val;
    case        'f_upperLimit'
        C.mf_upperLimit                 = val;
    case        'b_centroidLabelPlot'
        C.mb_centroidLabelPlot          = val;
    case        'annotFile'
        C.ms_annotation.mstr_annotFile  = val;
    case        'offScreenCentroidPlots'
        C.mb_offScreenCentroidPlots     = val;
    case        'perSubjCentroidsPlot'
        C.mb_perSubjCentroidsPlot       = val;
    case        'groupIDfile'
        C.ms_info.mstr_idFile           = val;
    case        'surface'
        C.mcstr_surfaceType             = val;
    case        'lineStyle'
        C.mc_lineStyle                  = val;
    case        'colorSpec'
        C.mc_colorSpec                  = val;
    case        'subjLabelFile_use'
        C.mb_subjLabelFile_use          = val;
    case        'usePlotLines'
        C.mb_useLines                   = val;

   otherwise
        error('curvature_analyze:Properties:set error');
   end
end

