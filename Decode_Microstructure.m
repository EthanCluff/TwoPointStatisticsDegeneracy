function [microstructure] = Decode_Microstructure(microstructure_digit, n)
    % This function finds the microstructure encoded within a digit. 

    % ARGUMENTS:
    % - microstructure_digit (uint64): The encoding of the microstructure
    % - n (double): The side length of the microstructure. Microstructures 
    % are assumed to be square

    % RETURNS:
    % - microstructure (logical array): The two-phase microstructure, with
    % one phase represented as 0s and the other phase as 1s

    % Get a logical array of the bits of the number, padded out to n^2
    log_array = logical(bitget(microstructure_digit, 1:n^2));

    % Reshape that logical array into the correct microstructure dimensions
    microstructure = reshape(log_array, n, n);
end

