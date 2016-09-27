function [ Instance ] = LoadInstance( InputModel, Part )
% Recognizes instances from InputModel and Part
% The global coordinates of nodes are transformed by translation and
% rotation about a specified axis
% Zone element node orderings are transformed into FLAC3d format
    Instance = struct('name', '', 'part', '', 'node', [], 'element', {});
%----------Transform zone element node orderings into FLAC3d format---------
    for i = 1:length(Part)
        for j = 1:length(Part(i).element(:, 1))
            ColNum = length(Part(i).element{j, 2}(1, :));
            AEl = Part(i).element{j, 2}(:, 2:ColNum);   % Elements in Abaqus
            FEl = AEl;                                % Elements in FLAC
            if strcmp(Part(i).element{j, 1}, 'C3D8R')
                FEl(:, 1) = AEl(:, 7);
                FEl(:, 2) = AEl(:, 6);
                FEl(:, 3) = AEl(:, 8);
                FEl(:, 4) = AEl(:, 3);
                FEl(:, 5) = AEl(:, 5);
                FEl(:, 6) = AEl(:, 4);
                FEl(:, 7) = AEl(:, 2);
                FEl(:, 8) = AEl(:, 1);
            end
            if strcmp(Part(i).element{j, 1}, 'C3D6')
                FEl(:, 1) = AEl(:, 3);
                FEl(:, 2) = AEl(:, 2);
                FEl(:, 3) = AEl(:, 6);
                FEl(:, 4) = AEl(:, 1);
                FEl(:, 5) = AEl(:, 5);
                FEl(:, 6) = AEl(:, 4);
            end
            if strcmp(Part(i).element{j, 1}, 'C3D4')
                FEl(:, 1) = AEl(:, 3);
                FEl(:, 2) = AEl(:, 4);
                FEl(:, 3) = AEl(:, 1);
                FEl(:, 4) = AEl(:, 2);
            end
            Part(i).element{j, 2}(:, 2:ColNum) = FEl;
        end
    end
%-----------------Find start line of assembly------------------
    LineIndex = 1;
    tline = InputModel{LineIndex};
    while strncmp('** ASSEMBLY', tline, length('** ASSEMBLY')) == 0
        LineIndex = LineIndex + 1;
        tline = InputModel{LineIndex};
    end
%=================Scan instances================================
    INum = 0;     % Total number of instances
    while strncmp('*End Assembly', tline, length('*End Assembly')) == 0
        if strncmp('*Instance', tline, length('*Instance')) == 1
            INum = INum + 1;
            commaP = regexp(tline, ',');       % Find commas, 'P' for 'Position'
            nameP = regexp(tline, 'name');     % Find 'name'
            partP = regexp(tline, 'part');     % Find 'part'
            Instance(INum).name = tline(nameP + 5:commaP(2) - 1);
            Instance(INum).part = tline(partP + 5:length(tline));
            for i = 1:length(Part)
                if strcmp(Instance(INum).part,Part(i).name)
                    LNode = Part(i).node;     % Local node coordinates
                    Instance(INum).element = Part(i).element;     % CAUTION!!!
                    break
                end
            end
            %-------------Geometrical translation of node coordinates------
            Instance(INum).node = LNode;      % If there is no translation.
            LineIndex = LineIndex + 1;
            tline = str2num(InputModel{LineIndex});
            if isempty(tline) == 0
                TNode = Trans3d(LNode, tline);
                LineIndex = LineIndex + 1;
                tline = str2num(InputModel{LineIndex});
                if isempty(tline) == 0
                    Instance(INum).node = RotAAx3d(TNode, tline(1:3), tline(4:6)...
                        , tline(7));
                else
                    Instance(INum).node = TNode;
                end
            end
        end
        LineIndex = LineIndex + 1;
        tline = InputModel{LineIndex};
    end
end