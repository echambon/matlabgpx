function gpxFieldnames = genGpxStructFieldnames(nodeParsedStruct,nodeStructFieldnamesIn,parentFieldname)
%GENGPXSTRUCTFIELDNAMES Summary of this function goes here
%   Detailed explanation goes here

% Manage inputs
gpxFieldnames = nodeStructFieldnamesIn;

% Determine next parent fieldname
nextParentFieldname     = [parentFieldname '.' nodeParsedStruct.Name];
gpxFieldnames           = [gpxFieldnames;nextParentFieldname];

% Recurse over children
currentNodeChildren = nodeParsedStruct.Children;
for i_child = 1:length(currentNodeChildren)
    gpxFieldnames = genGpxStructFieldnames(currentNodeChildren(i_child),gpxFieldnames,nextParentFieldname);
end

end

