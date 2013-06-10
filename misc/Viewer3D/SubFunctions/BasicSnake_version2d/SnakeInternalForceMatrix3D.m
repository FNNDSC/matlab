function B=SnakeInternalForceMatrix3D(FV,alpha,beta,gamma)
%
% B=SnakeInternalForceMatrix3D(F,alpha,beta,gamma)
%
% inputs,
%   FV : Struct (Patch) with the triangulated surface
%   alpha : membrame energy  (first order)
%   beta : thin plate energy (second order)
%   gamma : Step Size (Time)
%
% outputs,
%   B : The Snake Smoothness regulation matrix
%
% Function is written by D.Kroon University of Twente (July 2010)

Ne=VertexNeighbours(FV.faces,FV.vertices);
nV=size(FV.vertices,1);

% Matrix for umbrella mesh derivative function in (sparce) matrix form
NeMatrix = spalloc(nV,nV,nV*10);
for i=1:nV
    Nc=Ne{i};
    % Add the neighbours
    NeMatrix(i,Nc)=1/length(Nc);
    % Add the vertex it self 
    NeMatrix(i,i)=-1;
end

% Total internal force matrix
B=speye(nV,nV)+gamma*(alpha*NeMatrix-beta*NeMatrix*NeMatrix);

function Ne=VertexNeighbours(F,V)
% Function which return the neighbouring vertices of every vertex
% in a cell array list. (Basic version, not sorted by rotation)

% Neighbourh cell array 
Ne=cell(1,size(V,1));

% Loop through all faces
for i=1:length(F)
    % Add the neighbors of each vertice of a face
    % to his neighbors list.
    Ne{F(i,1)}=[Ne{F(i,1)} [F(i,2) F(i,3)]];
    Ne{F(i,2)}=[Ne{F(i,2)} [F(i,3) F(i,1)]];
    Ne{F(i,3)}=[Ne{F(i,3)} [F(i,1) F(i,2)]];
end

% Remove duplicate vertices
for i=1:size(V,1), Ne{i}=unique(Ne{i}); end



