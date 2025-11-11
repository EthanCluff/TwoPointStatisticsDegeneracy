function Enumerate_Nondirectional_Statistics(n, vf)
    % This function requires that the two-point statistics for the chosen 
    % side length and volume fraction already be calculated using the 
    % Enumerate_Statistics.m function. It takes the directional two-point
    % statistics calculated in that function and determines their
    % nondirectional form, creating a new hashmap that shows which
    % directional two-point statistics correspond to the same
    % nondirectional two-point statistic

    % ARGUMENTS:
    % - n (integer): The side length of the microstructure
    % - vf (integer): The number of values of phase "1" in the microstructure

    % RETURNS:
    % No return values

    %%%%%%%IN VF 7 4x4, CHECK THE VALUE THAT 7 0 6 0 6 0 6 ETC IS LINKED
    %%%%%%%WITH

    % Start the timer
    tic

    % Calculate the area of the microstructure
    microstructure_area = n^2;

    % Find the file storing the hashmap for this particular side length and
    % volume fraction
    curr_dir = pwd;
    save_dir = fullfile(curr_dir, "Outputs", sprintf("n%d", n), sprintf("vf%d", vf));
    two_point_map_file = fullfile(save_dir, sprintf("%dx%d_vf%d_2ps.mat", n, n, vf));

    % Throw an error if the two-point statistic hashmap has not been
    % calculated (or if it has been moved or deleted
    if ~exist(two_point_map_file, "file")
        error("The file %s was not found on this device. \nEither the " + ...
            "two-point statistics for side length %d and volume fraction " + ...
            "\n%d/%d have not yet been calculated, or the file has been moved," + ...
            " deleted, or not downloaded.\n", two_point_map_file, n, vf, ...
            microstructure_area)
    end

    % Save the hashmap to the specified location as a .mat file
    load(two_point_map_file, "two_point_map")

    % Create a new map that will map nondirectional two-point statistics to
    % directional two-point statistics
    nondir_to_dir_map = containers.Map(KeyType='char', ValueType='any');

    % Now we need to associate nondirectional two-point statistics with
    % their directional counterparts. Extract all of the directional
    % two-point statistics
    keys_autocorr = keys(two_point_map);

    % Iterate through all of the two-point statistics
    for i = 1:length(keys_autocorr)
        % Extract the key and decode it to get the two-point statistics
        key = keys_autocorr{i};
        autocorr = Decode_Correlation(key);

        % Calculate the nondirectional two-point statistics and get the
        % associated key
        nondir_autocorr = Make_Correlation_Nondirectional(autocorr);
        nondir_key = Encode_Correlation(nondir_autocorr);

        % In the hashmap, the key is the encoded nondirectional two-point
        % statistic, and the value is the encoded directional two-point
        % statistic. Any collisions will result in multiple values for each
        % key.
        if isKey(nondir_to_dir_map, nondir_key)
            existing = nondir_to_dir_map(nondir_key);  % this is already a cell
            existing{end+1} = key;                     % append new key
            nondir_to_dir_map(nondir_key) = existing;  % store back
        else
            nondir_to_dir_map(nondir_key) = {key};    % store as single-element cell
        end
    end

    % Save the hashmap to the specified location as a .mat file
    nondir_to_dir_map_file = fullfile(save_dir, sprintf("nondir_%dx%d_vf%d_2ps.mat", n, n, vf));
    save(nondir_to_dir_map_file, 'nondir_to_dir_map', '-v7.3')

    % Display information about the completed conversion.
    drawnow;
    fprintf("Calculated nondirectional two-point statistics for all " + ...
        "microstructures with side \nlength %d and volume fraction %d/%d. " + ...
        "Output was written to: \n%s.\n", ...
        n, vf, microstructure_area, nondir_to_dir_map_file);
    toc
    drawnow;

end
