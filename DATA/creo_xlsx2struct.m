function [S, matFileName] = creo_xlsx2struct(defaultSimLocation,ignoreNamesList, loadType)
% This function extracts all creo simulate graph results in .xlsx forma
% Inputs:
% defaultSimLocation - path to be search for .xlsx
% ignoreNamesList - optional list of ignore file names
% loadType - 'new' - for new load (default)
%            'load' - for load already saved files

currentDateTime = char(datetime('now', 'Format','yyyy_MM_dd__hh_mm'));
callerPath = pwd;

switch nargin
    case 2
        loadType = 'new';
    case 1
        ignoreNamesList = {''};
        loadType = 'new';
    case 0
        error('Not enough input arguments...')
    otherwise
        % full arguments input
end

switch loadType
    case 'new'
        [~,creoResultsLocation] = uigetfile_extended('xlsx', defaultSimLocation);

        % Get a list of all .xlsx files in the designated location
        fileList = dir(fullfile(creoResultsLocation, '*.xlsx'));
        fileNames = {fileList.name}';

        % Remove names matching the provided names
        filteredFileNames = setdiff(fileNames, ignoreNamesList);
        % Create a struct with fields as filenames' last characters after '_' without file extension
        S = struct();
        for i = 1:length(filteredFileNames)
            [~, name, ~] = fileparts(filteredFileNames{i});
            splittedFileName = split(name, '_');
            filedName = splittedFileName{end}; % Get the last character after '_'
            S.(filedName) = readtable(fullfile(creoResultsLocation, filteredFileNames{i}));
        end

        matFileName_ = split(creoResultsLocation, '\');
        matFileName = [matFileName_{end-1}, '_', currentDateTime, '.mat'];
        save(matFileName, 'S');
        sprintf('File %s was saved...', matFileName)
    case 'load'
        dirRes = dir('*.mat');
        if isempty(dirRes)
            error('No .mat files found.');
        end
        fileNames = {dirRes.name};

        [idx, ok] = listdlg( ...
            'PromptString', 'Select a MAT file:', ...
            'SelectionMode', 'single', ...
            'ListString', fileNames);

        selectedFile = fileNames{idx};
        disp(['Selected file: ', selectedFile]);
        load(selectedFile);
end
end