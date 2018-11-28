% This script will be the skeleton code for importing the FR8 data files
% (txt) and generating imformative plots about the data
% Hopefully the data will be structured in a way that would fit a LME
% (Linear Mixed-Effects Model).

clear; clc;
workspace;
format compact;

%% Process a sequence of files
% The problem with this is that I won't have a priori information as to how
% big the data will be, so I cannot preallocate memory for the struct of
% arrays that I want to obtain.

% Specifies the folder 
myFolder = 'C:\Users\MenaLab\\Desktop\Data files';
% myFolder = '/Users/Duygu/Google Drive/Sem III/Scientific Programming in Matlab/my codes for the course/Final project/Data files';
% Checks if the folder actually exists. Warns user if it doesn't.
if ~isfolder(myFolder)
  errorMessage = sprintf('The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Gets a list of all txt files in the folder.
filePattern = fullfile(myFolder, '*.txt');
allFiles = dir(filePattern);

for ii = 1 : length(allFiles)
  baseFileName = allFiles(ii).name;
  fullFileName = fullfile(myFolder, baseFileName);
  % Lets user know of what the script's doing
  fprintf(1, 'Now reading %s\n', fullFileName);
  % Here goes the read function that I'll write for the text files
  % I also don't know how to write on a struct in a way that would change
  % it's dimensions with each run
  readFR8txt(baseFileName); % I don't know where to lead the function to construct my struct, yet
end


%% Function to read the data files
function readFR8txt(filename)

% open the file
fid = fopen(filename, 'rt');
frewind(fid);
if fid<0
    error('Error opening the file %s.\n\n', filename);
end
% do stuff
while (fid~=-1)
    line = fgetl(fid);
    
end
% close the file
fclose(fid);

end

