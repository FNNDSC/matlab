function c = subjects_preprocess(c, varargin)
%
% NAME
%
%  function c = subjects_preprocess(c)
%
% ARGUMENTS
% INPUT
%	c		class		curvature_analyze class
%
% OPTIONAL
%
% OUTPUT
%	c		class		curvature_analyze class
%	
%
% DESCRIPTION
%
%       This function preprocess the subjects that are to be used in
%       a curvature_analyze run.
%       
% PRECONDITIONS
%
%	o the curvature_analyze class instance must be fully instantiated.
%       o subject names/dirs are assumed to be numeric!!
%
% POSTCONDITIONS
%
%	o the <c.mc_subjectInfo> cell array is populated.
%               - voxelSize and f_scaleFactor
%               - working directory, subject directory
%
% NOTE:
%
% HISTORY
% 18 September 2009
% o Initial design and coding.
%
% 26 October 2009
% o Added 'subjectName.txt' handling.
% 

%%%%%%%%%%%%%%
%%% Nested functions
%%%%%%%%%%%%%%

function dir_create(astr_dir)
        [ret str_console] = unix(sprintf('mkdir -p %s', astr_dir));
        if ret
            vprintf(c, 1, 'While attempting to create %s', astr_dir);
            error_exit(c, '1', 'Could not create working dir')
        end
end

%%%%%%%%%%%%%%
%%%%%%%%%%%%%%


c.mstack_proc 	        = push(c.mstack_proc, 'subjects_preprocess');
verbosityLevel          = c.m_verbosityLevel;
c.m_verbosityLevel      = 2;

cd(c.mstr_subjectsDir);
str_pwd         = pwd;
c.mstr_subjectsDir  = str_pwd;
c.mstr_analysisPath = sprintf('%s/%s', c.mstr_subjectsDir, c.mstr_analysisDir);
if exist(c.mstr_analysisPath) ~= 7, dir_create(c.mstr_analysisPath); end

c_dirLst        = dls(sprintf('-d %s', c.mstr_lsSubjArgs));
subjCount       = 0;
[ret str_cwd]   = unix('pwd');
str_cwd         = deblank(str_cwd);

for subjIndex = 1:numel(c_dirLst)
    str_subj    = c_dirLst{subjIndex};
    str_subjDir = sprintf('%s/%s', str_cwd, str_subj);
    if ~subjCount, [c, a_status] = annotation_parse(c, str_subjDir); end
    subjCount   = subjCount + 1;
    str_workingDir      = sprintf('%s/%s/%s', str_cwd, str_subj,        ...
                                c.ms_info.mstr_processDir);
    c.ms_info.mstr_workingDir = str_workingDir;
    str_subjLabelFile   = sprintf('%s/%s', str_workingDir,              ...
                                c.ms_info.mstr_subjLabelFile);
    if exist(str_workingDir) ~= 7       % see 'help exist'
        colprintf(c, 'Creating working dir for subject', '[ ok ]\n');
        dir_create(str_workingDir);
    else
        colprintf(c, 'Found working dir for subject', '[ ok ]\n');
    end
    str_label   = str_subj;
    if exist(str_subjLabelFile) & c.mb_subjLabelFile_use
        fid_subj                        = fopen(str_subjLabelFile, 'r');
        str_label                       = fscanf(fid_subj, '%s');
        fclose(fid_subj);
    else
        try
            fid_subj    = fopen(str_subjLabelFile, 'w');
        catch ME
	    error_exit(c, 	...
    'err:1', 'Unable to access file:\n%s\n. Possible permission problem?', ...
			str_subjLabelFile);
	end
        fprintf(fid_subj, '%s', str_label);
        fclose(fid_subj);
    end
    str_label                   = str_clean(str_label, '-', {'\.'});
    c.ms_info.mstr_subjLabel    = str_label;
    c.ms_info.mstr_subjDir      = sprintf('%s/%s', str_cwd, str_subj);
    c.ms_info.mstr_subjName     = str_subj;
    colprintf(c, 'Subject',     '[ %s ]\n', str_subj);
    colprintf(c, 'Label',       '[ %s ]\n', str_label);
    str_idFile                  = sprintf('%s/%s',      ...
                                    str_workingDir, c.ms_info.mstr_idFile);
    %
    % gids must be strictly positive integers                                
    if exist(str_idFile)
        % Catch for non-numeric contents??
        c.ms_info.mgid          = load(str_idFile);
        if ~isfloat(c.ms_info.mgid), c.ms_info.mgid = 1;                end;
        % If gid == 0, then set to 1
        if ~c.ms_info.mgid, c.ms_info.mgid = 1,                         end;
        % If gid < 0, then flip
        if ~c.ms_info.mgid < 0, c.ms_info.mgid = c.ms_info.mgid * -1;   end;
    else
        c.ms_info.mgid          = subjCount;
        save(str_idFile, 'subjCount', '-ascii');
    end
    colprintf(c, 'Subject gid', '[ %s-%d ]\n', str_subj, c.ms_info.mgid);

    % Voxel size
    str_voxelFile               = sprintf('%s/%s',      ...
                                str_workingDir, c.ms_info.mstr_voxelFile);
    str_voxel                   = '[ 1.0 1.0 1.0 ]';
    fstats                      = dir(str_voxelFile);
    if exist(str_voxelFile) & fstats.bytes
        colprintf(c, 'voxelSize.txt file in bytes', '[ %d ]\n', fstats.bytes);
        c.ms_info.mv_voxelSize  = load(str_voxelFile);
        lprintf(c, 'Loading voxelSize.txt...', str_voxelFile);
        str_voxel               = sprintf('%f ', c.ms_info.mv_voxelSize);
        colprintf(c, '', '[ ok ]\n');
    else
        colprintf(c, 'Probing for voxelSize...' , '[ ok ]\n');
        chq                     = char(39);     % '
        chs                     = char(92);     % \
        str_subjDir             = c.ms_info.mstr_subjDir;
        colprintf(c, 'Finding dcm file to query...', '[ ok ]\n');
        str_mri                 = sprintf('%s/mri/orig.mgz', str_subjDir);
%        [ret str_mri]           = unix(                 ...
%            sprintf('find %s -follow -iname "*.dcm"|head -n 1', str_subjDir))
        colprintf(c, 'Found file...', '[ ok ]\n');
        fstats = dir(str_mri);
        if length(str_mri) & fstats.bytes
            colprintf(c, 'Running "mri_info"...', '');
            [ret str_mriInfo]   = unix(sprintf('env LD_LIBRARY_PATH= mri_info %s', str_mri));
            [ret str_voxel]     =       ...
            unix(sprintf('echo "%s" | grep "voxel sizes" | awk -F %s: %s{print $2}%s', ...
            str_mriInfo, chs, chq, chq));
            colprintf(c, '', '[ ok ]\n');
            str_voxel           = deblank(str_voxel);
            c.ms_info.mv_voxelSize  = sscanf(str_voxel, '%f, %f, %f');
            fid = fopen(str_voxelFile, 'w');
            fprintf(fid, '%s', str_voxel);
            fclose(fid);
        else
            colprintf(c, 'mri file has zero length!', '[ failure ]\n');
        end
    end
    colprintf(c, 'Voxel size', '%s\n', str_voxel);

    % Scale factor
    % Assume that in plane resolution is iso, i.e. X == Y is TRUE
    if c.ms_info.mv_voxelSize(1) ~= c.ms_info.mv_voxelSize(2)
        error_exit(c, '1', 'In plane resolution not square: %f, %f',    ...
            c.ms_info.mv_voxelSize(1), c.ms_info.mv_voxelSize(2));
    end
    c.ms_info.mf_linearScaleFactor      = 1/c.ms_info.mv_voxelSize(1);
    c.ms_info.mf_surfaceScaleFactor     = 1/c.ms_info.mv_voxelSize(1)^2;

    c.mc_subjectInfo{subjCount}         = c.ms_info;
    c.mmap_subjectInfo(str_label)       = c.ms_info;
end

c.m_verbosityLevel       = verbosityLevel;
[c.mstack_proc, element] = pop(c.mstack_proc);

end