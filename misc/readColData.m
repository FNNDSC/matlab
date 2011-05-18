function  [labels,x,y] = readColData(fname,ncols,nhead,nlrows)
%  readColData  reads data from a file containing data in columns
%               that have text titles, and possibly other header text
%
%  Synopsis:
%     [labels,x,y] = readColData(fname)
%     [labels,x,y] = readColData(fname,ncols)
%     [labels,x,y] = readColData(fname,ncols,nhead)
%     [labels,x,y] = readColData(fname,ncols,nhead,nlrows)
%   
%  Input:
%     fname  = name of the file containing the data (required)
%     ncols  = number of columns in the data file.  Default = 2.  A value
%              of ncols is required only if nlrows is also specified.
%     nhead  = number of lines of header information at the very top of
%              the file.  Header text is read and discarded.  Default = 0.
%              A value of nhead is required only if nlrows is also specified.
%     nlrows = number of rows of labels.  Default = 1
%
%  Output:
%     labels  =  matrix of labels.  Each row of lables is a different
%                label from the columns of data.  The number of columns
%                in the labels matrix equals the length of the longest
%                column heading in the data file.  More than one row of
%                labels is allowed.  In this case the second row of column
%                headings begins in row ncol+1 of labels.  The third row
%                column headings begins in row 2*ncol+1 of labels, etc.
%
%          NOTE:  Individual column headings must not contain blanks
%
%     x = column vector of x values
%     y = matrix of y values.  y has length(x) rows and ncols columns
%
%  Author:
%     Gerald Recktenwald, gerry@me.pdx.edu
%     Portland State University, Mechanical Engineering Department
%     24 August 1995

%  process optional arguments
if nargin < 4
   nlrows = 1;      % default
   if nargin < 3
      nhead = 0;     % default
      if nargin < 2
         ncols = 2;   % default
      end
   end
end

%  open file for input, include error handling
fin = fopen(fname,'r');
if fin < 0
   error(['Could not open ',fname,' for input']);
end

%  Preliminary reading of titles to determine number of columns
%  needed in the labels matrix.  This allows for an arbitrary number
%  of column titles with unequal (string) lengths.  We cannot simply
%  append to the labels matrix as new labels are read because the first
%  label might not be the longest.  The number of columns in the labels
%  matrix (= maxlen) needs to be set properly from the start.

%  Read and discard header text on line at a time
for i=1:nhead,  buffer = fgetl(fin);  end

maxlen = 0;
for i=1:nlrows
   buffer = fgetl(fin);          %  get next line as a string
   for j=1:ncols
      [next,buffer] = strtok(buffer);       %  parse next column label
      maxlen = max(maxlen,length(next));   %  find the longest so far
   end
   
end

%  Set the number of columns in the labels matrix equal to the length
%  of the longest column title.  A complete preallocation (including
%  rows) of the label matrix is not possible since there is no string
%  equivalent of the ones() or zeros() command.  The blank() command
%  only creates a string row vector not a matrix.
labels = blanks(maxlen);

frewind(fin);    %  rewind in preparation for actual reading of labels and data

%  Read and discard header text on line at a time
for i=1:nhead,  buffer = fgetl(fin);  end

%  Read titles for keeps this time
for i=1:nlrows

   buffer = fgetl(fin);          %  get next line as a string
   for j=1:ncols
      [next,buffer] = strtok(buffer);     %  parse next column label
      n = j + (i-1)*ncols;                %  pointer into the label array for next label
      labels(n,1:length(next)) = next;    %  append to the labels matrix
   end
end

%  Read in the x-y data.  Use the vetorized fscanf function to load all
%  numerical values into one vector.  Then reshape this vector into a
%  matrix before copying it into the x and y matrices for return.

data = fscanf(fin,'%f');  %  Load the numerical values into one long vector

nd = length(data);        %  total number of data points
nr = nd/ncols;            %  number of rows; check (next statement) to make sure
if nr ~= round(nd/ncols)
   fprintf(1,'\ndata: nrow = %f\tncol = %d\n',nr,ncols);
   fprintf(1,'number of data points = %d does not equal nrow*ncol\n',nd);
   error('data is not rectangular')
end

data = reshape(data,ncols,nr)';   %  notice the transpose operator
x = data(:,1);
y = data(:,2:ncols);

%  end of readColData.m

