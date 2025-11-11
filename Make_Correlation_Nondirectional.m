function [nondir_autocorr] = Make_Correlation_Nondirectional(autocorr)
    % This function calculates the nondirectional two-point statistics
    % given the directional two-point statistics.

    % ARGUMENTS:
    % - autocorr (uint8 array): An nxn array of integers representing the
    % two-point statistics of a microstructure

    % RETURNS:
    % - autocorr (uint8 array): A flattened array where two-point
    % statistics with the same distance from the origin (1,1 in autocorr)
    % have been summed together. Entries are ordered by their distance from
    % the origin

    n = size(autocorr, 1);

    % Upper-triangular indices (i <= j)
    [r, c] = find(triu(true(n)));

    % Squared distances (integer)
    d2 = r.^2 + c.^2;

    % Extract upper-triangle values
    lin_up = sub2ind([n n], r, c);
    vals = autocorr(lin_up);

    % Add mirrored entries for off-diagonal elements
    off = (r ~= c);
    if any(off)
        lin_mirror = sub2ind([n n], c(off), r(off));
        vals(off) = vals(off) + autocorr(lin_mirror);
    end

    % Group by unique squared distance and sum
    [~, ~, ic] = unique(d2);
    sums = accumarray(ic, vals);

    % Convert back to uint8 and return as row vector
    nondir_autocorr = uint8(sums(:)');
end

