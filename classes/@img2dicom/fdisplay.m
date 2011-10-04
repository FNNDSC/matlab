function fdisplay(c)
%
% NAME
%
%  function fdisplay(c)
%
% ARGUMENTS
% INPUT
%	c		class		cortical parellation class
%
% OPTIONAL
%
% DESCRIPTION
%
%	'display' writes the internals of the class to stdout in
%	a formatted manner.
%
% NOTE:
%
% HISTORY
% 12 June 2007
% o Initial design and coding.
%

LC = 25;
RC = c.m_marginRight;

disp(' ');
disp([inputname(1), ' = ']);
disp(' ');

fprintf(1, 'Internals:\n')
fprintf(1, '%*s: %s\n', LC, 'mstr_class', 	c.mstr_class);
fprintf(1, '%*s: %s\n', LC, 'mstr_obj', 	c.mstr_obj);
fprintf(1, '%*s: ',     LC, 'mstack_proc');
disp(c.mstack_proc);

fprintf(1, '\nSource data info:\n')
fprintf(1, '%*s: %s\n', LC, 'mstr_subjectsDir',	c.mstr_subjectsDir);
fprintf(1, '%*s: %s\n', LC, 'mstr_workingDir', 	c.mstr_workingDir);
fprintf(1, '%*s: %s\n', LC, 'mstr_sulcTable', 	c.mstr_sulcTable);
fprintf(1, '%*s: %s\n', LC, 'mstr_PID', 	c.mstr_PID);
fprintf(1, '%*s: %s\n', LC, 'mstr_scan', 	c.mstr_scan);
fprintf(1, '%*s: %s\n', LC, 'mstr_FSBaseDir', 	c.mstr_FSBaseDir);

fprintf(1, '\nOperational flags:\n')
fprintf(1, '%*s: %d\n', LC, 'mb_useSegmentedVol', c.mb_useSegmentedVol);
fprintf(1, '%*s: %d\n', LC, 'mb_useSmoothPhantom', c.mb_useSmoothPhantom);
fprintf(1, '%*s: %d\n', LC, 'mb_useVoxelPhantom', c.mb_useVoxelPhantom);

fprintf(1, '\nInternal data info:\n')
fprintf(1, '%*s: ', LC, 'mv_cardviewsDims');
disp(c.mv_cardviewsDims);
fprintf(1, '%*s: ', LC, 'mv_dims');
disp(c.mv_dims);
%  fprintf(1, '%*s: ', LC, 'mV_data');
%  disp(c.mV_data);
fprintf(1, '%*s:\n', LC, 'MRIstruct');
disp(c.MRIstruct);

fprintf(1, '\nAuxillary bash shell scripts:\n')
fprintf(1, '%*s: %s\n', LC, 'mscript_sulcusList', 	c.mscript_sulcusList);
fprintf(1, '%*s: %s\n', LC, 'mscript_idList', 		c.mscript_idList);
fprintf(1, '%*s: %s\n', LC, 'mscript_idExtract', 	c.mscript_idExtract);
fprintf(1, '%*s: %s\n', LC, 'mscript_cardviewsDims', 	c.mscript_cardviewsDims);

disp(' ');
