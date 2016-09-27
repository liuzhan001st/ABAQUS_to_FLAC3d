function [ P1 ] = RotAAx3d( P, Sp, Ep, Deg )
% Rotate point array P to P1 about axis defined by start point Sp and end 
% point Ep for degree Deg
% All input and output variables are non-homogeneous
    PNum = size(P, 1);
    P1 = ones(PNum, 4);
    %----------------------Homogenization----------------------
    P(:, 4) = ones(PNum, 1);
    %-------------Translation matrix: Translate axis from Sp to origin-----
    T = eye(4);
    T(4, 1:3) = -Sp;
    EpT = Ep - Sp;      % Translated end point of the axis
    %-------------Translation matrix: Rotate axis to xoz plane------------
    Rx = eye(4);
    Rx(2, 2) = EpT(3) / sqrt(EpT(2)^2 + EpT(3)^2);
    Rx(3, 3) = Rx(2, 2);
    Rx(2, 3) = EpT(2) / sqrt(EpT(2)^2 + EpT(3)^2);
    Rx(3, 2) = -Rx(2, 3);
    if isnan(det(Rx))
        Rx = eye(4);      % Singularity distinguishing for vanishing rot-angle
    end
    %-------------Translation matrix: Rotate axis to coincide with z-axis--
    Ry = eye(4);
    Ry(1, 1) = sqrt(EpT(2)^2 + EpT(3)^2) / norm(EpT);
    Ry(3, 3) = Ry(1, 1);
    Ry(3, 1) = -EpT(1) / norm(EpT);
    Ry(1, 3) = -Ry(3, 1);
    if isnan(det(Ry))
        Ry = eye(4);      % Singularity distinguishing for vanishing rot-angle
    end
    %-------------Translation matrix: Rotate about z axis for degree Deg---
    Rz = eye(4);
    psi = Deg * pi / 180;
    Rz(1, 1) = cos(psi);
    Rz(2, 2) = Rz(1, 1);
    Rz(1, 2) = sin(psi);
    Rz(2, 1) = -sin(psi);
    if isnan(det(Rz))
        Rz = eye(4);      % Singularity distinguishing for vanishing rot-angle
    end    
    %-------------Final translation matrix---------------------------------
    H = T * Rx * Ry * Rz * Ry^(-1) * Rx^(-1) * T^(-1);
    %-------------Translation Operation------------------------------------
    for i = 1:PNum
       P1(i, :) = P(i, :) * H; 
    end
    P1(:, 4) = [];
end