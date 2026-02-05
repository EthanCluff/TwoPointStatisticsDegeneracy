function [autocorr] = Calculate_Two_Point_Statistics_Barebones(microstructure)
    % This function calculates the two-point statistics of a given
    % microstructure. As part of the calculation, it also enumerates all
    % trivial versions of the microstructure, returning those as well.

    % ARGUMENTS:
    % - microstructure (logical array): An nxn logical array representing the
    % two-phase microstructure

    % RETURNS:
    % - autocorr (uint8 array): An nxn array of 8-bit unsigned integers
    % representing the unnormalized two-point statistics
    % - shifted_microstructures (cell array): An nxnx2 array of all trivial
    % degeneracies of the given microstructure. This includes all shifted
    % versions of the microstructure (nxn) and all shifted versions of the
    % 180 degree rotated microstructure (nxn)

    % The length of the microstructure (assumes square microstructure)
    n = uint8(sqrt(numel(microstructure)));

    % Create containers for two-point statistics and all trivial
    % degeneracies
    autocorr = uint8(n);

    for j = 0:n-1
        for k = 0:n-1
            % Shift the microstructure and rotated microstructure
            shifted_microstructure = circshift(microstructure, [j,k]);

            % Calculate the autocorrelation
            autocorr(j+1, k+1) = sum(microstructure(:) & shifted_microstructure(:));
        end
    end
end

