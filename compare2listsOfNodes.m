close all; clear; clc;

% compare nodes in two different files

%% import list of nodes within the analysed zone
disp('1. Import old list of nodes ...')
filename = 'input-2016-07/ecbd_nodes_noSink_19-Jul-2016.txt';
delimiter = ' ';
formatSpec = '%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN, 'ReturnOnError', false);
fclose(fileID);

node_id_eCBD = dataArray{:, 1};
x_pos_eCBD = dataArray{:, 2}; % in cm
y_pos_eCBD = dataArray{:, 3}; % in cm

clearvars filename delimiter formatSpec fileID dataArray ans;

disp('2. Import new list of nodes ...')
filename = 'input-2016-07/extcbdnodes.csv';
delimiter = '';
startRow = 2;
formatSpec = '%f%[^\n\r]';
fileID = fopen(filename,'r');

dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);

node_id_eCBD2 = dataArray{:, 1};

clearvars filename delimiter formatSpec fileID dataArray ans;

newNodes = setdiff(node_id_eCBD, node_id_eCBD2);