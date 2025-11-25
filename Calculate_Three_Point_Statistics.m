function autocorr = Calculate_Three_Point_Statistics(microstructure)
    % This function calculates the three-point statistics of a given
    % microstructure. As part of the calculation, it also enumerates all
    % trivial versions of the microstructure, returning those as well.

    % ARGUMENTS:
    % - microstructure (logical array): An nxn logical array representing the
    % three-phase microstructure

    % RETURNS:
    % - autocorr (uint8 array): An nxn array of 8-bit unsigned integers
    % representing the unnormalized three-point statistics

    % The length of the microstructure (assumes square microstructure)
    n = size(microstructure, 1);

    % Create container to hold all shifted microstructures
    shifted_microstructures = cell(n);

    for i = 0:n-1
        for j = 0:n-1
            % Shift the microstructure and rotated microstructure
            shifted_microstructure = circshift(microstructure, [i,j]);

            % Store the shifted microstructures for later calculation
            shifted_microstructures{i+1, j+1} = shifted_microstructure;
        end
    end

    autocorr = zeros(n, n, n, n);

    for i = 1:n
        for j = 1:n
            shifted_1 = shifted_microstructures{i, j};
            for k = 1:n
                for l = 1:n
                    shifted_2 = shifted_microstructures{k, l};

                    autocorr(i, j, k, l) = sum(microstructure(:) & shifted_1(:) & shifted_2(:));
                end
            end
        end
    end
end

