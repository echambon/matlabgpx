function [nodeStruct,countersOut] = genGpxStruct(nodeParsedStruct,nodeStructIn,parentFieldname,countersIn)
% TODO: move to gpxload in the end
% TODO: also review parseChildNodes code not to create the intermediate Name,Attributes,etc. structures but directly execute this code 

% Initialize
nodeStruct      = nodeStructIn;
countersOut     = countersIn;

action_addfield             = false;
action_substruct_addfield   = false;
action_savedata             = false;
action_substruct_savedata   = false;

my_substruct = struct();

% Detect if we are at the trk, trk.trkseg or trk.trkseg.trkpt level
if contains(parentFieldname,'trk')
    my_substruct = substruct('()',{1,1},...
                             '.','trk',...
                             '()',{countersIn.trk,1});
    if contains(parentFieldname,'trkseg')
        my_substruct = substruct('()',{1,1},...
                                 '.','trk',...
                                 '()',{countersIn.trk,1},...
                                 '.','trkseg',...
                                 '()',{countersIn.trkseg,1});
        % if contains(parentFieldname,'trkpt')
            % unchanged substruct
            % elements will be stored in trk(i).trkseg(j).lat/lon/ele/etc.
        % end
    end
end

% Actions depend on node type
switch nodeParsedStruct.Name
    case {'gpx','metadata','link','desc','name','author','copyright','time'}
        if contains(parentFieldname,'trk')
            action_substruct_addfield = true;
        else
            action_addfield	= true;
        end
    case '#text'
        if contains(parentFieldname,'trk')
            action_substruct_savedata = true;
        else
            action_savedata	= true;
        end
    case 'trk'
        countersOut.trk     = countersOut.trk + 1;
        countersOut.trkseg  = 0;
        countersOut.trkpt   = 0;
    case 'trkseg'
        countersOut.trkseg  = countersOut.trkseg + 1;
        countersOut.trkpt   = 0;
    case 'trkpt'
        countersOut.trkpt   = countersOut.trkpt + 1;
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

if action_substruct_addfield
    % TODO : use substruct
end

% Manage data
if action_savedata
    % Generate cell for setfield
    tmp_setfield_cell = split(parentFieldname,'.',2);
    
    % Assign data
    nodeStruct = setfield(nodeStruct,tmp_setfield_cell{:},nodeParsedStruct.Data);
end

if action_substruct_savedata
    % TODO : use substruct
end

%% Recurse over children
% Loop over children
currentNodeChildren = nodeParsedStruct.Children;
for i_child = 1:length(currentNodeChildren)
    [nodeStruct,countersOut] = genGpxStruct(currentNodeChildren(i_child),nodeStruct,nextParentFieldname,countersOut);
end

end