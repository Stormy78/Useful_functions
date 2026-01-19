function [creoResultsFile,creoResultsLocation] = uigetfile_extended(fileExtension,defaultSimResFolder)
try
    lastLocation_ = readlines("lastLocation.txt");
    lastLocation = lastLocation_{1};
catch
    lastLocation = defaultSimResFolder;
end

[creoResultsFile, creoResultsLocation] = uigetfile(fullfile(lastLocation,['*.' fileExtension]),...
    "Provide Simulation Results File");
writelines(creoResultsLocation, 'lastLocation.txt')
end