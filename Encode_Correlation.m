function encoding = Encode_Correlation(autocorr)
    % This function converts an nxn uint8 array (values 0–18) to a 1×(n^2) 
    % char array.
    % 0–9  → '0'–'9'
    % 10–18 → 'A'–'I'
    
    % ARGUMENTS:
    % - autocorr: The two-point statistics for a microstructure

    % RETURNS:
    % - encoding: The character representation of the given two-point
    % statistics, with the double-digit numbers replaced as described above

    % Flatten the two-point statistics
    autocorr = autocorr(:);

    % Preallocate a character array of the same length
    encoding = repmat(' ', 1, numel(autocorr));

    % Store the single digit numbers as their character representations
    mask_num = autocorr < 10;
    encoding(mask_num) = char('0' + autocorr(mask_num));

    % Store the double digit numbers as a letter of the alphabet, starting 
    % with 'A' 
    mask_alpha = autocorr >= 10;
    encoding(mask_alpha) = char('A' + (autocorr(mask_alpha) - 10));
end

