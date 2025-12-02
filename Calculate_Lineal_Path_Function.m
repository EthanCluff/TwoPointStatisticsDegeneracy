function lineal_path = Calculate_Lineal_Path_Function(microstructure)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    n = size(microstructure, 1);
    lineal_path = zeros(n, 2);

    for i = 1:n
        for j = 1:n
            shifted = circshift(microstructure, [i-1, j-1]);
            for r = 1:n
                lineal_path(r, 1) = lineal_path(r, 1) + floor(sum(shifted(1:r, 1)) / r);
                lineal_path(r, 2) = lineal_path(r, 2) + floor(sum(shifted(1, 1:r)) / r);
            end
        end
    end
end