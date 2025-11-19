function num_distinct = Count_Distinct_Microstructures(microstructure)
    n = size(microstructure, 1);

    % Convert microstructure to uint64 to avoid type issues
    microstructure = uint64(microstructure);
    
    % Precompute 180-degree rotation
    microstructure_180 = rot90(microstructure, 2);

    % Preallocate space for all candidate microstructures (2*n^2)
    all_micros = zeros(2*n^2, 1, 'uint64');

    % Linear index counter
    idx = 1;

    % Precompute powers of 2 for binary-to-integer conversion
    powers_of_two = uint64(2).^(uint64(n^2-1:-1:0));

    % Loop over all translations
    for dy = 0:n-1
        for dx = 0:n-1
            % Shift the original and rotated microstructure
            shifted = circshift(microstructure, [dy, dx]);
            shifted_180 = circshift(microstructure_180, [dy, dx]);

            % Flatten and multiply elementwise
            all_micros(idx)   = sum(shifted(:) .* powers_of_two(:));
            all_micros(idx+1) = sum(shifted_180(:) .* powers_of_two(:));

            idx = idx + 2;
        end
    end

    % Count unique microstructures. Store in a uint8, as the largest
    % possible value is 72
    num_distinct = uint8(numel(unique(all_micros)));
end
