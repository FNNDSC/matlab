function M = linMat_create(rows, cols, varargin)
%%
%% NAME
%%
%%      linMat_create.m
%%
%% SYNOPSIS
%%
%%      function M = linMat_create(rows, cols [, start=1, delta=1])
%%
%% ARGUMENTS
%%
%%      rows            in              number of rows in returned matrix
%%      cols            in              number of cols in returned matrix
%%      start           in/opt          starting value for elements
%%      delta           in/opt          element increment
%%
%%      M               out             returned matrix whose elements
%%                                              increase linearly from
%%
%% DESCRIPTION
%%
%%      This function simply returns a (col-major) matrix of linearly
%%      increasing element values, starting at (1, 1) with value start
%%      and increasing across each column with delta.
%%

%% Defaults
start   = 1;
delta   = 1;

if nargin>=3
        start   = varargin{1};
end

if nargin>=4
        delta   = varargin{2};
end

M       = zeros(rows, cols);
value   = start;

for row=1:rows,
        for col=1:cols,
                M(row, col)     = value;
                value           = value + delta;
        end
end


