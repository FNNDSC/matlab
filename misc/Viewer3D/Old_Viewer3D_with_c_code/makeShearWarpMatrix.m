function [Mshear,Mwarp2D,c]=makeShearWarpMatrix(Mview,sizes)
% Function MAKESHEARWARPMATRIX splits a View Matrix in to
% a shear matrix and warp matrix, for efficient 3D volume rendering.
%
% [Mshear,Mwarp2D,c]=makeShearWarpMatrix(Mview,sizes)
%
% inputs,
%   Mview: The 4x4 viewing matrix
%   sizes: The sizes of the volume which will be rendered
%
% outputs,
%  Mshear: The shear matrix
%  Mwarp2D: The warp matrix
%  c: The principal viewing axis 1..6
%
% example,
%
%   Mview=makeViewMatrix([45 45 0],[0.5 0.5 0.5],[0 0 0]);
%   sizes=[512 512];
%   [Mshear,Mwarp2D,c]=makeShearWarpMatrix(Mview,sizes)
%
% Function is written by D.Kroon University of Twente (October 2008)

% Find the principal viewing axis
Vo=[Mview(1,2)*Mview(2,3) - Mview(2,2)*Mview(1,3);
    Mview(2,1)*Mview(1,3) - Mview(1,1)*Mview(2,3);
    Mview(1,1)*Mview(2,2) - Mview(2,1)*Mview(1,2)];

[maxv,c]=max(abs(Vo));

% Choose the corresponding Permutation matrix P
switch(c)
    case 1, %yzx
        P=[0 1 0 0;
           0 0 1 0;
           1 0 0 0;
           0 0 0 1;];
    case 2, % zxy
        P=[0 0 1 0;
           1 0 0 0;
           0 1 0 0;
           0 0 0 1;];
    case 3, % xyz
        P=[1 0 0 0;
           0 1 0 0;
           0 0 1 0;
           0 0 0 1;];
end

% Compute the permuted view matrix from Mview and P
Mview_p=Mview*inv(P);

% 180 degrees rotate detection
if(Mview_p(3,3)<0), c=c+3; end

% Compute the shear coeficients from the permuted view matrix
Si = (Mview_p(2,2)* Mview_p(1,3) - Mview_p(1,2)* Mview_p(2,3)) / (Mview_p(1,1)* Mview_p(2,2) - Mview_p(2,1)* Mview_p(1,2));
Sj = (Mview_p(1,1)* Mview_p(2,3) - Mview_p(2,1)* Mview_p(1,3)) / (Mview_p(1,1)* Mview_p(2,2) - Mview_p(2,1)* Mview_p(1,2));

% Compute the translation between the orgins of standard object coordinates
% and intermdiate image coordinates

if((c==1)||(c==4)), kmax=sizes(1)-1; end
if((c==2)||(c==5)), kmax=sizes(2)-1; end
if((c==3)||(c==6)), kmax=sizes(3)-1; end

if ((Si>=0)&&(Sj>=0)), Ti = 0;        Tj = 0;        end
if ((Si>=0)&&(Sj<0)),  Ti = 0;        Tj = -Sj*kmax; end
if ((Si<0)&&(Sj>=0)),  Ti = -Si*kmax; Tj = 0;        end
if ((Si<0)&&(Sj<0)),   Ti = -Si*kmax; Tj = -Sj*kmax; end

% Compute the shear matrix 
Mshear=[1  0 Si Ti;
        0  1 Sj Tj;
        0  0  1  0;
        0  0  0  1];
        
% Compute the 2Dwarp matrix
Mwarp2D=[Mview_p(1,1) Mview_p(1,2) (Mview_p(1,4)-Ti*Mview_p(1,1)-Tj*Mview_p(1,2)); 
         Mview_p(2,1) Mview_p(2,2) (Mview_p(2,4)-Ti*Mview_p(2,1)-Tj*Mview_p(2,2)); 
               0           0                                  1                  ];

% Compute the 3Dwarp matrix
% Mwarp3Da=[Mview_p(1,1) Mview_p(1,2) (Mview_p(1,3)-Si*Mview_p(1,1)-Sj*Mview_p(1,2)) Mview_p(1,4); 
%           Mview_p(2,1) Mview_p(2,2) (Mview_p(2,3)-Si*Mview_p(2,1)-Sj*Mview_p(2,2)) Mview_p(2,4); 
%           Mview_p(3,1) Mview_p(3,2) (Mview_p(3,3)-Si*Mview_p(3,1)-Sj*Mview_p(3,2)) Mview_p(3,4); 
%                 0           0                                  0                        1      ];
% Mwarp3Db=[1 0 0 -Ti;
%           0 1 0 -Tj;
%           0 0 1   0;
%           0 0 0   1];
% Mwarp3D=Mwarp3Da*Mwarp3Db;
% % Control matrix Mview
% Mview_control = Mwarp3D*Mshear*P;
% disp(Mview)
% disp(Mview_control)

