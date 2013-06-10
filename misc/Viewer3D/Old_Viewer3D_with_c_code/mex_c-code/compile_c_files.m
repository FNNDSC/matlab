% This script will compile all the C files of the registration methods
files=dir('*.c');
for i=1:length(files)
    mex(files(i).name,'-v');
end
cd('..');