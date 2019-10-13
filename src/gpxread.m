function gpxstruct = gpxread(gpxfile)
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
% TODO: try to delete this part later because this consumes a lot of ressource and could be done in genGpxStruct
try
    tmpStructNodes = parseChildNodes(tree);
catch
    % Parsing error
    error('matlabgpx:ParsingError','Error thrown while parsing GPX file.');
end

%% Execute genGpxStruct
counters.trk    = 0;
counters.trkseg = 0;
counters.trkpt  = 0;
[gpxstruct,~] = gengpxstruct(tmpStructNodes,struct(),'',counters);

end