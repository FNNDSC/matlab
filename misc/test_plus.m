
function [corr_offset, cc] = test_plus(n_template,n,coffset,roffset)
%
% function [corr_offset] = test_plus(n_template,n,coffset,roffset)
%
% n = the number of pixels per side of the image
% n_template = the number of pixels per side in the template
% coffset = offset in columns
% roffset = offset in rows

if (n<n_template)
error('n must be greater than n_template.')
end

% Make a template image containing a plus
template = .6*ones(n_template);
center = floor((n_template - 1)/2);
half_width = floor(.1*n_template);
cmin = center - half_width;
cmax = center + half_width;

template(1:n_template,cmin:cmax) = .2;
template(cmin:cmax,1:n_template) = .2;
imshow(template)
template_size = size(template);


% Make an n-by-n image containing the template shifted by roffset rows
% and coffset columns.
J = .6*ones(n);
rbegin = 1 + roffset;
rend = rbegin + template_size(1) - 1;
cbegin = 1 + coffset;
cend = cbegin + template_size(2) - 1;

J(rbegin:rend,cbegin:cend) = template;
figure;
imshow(J)

%cross-correlate the images
cc = normxcorr2(template,J);

%find the correlation peak coordinates
[max_cc, imax] = max(abs(cc(:)))
[ypeak, xpeak] = ind2sub(size(cc),imax(1));
corr_offset = [ (xpeak-template_size(2)) (ypeak-template_size(1)) ];
