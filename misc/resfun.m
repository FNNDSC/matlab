function [res] = xform(par,p1_sd,p2_sd,p1_poser,p2_poser,front,align);
% This function is the residuals of the transform equation
% from poser to sd/fast
% fsolve will try to find a set of 6 parameters that produce
% zero residuals

res = zeros(6,1);
res(1:3) = p1_sd - xform(p1_poser, par, front);
res(4:6) = p2_sd - xform(p2_poser, par, front);
