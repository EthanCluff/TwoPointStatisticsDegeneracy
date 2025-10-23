tic

% Stats for this run
n = 4;
microstructure_size = n^2;
vf = 7;

% Set up all possible combinations
combinations = uint8(nchoosek(1:microstructure_size, vf));
num_combinations = size(combinations, 1);

% Set up "completed" hashmap
completed_map = false(2^microstructure_size,1);

% Create hashmap for finished microstructures and their two-point
% statistics
two_point_map = containers.Map(KeyType='char', ValueType='uint64');

% Iterate through values in "completed" array
for i = 1:num_combinations
    % Convert the combination to an array of 1s and 0s
    microstructure=false(n);
    microstructure(combinations(i,:))=true;
    microstructure_digit=Get_Digit(microstructure);

    % Check if the two-point statistics have already been calculated
    if completed_map(microstructure_digit)
        continue
    end

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

    % Go through all of the shifted microstructures and set their value in
    % the hash map to true (they've been completed)
    for j = 1:numel(shifted_microstructures)
        trivial_microstructure = shifted_microstructures{j};
        trivial_digit = Get_Digit(trivial_microstructure);
        completed_map(trivial_digit) = true;
    end

    % Find a unique key for the calculated two-point statistic
    hash_key = Encode_Correlation(autocorr);

    % Store the digit representation of the microstructure in the 
    two_point_map(hash_key) = microstructure_digit;

end

toc

% This function takes in a microstructure as a logical array and converts
% it to its representation as a 64 bit digit
function digit = Get_Digit(log_array)
    bits = uint64(log_array(:));
    powers = uint64(2).^(uint64(numel(bits)-1:-1:0))';
    digit = sum(bits .* powers, 'native');  % keep uint64 precision
end

% This function converts an nxn uint8 array (values 0–18) to a 1×(n^2) 
% char array.
% 0–9  → '0'–'9'
% 10–18 → 'A'–'I'
function chars_out = Encode_Correlation(autocorr)
    % Flatten
    autocorr = autocorr(:);

    % Preallocate
    chars_out = repmat(' ', 1, numel(autocorr));

    % Numeric part (0–9)
    mask_num = autocorr < 10;
    chars_out(mask_num) = char('0' + autocorr(mask_num));

    % Alphabetic part (10–18)
    mask_alpha = autocorr >= 10;
    chars_out(mask_alpha) = char('A' + (autocorr(mask_alpha) - 10));
end