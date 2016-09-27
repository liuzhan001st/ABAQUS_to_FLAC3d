% Convert solid elements and structural elements from ABAQUS to FLAC3d.
% Author: liuzhan001st, liuzhan001st@163.com, https://github.com/liuzhan001st
%
% This code was wrote in MATLABr2015a and tested with 
% ABAQUS6.14.1 and FLAC3d5.0.
%
% Input model is orgnized by conceptions of part, set and assembly in
% ABAQUS.
% Solid elements are coverted directly to FLAC3d .flac3d file and
% structrual elements are transfer to FLAC3d command lines.
% Input:
%   An .inp file written by ABAQUS. 
% Rules of modeling with ABAQUS:
%   (1) Only one solid(shell) part correspongding to FLAC zones(SEL Liner/Shells) 
%   should be created,and only one solid(shell) instance should be created 
%   at Assembly level;
%   (2) A wire part should contain an individual wire meshed with truss or 
%   beam elements, element number will be interpreted as segment number in 
%   the output file, and the support system is created by patterning the 
%   wire parts;
%   (3) Shell elements within a same part are treated as linked
%   shells/liners in the output file;
%   (4) Shell elements and wire shaped elements should be assigned to 
%   different sets as their meshes need not to associate (Linkings need not
%   to be established);
%   (5) No wire feature exist in the solid part;
%   (6) Elsets should be created in Assembly level (by simply creating 
%   geometry set within Assembly leverl), and structural elements and solid
%   elements can not be assigned to a same Elset;
%   (7) Rockbolts and cables should not be assigned to a same Elset.
%   (8) Elements converting rules:
% Outputs:
%   (1) a .flac3d file contains grid points, zones and zgroup for solid
%   elements; and
%   (2) a series of .dat files contain command lines to generate structural
% nodes and elements in FLAC3d.
%--------------------------------------------------------------------------
close all
clear
clc
%===========================Load Model=============================
LoadingStart = tic;
InputFileName = 'ABA-FLAC3d-StdTest.inp';
InputModel = ImportInp(InputFileName);
Part = LoadPart(InputModel);
% Returned Instances contain global node coordinates and FLAC3d formated
% node orderings within elements.
Instance = LoadInstance(InputModel, Part);
ElSet = LoadSet(InputModel);  % Homonymous instances within a set are not merged, 
                            % that may lead to incomplete zgroup defenition!!!
LoadingTime = toc(LoadingStart)
%==========================Export Model============================
%-------------Export zones and zgroups--------------
ExportStart = tic;
FileName = sprintf('%s%s', InputFileName, '.flac3d');
ExportZone(Instance, ElSet, FileName);
[TNodeNum, TCidNum] = ExportCPSEL(Instance, ElSet);
%ExportLinerSEL(Instance,ElSet,TNodeNum,TCidNum);
ExportLinerSEL_NodePrior(Instance, ElSet, TNodeNum, TCidNum);
ExportTime = toc(ExportStart)