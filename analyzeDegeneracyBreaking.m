%% Analyze degeneracy breaking for 3 point statistics
tic

ns = [4 5 6];
vfs = {[1 2 3 4 5 6 7 8] [1 2 3 4 5 6 7 8 9 10 11 12] [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");

for i = 1:length(ns)
    % Extract the side length and the volume fractions for this side length
    n = ns(i);
    n_vfs = vfs{i};

    % Iterate through all of the volume fractions
    for j = 1:length(n_vfs)
        % Extract the volume fraction
        vf = n_vfs(j);

        % Create a struct to store the plotting data in
        data_path = fullfile(outputs_path, sprintf("n%d", n), sprintf("vf%d", vf), sprintf("plotting_data_%dx%d_vf%d.mat", n, n, vf));
        plotting_data = load(data_path).plotting_data;

        selected_tps = plotting_data.selected_tps;

        all_micros_enc = selected_tps.micros_enc;

        fprintf("Analyzing %d two-point statistics for n=%d, vf=%d\n", length(all_micros_enc), n, vf)

        for k = 1:length(all_micros_enc)
            micros_enc = all_micros_enc{k};

            unique_3ps = {};

            for l = 1:length(micros_enc)
                micro_enc = micros_enc(l);
                micro = Decode_Microstructure(micro_enc, n);

                three_point_stat = Calculate_Three_Point_Statistics(micro);

                if isempty(unique_3ps)
                    unique_3ps{end+1} = three_point_stat;
                else
                    seen = false;
                    for m = 1:length(unique_3ps)
                        comp_autocorr = unique_3ps{m};
                        if isequal(three_point_stat, comp_autocorr)
                            seen = true;
                            break;
                        end
                    end

                    if ~seen
                        unique_3ps{end+1} = three_point_stat;
                    end
                end
            end

            % if length(unique_3ps) ~= length(micros_enc)
            %     disp("Three point statistics did not break the degeneracy!")
            % end
        end
    end
end

toc
%% Analyze degeneracy breaking for lineal path function
tic

ns = [4 5 6];
vfs = {[1 2 3 4 5 6 7 8] [1 2 3 4 5 6 7 8 9 10 11 12] [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");

for i = 1:length(ns)
    % Extract the side length and the volume fractions for this side length
    n = ns(i);
    n_vfs = vfs{i};

    % Iterate through all of the volume fractions
    for j = 1:length(n_vfs)
        % Extract the volume fraction
        vf = n_vfs(j);

        % Create a struct to store the plotting data in
        data_path = fullfile(outputs_path, sprintf("n%d", n), sprintf("vf%d", vf), sprintf("plotting_data_%dx%d_vf%d.mat", n, n, vf));
        plotting_data = load(data_path).plotting_data;

        selected_tps = plotting_data.selected_tps;

        all_micros_enc = selected_tps.micros_enc;

        fprintf("Analyzing %d two-point statistics for n=%d, vf=%d\n", length(all_micros_enc), n, vf)

        for k = 1:length(all_micros_enc)
            micros_enc = all_micros_enc{k};

            unique_lineal_paths = {};

            for l = 1:length(micros_enc)
                micro_enc = micros_enc(l);
                micro = Decode_Microstructure(micro_enc, n);

                lineal_path = Calculate_Lineal_Path_Function(micro);

                if isempty(unique_lineal_paths)
                    unique_lineal_paths{end+1} = lineal_path;
                else
                    seen = false;
                    for m = 1:length(unique_lineal_paths)
                        comp_lineal_path = unique_lineal_paths{m};
                        if isequal(lineal_path, comp_lineal_path)
                            seen = true;
                            break;
                        end
                    end

                    if ~seen
                        unique_lineal_paths{end+1} = lineal_path;
                    end
                end
            end

            if length(unique_lineal_paths) ~= length(micros_enc)
                fprintf("Lineal path function did not break the degeneracy!\n" + ...
                    "%d micros resulted in %d lineal paths\n", length(micros_enc), length(unique_lineal_paths));
            end
        end
    end
end

toc
%% Analyze degeneracy breaking for cluster function
tic

ns = [4 5 6];
vfs = {[1 2 3 4 5 6 7 8] [1 2 3 4 5 6 7 8 9 10 11 12] [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");

for i = 1:length(ns)
    % Extract the side length and the volume fractions for this side length
    n = ns(i);
    n_vfs = vfs{i};

    % Iterate through all of the volume fractions
    for j = 1:length(n_vfs)
        % Extract the volume fraction
        vf = n_vfs(j);

        % Create a struct to store the plotting data in
        data_path = fullfile(outputs_path, sprintf("n%d", n), sprintf("vf%d", vf), sprintf("plotting_data_%dx%d_vf%d.mat", n, n, vf));
        plotting_data = load(data_path).plotting_data;

        selected_tps = plotting_data.selected_tps;

        all_micros_enc = selected_tps.micros_enc;

        fprintf("Analyzing %d two-point statistics for n=%d, vf=%d\n", length(all_micros_enc), n, vf)

        for k = 1:length(all_micros_enc)
            micros_enc = all_micros_enc{k};

            unique_clusters = {};

            for l = 1:length(micros_enc)
                micro_enc = micros_enc(l);
                micro = Decode_Microstructure(micro_enc, n);

                cluster = Calculate_Cluster_Function(micro);

                if isempty(unique_clusters)
                    unique_clusters{end+1} = cluster;
                else
                    seen = false;
                    for m = 1:length(unique_clusters)
                        comp_cluster = unique_clusters{m};
                        if isequal(cluster, comp_cluster)
                            seen = true;
                            break;
                        end
                    end

                    if ~seen
                        unique_clusters{end+1} = cluster;
                    end
                end
            end

            if length(unique_clusters) ~= length(micros_enc)
                fprintf("Cluster function did not break the degeneracy!\n" + ...
                    "%d micros resulted in %d cluster functions\n", length(micros_enc), length(unique_lineal_paths));
            end
        end
    end
end

toc
%% Analyze degeneracy breaking for grain size distribution
tic

ns = [4 5 6];
vfs = {[1 2 3 4 5 6 7 8] [1 2 3 4 5 6 7 8 9 10 11 12] [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");

for i = 1:length(ns)
    % Extract the side length and the volume fractions for this side length
    n = ns(i);
    n_vfs = vfs{i};

    % Iterate through all of the volume fractions
    for j = 1:length(n_vfs)
        % Extract the volume fraction
        vf = n_vfs(j);

        % Create a struct to store the plotting data in
        data_path = fullfile(outputs_path, sprintf("n%d", n), sprintf("vf%d", vf), sprintf("plotting_data_%dx%d_vf%d.mat", n, n, vf));
        plotting_data = load(data_path).plotting_data;

        selected_tps = plotting_data.selected_tps;

        all_micros_enc = selected_tps.micros_enc;

        fprintf("Analyzing %d two-point statistics for n=%d, vf=%d\n", length(all_micros_enc), n, vf)

        for k = 1:length(all_micros_enc)
            micros_enc = all_micros_enc{k};

            unique_dists = {};

            for l = 1:length(micros_enc)
                micro_enc = micros_enc(l);
                micro = Decode_Microstructure(micro_enc, n);

                dist = Calculate_Grain_Size_Distribution(micro);

                if isempty(unique_dists)
                    unique_dists{end+1} = dist;
                else
                    seen = false;
                    for m = 1:length(unique_dists)
                        comp_dist = unique_dists{m};
                        if isequal(dist, comp_dist)
                            seen = true;
                            break;
                        end
                    end

                    if ~seen
                        unique_dists{end+1} = dist;
                    end
                end
            end

            if length(unique_dists) ~= length(micros_enc)
                fprintf("Grain size distribution did not break the degeneracy!\n" + ...
                    "%d micros resulted in %d grain size distributions\n", length(micros_enc), length(unique_lineal_paths));
            end
        end
    end
end

toc