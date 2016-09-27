function [TNodeNum, TCidNum] = ExportCPSEL( Instance, ElSet )
% Exports cable and pile (for rockbolt) sels, and total number of ids will
% be written to head of the output file as a comment.
% Output files' names follow structural sets.
% Returns Total Node Numbers TNodeNum.
    WSELSet = struct('name', '', 'type', '', 'element', {});     % Wire shaped sel set.
    % *.element = {'InstName1' [element nodeid] [node]  
    %              'InstName2' [element nodeid] [node]
    %              ...                                }
    CSetNum = 0;      % Total number of CSELSets.
    PSetNum = 0;      % Total number of PSELSets.
    WSetNum = 0;
    TNodeNum = 0;
    TCidNum = 0;
    for i = 1:length(ElSet)
        for j = 1:length(Instance)
            if strcmp(Instance(j).name, ElSet(i).element{1, 1})
                break
            end
        end
        if strcmp(Instance(j).element{1, 1}, 'B31')
            CSetNum = CSetNum + 1;
            WSetNum = WSetNum + 1;
            WSELSet(WSetNum).type = 'pile';
            WSELSet(WSetNum).name = ElSet(i).name;
            WSELSet(WSetNum).element = ElSet(i).element;
        elseif strcmp(Instance(j).element{1, 1}, 'T3D2')
            PSetNum = PSetNum + 1;
            WSetNum = WSetNum + 1;
            WSELSet(WSetNum).type = 'cable';
            WSELSet(WSetNum).name = ElSet(i).name;
            WSELSet(WSetNum).element = ElSet(i).element;
        end
    end
    %-----------------Load node coordinates to CSELSet and PSELSet-------
    for i = 1:WSetNum
        for j = 1:length(WSELSet(i).element(:, 1))
            for k = 1:length(Instance)
                if strcmp(Instance(k).name, WSELSet(i).element{j, 1})
                    WSELSet(i).element{j, 3} = Instance(k).node;
                end
            end
        end
    end
    %===============Export wire shaped SELs====================
    if WSetNum > 0
        PileID = 0;
        CableID = 0;
        TPnsegNum = 0;
        TCnsegNum = 0;
        for i = 1:WSetNum
            FileName = sprintf('%s%s', WSELSet(i).name, '.dat');
            fid = fopen(FileName, 'w');
            IDNum = length(WSELSet(i).element(:, 1));
            PileFlag = 0;
            if strcmp(WSELSet(i).type, 'pile')
                PileFlag = 1;
                formatspec = '; creating %d piles(rockbolts)\r\n';
                fprintf(fid, formatspec, IDNum);
                PCIDStart = TPnsegNum + 1;
                for j = 1:IDNum
                    PileID = PileID + 1;
                    formatspec1 = 'SEL pile id %d begin %10.5f %10.5f %10.5f ';
                    formatspec2 = 'end %10.5f %10.5f %10.5f nseg %d\r\n';
                    formatspec = sprintf('%s%s', formatspec1, formatspec2);
                    nseg = length(WSELSet(i).element{j, 2});
                    TPnsegNum = TPnsegNum + nseg;
                    NodeNum = length(WSELSet(i).element{j, 3}(:, 1));
                    TCidNum = TCidNum + nseg;
                    TNodeNum = TNodeNum + NodeNum;
                    NStart = WSELSet(i).element{j, 3}(1, :);
                    NEnd = WSELSet(i).element{j, 3}(NodeNum, :);
                    fprintf(fid, formatspec, PileID, NStart, NEnd, nseg);
                end
            elseif strcmp(WSELSet(i).type, 'cable')
                formatspec = '; creating %d cables\r\n';
                fprintf(fid, formatspec, IDNum);
                CCIDStart = TCnsegNum + 1;
                 for j = 1:IDNum
                    CableID = CableID + 1;
                    formatspec1 = 'SEL cable id %d begin %10.5f %10.5f %10.5f ';
                    formatspec2 = 'end %10.5f %10.5f %10.5f nseg %d\r\n';
                    formatspec = sprintf('%s%s', formatspec1, formatspec2);
                    nseg = length(WSELSet(i).element{j, 2});
                    TCnsegNum = TCnsegNum + nseg;
                    NodeNum = length(WSELSet(i).element{j, 3}(:, 1));
                    TCidNum = TCidNum + nseg;
                    TNodeNum = TNodeNum + NodeNum;
                    NStart = WSELSet(i).element{j, 3}(1, :);
                    NEnd = WSELSet(i).element{j, 3}(NodeNum, :);
                    fprintf(fid, formatspec, CableID, NStart, NEnd, nseg);
                end
            end
            if PileFlag == 1
                fprintf(fid, '\r\n\r\n;----------------\r\n');
                fprintf(fid, 'SEL pile prop rockbolt on\r\n');
                fprintf(fid, '\r\n;------------------------------\r\n');
%                fprintf(fid, 'SEL group %s range cid %d %d\r\n', ...
%                    WSELSet(i).name, PCIDStart, TPnsegNum);
%            else               
            end
            fclose(fid);
        end
    end
end

