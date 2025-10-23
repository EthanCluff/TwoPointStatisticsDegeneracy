function digit = Get_Digit(log_array)
    % This function takes in a microstructure as a logical array and converts
    % it to its representation as a 64 bit digit

    % ARGUMENTS:
    % - log_array (logical array): A logical array representing the
    % two-phase microstructure being analyzed

    % RETURNS:
    % - digit (uint64): The single uint64 digit representing the
    % microstructure

    % Flatten the array
    bits = uint64(log_array(:));

    % Calculate the value of each digit
    powers = uint64(2).^(uint64(0:numel(bits)-1))';

    % Multiply the power by the array, giving a uint64 digit
    digit = sum(bits .* powers, 'native');
end