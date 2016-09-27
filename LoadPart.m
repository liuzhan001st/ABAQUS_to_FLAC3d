function [ Part ] = LoadPart( InputModel )
% Recognizes parts from InputModel
% InputModel is a cell array returned by function ImportInp
% Part is a global struct array:
%   Part=struct('name','','node',[],'element',{})
%   where feild 'element' stores element types and node indexes
%       { 'C3D8R' []
%         'C3D4'  []
%           ...     }
%       [elementID node1 node2 ... ]
%           elementIDs are stored as they may not continuous if there are
%           two or more element types within one part!
    Part = struct('name', '', 'node', [], 'element', {});
        % 'element' is a cell array:{'type1',[];'type2',[];...}
    LineIndex = 1;   % Global line index
    tline = InputModel{LineIndex};
    PNum = 0;         % Total number of parts
%    PNumFlag=0;        % Flag of PNum increament
%====================Scan parts====================
    while strncmp('** ASSEMBLY', tline, length('** ASSEMBLY')) == 0
        PNumFlag = 0;
        %---------------Recognizes a part-------------
        if strncmp('*Part', tline, length('*Part')) == 1
            PNum = PNum + 1;
%            PNumFlag=1;
            Part(PNum).name = InputModel{LineIndex}(length('*Part, name=') + 1:...
                length(InputModel{LineIndex}));
            LineIndex = LineIndex + 2;  % Goto starting line of node data block
            NNum = 0;  % Total number of nodes
            tNode = str2num(InputModel{LineIndex});
            %-----------Load nodes-------------------
            while ~isempty(tNode)
                NNum = NNum + 1;
                Part(PNum).node(NNum, :) = tNode(2: 4);
                LineIndex = LineIndex + 1;
                tNode = str2num(InputModel{LineIndex});
            end
            %-----------Load elements----------------
            tline = InputModel{LineIndex};
            ETNum = 0;      % Total number of element types
            while strncmp('*End Part', tline, length('*End Part')) == 0
                if strncmp('*Element', tline, length('*Element')) == 1
                    ETNum = ETNum + 1;
                    TSIndex = regexp(tline, 'type');
                    Part(PNum).element{ETNum, 1} = InputModel{LineIndex}...
                        (TSIndex + 5:length(InputModel{LineIndex}));
                    LineIndex = LineIndex + 1;
                    tline = InputModel{LineIndex};
                    %----------Load element matrix----------
                    tElement = str2num(tline);
                    ENum = 0;     %Total number of elements of current type
                    while ~isempty(tElement)
                        ENum = ENum + 1;
                        Part(PNum).element{ETNum, 2}(ENum, :) = ...
                            tElement(1:length(tElement));
                        LineIndex = LineIndex + 1;
                        tline = InputModel{LineIndex};
                        tElement = str2num(tline);
                    end
                    LineIndex = LineIndex - 1;
                end
                LineIndex = LineIndex + 1;
                tline = InputModel{LineIndex};
           end
        end
        if PNumFlag == 1
            LineIndex = LineIndex - 1;
        end
        LineIndex = LineIndex + 1;
        tline = InputModel{LineIndex};            
    end
end