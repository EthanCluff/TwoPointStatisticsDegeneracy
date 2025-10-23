function [autocorr, shifted_microstructures] = Calculate_Two_Point_Statistics(microstructure)
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

    % Find the 180 degree rotated microstructure  
    microstructure_180 = rot90(microstructure, 2);

    % Create containers for two-point statistics and all trivial
    % degeneracies
    autocorr = uint8(n);
    shifted_microstructures = cell(n, n, 2);

    for j = 0:n-1
        for k = 0:n-1
            % Shift the microstructure and rotated microstructure
            shifted_microstructure = circshift(microstructure, [j,k]);
            shifted_microstructure_180 = circshift(microstructure_180, [j,k]);

            % Calculate the autocorrelation
            autocorr(j+1, k+1) = sum(microstructure(:) & shifted_microstructure(:));

            % Store the shifted microstructures for later extraction
            shifted_microstructures{j+1, k+1, 1} = shifted_microstructure;
            shifted_microstructures{j+1, k+1, 2} = shifted_microstructure_180;
        end
    end
end

