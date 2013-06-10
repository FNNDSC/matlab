function [K1 KN ERR]=SeparateKernel(H)
% This function SEPARATEKERNEL will separate ( do decomposition ) any 
% 2D, 3D or nD kernel into 1D kernels. Ofcourse only a sub-set of Kernels
% are separable such as a Gaussian Kernel, but it will give least-squares
% sollutions for non-separatable kernels.
% 
% Separating a 3D or 4D image filter in to 1D filters will give an large
% speed-up in image filtering with for instance the function imfilter.
%
% [K1 KN ERR]=SeparateKernel(H);
%   
% inputs,
%   H : The 2D, 3D ..., ND kernel
%   
% outputs,
%   K1 : Cell array with the 1D kernels
%   KN : Approximation of the ND input kernel by the 1D kernels
%   ERR : The sum of absolute difference between approximation and input kernel
%
% 
% How the algorithm works:
% If we have a separable kernel like
% 
%  H = [1 2 1
%       2 4 2
%       3 6 3];
%
% We like to solve unknow 1D kernels,
%  a=[a(1) a(2) a(3)]
%  b=[b(1) b(2) b(3)]
%
% We know that,
%  H = a'*b
%
%       b(1)    b(2)    b(3)
%       --------------------
%  a(1)|h(1,1) h(1,2) h(1,3)
%  a(2)|h(2,1) h(2,2) h(2,3)
%  a(3)|h(3,1) h(3,2) h(3,3)
%
% Thus,
%  h(1,1) == a(1)*b(1)
%  h(2,1) == a(2)*b(1)
%  h(3,1) == a(3)*b(1)
%  h(4,1) == a(1)*b(2)
%  ...
%
% We want to solve this by using fast matrix (least squares) math,
%
%  c = M * d; 
%  
%  c a column vector with all kernel values H
%  d a column vector with the unknown 1D kernels 
%
% But matrices "add" values and we have something like  h(1,1) == a(1)*b(1);
% We solve this by taking the log at both sides 
% (We replace zeros by a small value. Whole lines/planes of zeros are
%  removed at forehand and re-added afterwards)
%
%  log( h(1,1) ) == log(a(1)) + log b(1))
%
% The matrix is something like this,
%
%      a1 a2 a3 b1 b2 b3    
% M = [1  0  0  1  0  0;  h11
%      0  1  0  1  0  0;  h21
%      0  0  1  1  0  0;  h31
%      1  0  0  0  1  0;  h21
%      0  1  0  0  1  0;  h22
%      0  0  1  0  1  0;  h23
%      1  0  0  0  0  1;  h31
%      0  1  0  0  0  1;  h32
%      0  0  1  0  0  1]; h33
%
% Least squares solution
%  d = exp(M\log(c))
%
% with the 1D kernels
%
%  [a(1);a(2);a(3);b(1);b(2);b(3)] = d
%
% The Problem of Negative Values!!!
%
% The log of a negative value is possible it gives a complex value, log(-1) = i*pi
% if we take the expontential it is back to the old value, exp(i*pi) = -1 
%
%  But if we use the solver with on of the 1D vectors we get something like, this :
%
%  input         result        abs(result)    angle(result) 
%   -1     -0.0026 + 0.0125i     0.0128         1.7744 
%    2      0.0117 + 0.0228i     0.0256         1.0958 
%   -3     -0.0078 + 0.0376i     0.0384         1.7744  
%    4      0.0234 + 0.0455i     0.0512         1.0958
%    5      0.0293 + 0.0569i     0.0640         1.0958
% 
% The absolute value is indeed correct (difference in scale is compensated
% by the order 1D vectors)
%
% As you can see the angle is correlated with the sign of the values. But I
% didn't found the correlation yet. For some matrices it is something like
%
%  sign=mod(angle(solution)*scale,pi) == pi/2;
%
% In the current algorithm, we just flip the 1D kernel values one by one.
% The sign change which gives the smallest error is permanently swapped. 
% Until swapping signs no longer decreases the error
%
% Examples,
%   a=permute(rand(5,1),[1 2 3 4])-0.5;
%   b=permute(rand(5,1),[2 1 3 4])-0.5;
%   c=permute(rand(5,1),[3 2 1 4])-0.5;
%   d=permute(rand(5,1),[4 2 3 1])-0.5;
%   H = repmat(a,[1 5 5 5]).*repmat(b,[5 1 5 5]).*repmat(c,[5 5 1 5]).*repmat(d,[5 5 5 1]);
%   [K,KN,err]=SeparateKernel(H);
%   disp(['Summed Absolute Error between Real and approximation by 1D filters : ' num2str(err)]);
%
%   a=permute(rand(3,1),[1 2 3])-0.5;
%   b=permute(rand(3,1),[2 1 3])-0.5;
%   c=permute(rand(3,1),[3 2 1])-0.5;
%   H = repmat(a,[1 3 3]).*repmat(b,[3 1 3 ]).*repmat(c,[3 3 1 ])
%   [K,KN,err]=SeparateKernel(H); err
%
%   a=permute(rand(4,1),[1 2 3])-0.5;
%   b=permute(rand(4,1),[2 1 3])-0.5;
%   H = repmat(a,[1 4]).*repmat(b,[4 1]);
%   [K,KN,err]=SeparateKernel(H); err
%
% Function is written by D.Kroon, uses "log idea" from A. J. Hendrikse, 
% University of Twente (July 2010)


% We first make some structure which contains information about
% the transformation from kernel to 1D kernel array, number of dimensions
% and other stuff
data=InitializeDataStruct(H);

% Make the matrix of c = M * d; 
M=makeMatrix(data);

% Solve c = M * d with least squares
warning('off','MATLAB:rankDeficientMatrix');
par=exp(M\log(abs(data.H(:))));

% Improve the values by solving the remaining difference
KN = Filter1DtoFilterND(par,data);
par2=exp(M\log(abs(KN(:)./data.H(:))));
par=par./par2;

% Change the sign of a 1D filtering value if it decrease the error
par = FilterCorrSign(par,data);

% Split the solution d in separate 1D kernels
K1 = ValueList2Filter1D(par,data);

% Re-add the removed zero rows/planes to the 1D vectors
K1=re_add_zero_rows(data,K1);

% Calculate the approximation of the ND kernel if using the 1D kernels
KN = Filter1DtoFilterND(par,data,K1);

% Calculate the absolute error
ERR =sum(abs(H(:)-KN(:)));

function par = FilterCorrSign(par,data)
Ert=zeros(1,length(par));
ERR=inf; t=0;
par=sign(rand(size(par))-0.5).*par;
while(t<ERR)
    % Calculate the approximation of the ND kernel if using the 1D kernels
    KN = Filter1DtoFilterND(par,data);
    % Calculate the absolute error
    ERR =sum(abs(data.H(:)-KN(:)));
    % Flip the sign of every 1D filter value, and look if the error
    % improves
    for i=1:length(par)
        par2=par; par2(i)=-par2(i);
        KN = Filter1DtoFilterND(par2,data);
        Ert(i) =sum(abs(data.H(:)-KN(:)));
    end
    % Flip the sign of the 1D filter value with the largest improvement
    [t,j]=min(Ert); if(t<ERR), par(j)=-par(j); end
end

function data=InitializeDataStruct(H)
data.sizeHreal=size(H);
data.nreal=ndims(H);
[H,preserve_zeros]=remove_zero_rows(H);
data.H=H;
data.n=ndims(H);
data.preserve_zeros=preserve_zeros;
data.H(H==0)=eps;
data.sizeH=size(data.H);
data.sep_parb=cumsum([1 data.sizeH(1:data.n-1)]);
data.sep_pare=cumsum(data.sizeH);
data.sep_parl=data.sep_pare-data.sep_parb+1;
data.par=(1:numel(H))+1;

function [H,preserve_zeros]=remove_zero_rows(H)
% Remove whole columns/rows/planes with zeros,
% because we know at forehand that they will give a kernel 1D value of 0
% and will otherwise increase the error in the end result.
preserve_zeros=zeros(numel(H),2); pz=0;
sizeH=size(H);
for i=1:ndims(H)
    H2D=reshape(H,size(H,1),[]);
    check_zero=~any(H2D,2);
    if(any(check_zero))
        zero_rows=find(check_zero);
        for j=1:length(zero_rows)
            pz=pz+1;
            preserve_zeros(pz,:)=[i zero_rows(j)];
            sizeH(1)=sizeH(1)-1;
        end
        H2D(check_zero,:)=[];
        H=reshape(H2D,sizeH);
    end
    H=shiftdim(H,1);
    sizeH=circshift(sizeH,[0 -1]);
    H=reshape(H,sizeH);
end
preserve_zeros=preserve_zeros(1:pz,:);

function K1=re_add_zero_rows(data,K1)
% Re-add the 1D kernel values responding to a whole column/row or plane
% of zeros
for i=1:size(data.preserve_zeros,1)
    di=data.preserve_zeros(i,1);
    pos=data.preserve_zeros(i,2);
    if(di>length(K1)), K1{di}=1; end
    val=K1{di};
    val=val(:);
    val=[val(1:pos-1);0;val(pos:end)];
    dim=ones(1,data.nreal); dim(di)=length(val);
    K1{di}=reshape(val,dim);
end

function M=makeMatrix(data)
 M = zeros(numel(data.H),sum(data.sizeH));
 K1 = (1:numel(data.H))';
 for i=1:data.n;
    p=data.par(data.sep_parb(i):data.sep_pare(i)); p=p(:);
    dim=ones(1,data.n); dim(i)=data.sep_parl(i);
    Ki=reshape(p(:),dim);
    dim=data.sizeH; dim(i)=1;
    K2=repmat(Ki,dim)-1;
    M(sub2ind(size(M),K1(:),K2(:)))=1;
 end
 
function Kt = Filter1DtoFilterND(par,data,K1)
if(nargin==2)
 Kt=ones(data.sizeH);
 for i=1:data.n
     p=par(data.sep_parb(i):data.sep_pare(i)); p=p(:);
     dim=ones(1,data.n); dim(i)=data.sep_parl(i);
     Ki=reshape(p(:),dim);
     dim=data.sizeH; dim(i)=1;
     Kt=Kt.*repmat(Ki,dim);
 end
else
  Kt=ones(data.sizeHreal);
  for i=1:data.n
    dim=data.sizeHreal; dim(i)=1;
    Kt=Kt.*repmat(K1{i},dim);
  end
end

function K = ValueList2Filter1D(par,data)
 K=cell(1,data.n);
 for i=1:data.n
     p=par(data.sep_parb(i):data.sep_pare(i)); p=p(:);
     dim=ones(1,data.n); dim(i)=data.sep_parl(i);
     K{i}=reshape(p(:),dim);
 end