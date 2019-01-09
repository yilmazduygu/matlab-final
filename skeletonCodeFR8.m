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
% data = repmat(struct('field1',[],'field2',[],'field3', [], 'field4', [], ...
%     'field5',[], 'field6', [], 'field7', [], 'field8', [], 'field9', [], ...
%     'field10', [], 'field11', [], 'field12', [], 'field13', [], 'field14', []),1,length(allFiles));

for ii = 1 : length(allFiles)
  baseFileName = allFiles(ii).name;
  fullFileName = fullfile(myFolder, baseFileName);
  % Lets user know of what the script is doing. 
  fprintf(1, '%d. Now reading %s\n', ii, baseFileName);
  data(ii) = readFR8txt(fullFileName);  % I don't know how to pre-allocate memory for 'data', so I cannot fix the warning Matlab gives here
end
if ii ~= length(allFiles)
    error('Problem with reading all the files in %s\n', myFolder);
else
    fprintf(1, 'Finished reading all files in %s\n', myFolder);
end
save 'data.mat' data

%% Clean and sort the data

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
rm = sum(rm,2); % because for each double-session case rm put the logical values in seperate column
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

%% Make the figure
T.efficiency = (T.numReward.*8)./T.numPress;
[perSession,sessions] = findgroups(T(:,'date'));
[perAnimal,animals] = findgroups(T(:,'animal'));
meanEfficiency = mean(T.efficiency);

figure(1);
clf;hold on
boxplot(T.efficiency,perSession);
set(gca,'YLim', [0 1]);
plot(get(gca,'XLim'),[meanEfficiency meanEfficiency],'k');
xStart = 3;
xEnd = 2;
yStart = 0.5;
line([xStart xEnd],[yStart meanEfficiency], 'Color','black');
text(xStart,yStart-0.01,['\mu = ' num2str(meanEfficiency)], 'HorizontalAlignment',...
    'left','color','k');
xlabel('Training days');
ylabel('Efficiency score (au)');
title('Efficiency scores grouped across training days');
% h = findobj(gcf,'tag','Outliers');
% xdata = get(h,'XData');
% ydata = get(h,'YData');
% yd = cell2mat(ydata);
% yd = ~isnan(yd);
% text(xdata(yd),ydata(yd),animals(yd),'HorizontalAlignment',...
%     'left','color','r');
hold off


figure(2);
clf;hold on
boxplot(T.efficiency,perAnimal);
xticklabels(table2cell(animals));
xtickangle(45);
set(gca,'YLim', [0 1]);
plot(get(gca,'XLim'),[meanEfficiency meanEfficiency],'k');
xStart = 4;
xEnd = 2.6;
yStart = 0.45;
line([xStart xEnd],[yStart meanEfficiency], 'Color','black');
text(xStart,yStart-0.01,['\mu = ' num2str(meanEfficiency)], 'HorizontalAlignment',...
    'left','color','k');
xlabel('Animals'); 
ylabel('Efficiency score (au)');
title('Efficiency scores per animal');
hold off

% figure(3);
% clf;
% R=7;
% C=2;
% for ii=1:length(animals)
%     subplot(R,C,ii);
%     plot(T.efficiency(T.animal == animals(ii),);
% end
% meanEffiPerSesh = splitapply(@mean,tableData.efficiency,perSession);
% stdEffiPerSesh = splitapply(@std,tableData.efficiency,perSession);
% SEMfxn = @(x)std(x)/sqrt(length(x));
% semEffiPerSesh = splitapply(SEMfxn,tableData.efficiency,perSession);
% tableData.date = categorical(tableData.date);
% [tf,idx] = ismember(tableData.date,sessions);
% outlierTF = zeros(length(tableData.efficiency));
% for ii=1:length(tableData.efficiency)
%     if (tableData.efficiency(ii) > (meanEffiPerSesh(idx)) + 3*stdEffiPerSesh(idx)) ...
%             || (tableData.efficiency(ii) < (meanEffiPerSesh - 3*stdEffiPerSesh(idx)))
%         outlierTF(ii) = 1;
%     else 
%         outlierTF(ii) = 0;
%     end
% end
% outlierTF = logical(outlierTF);
% figure(2);clf;hold on
% errorbar(meanEffiPerSesh,semEffiPerSesh,':');
% plot(sessions,tableData.efficiency,'r*');
% 
% [perAnimal,animals] = findgroups(tableData(:,'animal'));
% meanEffiPerAni = splitapply(@mean,tableData.efficiency,perAnimal);
% 
% semEffiPerAni = splitapply(SEMfxn,tableData.efficiency,perAnimal);
% % errorbar(meanEffiPerAni,semEffiPerAni);

%% Function to read each data file
function S = readFR8txt(filename)

% Open text file, give error if not possible
fid = fopen(filename);
if fid<0
    error('Error opening the file %s.\n', filename);
end

% Set up the struct S, assign default values to each field
S = struct;
S.animal = NaN;
S.date = NaT;
S.group = NaN;
S.box = NaN;
S.duration = NaT;
S.program = '';
S.numPress = NaN;
S.numReward = NaN;
S.presses = NaN;
S.rewards = NaN;
S.headEntries = NaN;
S.comments = '';
S.start = NaT;
S.name = '';
% Read header info, write each bit to its corresponding field in S
while true
    line = fgetl(fid);
    if isempty(line) || length(line) == 0;continue;end % Skip empty lines: I cannot fix the warning Matlab gives here, because for my files, with fgetl, isempty function does not work, only length does
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
            recDate = char(value); % for later use
        case 'END DATE'
            % Found the date session ended, not important, continue
            continue;
        case 'SUBJECT'
            % Found the animal ID #
            S.animal = str2double(value);
            if ~(str2double(S.name(42:46)) == S.animal)
                warning('Animal ID possibly read incorrectly');
            end
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
            recTime = char(value);
            S.start= datetime([recDate, ' ', recTime], 'InputFormat', 'MM/dd/yy HH:mm:ss');
        case 'END TIME'
            % Found the time session has ended, use this to find out
            % session duration
            recTimeEnd = char(value);
            endTime = datetime([recDate, ' ', recTimeEnd], 'InputFormat', 'MM/dd/yy HH:mm:ss');
            S.duration = endTime - S.start;
            if S.duration > minutes(60) % Sanity check
                warning('Session duration longer than an hour for this one');
            end
        case 'MSN'
            % Found the program run that day
            S.program = char(value);
            earlyTraining = {'FR8_Day4_NKG','FR8_Day3_NKG','FR8_Day2_NKG',...
                'FR3_FULL_3ar_nolimit','FR5_FULL_3ar_nolimit'};
            if ismember(S.program,earlyTraining)
                return; % I don't want the data for earlier stages of training
            end
        case 'F'
            % Irrelevant info about MED-PC
            continue;
        case 'L'
            % Found the total number of presses the animal did
            S.numPress = str2double(value);
        case 'R'
            % Found the total number of rewards the animal got
            S.numReward = str2double(value);
        otherwise
            error(['Found an unknown tag ' tag]);
    end
end
% Now fid should be right below the line "A: "
if ~(line(1)=='A')
    error('Cursor is at an unintended line');
end
line = fgetl(fid); % irrelevant info on this line, do not store

% Read Lever Press Array (C):
line = fgetl(fid); % next line, 'C:'
if line(1) == 'C' % fid is at lever press array
    S.presses = readArray('C', 'D');
else
    error('Cursor is at an unintended line');
end

% Read Rewards Array (D):
if line(1) == 'D' % fid is at rewards array
    S.rewards = readArray('D','E');
else
    error('Cursor is at an unintended line');
end

% Read Head Entries Array (E):
if line(1) == 'E' % fid is at head entry array
    [S.headEntries, S.comments] = readArray('E', 'X');
end

% Function to read data arrays:
    function [array, comment] = readArray(whichArray, untilWhere)
        allArrays = {'C', 'D', 'E'};
        if ~ismember(whichArray, allArrays)
            error('Local function called wrong');
        end
        
        counter = 0;
        temp = {};
        comment = '';
        while true
            line = fgetl(fid); % next line, where the data starts
            if line(1) == untilWhere;break;end
            if line(1) == '\'
                comment = line(2:end);
                continue;
            end
            if line == -1;break;end
            counter = counter + 1; % counts the lines it reads
            values = extractAfter(line, ': ');
            A = sscanf(values, '%f');
            temp{counter} = A'; %I probably couldn't understand what you meant, because I couldn't get rid of this transpose, nor the str2num worked.
        end
        array = cat(2, temp{:});
    end

% Close the file
fclose(fid);
end
