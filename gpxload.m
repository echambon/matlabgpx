function gpxstruct = gpxload(gpxfile)
%GPXLOAD Summary of this function goes here
%   Detailed explanation goes here

%% Read XML file
try
    tree = xmlread(gpxfile);
catch
    % File not found
    error('matlabgpx:FileNotFound','GPX file not found.');
end

%% Recurse over child nodes
try
    tmpStructNodes = parseChildNodes(tree);
catch
    % Parsing error
    error('matlabgpx:ParsingError','Error thrown while parsing GPX file.');
end

%% Debug
gpxstruct = tmpStructNodes;

end