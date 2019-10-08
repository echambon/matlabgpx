function nodeStruct = genGpxStruct(nodeParsedStruct,nodeStructIn,parentFieldname)
% TODO: move to gpxload in the end

% Initialize
nodeStruct      = nodeStructIn;

action_addfield	= false;
action_savedata	= false;

% Actions depend on node type
switch nodeParsedStruct.Name
    case {'gpx','metadata','link','trk','name'}
        action_addfield	= true;
    case '#text'
        switch nodeParsedStruct.ParentName
            case {'gpx','metadata','link','trk','name'}
                action_savedata	= true;
            otherwise
                % TODO: manage data differently
        end
    case 'trkseg'
        % TODO
    case 'trkpt'
        % TODO
end

%% Actions
% Determine next parent fieldname
if isempty(parentFieldname)
    nextParentFieldname = nodeParsedStruct.Name;
else
    nextParentFieldname = [parentFieldname '.' nodeParsedStruct.Name];
end

% Add field to nodeStruct
if action_addfield
    % Generate cell for setfield
    tmp_setfield_cell = split(nextParentFieldname,'.',2);
    
    % Initialize structure
    nodeStruct = setfield(nodeStruct,tmp_setfield_cell{:},struct());
    
    % Store attributes in newly created field
    tmp_attributes = nodeParsedStruct.Attributes;
    tmp_attributes_struct = struct();
    for i_attribute = 1:length(tmp_attributes)
        tmp_attributes_struct.(tmp_attributes(i_attribute).Name) = tmp_attributes(i_attribute).Value;
    end
    % Assign structure
    nodeStruct = setfield(nodeStruct,tmp_setfield_cell{:},tmp_attributes_struct);
end

% Manage data
if action_savedata
    % Generate cell for setfield
    tmp_setfield_cell = split(parentFieldname,'.',2);
    
    % Assign data
    nodeStruct = setfield(nodeStruct,tmp_setfield_cell{:},nodeParsedStruct.Data);
end

%% Recurse over children
% Loop over children
currentNodeChildren = nodeParsedStruct.Children;
for i_child = 1:length(currentNodeChildren)
    nodeStruct = genGpxStruct(currentNodeChildren(i_child),nodeStruct,nextParentFieldname);
end

end