tic

% Stats for this run
n = 4;
size = n^2;
vf = 7;

% Set up all possible combinations
combinations = nchoosek(1:size, vf);
num_combinations = size(combinations, 1);

% Set up "completed" hashmap
completed_map = containers.Map();

% Create hashmap for finished microstructures and their two-point
% statistics
two_point_map = containers.Map();

% Iterate through values in "completed" array
for i = 1:num_combinations
    % Convert the combination to an array of 1s and 0s
    microstructure=false(n);
    microstructure(combinations(i,:))=true;
    microstructure_digit=Get_Digit(microstructure);

    % Check if the two-point statistics have already been calculated
    if isKey(completed_map, microstructure_digit)
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
    hash_array = Pack_Key(autocorr);
    hash_key = sprintf('%016x%016x%016x', hash_array(1), hash_array(2), hash_array(3));

    % Store the digit representation of the microstructure in the 
    two_point_map(hash_key) = microstructure_digit;

end

toc

function key_64 = Pack_Key(key_array)
    % key_array: 6x6 uint8, values 0-18
    % Output: 1x3 uint64 array representing the 180-bit key

    key_flat = uint64(key_array(:));  % flatten to 36x1 uint64
    key_64 = zeros(1,3,'uint64');    % 3 uint64 slots = 192 bits total

    bitPos = 0; % bit position in key64 array
    for i = 1:length(key_flat)
        idx = floor(bitPos / 64) + 1; % which uint64 slot
        shift = mod(bitPos,64);       % bit offset within slot
        key_64(idx) = bitor(key_64(idx), bitshift(key_flat(i), shift));

        % handle overflow into next uint64
        if shift > 59  % 64 - 5 = 59, value spans 2 slots
            key_64(idx+1) = bitor(key_64(idx+1), bitshift(key_flat(i), shift-64));
        end
        bitPos = bitPos + 5;
    end
end

% This function takes in a microstructure as a logical array and converts
% it to its representation as a 64 bit digit
function digit = Get_Digit(log_array)
    log_array_flattened = log_array(:);
    digit = uint64(0);
    for j = 1:length(log_array_flattened)
        digit = bitor(digit, bitshift(uint64(log_array_flattened(j)), j-1));
    end
end

% tic
% 
% n = 6;
% number = 1234567473;
% bitmap = logical(bitget(number, 36:-1:1));
% bitmap = reshape(bitmap,6,6)';
% 
% % shifted_bitmaps = cell(n);
% autocorr = uint8(n);
% 
% for i = 0:n-1
%     for k = 0:n-1
%         shifted_bitmap = circshift(bitmap, [iter,k]);
%         autocorr(i+1, k+1) = sum(bitmap(:) & shifted_bitmap(:));
%         % shifted_bitmaps{i+1, j+1} = shifted_bitmap
%     end
% end