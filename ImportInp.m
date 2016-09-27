function [ InputModel ] = ImportInp( InputFileName )
% Read .inp file named InputFileName
% InputFileName is a string
    fid = fopen(InputFileName);
    InputModel = cell(1e6, 1);
    i = 0;
    tline = fgetl(fid);
    while ischar(tline)
        i = i + 1;
        InputModel{i} = tline;
        tline = fgetl(fid);
    end
    fclose(fid);
    InputModel = InputModel(1:i);
end

