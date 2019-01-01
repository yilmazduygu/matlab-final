clear; clc; % housekeeping
% This part should identify your current folder, find the file there, and
% run the script on that file. Just put both this .m file and the data file
% in the same folder.
myFolder = pwd; % path to the current folder
baseFileName = '2018-12-05_17h04m_Subject 18054.txt';
fullFileName = fullfile(myFolder, baseFileName);

%% Open text file, give error if not possible
fid = fopen(fullFileName);
if fid<0
    error('Error opening the file %s.\n', baseFileName);
end

S = struct;

%% Read header info, write each bit to its corresponding field in S
while true
    line = fgetl(fid);
    if isempty(line) || length(line) == 0;continue;end % Skip empty lines
    if line(1) == 'A';break;end % Exit the loop to get the arrays in the next step
    tagValue = strsplit(line,':'); 
    tag = tagValue{1}; 
    value = tagValue{2};
    % Because of windows' directory naming, strsplit function splits 
    % 'C:directory\filename' as well. Go around this as follows:
    if length(tagValue) > 2; value = cat(2, tagValue{2}, ':', tagValue{3});end 
    switch upper(tag)
        case 'FILE'
            % Found the file name
            S.group.animal.date.name = char(value);
        case 'START DATE'
            % Found the session date
            S.group.animal.date = sscanf(value, '%{MM/dd/yy}D'); % this doesn't work, it doesn't write the value in to the struct's related field
        case 'END DATE'
            % Found the date session ended, not important, continue
            continue;
        case 'SUBJECT'
            % Found the animal ID #
            S.group.animal = str2double(value);
        case 'EXPERIMENT'
            % experiment name, not important, continue
            continue;
        case 'GROUP'
            % Found the treatment group
            S.group = str2double(value); % this doesn't work, see bottom of the script
        case 'BOX'
            % Found the box the animal's been tested
            S.group.animal.date.box = str2double(value); 
        case 'START TIME'
            % Found the time session has started
            S.group.animal.date.time = datetime(value, 'HH:mm:ss'); % This doesn't work
        case 'END TIME'
            continue;
        case 'MSN'
            S.group.animal.date.program = char(value);
        case 'F'
            continue;
        case 'L'
            S.group.animal.date.numPress = str2double(value);
        case 'R'
            S.group.animal.date.numReward = str2double(value);
        otherwise
            error(['Found an unknown tag ' tag]);
    end
end
% Now fid should be right below the line "A: "
line = fgetl(fid); % irrelevant info on this line, do not store

%% Read Lever Press Array (C):
line = fgetl(fid); % next line, 'C:'
countC = 0;
temp = cell;
if line(1) == 'C' % fid is at lever press array
    while true
        line = fgetl(fid); % next line, where the data starts
        if line(1) == 'D';break;end 
        countC = countC + 1; % counts the lines it reads
        temp{countC} = sscanf(line, '%*: %f %f %f %f %f'); % possibly problematic 
    end   
    if ~(countC*5 == ceil(S.group.animal.date.numPress/5)) % sanity check
        warning('lever press array (C) read incorrectly');
    end
    S.group.animal.date.presses = cat(2, temp); % this part of code not yet 
        % finished, but basically I will concatenate temp, and use cell2num 
        % to write the data vector into the relevant field in S
end

% Then, the same thing as C, but for D and E, here
% Read Reward Array (D):
% Read Head Entry Array (E):

%% Close the file
fclose(fid);



%% problems:
% #1. Biggest one of my problems is that the struct here does not build
% itself smoothly. The hierachy of the struct is as such:
% S.group.animal.date.allTheRestOfTheFields. But currently if there's an
% issue with a field e.g. group info missing in the txt file, the script
% writes NaN to S.group, and all the fields below group are gone. How can I
% structure S so that even if some info are missing, it would keep the rest
% of the info? 
% #2. I want to read the date and time info, and write them to
% the struct as date and time, such that matlab knows that they are date
% and time. But I couldn't make the script do that. Isn't datetime function
% supposed to do that? Or, why doesn't sscanf(line, '%D') write the date to
% its respective field?
% #3. Another very important issue is that I couldn't figure out how to
% call this function in my actual script. This function gives out a struct,
% but I want the whole script to go about the folder file by file, read
% each file and store that info in the struct S, only to put S to the
% bigger data struct, then go on to the next file, adding that info to the
% bigger struct right below the previous one. 
