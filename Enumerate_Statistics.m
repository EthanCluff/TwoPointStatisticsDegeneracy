function Enumerate_Statistics(n, vf)
    % This function calculated the two-point statistics of all two-phase
    % square microstructures of a side length n that have a volume fraction
    % of vf/n.

    % ARGUMENTS:
    % - n (integer): The side length of the microstructure
    % - vf (integer): The number of values of phase "1" in the microstructure

    % RETURNS:
    % No return values

    % Start the timer
    tic

    % Calculate the area of the microstructure
    microstructure_area = n^2;
    
    % Set up all possible combinations
    combinations = uint8(nchoosek(1:microstructure_area, vf));
    num_combinations = size(combinations, 1);
    
    % Set up array to track two-point statistics that have already been
    % calculated
    completed = false(2^microstructure_area,1);
    
    % Create hashmap that maps every unique set of two-point statistics to
    % the microstructures that result in that statistic. Each
    % two-point statistic is encoded as a n^2 element character array,
    % where each character corresponds to one of the unnormalized values of
    % the two-point statistics. Each microstructure is encoded as a single
    % unsigned 64 bit integer. The binary representation of the integer
    % encodes the microstructure
    two_point_map = containers.Map(KeyType='char', ValueType='any');
    
    % Iterate through each possible combination
    for i = 1:num_combinations
        % Convert the combination to an array of 1s and 0s and extract its
        % representation as a 64-bit unsigned integer
        microstructure=false(n);
        microstructure(combinations(i,:))=true;
        microstructure_digit=Get_Digit(microstructure);
    
        % Check if the two-point statistics have already been calculated
        if completed(microstructure_digit)
            continue
        end
    
        [autocorr, shifted_microstructures] = Calculate_Two_Point_Statistics(microstructure);
    
        % Go through all of the trivial shifted microstructures and set 
        % their value in the "completed" array to "true" so they will be
        % skipped
        for j = 1:numel(shifted_microstructures)
            trivial_microstructure = shifted_microstructures{j};
            trivial_digit = Get_Digit(trivial_microstructure);
            completed(trivial_digit) = true;
        end
    
        % Find a unique key for the calculated two-point statistic. Each
        % key is a string with n^2 characters where each character
        % represents a two-point statistics value. Double digit numbers are
        % representated as letters as described in Get_Digit.m
        hash_key = Encode_Correlation(autocorr);
    
        % Store the digit representation of the microstructure in the 
        % hashmap
        if isKey(two_point_map, hash_key)
            two_point_map(hash_key) = [two_point_map(hash_key), microstructure_digit];
        else
            two_point_map(hash_key) = microstructure_digit;
        end
    end

    % Display information about the completed run.
    fprintf("Calculated two-point statistics for all microstructures with " + ...
        "side length %d \nand volume fraction %d/%d. ", n, vf, microstructure_area);
    toc
end