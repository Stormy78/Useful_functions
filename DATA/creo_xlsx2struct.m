function [S, matFileName] = creo_xlsx2struct(defaultSimLocation,ignoreNamesList, loadType, toSave)
% This function extracts all creo simulate graph results in .xlsx forma
% Inputs:
% defaultSimLocation - path to be search for .xlsx
% ignoreNamesList - optional list of ignore file names
% loadType - 'new' - for new load (default)
%            'load' - for load already saved files

arguments
    defaultSimLocation % no default
    ignoreNamesList = {''}       %default - an empty array
    loadType = 'new'             %by default load new data
    toSave = false               %by default dont save .mat
end

currentDateTime = char(datetime('now', 'Format','yyyy_MM_dd__hh_mm'));

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
            opts = detectImportOptions(fullfile(creoResultsLocation, filteredFileNames{i}));
            opts.VariableNamingRule = 'modify';     
            S.(filedName) = readtable(fullfile(creoResultsLocation, filteredFileNames{i}), opts);
        end

        matFileName_ = split(creoResultsLocation, '\');
        matFileName = [matFileName_{end-1}, '_', currentDateTime, '.mat'];

        if toSave

            save(matFileName, 'S');
            sprintf('File %s was saved...', matFileName)
        end
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