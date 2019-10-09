clear; close all; restoredefaultpath;
addpath('../src');
addpath('../inc');

nodeParsedStruct = gpxload('AC2019_J1_M1_debug.gpx');

% nodeParsedStruct = importdata('tmpStructNode.mat');
% gpxstruct = genGpxStruct(nodeParsedStruct,struct());
% TODO: put everything in genGpxStruct once debug is finished ...
gpxstruct   = genGpxStructFieldnames(nodeParsedStruct,{},'root');
% gpxstruct2  = genGpxFlatNodes(nodeParsedStruct,{});

counters.trk    = 0;
counters.trkseg = 0;
counters.trkpt  = 0;

[gpxstruct3,countersDebug] = genGpxStruct(nodeParsedStruct,struct(),'',counters);
gpxstruct3.gpx.trk(1).trkseg(1)

% TODO:
% counters for:
% * trk
% * * trkseg
% * * * trkpt
% * rte
% * * rtept
% * wpt