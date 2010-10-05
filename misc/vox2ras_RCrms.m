%%
%% NAME
%%
%%     vox2ras_RCrms.m
%%
%% SYNOPSIS
%%
%%     vox2ras_RCrms
%%
%% DESCRIPTION
%%
%%     "vox2ras_RCrms" is used to perform some (rudimentary) accuracy
%%	calculations on vox2ras_dfmeas(...).
%%
%%
%% PRECONDITIONS
%%
%%     o Directories that contain raw data should also contain a file,
%%
%%		'vox2ras.dicom'
%%
%%	 that describes the *correct* vox2ras for that particular run.
%%
%%     o Relies on non-standard MatLAB command, 'split'
%%
%% POSTCONDITIONS
%%
%%     o A table of data sorted by inPlaneRot:
%%	
%%		inPlaneRot	rms_rot		rms_c
%%
%%	where rms_rot is the rms of the matrix division of the rotational
%%	component, and rms_c is the rms of the matrix divixion of the
%%	center of k-space component.
%%
%% SEE ALSO
%%
%%     se_matProcess.m
%%
%% HISTORY
%%
%% 07 June 2004
%% o Initial design and coding
%%

% Create a list of subdirectories containing "vox2ras.dicom"

cmd		= [ 'find . -name vox2ras.dicom | sed ' char(39) 's/\(.*\)vox2ras.dicom/\1/' char(39)'];
[s, str_d]	= system(cmd);

% 'str_d' now contains a single string of directories. Convert this to a string array, astr_d, where each
% element is a diectory.
w1	= strrep(str_d, char(10), ' ');
astr_d	= split(' ', w1);

[r c]	= size(astr_d);
c	= c-1;

table		= zeros(c+1, 5);
str_filename	= 'meas.asc';
swd		= pwd;
for i=1:c,
    cd(char(astr_d(i)));
    v_dicom	= load('vox2ras.dicom');
    v_meas	= vox2ras_dfmeas(str_filename);
    v_cmeas	= vox2ras_dfmeas(str_filename, 'c');
    cmd = ['cat ' str_filename ' | grep -a sSliceArray.asSlice | grep dInPlaneRot' ... 
    		' | awk ' char(39) '{print $3}' char(39)];
    [s, inPlaneRot]	= system(cmd);
    inPlaneRotation	= str2num(inPlaneRot);
    
    v_dicomRot	= v_dicom(1:3,1:3);
    v_measRot	= v_meas(1:3,1:3);
    v_cmeasRot	= v_cmeas(1:3,1:3);
    v_dicomC	= v_dicom(1:3, 4);
    v_measC	= v_meas(1:3, 4);
    v_cmeasC	= v_cmeas(1:3, 4);
    
    M_rotrms	= v_dicomRot * v_measRot^-1;
    rotrms	= norm(M_rotrms)./sqrt(prod(size(M_rotrms)));
    M_crotrms	= v_dicomRot * v_cmeasRot^-1;
    crotrms	= norm(M_rotrms)./sqrt(prod(size(M_crotrms)));
    M_crms	= v_dicomC./v_measC;
    crms	= norm(M_crms)./sqrt(prod(size(M_crms)));
    M_ccrms	= v_dicomC./v_cmeasC;
    ccrms	= norm(M_ccrms)./sqrt(prod(size(M_ccrms)));
    
    table(i, 1)	= inPlaneRotation;
    table(i, 2)	= rotrms;
    table(i, 3)	= crotrms;
    table(i, 4)	= crms;
    table(i, 5)	= ccrms;
    
    cd(swd);
end
table(c+1,:)	= mean(table(1:c, :));
