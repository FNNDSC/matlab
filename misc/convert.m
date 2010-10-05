% convert.m
% produces a VRML Transform that converts a Poser body segment geometry
% to an SD/FAST local coordinate system
%
% coordinates of joint centers, from .sd file 
% RFoot p1_sd = [ -0.01040   -0.06579   0.06700]';
% RFoot p2_sd = [ -0.0296  0.1457  0.06700]';
% LFoot p1_sd = [ -0.0042   -0.06579   0.0749]';
% LFoot p2_sd = [ 0.0125  0.1444  0.0749]';
% pelvis p1_sd = [ 0 0 0 ]';
% pelvis p2_sd = [ 0 0 -0.22055 ]';
% RFemur p1_sd = [ -0.02002 0.01527 0.17572 ]';
% RFemur p2_sd = [ 0.02888 -0.02203 -0.25338 ]';
% RTibia p1_sd = [ -0.02622 0.02912 0.16159 ]';
% RTibia p2_sd = [ 0.03258 -0.03618 -0.20081 ]';

% Rudolph's bipedalmodel.sd file data (should be very similar to
% Elizabeth's)
% RFemur  p1_sd = [-0.195 0 0.1050]';
% RFemur  p2_sd = [0.256 0 0.1050]';
% RTibia  p1_sd = [-0.176 0 0.105]';
% RTibia  p2_sd = [ 0.23 0 0.105]';
% RFoot   
p1_sd = [ 0 0 0.105]';
% RFoot   
p2_sd = [0.17 0 0.105]';
% LFemur  p1_sd = [-0.195 0 -0.105]';
% LFemur  p2_sd = [0.256 0 -0.105]';
% LTibia  p1_sd = [-0.176 0 -0.105]';
% LTibia  p2_sd = [ 0.23 0 -0.105]';
% LFoot   p1_sd = [ 0 0 -0.105]';
% LFoot   p2_sd = [0.17 0 -0.105]';
% pelvis  p1_sd = [0.33 0 0.1050]';
% pelvis  p2_sd = [0.33 0 -0.105]';

front = 'Y';	% Xuemei's SD/FAST model faces this direction
align = 'X';    % the axis that is closest to the long axis of the
                % segment in the SD/FAST model ('Y' is the foot in Xuemei's model

% coordinates of the same joints, from Poser (example: Additional Figures->Skeleton Man)
% from Joint Editor, after clicking "Zero Figure"
% make sure to export VRML from the same pose
% RFoot  
p1_poser = [-0.024  0.029  -0.007]';
% RFoot  
p2_poser = [-0.026  0.029  0.061]';
% LFoot  p1_poser = [0.024  0.029  -0.007]';
% LFoot  p2_poser = [0.026  0.029  0.061]';
% RFemur p1_poser = [-0.043 0.378 -0.015]';
% RFemur p2_poser = [-0.030 0.195 -0.004]';
% LFemur p1_poser = [0.043 0.378 -0.015]';
% LFemur p2_poser = [0.030 0.195 -0.004]';
% RTibia p1_poser = [-0.030 0.195 -0.004]';
% RTibia p2_poser = [-0.024 0.029 -0.007]';
% LTibia p1_poser = [0.030 0.195 -0.004]';
% LTibia p2_poser = [0.024 0.029 -0.007]';
% pelvis p1_poser = [-0.043 0.378 -0.015]';
% pelvis p2_poser = [0.043 0.378 -0.015]';

% Solve the 6 unknowns (x,y,z,scale,beta,alpha) from 6 equations (2 points x 3 coordinates)
[par] = fsolve('resfun',[0 0 0 1 0 0],optimset('TolFun',1e-10),p1_sd,p2_sd,p1_poser,p2_poser,front);
tranformation_parameters = par
residuals = resfun(par,p1_sd,p2_sd,p1_poser,p2_poser,front,align)'

% generate the rotation matrix and convert to axis-angle representation for VRML
R = zeros(3,3);
rotdata = zeros(1,4);
rotpar = [0 0 0 1.0 par(5) par(6)];
R(:,1) = xform([1 0 0]',rotpar,front);
R(:,2) = xform([0 1 0]',rotpar,front);
R(:,3) = xform([0 0 1]',rotpar,front);
% amount of rotation:
rotdata(4) = acos((trace(R) - 1.0)/2.0); 
% rotation axis:
rotdata(1) = R(3,2) - R(2,3);
rotdata(2) = R(1,3) - R(3,1);
rotdata(3) = R(2,1) - R(1,2);
rotdata(1:3) = rotdata(1:3)/norm(rotdata(1:3));

% now generate the VRML Transform
fprintf('  Transform {\n');
fprintf('    rotation %4.4f %4.4f %4.4f %4.4f\n', rotdata);
fprintf('    scale %6.6f %6.6f %6.6f\n', par(4), par(4), par(4));
fprintf('    translation %6.6f %6.6f %6.6f\n', par(1), par(2), par(3));
fprintf('    children [\n');
fprintf('      <POSER VRML GEOMETRY GOES HERE>\n');
fprintf('      ]\n');
fprintf('    }\n');
