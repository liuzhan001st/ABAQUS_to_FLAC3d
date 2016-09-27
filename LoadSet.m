function [ ElSet ] = LoadSet( InputModel )
% Recognizes ElSets from InputModel and Instances
    ElSet = struct('name', '', 'element', {});
    % ElSet(i).Element={'instance1' [];
    %                   'instance2' [];
    %                   ...            }
    %---------------------Find start line of Elset in Assembly level------
    LineIndex = 1;
    tline = InputModel{LineIndex};
    while ~strcmp(tline, '** ASSEMBLY')
        LineIndex = LineIndex + 1;
        tline = InputModel{LineIndex};
    end
    while ~strncmp(tline, '*Elset', length('*Elset')) && ...
            LineIndex<length(InputModel)
        LineIndex = LineIndex + 1;
        tline = InputModel{LineIndex};
    end
    %=====================Scan Elsets====================================
    ElSNum = 0;       % Total number of ElSets, with homonymous
    while ~strcmp(tline, '*End Assembly')
        if strncmp('*Elset', tline, length('*Elset'))
            ElSNum = ElSNum + 1;
            commaP = regexp(tline, ',');       % Find commas, 'P' for 'Position'
            nameP = regexp(tline, 'elset');    % Find 'elset'
            instP = regexp(tline, 'instance'); % Find 'instance'
            ElSet(ElSNum).name = tline(nameP + 6:commaP(2) - 1);
            tlineL = length(tline);          
            if strcmp('generate', tline(tlineL - 7:tlineL))
                ElSet(ElSNum).element{1, 1} = tline(instP + 9:commaP(3) - 1);  % Load instance name
                LineIndex = LineIndex + 1;
                tline = InputModel{LineIndex};
                LoopI = str2num(tline);       % Loop index values
                ElNum = 0;                    % Total number of elements
                for i = LoopI(1):LoopI(3):LoopI(2)
                    ElNum = ElNum + 1;
                    ElSet(ElSNum).element{1, 2}(ElNum, 1) = i;
                end
            else
                ElSet(ElSNum).element{1, 1} = tline(instP + 9:tlineL);       % Load instance name
                LineIndex = LineIndex + 1;
                tline = InputModel{LineIndex};
                ElIDtmp = str2num(tline);
                ElSet(ElSNum).element{1, 2} = [];
                while ~isempty(ElIDtmp)
                    ElIDS = length(ElSet(ElSNum).element{1, 2}) + 1;     % Starting position of element
                    ElSet(ElSNum).element{1, 2}(...
                        ElIDS:ElIDS + length(ElIDtmp) - 1, 1) = ElIDtmp';
                    LineIndex = LineIndex + 1;
                    tline = InputModel{LineIndex};
                    ElIDtmp = str2num(tline);
                end
                LineIndex = LineIndex - 1;
            end
        end
        LineIndex = LineIndex + 1;
        tline = InputModel{LineIndex};
    end
    %================Merge homonymous sets=================================
    if length(ElSet) <= 1
        return
    end
    ElSNum = 1;
    InstNum = length(ElSet(ElSNum).element(:, 1));
    ElSettmp(ElSNum) = ElSet(1);
    for i = 2:length(ElSet)
        if strcmp(ElSet(i).name, ElSettmp(ElSNum).name)  % Homonymous instances within a set are not considered!!!
            InstNum = InstNum+1;
            ElSettmp(ElSNum).element{InstNum, 1} = ElSet(i).element{1, 1};
            ElSettmp(ElSNum).element{InstNum, 2} = ElSet(i).element{1, 2};
        else
            ElSNum = ElSNum + 1;
            InstNum = length(ElSet(ElSNum).element(:, 1));
            ElSettmp(ElSNum) = ElSet(i);
        end
    end
    ElSet = ElSettmp;
end