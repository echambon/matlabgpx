clear; close all; restoredefaultpath;
addpath('../src');
addpath('../inc');

gpxstruct = gpxload('AC2019_J1_M1_debug.gpx');

% TODO:
% counters for:
% * trk
% * * trkseg
% * * * trkpt
% * rte
% * * rtept
% * wpt