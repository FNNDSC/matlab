% This script runs mris_pmake to generate autodijk runs from six
% points on a sphere.  

% Base subject directory
subjectBaseDirs =  { '/chb/users/ginsburg/projects/curvatureAnalysis/recon-normal', ...
                     '/chb/users/ginsburg/projects/curvatureAnalysis/recon-PMG' };
referenceSubjects = { 'CHB01', 'PMG01' };                
hemis = { 'lh', 'rh' };
curvs = { 'K1', 'K2', 'K', 'H' };

roiRadius = 100.0 * sin(deg2rad(45)) / sin(deg2rad(67.5));  % Radius about dijkstra point to use from surface

% Size of bounding box about vertex to sample curvatures from resampled
% surface
%samplingBoxSize = 4.0;

% Boolean toggles
runDijkstra = 0;                % Run mris_pmake to generate autodijk results
runGenCombinedOverlay = 0;      % Generate combined overlay from mris_pmake runs
runResampleSphere = 1;

origin = [0, 0, 100];

% Get six points in the reference surface (need to use the same
% reference surface for all cases in order to have the same six points
% in all surfaces)  Both for normal AND pmg this should be the same.
refSurfaceFileName='/chb/users/ginsburg/projects/curvatureAnalysis/recon-normal/CHB01/surf/lh.sphere';
[refVerts, reFaces] = read_surf(refSurfaceFileName);
[refIndices, refPoints] = find_six_equidistant_points(origin, refVerts);

% Generate standard sized sphere to resample to
if runResampleSphere
   [resampledVerts, resampledFaces] = generate_sphere(500, 100.0); 
end

for subjIdx = 1:length(subjectBaseDirs)
    subjectDir = subjectBaseDirs{subjIdx};
    subjectDirs = dir(subjectDir);
    setenv('SUBJECTS_DIR', subjectDir);
    
    referenceSubject = referenceSubjects{subjIdx};
    
    for hemiIdx=1:length(hemis)
        hemi=hemis{hemiIdx};

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

                    combinedCurvFile = sprintf('%s/%s/surf/%s.autodijk.%s-combined.crv', subjectDir, ...
                                                                                         curDir.name, ...
                                                                                         hemi, ...
                                                                                         curv);


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

                        write_curv(combinedCurvFile, combinedCurv, numFaces);
                        fprintf('Wrote %s\n', combinedCurvFile);
                    end

                    % Resample the curvature values to a standard sphere
                    % for comparison
                    if runResampleSphere

                        % Build kdtree for surface, requires this code:
                        % http://www.mathworks.com/matlabcentral/fileexchange/7030-kd-tree-nearest-neighbor-and-range-search
                        surfKDTree=kdtree(verts);

                        [combinedCurv] = read_curv(combinedCurvFile);
                        resampledCurv = zeros(length(resampledVerts),1);

                        % Find the closest vertex in the resampled surface to
                        % the original and store its curvature value
                        for vertIdx=1:length(resampledVerts)                        
                            %curVert=resampledVerts(vertIdx,:);
                            %halfBoxSize = samplingBoxSize / 2.0;
                            %boundingBox=[ [curVert(1) - halfBoxSize, curVert(1) + halfBoxSize];
                            %              [curVert(2) - halfBoxSize, curVert(2) + halfBoxSize];
                            %              [curVert(3) - halfBoxSize, curVert(3) + halfBoxSize] ];
                            %closestIndices = kdtree_range(surfKDTree, boundingBox);

                            % Average the closest points
                            %numPoints = length(closestIndices);
                            %curvValue = 0.0;
                            %for j=1:numPoints
                            %    curIdx = closestIndices(j);
                            %    curvValue = curvValue + combinedCurv(curIdx);                            
                            %end
                            %curvValue = curvValue / numPoints;
                            %resampledCurv(vertIdx) = curvValue;                            
                            closestIndex = kdtree_closestpoint(surfKDTree, resampledVerts(vertIdx,:));
                            resampledCurv(vertIdx) = combinedCurv(closestIndex);                            
                        end

                        % Write out the resampled sphere and the resampled
                        % curvature
                        resampledSurfFile = sprintf('%s.resampled', surfaceFileName);
                        resampledCrvFile = sprintf('%s.resampled', combinedCurvFile);

                        write_surf(resampledSurfFile, resampledVerts, resampledFaces);
                        fprintf('Wrote %s\n', resampledSurfFile);
                        write_curv(resampledCrvFile, resampledCurv, length(resampledCurv));
                        fprintf('Wrote %s\n', resampledCrvFile);
                    end
                    cd(workingDir);
                end
            end
        end
    end
end
