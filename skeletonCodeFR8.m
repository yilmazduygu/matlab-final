% This script will be the code for importing the FR8 data files
% (txt) and generating imformative plots about the data
% Hopefully the data will be structured in a way that would fit a LME
% (Linear Mixed-Effects Model).


clear; clc;
format compact;

%% Process a sequence of files
% 

% Specify the folder 
% myFolder = 'C:\Users\MenaLab\\Desktop\Data files';
myFolder = '/Users/Duygu/Google Drive/Sem III/Scientific Programming in Matlab/my codes for the course/Final project/Data files';
% Check if the folder actually exists. Warn user if it doesn't.
if ~isfolder(myFolder)
  errorMessage = sprintf('The following folder does not exist:\n%s', myFolder);
  uiwait(warndlg(errorMessage));
  return;
end
% Get a list of all txt files in the folder.
filePattern = fullfile(myFolder, '*.txt');
allFiles = dir(filePattern);

for ii = 1 : length(allFiles)
  baseFileName = allFiles(ii).name;
  fullFileName = fullfile(myFolder, baseFileName);
  % Lets user know of what the script's doing
  fprintf(1, 'Now reading %s\n', baseFileName);
 
  data(ii) = readFR8txt(fullFileName); 
end
fprintf(1, 'Finished reading all files in %s\n', myFolder);
save 'data.mat' data

%% Make the figure


%% Function to read each data file
function S = readFR8txt(filename)

%% Open text file, give error if not possible
fid = fopen(filename);
if fid<0
    error('Error opening the file %s.\n', filename);
end

% Set up the struct S, assign default values to each field
S = struct;
S.name = '';
S.date = NaT;
S.animal = NaN;
S.group = NaN;
S.box = NaN;
S.time = NaT;
S.program = '';
S.numPress = NaN;
S.numReward = NaN;
S.presses = NaN;
S.rewards = NaN;
S.headEntries = NaN;
S.comments = '';

% Read header info, write each bit to its corresponding field in S
while true
    line = fgetl(fid);
    if isempty(line) || length(line) == 0;continue;end % Skip empty lines
    if line(1) == 'A';break;end % Exit the loop to get the arrays in the next step
    tagValue = strsplit(line,': '); 
    tag = tagValue{1}; 
    value = tagValue{2};
    % Because of windows' directory naming, strsplit function splits 
    % 'C:directory\filename' as well. Go around this as follows:
    if length(tagValue) > 2; value = cat(2, tagValue{2}, ':', tagValue{3});end 
    switch upper(tag)
        case 'FILE'
            % Found the file name
            S.name = char(value);
        case 'START DATE'
            % Found the session date
            S.date = datetime(value, 'InputFormat', 'MM/dd/yy'); 
        case 'END DATE'
            % Found the date session ended, not important, continue
            continue;
        case 'SUBJECT'
            % Found the animal ID #
            S.animal = str2double(value);
        case 'EXPERIMENT'
            % experiment name, not important, continue
            continue;
        case 'GROUP'
            % Found the treatment group
            S.group = str2double(value); 
        case 'BOX'
            % Found the box the animal's been tested
            S.box = str2double(value); 
        case 'START TIME'
            % Found the time session has started
            S.time = datetime(value, 'InputFormat', 'HH:mm:ss'); % here the 
                % datetime fxn adds today's date before the time info it pulls
        case 'END TIME'
            continue;
        case 'MSN'
            S.program = char(value);
            if strcmp(S.program, 'FR8_Day4_NKG') || strcmp(S.program,'FR8_Day3_NKG') || strcmp(S.program,'FR8_Day2_NKG')
                return; % I don't want the data for earlier stages of training
            end
        case 'F'
            continue;
        case 'L'
            S.numPress = str2double(value);
        case 'R'
            S.numReward = str2double(value);
        otherwise
            error(['Found an unknown tag ' tag]);
    end
end
% Now fid should be right below the line "A: "
line = fgetl(fid); % irrelevant info on this line, do not store

% Read Lever Press Array (C):
line = fgetl(fid); % next line, 'C:'
counter = 0;
temp = {};
if line(1) == 'C' % fid is at lever press array
    while true
        line = fgetl(fid); % next line, where the data starts
        if line(1) == 'D';break;end 
        counter = counter + 1; % counts the lines it reads
        tagValue = strsplit(line,': '); 
        tag = tagValue{1}; 
        value = tagValue{2};
        A = sscanf(value, '%f');
        temp{counter} = A';
    end   
    if ~(counter== ceil(S.numPress/5)) % sanity check
        warning('lever press array (C) in %s possibly read incorrectly', filename);
    end
    S.presses = cat(2, temp{:});
end

% Read Rewards Array (D):
counter = 0;
temp = {};
if line(1) == 'D' % fid is at rewards array
    while true
        line = fgetl(fid); % next line, where the data starts
        if line(1) == 'E';break;end 
        counter = counter + 1; % counts the lines it reads
        tagValue = strsplit(line,': '); 
        tag = tagValue{1}; 
        value = tagValue{2};
        A = sscanf(value, '%f');
        temp{counter} = A';
    end   
    if ~(counter== ceil(S.numReward/5)) % sanity check
        warning('rewards array (D) in %s possibly read incorrectly', filename);
    end
    S.rewards = cell2mat(temp);
end

% Read Head Entries Array (E):
counter = 0;
temp = {};
if line(1) == 'E' % fid is at head entry array
    while true
        line = fgetl(fid); % next line, where the data starts   
        if line == -1;break;end 
        if line(1) == '\'
            S.comments = line(2:end);
            continue;
        end
        counter = counter + 1; 
        tagValue = strsplit(line,': '); 
        tag = tagValue{1}; 
        value = tagValue{2};
        A = sscanf(value, '%f');
        temp{counter} = A';
    end   
    % I don't have the total num of head entries info on the file, so a
    % sanity check is not possible for this one
    S.headEntries = cell2mat(temp); 
end

% Close the file
fclose(fid);

end

%% problems:

% #1. datetime function on line 100 does a funny thing: even though the
% format i specify is HH:mm:ss, it adds todat's date in front of the time
% and writes to the data struct in that form. I probably wont be using that
% info, but still. Am I calling the function wrong again?
% #2. I wish to skip reading some files based on S.program info, because I
% am not interested in data from the earlier stages of training. I tried to
% do that in line 107, but it gives me the error 'matrix dimensions must
% agree' where I call the function in the main script.
% #3. lines 141, 161, and 184: I am not sure which one to pick. Both
% versions seem to work fine, though?