function gpxFlatNodes = genGpxFlatNodes(nodeParsedStruct,flatNodesIn)
%GENGPXSTRUCTFIELDNAMES Summary of this function goes here
%   Detailed explanation goes here

% Manage inputs
gpxFlatNodes = flatNodesIn;

% Determine next parent fieldname
tmpSimplifiedStruct = rmfield(nodeParsedStruct,'Children');
gpxFlatNodes        = [gpxFlatNodes;tmpSimplifiedStruct];

% Recurse over children
currentNodeChildren = nodeParsedStruct.Children;
for i_child = 1:length(currentNodeChildren)
    gpxFlatNodes = genGpxFlatNodes(currentNodeChildren(i_child),gpxFlatNodes);
end

end

