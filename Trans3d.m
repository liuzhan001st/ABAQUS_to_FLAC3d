function [ P1 ] = Trans3d( P, v )
% Translate input point array P to P1 using given translation vector v
    P1 = zeros(size(P, 1), 3);
    for i = 1:size(P, 1)
        P1(i,:) = P(i,:) + v;
    end
end

