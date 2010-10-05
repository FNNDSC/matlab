function result = dist(a,b,c,d,e)
%DIST Euclidean distance weight function.
%
%	Syntax
%
%	  Z = dist(W,P,FP)
%	  info = dist(code)
%   dim = dist('size',S,R,FP)
%   dp = dist('dp',W,P,Z,FP)
%   dw = dist('dw',W,P,Z,FP)
%	  D = dist(pos)
%
%	Description
%
%	  DIST is the Euclidean distance weight function. Weight
%	  functions apply weights to an input to get weighted inputs.
%
%	  DIST(W,P,FP) takes these inputs,
%	    W - SxR weight matrix.
%	    P - RxQ matrix of Q input (column) vectors.
%	    FP - Row cell array of function parameters (optional, ignored).
%	  and returns the SxQ matrix of vector distances.
%
%	  DIST(code) returns information about this function.
%	  These codes are defined:
%	    'deriv'      - Name of derivative function.
%     'fullderiv'  - Full derivative = 1, linear derivative = 0.
%	    'name'       - Full name.
%	    'fpnames'    - Returns names of function parameters.
%	    'fpdefaults' - Returns default function parameters.
%
%   DIST('size',S,R,FP) takes the layer dimension S, input dimention R,
%   and function parameters, and returns the weight size [SxR].
%
%   DIST('dp',W,P,Z,FP) returns the derivative of Z with respect to P.
%   DIST('dw',W,P,Z,FP) returns the derivative of Z with respect to W.
%
%	  DIST is also a layer distance function which can be used
%	  to find the distances between neurons in a layer.
%
%	  DIST(POS) takes one argument,
%	    POS - NxS matrix of neuron positions.
%     and returns the SxS matrix of distances.
%
%	Examples
%
%	  Here we define a random weight matrix W and input vector P
%	  and calculate the corresponding weighted input Z.
%
%	    W = rand(4,3);
%	    P = rand(3,1);
%	    Z = dist(W,P)
%
%	  Here we define a random matrix of positions for 10 neurons
%	  arranged in three dimensional space and find their distances.
%
%	    pos = rand(3,10);
%	    D = dist(pos)
%
%	Network Use
%
%	  You can create a standard network that uses DIST
%	  by calling NEWPNN or NEWGRNN.
%
%	  To change a network so an input weight uses DIST set
%	  NET.inputWeight{i,j}.weightFcn to 'dist.  For a layer weight
%	  set NET.inputWeight{i,j}.weightFcn to 'dist'.
%
%	  To change a network so that a layer's topology uses DIST set
%	  NET.layers{i}.distanceFcn to 'dist'.
%
%	  In either case, call SIM to simulate the network with DIST.
%	  See NEWPNN or NEWGRNN for simulation examples.
%
%	Algorithm
%
%	  The Euclidean distance D between two vectors X and Y is:
%	
%	    D = sum((x-y).^2).^0.5
%
%	See also SIM, DOTPROD, NEGDIST, NORMPROD, MANDIST, LINKDIST.

% Mark Beale, 12-15-93
% Revised 11-31-97, MB
% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% Copyright 1992-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2007/06/14 05:18:11 $

fn = mfilename;
boiler_weight

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Name
function n = name
n = 'Euclidean Distance';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Flag for dZ/dP type
function d = p_deriv
d = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Flag for dZ/dW type
function d = w_deriv
d = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameter default values
function fp = param_defaults
fp = struct;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameter Names
function names = param_names
names = {};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameter Check
function err = param_check(fp)
err = '';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Weight Size
function dim = weight_size(s,r,fp)
dim = [s r];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Apply Weight Function
function z = apply(w,p,fp)

[S,R] = size(w);
[R2,Q] = size(p);
if (R ~= R2), error('NNET:Dimensions','Inner matrix dimensions do not match.'),end
z = zeros(S,Q);
if (Q<S)
  p = p';
  copies = zeros(1,S);
  for q=1:Q
    z(:,q) = sum((w-p(q+copies,:)).^2,2);
  end
else
  w = w';
  copies = zeros(1,Q);
  for i=1:S
    z(i,:) = sum((w(:,i+copies)-p).^2,1);
  end
end
z = z.^0.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Derivative w/respect to Input
function d = derivative_dz_dp(w,p,z,fp)

[S,R] = size(w);
[R2,Q] = size(p);
p = p';
d = cell(1,Q);
copies1 = zeros(1,S);
copies2 = zeros(R,1);
for q=1:Q
  den = z(:,q+copies2);
  flg = den~=0;
  num = (p(q+copies1,:)-w);
  num = flg.*num;
  den = den + ~flg;
  d{q} = num./den;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Derivative w/respect to Weight
function d = derivative_dz_dw(w,p,z,fp)

[S,R] = size(w);
[R2,Q] = size(p);
d = cell(1,S);
w = w';
copies1 = zeros(1,Q);
copies2 = zeros(R,1);
for i=1:S 
  den = z(i+copies2,:);
  flg = den~=0;
  num = w(:,i+copies1)-p;
  num = flg.*num;
  den = den + ~flg;
  d{i} = num./den;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
