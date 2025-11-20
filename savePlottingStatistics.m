ns = [4 5]; %6];
vfs = {[1 2 3 4 5 6 7 8] [1 2 3 4 5 6 7 8 9 10 11 12]};% [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");

for i = 1:length(ns)
    % Extract the side length and the volume fractions for this side length
    n = ns(i);
    n_vfs = vfs{i};

    % Iterate through all of the volume fractions
    for j = 1:length(n_vfs)
        tic
        % Create a struct to store the plotting data in
        plotting_data = struct();

        % Extract the volume fraction and calculate the number of
        % microstructures for this volume fraction
        vf = n_vfs(j);
        micro_area = n^2;
        total_micros = factorial(micro_area) / (factorial(micro_area - vf) * factorial(vf));

        % Load the two point statistics map
        tpm_path = fullfile(outputs_path, sprintf("n%d", n), sprintf("vf%d", vf), sprintf("%dx%d_vf%d_2ps.mat", n, n, vf));
        two_point_map = load(tpm_path).two_point_map;

        % Load the nondirectional two point statistics map
        nondir_path = fullfile(outputs_path, sprintf("n%d", n), sprintf("vf%d", vf), sprintf("nondir_%dx%d_vf%d_2ps.mat", n, n, vf));
        nondir_map = load(nondir_path).nondir_map;

        % Load the micros to unique hash map
        m2u_path = fullfile(outputs_path, sprintf("n%d", n), sprintf("vf%d", vf), sprintf("m2u_%dx%d_vf%d.mat", n, n, vf));
        micro_to_unique = load(m2u_path).micro_to_unique;

        % Initialize the values that we want to store
        total_micros_est_dir = 0;
        total_deg_est_dir = 0;
        dir_total_deg_map = containers.Map(KeyType='uint64', ValueType='double');
        dir_nontriv_deg_map = containers.Map(KeyType='double', ValueType='double');
        selected_tps = struct();
        selected_tps.num_nontriv = 0;

        % Extract the keys from the two point statistics map and iterate
        % over them
        keys_tpm = keys(two_point_map);
        for k = 1:length(keys_tpm)
            % Extract each key from the map and find the corresponding
            % microstructure digits
            curr_key = keys_tpm{k};
            micros = two_point_map(curr_key);
            num_micros_key = length(micros);

            % Keep track of how many times this number of nontrivial
            % degeneracies has happened for histogram purposes
            if isKey(dir_nontriv_deg_map, num_micros_key)
                dir_nontriv_deg_map(num_micros_key) = dir_nontriv_deg_map(num_micros_key) + 1;
            else
                dir_nontriv_deg_map(num_micros_key) = 1;
            end

            % If this is the largest set of nontrivially degenerate
            % microstructures found so far, store it as the two-point
            % statistic we want to keep (as well as all of the
            % microstructures it corresponds to). Store all of the
            % two-point statistics that have the highest amount of
            % nontrivial degeneracy.
            if num_micros_key > selected_tps.num_nontriv
                selected_tps.num_nontriv = num_micros_key;
                selected_tps.two_point_stat_enc = {curr_key};
                selected_tps.micros_enc = {micros};
            elseif num_micros_key == selected_tps.num_nontriv
                selected_tps.two_point_stat_enc{end+1} = curr_key;
                selected_tps.micros_enc{end+1} = micros;
            end

            % Variable to store the total number of trivial and nontrivial
            % degeneracies for this key
            total_num_deg = uint64(0);

            % Iterate through each microstructure digit
            for l = 1:num_micros_key
                % Decode the microstructure and extract how many distinct
                % microstructures it corresponds to from the map
                micro_digit = micros(l);
                num_unique = uint64(micro_to_unique(micro_digit));

                % Update the estimate for total number of microstructures
                total_micros_est_dir = total_micros_est_dir + num_unique;
                
                % If this microstructure has a nontrivial degeneracy, then
                % keep track of that as well
                if num_micros_key > 1
                    total_deg_est_dir = total_deg_est_dir + num_unique;
                end

                total_num_deg = total_num_deg + num_unique;
            end

            % Keep track of how many times this number of trivial and
            % nontrivial degeneracies has occurred (for histogram
            % purposes) 
            if isKey(dir_total_deg_map, total_num_deg)
                dir_total_deg_map(total_num_deg) = dir_total_deg_map(total_num_deg) + 1;
            else
                dir_total_deg_map(total_num_deg) = 1;
            end
        end

        % Throw a warning if the calculation of total microstructures is
        % wrong
        if total_micros_est_dir ~= total_micros
            warning("The directional map did not correctly estimate the total number\n " + ...
                "of microstructures. Estimated %d, actual %d", total_micros_est_dir, total_micros)
        end

        % Save all of the plotting data that has been generated so far
        plotting_data.total_micros_est_dir = total_micros_est_dir;
        plotting_data.total_deg_est_dir = total_deg_est_dir;
        plotting_data.dir_total_deg_map = dir_total_deg_map;
        plotting_data.dir_nontriv_deg_map = dir_nontriv_deg_map;
        plotting_data.selected_tps = selected_tps;

        % Initialize the values that we want to store
        total_micros_est_nondir = 0;
        total_deg_est_nondir = 0;
        nondir_total_deg_map = containers.Map(KeyType='uint64', ValueType='double');
        nondir_nontriv_deg_map = containers.Map(KeyType='double', ValueType='double');

        % Extract the keys from the two point statistics map and iterate
        % over them
        keys_ntpm = keys(nondir_map);
        for k = 1:length(keys_ntpm)
            % Extract each key from the map and find the corresponding
            % microstructure digits
            micros = nondir_map(keys_ntpm{k});
            num_micros_key = length(micros);

            % Keep track of how many times this number of nontrivial
            % degeneracies has happened for histogram purposes
            if isKey(nondir_nontriv_deg_map, num_micros_key)
                nondir_nontriv_deg_map(num_micros_key) = nondir_nontriv_deg_map(num_micros_key) + 1;
            else
                nondir_nontriv_deg_map(num_micros_key) = 1;
            end

            total_num_deg = uint64(0);

            % Iterate through each microstructure digit
            for l = 1:num_micros_key
                % Decode the microstructure and extract how many distinct
                % microstructures it corresponds to from the map
                micro_digit = micros(l);
                num_unique = uint64(micro_to_unique(micro_digit));

                % Update the estimate for total number of microstructures
                total_micros_est_nondir = total_micros_est_nondir + num_unique;
                
                % If this microstructure has a nontrivial degeneracy, then
                % keep track of that as well
                if num_micros_key > 1
                    total_deg_est_nondir = total_deg_est_nondir + num_unique;
                end

                total_num_deg = total_num_deg + num_unique;
            end

            % Keep track of how many times this number of trivial and
            % nontrivial degeneracies has occurred (for histogram
            % purposes) 
            if isKey(nondir_total_deg_map, total_num_deg)
                nondir_total_deg_map(total_num_deg) = nondir_total_deg_map(total_num_deg) + 1;
            else
                nondir_total_deg_map(total_num_deg) = 1;
            end
        end

        % Throw a warning if the calculation of total microstructures is
        % wrong
        if total_micros_est_nondir ~= total_micros
            warning("The nondirectional map did not correctly estimate the total number\n " + ...
                "of microstructures. Estimated %d, actual %d", total_micros_est_nondir, total_micros)
        end

        % Save all of the plotting data that has been generated so far
        plotting_data.total_micros_est_nondir = total_micros_est_nondir;
        plotting_data.total_deg_est_nondir = total_deg_est_nondir;
        plotting_data.nondir_total_deg_map = nondir_total_deg_map;
        plotting_data.nondir_nontriv_deg_map = nondir_nontriv_deg_map;

        % Save the hash map in the appropriate location
        save_path = fullfile(outputs_path, sprintf("n%d", n), ...
            sprintf("vf%d", vf), sprintf("plotting_data_%dx%d_vf%d.mat", n, n, vf));
        save(save_path, 'plotting_data');

        % Output that the run has been completed
        fprintf("Plotting stats for n=%d, vf=%d/%d saved\n", n, vf, micro_area);
        toc
        drawnow('update')
        pause(0.0001)
    end
end
