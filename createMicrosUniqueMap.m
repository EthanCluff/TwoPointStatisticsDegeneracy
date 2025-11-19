ns = [4 5];% 6];
vfs = {[1 2 3 4 5 6 7 8], [1 2 3 4 5 6 7 8 9 10 11 12]};%, 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18}
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");

for i = 1:length(ns)
    % Extract the side length and the volume fractions for this side length
    n = ns(i);
    n_vfs = vfs{i};

    % Iterate through all of the volume fractions
    for j = 1:length(n_vfs)
        tic
        % Extract the volume fraction
        vf = n_vfs(j);

        % Load the two point statistics map
        input_map_path = fullfile(outputs_path, sprintf("n%d", n), sprintf("vf%d", vf), sprintf("%dx%d_vf%d_2ps.mat", n, n, vf));
        two_point_map = load(input_map_path).two_point_map;

        % Create a hash map. This hash map will link each microstructure to
        % the number of unique microstructures within the set of 2*n^2
        % rotations/translations that it represents
        micro_to_unique = containers.Map(KeyType='uint64', ValueType='uint8');

        % Extract the keys from the two point statistics map and iterate
        % over them
        keys_tpm = keys(two_point_map);
        for k = 1:length(keys_tpm)
            % Extract each key from the map and find the corresponding
            % microstructure digits
            micros = two_point_map(keys_tpm{k});
            num_micros_key = length(micros);

            % Iterate through each microstructure digit
            for l = 1:num_micros_key
                % Decode the microstructure and find how many distinct
                % microstructures it corresponds to
                micro_digit = micros(l);
                micro = Decode_Microstructure(micro_digit, n);
                num_trivial = Count_Distinct_Microstructures(micro);

                % Save the calculated value into the hash map
                micro_to_unique(micro_digit) = num_trivial;
            end
        end

        % Save the hash map in the appropriate location
        save_path = fullfile(outputs_path, sprintf("n%d", n), ...
            sprintf("vf%d", vf), sprintf("m2u_%dx%d_vf%d.mat", n, n, vf));
        save(save_path, 'micro_to_unique');

        % Output that the run has been completed
        micro_area = n^2;
        fprintf("n=%d, vf=%d/%d complete\n", n, vf, micro_area);
        toc
        drawnow('update')
        pause(0.0001)
    end
end