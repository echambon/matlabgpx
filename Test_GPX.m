clear; close all; restoredefaultpath;
addpath('inc');

nodeParsedStruct = gpxload('AC2019_J1_M1_debug.gpx');

% nodeParsedStruct = importdata('tmpStructNode.mat');
% gpxstruct = genGpxStruct(nodeParsedStruct,struct());
% TODO: put everything in genGpxStruct once debug is finished ...
gpxstruct   = genGpxStructFieldnames(nodeParsedStruct,{},'root');
% gpxstruct2  = genGpxFlatNodes(nodeParsedStruct,{});

gpxstruct3 = genGpxStruct(nodeParsedStruct,struct(),'');
% gpxstruct

% TODO:
% counters for:
% * trk
% * * trkseg
% * * * trkpt
% * rte
% * * rtept
% * wpt