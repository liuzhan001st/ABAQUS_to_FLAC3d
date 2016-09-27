function ExportLinerSEL_NodePrior( Instance, ElSet, TNodeNum, TCidNum )
% Exports S3R or S3 elements to LinerSEL used in FLAC3d.
% Output files:
%   1. LinerSEL_Nodes.dat for creating SEL nodes of linersels
%   2. A series of files contain commands of creating linersels and groups.
%   3. Links between LinerSEL and grid are established by SEL node init command.
    TNodeNum = TNodeNum + 1000;
    TCidNum = TCidNum + 1000;
    ExpFlag = 0;
    %----------Get and export all Liner nodes------------
    for i = 1:length(Instance)
        if strcmp(Instance(i).element{1, 1}, 'S3') || ...
                strcmp(Instance(i).element{1, 1}, 'S3R')
            LinerNode = Instance(i).node;
            ExpFlag = 1;          % ExpFlag==1 for the liner instance is found
            break
        end
    end
    if ExpFlag == 0
        return
    end
    NodeIDExp = zeros(length(LinerNode(:, 1)), 1);
    for i = 1:length(NodeIDExp)
        NodeIDExp(i) = TNodeNum + i;
    end
    fid = fopen('LinerSEL_Nodes.dat', 'w');
    fprintf(fid, ';Creating %d SEL nodes for linersels\r\n\r\n',...
        length(LinerNode(:, 1)));
    for i = 1:length(LinerNode(:, 1))
        formatspec = 'SEL node id %d %10.5f %10.5f %10.5f\r\n';
        fprintf(fid, formatspec, NodeIDExp(i), LinerNode(i, :));
    end
    fclose(fid);
    %---------Get all Liner ElSets----------------
    LSELSet = struct('name', '', 'element', {});
    LSetNum = 0;      % Total number of LSELSets.
    LIID = 0;  % ID of Liner Instance, only one liner instance exists.
    for i = 1:length(ElSet)
        for j = 1:length(Instance)
            if strcmp(Instance(j).name, ElSet(i).element{1, 1})
                break
            end
        end
        if strcmp(Instance(j).element{1, 1}, 'S3') || ...
                strcmp(Instance(j).element{1, 1}, 'S3R')
            LSetNum = LSetNum + 1;
            LSELSet(LSetNum) = ElSet(i);
            LIID = j;      % Only one liner instance exists in assembly
        end
    end
    %=============Export Liner=====================
    if LSetNum > 0
        CIDExp = TCidNum;
        for i = 1:LSetNum
            CIDExp = CIDExp + 1000;
            FileName = sprintf('%s%s', LSELSet(i).name, '.dat');
            fid = fopen(FileName, 'w');
            CIDNum = length(LSELSet(i).element{1, 2});
            fprintf(fid, ';creating %d linersels\r\n', CIDNum);
            CIDExpStart = CIDExp + 1;
            for j = 1:CIDNum
                fprintf(fid, '\r\n;-------------------------\r\n');
                CIDExp = CIDExp + 1;
                tEID = LSELSet(i).element{1, 2}(j);    % Temp element id.
                tNID = Instance(LIID).element{1, 2}(tEID, 2:4); % Temp node id
                formatspec = 'SEL linersel cid %d id 1 nodes %d %d %d\r\n';
                fprintf(fid, formatspec, ...
                    CIDExp, NodeIDExp(tNID(1)), NodeIDExp(tNID(2)), ...
                    NodeIDExp(tNID(3)));
                for ii = 1:3
                    % Create link between SEL and grid
                    formatspec = 'SEL node init xpos %10.5f range id %d %d\r\n';
                    fprintf(fid, formatspec, LinerNode(tNID(ii), 1), ...
                        NodeIDExp(tNID(ii)), NodeIDExp(tNID(ii)));
                end
            end
            fprintf(fid, '\r\n;-------------------------\r\n');
            fprintf(fid, 'SEL group %s range cid %d %d\r\n', ...
                LSELSet(i).name, CIDExpStart, CIDExpStart + CIDNum - 1);            
            fclose(fid);
        end
    end
end