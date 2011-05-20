function [] = ADCASL_stats(astr_ADCsubj, astr_ASLsubj, astr_ADCASLcontrol, ...
                                varargin)
%
% NAME
%
%	function [] = ADCASL_stats(     astr_ADCsubj,           ...
%                                       astr_ASLsubj,           ...
%                                       astr_ADCASLcontrol[,    ...
%                                       astr_type])
%
% ARGUMENTS
% INPUT
%	astr_ADCsubj            string          ROI filename for subj ADC
%	astr_ASLsubj            string          ROI filename for subj ASL
%	astr_ADCASLcontrol      string          ROI filename for control ADC,ASL
%
% OPTIONAL INPUT
%       astr_type               string          one of 'mean', 'var', 'varperc'
%
% DESCRIPTION
%
% Parses the intensity data, and performs several t-tests.
%
% PRECONDITIONS
%
% POSTCONDITIONS
%
% NOTE:
%
% HISTORY
% 02 March 2011
% o Initial design and coding.
%

% defaults
str_type        = 'mean';

if length(varargin), str_type = varargin{1};, end;

% Load input files
%lprintf(50, 'Reading input files');
M_ADCsubj       = load(astr_ADCsubj);
M_ASLsubj       = load(astr_ASLsubj);
M_norm          = load(astr_ADCASLcontrol);
%lprintf(30, '[ ok ]\n\n\n');

% Create subject and control ADC and ASL vectors
v_subjADCroi    = M_ADCsubj(:, 1);
v_subjADCnroi   = M_ADCsubj(:, 2);

v_subjASLroi    = M_ASLsubj(:, 1);
v_subjASLnroi   = M_ASLsubj(:, 2);

v_normADC       = M_norm(:, 1);
v_normASL       = M_norm(:, 2);

% Perform the t-tests

cM_test         = {                                             ...
                        [ v_subjADCroi  v_subjADCnroi ],        ...
                        [ v_subjADCroi  v_normADC],             ...
                        [ v_subjADCnroi v_normADC],             ...
                        [ v_subjASLroi  v_subjASLnroi],         ...
                        [ v_subjASLroi  v_normASL],             ...
                        [ v_subjASLnroi v_normASL]              ...
                };
cstr_testDesc   = {                                             ...
                        'ADC$_s(r)$ -vs- ADC$_s(\check{r})$',   ...
                        'ADC$_s(r)$ -vs- ADC$_n$',              ...
                        'ADC$_s(\check{r})$ -vs- ADC$_n$',      ...
                        'ASL$_s(r)$ -vs- ASL$_s(\check{r})$',   ...
                        'ASL$_s(r)$ -vs- ASL$_n$',              ...
                        'ASL$_s(\check{r})$ -vs- ASL$_n$',      ...
                };

cstr_testDescA  = {                                             ...
                        'ADC$_s(r)$',                           ...
                        'ADC$_s(r)$',                           ...
                        'ADC$_s(\check{r})$',                   ...
                        'ASL$_s(r)$',                           ...
                        'ASL$_s(r)$',                           ...
                        'ASL$_s(\check{r})$',                   ...
                };

cstr_testDescB  = {                                             ...
                        'ADC$_s(\check{r})$',                   ...
                        'ADC$_n$',                              ...
                        'ADC$_n$',                              ...
                        'ASL$_s(\check{r})$',                   ...
                        'ASL$_n$',                              ...
                        'ASL$_n$',                              ...
                };

cstr_tail       = { 'both', 'right', 'left'};

cstr_headingMean = { '$\bar{x}(a)$', '$\bar{x}(b)$'};
cstr_tailDescMean= { '$\bar{x}(a) \neq \bar{x}(b)$',                    ...
                        '$\bar{x}(a) > \bar{x}(b)$',                    ...
                        '$\bar{x}(a) < \bar{x}(b)$'};

cstr_headingStd = { '$\sigma(a)$', '$\sigma(b)$'};
cstr_tailDescStd= { '$\sigma(a) \neq \sigma(b)$',                       ...
                        '$\sigma(a) > \sigma(b)$',                      ...
                        '$\sigma(a) < \sigma(b)$'};

cstr_headingStdn = { '$\hat{\sigma}(a)$', '$\hat{\sigma}(b)$'};
cstr_tailDescStdn= { '$\hat{\sigma}(a) \neq \hat{\sigma}(b)$',          ...
                        '$\hat{\sigma}(a) > \hat{\sigma}(b)$',          ...
                        '$\hat{\sigma}(a) < \hat{\sigma}(b)$'};

cstr_tailDesc   = cstr_tailDescMean;

if strcmp(str_type, 'mean')
    cstr_tailDesc = cstr_tailDescMean;
    cstr_heading  = cstr_headingMean;    
end
if strcmp(str_type, 'var')
    cstr_tailDesc = cstr_tailDescStd; 
    cstr_heading  = cstr_headingStd;    
end
if strcmp(str_type, 'varperc')
    cstr_tailDesc = cstr_tailDescStdn;
    cstr_heading  = cstr_headingStdn;    
end

w_colName       = 35;
w_colA          = 20;
w_colB          = 20;
w_colData       = 25;

fprintf('\\begin{table}\n');
fprintf('\\begin{centering}\n');
fprintf('\\begin{tabular}{|cc||c|c|c|}\n');
fprintf('\\hline \n');
fprintf('%*s & %*s & %*s & %*s & %*s \\\\\n',                   ...
        w_colA, cstr_heading{1},                                ...
        w_colB, cstr_heading{2},                                ...
        w_colData, cstr_tailDesc{1},                            ...
        w_colData, cstr_tailDesc{2},                            ...
        w_colData, cstr_tailDesc{3});
fprintf('\\hline \\hline \n');
for exp = 1:length(cM_test)
    M   = cM_test{exp};
    v1  = M(:, 1);
    v2  = M(:, 2);
    fprintf('%*s &', w_colA, cstr_testDescA{exp});
    fprintf('%*s',   w_colB, cstr_testDescB{exp});
    for tail = 1:length(cstr_tail)
        [h, f_p]  = ttest2(v1, v2, 0.05, cstr_tail{tail}, 'unequal');
        str_test  = sprintf('%d (%.3e)', h, f_p);
        fprintf(' & %*s', w_colData, str_test);
    end
    fprintf(' \\\\\n\\hline \n');
end

fprintf('\\end{tabular}\n');
fprintf('\\par\\end{centering}\n');
fprintf('\\end{table}\n');




