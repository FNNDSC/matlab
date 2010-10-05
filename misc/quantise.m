function [V] = quantise(start, stop, quanta)
%//
%// ARGS
%//   V         out         Vector of quantised boundaries
%//   start     in          "left most" boundary
%//   stop      in          "right most" boundary
%//   quanta    in          number of discrete levels to quantise
%//
%// DESC
%//   This function returns a "quantisation" vector, which is
%//   really a lookup-table defining the quantisation bounds
%//   across the range from start to stop.
%//
%// PRECONDITIONS
%//   Make sure that all parameters are passed correctly
%//   There must be at least 3 quantisation levels
%//
%// POSTCONDITIONS
%//   The "right most" vector cell defines the boundary between
%//   cell (n-1) and any value beyond it. 
%//
%// EXAMPLE
%//   A range of [-pi.. pi] with 7 quantise levels will result in:
%//
%//-3.1416   -2.6180   -1.5708   -0.5236    0.5236    1.5708    2.6180
%//
%// AUTHOR
%//   Rudolph Pienaar (pienaar@bme.ri.ccf.org)
%//

range   = stop - start;
V       = ones(1, quanta);
quantum = range / (quanta-1);

V(1)    = start;
%V(2)    = start + quantum / 2;

for i=2:quanta
    V(i) = V(i-1) + quantum;
end
