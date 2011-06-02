% This script runs mris_pmake to generate autodijk runs from six
% points on a sphere.  

% Base subject directory
subjectBaseDirs =  { '/chb/users/ginsburg/projects/curvatureAnalysis/recon-normal', ...
                     '/chb/users/ginsburg/projects/curvatureAnalysis/recon-PMG' };
referenceSubjects = { 'CHB01', 'PMG01' };                
hemi = 'lh';
curvs = { 'K1', 'K2', 'K', 'H' };

roiRadius = 100.0 * sin(deg2rad(45)) / sin(deg2rad(67.5));  % Radius about dijkstra point to use from surface

% Boolean toggles
runDijkstra = 1;                % Run mris_pmake to generate autodijk results
runGenCombinedOverlay = 1;      % Generate combined overlay from mris_pmake runs

origin = [0, 0, 100];

% Get six points in the reference surface (need to use the same
% reference surface for all cases in order to have the same six points
% in all surfaces)  Both for normal AND pmg this should be the same.
refSurfaceFileName='/chb/users/ginsburg/projects/curvatureAnalysis/recon-normal/CHB01/surf/lh.sphere';
[refVerts, reFaces] = read_surf(refSurfaceFileName);
[refIndices, refPoints] = find_six_equidistant_points(origin, refVerts);

for subjIdx = 1:length(subjectBaseDirs)
    subjectDir = subjectBaseDirs{subjIdx};
    subjectDirs = dir(subjectDir);
    setenv('SUBJECTS_DIR', subjectDir);
    
    referenceSubject = referenceSubjects{subjIdx};

    for curvIdx = 1:length(curvs)        
        curv = curvs{curvIdx};

        for index = 1:length(subjectDirs)
            curDir = subjectDirs(index);
            if curDir.isdir == 1 && ...
               strcmp(curDir.name,'.') == 0 && ...
               strcmp(curDir.name, '..') == 0

                % Load spherical surface
                if strcmp(referenceSubject, curDir.name)             
                    surfaceFileName = sprintf('%s/%s/surf/%s.sphere', subjectDir, ...
                                                                      curDir.name, ...
                                                                      hemi);            

                else
                    surfaceFileName = sprintf('%s/%s/surf/%s.sphere.to_%s.reg', subjectDir, ...
                                                                           curDir.name, ...
                                                                           hemi, ...
                                                                           referenceSubject);            
                end

                [verts, faces] = read_surf(surfaceFileName);

                % Find the corresponding closest points from the reference sphere
                % in the current sphere
                points = zeros(6,3);
                indices = zeros(6,1);
                for ptIndex=1:length(refPoints)
                    indices(ptIndex) = find_closest_vertex(verts, refPoints(ptIndex,:), 0);
                    points(ptIndex,:)=verts(indices(ptIndex),:);
                end

                workingDir = pwd;
                outputDir = sprintf('%s/%s/surf', subjectDir, curDir.name);
                cd(outputDir);

                % Run mris_pmake for each subject from its points
                if runDijkstra        
                    for i=1:length(indices)            
                        % Run mris_pmake to generate the autodijk surfaces from each point
                        cmd = sprintf(['mris_pmake --subject %s --hemi %s --surface0 smoothwm',...
                                       ' --surface1 sphere --curv0 smoothwm.%s.crv --mpmProg autodijk',...
                                       ' --mpmArgs vertexPolar:%d,costCurvStem:%s-%d --mpmOverlay legacy'], curDir.name, hemi, curv, indices(i)-1, curv, i);
                        disp(cmd);                       
                        system(cmd);
                    end
                end

                % Generate the combine curvature overlay from each of the six dijkstra runs
                if runGenCombinedOverlay
                    % First read the smoothwm curvature and initialize all values
                    % to 0, we are going to overwrite these with values from each
                    % of the surfaces
                    smoothwmCurvFile = sprintf('%s/%s/surf/%s.smoothwm.%s.crv', subjectDir, ...
                                                                                curDir.name, ...
                                                                                hemi, ...
                                                                                curv);
                    [combinedCurv, numFaces] = read_curv(smoothwmCurvFile);
                    combinedCurv = zeros(length(combinedCurv),1);
                    for i=1:length(indices)            
                        % Load autodijk curv for region opposite current point
                        if mod(i, 2) == 1                    
                            autodijkStartIndex = i+1;
                        else
                            autodijkStartIndex = i-1;
                        end                                

                        roiCenter = verts(indices(i), :);                
                        autodijkCurvFile = sprintf('%s/%s/surf/%s.autodijk.%s-%d.crv', subjectDir, ...
                                                                                      curDir.name, ...
                                                                                      hemi, ...
                                                                                      curv, ...
                                                                                      autodijkStartIndex);
                        autodijkCurv = read_curv(autodijkCurvFile);

                        % Combine all of the curvature regions                                                            
                        for vertIdx=1:length(verts)
                            dist=norm(verts(vertIdx,:) - roiCenter, 2);
                            if (dist < roiRadius)
                                combinedCurv(vertIdx) = autodijkCurv(vertIdx);
                            end
                        end                
                    end

                    combinedCurvFile = sprintf('%s/%s/surf/%s.autodijk.%s-combined.crv', subjectDir, ...
                                                                                        curDir.name, ...
                                                                                        hemi, ...
                                                                                        curv);
                    write_curv(combinedCurvFile, combinedCurv, numFaces);
                    fprintf('Wrote %s\n', combinedCurvFile);
                end
                cd(workingDir);
            end
        end
    end
end
