function ExportZone( Instance, ElSet, FileName )
% Exports FLAC3d zones and zgroups into a *.flac3d file    
    fid = fopen(FileName, 'w');
    CID = 0;          % Index of solid instance
    CElType = {'C3D8R' 'C3D6' 'C3D4'};
    for i = 1:length(Instance)
        CFlag = 0;        % CFlag==1 if the instance is created from a solid part
        for j = 1:length(CElType)
            if strcmp(Instance(i).element{1, 1}, CElType{j})
                CFlag = 1;
                break
            end
        end
        if CFlag == 1
            CID = i;
            break
        end
    end
    %================Export grids points and zones===================
    %----------------Export nodes------------------------------------
    fprintf(fid, '*GRIDPOINTS\r\n');   
    for i = 1:length(Instance(CID).node)      % Index is used as node id
        formatspec = 'G %d %10.5f %10.5f %10.5f\r\n';
        fprintf(fid,formatspec, i, Instance(CID).node(i,1), ...
            Instance(CID).node(i,2), Instance(CID).node(i,3));
    end
    fprintf(fid, '\r\n');
    %----------------Export zones-------------------------------------
    fprintf(fid, '*ZONES\r\n');
    for i = 1:length(Instance(CID).element(:, 1))
        if strcmp(Instance(CID).element{i, 1}, 'C3D8R')
            formatspec = 'Z B8 %d %d %d %d %d %d %d %d %d\r\n';
            for j = 1:size(Instance(CID).element{i, 2}, 1);
                fprintf(fid, formatspec, Instance(CID).element{i, 2}(j, :));
            end
        end
        if strcmp(Instance(CID).element{i, 1}, 'C3D6')
            formatspec = 'Z W6 %d %d %d %d %d %d %d\r\n';
            for j = 1:size(Instance(CID).element{i, 2}, 1);
                fprintf(fid,formatspec,Instance(CID).element{i, 2}(j, :));
            end
        end
        if strcmp(Instance(CID).element{i, 1}, 'C3D4')
            formatspec = 'Z T4 %d %d %d %d %d\r\n';
            for j = 1:size(Instance(CID).element{i, 2}, 1);
                fprintf(fid, formatspec, Instance(CID).element{i, 2}(j, :));
            end
        end
    end
    fprintf(fid, '\r\n');
    %----------------Export zgroups-----------------------------------
    fprintf(fid, '*GROUPS\r\n');
    for i = 1:length(ElSet)
        CFlag = 0;
        for j = 1:length(Instance)    %   Find corresponding instance
            if strcmp(ElSet(i).element{1, 1}, Instance(j).name)
                break
            end
        end
        for k = 1:length(CElType)     %   Determine solid instance
            if strcmp(Instance(j).element{1, 1}, CElType{k})
                CFlag = 1;
                break
            end
        end
        if CFlag == 1
            GrpNameLine = sprintf('%s%s', 'ZGROUP ', ElSet(i).name);
            fprintf(fid, '%s\r\n', GrpNameLine);
            LENum = 0;     %  Total number of elements in a sinlge line
            for ii = 1:length(ElSet(i).element{1, 2})
                LENum = LENum + 1;
                fprintf(fid, '%d ', ElSet(i).element{1, 2}(ii));
                if mod(LENum, 10) == 0
                    fprintf(fid, '\r\n');
                end
            end
            fprintf(fid, '\r\n\r\n');
        end
    end
    fclose(fid);
end