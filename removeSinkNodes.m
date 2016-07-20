close all; clear; clc;

% last update: 2016-July-18

% this script filters the network nodes to remove nodes, which
% should not be origin/ destination of the trips

%% import all nodes
disp('1. Import list of nodes to be sorted...')
filename = 'input-2016-07/ecbd_nodes20160719.txt';
delimiter = ' ';
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

node_id_entireSG = dataArray{:, 1};
pos_x = dataArray{:, 2};
pos_y = dataArray{:, 3};

clearvars filename delimiter formatSpec fileID dataArray ans;


%% import sink nodes
disp('1. Import sink nodes...')
filename = 'input-2016-07/sinknodes.csv';
delimiter = ',';
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

sinkNodes = dataArray{:, 1};

clearvars filename delimiter formatSpec fileID dataArray ans;

%% filter nodes
disp('3. filter nodes...')

[selectedNodes, indexInA] = setdiff(node_id_entireSG, sinkNodes);

%% save list to file

disp('4. Save to file...')

c = datetime('today');
dateString = datestr(c);

filenameC = sprintf('ecbd_nodes_noSink_%s.txt', dateString);
fileNodes = fopen(filenameC,'w');

for j = 1:length(selectedNodes)
    ind = indexInA(j);
    fprintf(fileNodes,'%0u %0f %0f\n', node_id_entireSG(ind), pos_x(ind), pos_y(ind));
    
end

fclose(fileNodes);

disp('Done.')