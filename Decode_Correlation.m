function [autocorr] = Decode_Correlation(encoded_statistics)
    % This function calculates the two-point statistics of a given
    % microstructure. As part of the calculation, it also enumerates all
    % trivial versions of the microstructure, returning those as well.

    % ARGUMENTS:
    % - encoded_statistics: The encoding of the two-point statistics. A
    % character array where letters A+ correspond to 10+

    % RETURNS:
    % - autocorr (uint8 array): An nxn array of 8-bit unsigned integers
    % representing the unnormalized two-point statistics

    % Assume the two-point statistics is square. Extract the side length
    n = sqrt(numel(encoded_statistics));

    % Get the autocorrelation in flattened form. Letters will be incorrect
    autocorr_flattened = uint64(encoded_statistics - '0'); 

    % Find the letters and set their values correctly
    letter_mask = encoded_statistics >= 'A';
    autocorr_flattened(letter_mask) = encoded_statistics(letter_mask) - 'A' + 10;

    % Reshape to the correct dimensions and cast as a uint8 to match
    % argument to encoding scheme
    autocorr = uint8(reshape(autocorr_flattened, n, n));
end

