function readCleanSave(myFolder, matFileName)
% FUNCTION readCleanSave(myFolder, matFileName) 
% HELP SECTION TO BE ADDED
% Goes through the folder specified by the user in "myFolder", reads the MED-PC
% text files in that folder, creates a data struct in the current path,
% named "data.mat". Gives out the path to that .mat file.
%   INPUT: 
%       myFolder = a string array specifying the complete path to the folder
%       with data files, that needs to be gone through.
%   OUTPUT:
%       path2data = the destination path to the data struct consisting of
%       the information collected from MED-PC text files in "myFolder".
%

% Check if the folder actually exists. Warn user if it doesn't.
if ~isfolder(myFolder)
  errorMessage = sprintf('The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all txt files in the folder.
filePattern = fullfile(myFolder, '*.txt');
allFiles = dir(filePattern);

% Loop through myFolder for text files, inform user of the progress.
for ii = 1 : length(allFiles)
  baseFileName = allFiles(ii).name;
  fullFileName = fullfile(myFolder, baseFileName);
  % Lets user know of what the script is doing.
  fprintf(1, '%d. Now reading %s\n', ii, baseFileName);
  data(ii) = readFR8txt(fullFileName); 
end
if ii ~= length(allFiles) % Sanity check
    error('Problem with reading all the files in %s\n', myFolder);
else
    fprintf(1, 'Finished reading all files in %s\n', myFolder);
end

% CLEANING

rawT= struct2table(data, 'AsArray',1);
T = rmmissing(rawT, 'DataVariables', 'numPress'); % remove 
        % the cases with no data in numPress (These are due to me choosing 
        % not to read them from the files, below)

% For some animals, I needed to re-run their sessions, due to technical
% problems. Replace data for problematic sessions with the second runs
% (noted in the comments)
secondRuns = ~ismissing(T.comments);
[r,~] = find(secondRuns);
d = T.date(r); % dates of those double sessions
a = T.animal(r); % animals that had been re-run
for ii=1:length(r)
    rm(:,ii) = T.date == d(ii) & T.animal == a(ii) & strcmp(T.comments, '');
end
rm = sum(rm,2); % because for each double-session case rm puts the logical 
  % values in a seperate column
rows2remove = logical(rm);
T(rows2remove,:) = [];

% On Dec 13th, I started training the mice with the test code, later due to
% some problems we had to postpone the testing, so those two days do not
% mean much, nor are they comparable to the rest of the data, remove:
testDays = (T.date == '13-Dec-2018') + (T.date == '14-Dec-2018');
testDays = logical(testDays);
T(testDays,:) = [];

% Exclude the earlier phases of training with wider press windows  
wideWindow = {'FR8_FULL_3ar_nolimit','FR8_FULL_3ar_60sec','FR8_FULL_3ar_40sec',...
    'FR8_FULL_3ar_30secc'};
w = ismember(T.program,wideWindow);
T(w,:) = [];
T = sortrows(T,[1 2]);

save(matFileName);
