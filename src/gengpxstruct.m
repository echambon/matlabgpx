function [nodeStruct,countersOut] = gengpxstruct(nodeParsedStruct,nodeStructIn,parentFieldname,countersIn)
% TODO: move to gpxload in the end
% TODO: also review parseChildNodes code not to create the intermediate Name,Attributes,etc. structures but directly execute this code 
% TODO: lat lon are attributes in trkpt, not supported yet ...

% Initialize
nodeStruct      = nodeStructIn;
countersOut     = countersIn;

action_addfield             = false;
action_substruct_addfield   = false;
action_savedata             = false;
action_substruct_savedata   = false;
action_substruct_latlon     = false;

my_substruct = struct();

% Detect if we are at the trk, trk.trkseg or trk.trkseg.trkpt level
% TODO: rte and wpt support
if contains(parentFieldname,'trk')
    my_substruct = substruct('()',{1,1},...
                             '.','trk',...
                             '()',{countersIn.trk,1},...
                             '.',nodeParsedStruct.Name);
    if contains(parentFieldname,'trkseg')
        % Updating substruct
        my_substruct(end).subs = 'trkseg';
        my_substruct(end+1) = substruct('()',{countersIn.trkseg,1});
        my_substruct(end+1) = substruct('.',nodeParsedStruct.Name);
        if contains(parentFieldname,'trkpt')
            % elements will be stored in trk(i).trkseg(j).lat/lon/ele/etc.
            % Updating substruct
            my_substruct(end+1) = substruct('()',{countersIn.trkpt,1});
        end
    end
end

% Actions depend on node type
switch nodeParsedStruct.Name
    case {'gpx','metadata','link','desc','name','author','copyright'}
        if contains(parentFieldname,'trk')
            action_substruct_addfield = true;
        else
            action_addfield	= true;
        end
    case 'time'
        if ~contains(parentFieldname,'trk')
            action_addfield	= true;
        end
    case '#text'
        if contains(parentFieldname,'trk')
            action_substruct_savedata = true;
            if ~contains(parentFieldname,'trkpt')
            	my_substruct(end).subs = nodeParsedStruct.ParentName;
            else
            	my_substruct(end-1).subs = nodeParsedStruct.ParentName;
            end
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
        countersOut.trkpt       = countersOut.trkpt + 1;
        action_substruct_latlon = true;
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
    % TODO: support wpt and rte
    % Generate cell for setfield but halted just before trk
    tmp_trk_find = strfind(nextParentFieldname,'.trk');
    tmp_setfield_cell = split(nextParentFieldname(1:tmp_trk_find(1)-1),'.',2);
    
    % Get field at the setfield level
    tmp_current_field = getfield(nodeStruct,tmp_setfield_cell{:});
    
    % Store attributes temporary structure to be assigned
    tmp_attributes = nodeParsedStruct.Attributes;
    tmp_attributes_struct = struct();
    for i_attribute = 1:length(tmp_attributes)
        tmp_attributes_struct.(tmp_attributes(i_attribute).Name) = tmp_attributes(i_attribute).Value;
    end
    
    % Assign temporary structure
    tmp_current_field = subsasgn(tmp_current_field,my_substruct,tmp_attributes_struct);
    
    % Re-assign to nodeStruct
    nodeStruct = setfield(nodeStruct,tmp_setfield_cell{:},tmp_current_field);
end

% Manage data
if action_savedata
    % Generate cell for setfield
    tmp_setfield_cell = split(parentFieldname,'.',2);
    
    % Assign data
    nodeStruct = setfield(nodeStruct,tmp_setfield_cell{:},nodeParsedStruct.Data);
end

if action_substruct_savedata
    % TODO: support wpt and rte
    % Generate cell for setfield but halted just before trk
    tmp_trk_find = strfind(parentFieldname,'.trk');
    tmp_setfield_cell = split(parentFieldname(1:tmp_trk_find(1)-1),'.',2);
    
    % Get field at the setfield level
    tmp_current_field = getfield(nodeStruct,tmp_setfield_cell{:});
    
    % Assign temporary structure
    try
        % Try converting supported nodes
        tmp_data = convertData(nodeParsedStruct.ParentName,nodeParsedStruct.Data);
        tmp_current_field = subsasgn(tmp_current_field,my_substruct,tmp_data);
    catch
        % In case of error, just fill a cell
        tmp_current_field = subsasgn(tmp_current_field,my_substruct,{nodeParsedStruct.Data});
    end
    
    % Re-assign to nodeStruct
    nodeStruct = setfield(nodeStruct,tmp_setfield_cell{:},tmp_current_field);
end

if action_substruct_latlon
    % TODO
end

%% Recurse over children
% Loop over children
currentNodeChildren = nodeParsedStruct.Children;
for i_child = 1:length(currentNodeChildren)
    [nodeStruct,countersOut] = gengpxstruct(currentNodeChildren(i_child),nodeStruct,nextParentFieldname,countersOut);
end

end

function cdata = convertData(nodename,data)
switch nodename
    case {'name','cmt','desc','src','link','type'}
        cdata = data;
    case 'time'
        % TODO: not working (throws an error even if correctly converted to datetime object)
        % NB: working if put between {} ...
        cdata = datetime(data,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSS''Z''');
    otherwise
        cdata = str2double(data);
end
end