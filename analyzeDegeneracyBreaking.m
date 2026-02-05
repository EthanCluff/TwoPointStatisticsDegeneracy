%% Plotting Analysis

% Analyze degeneracy breaking for 3 point statistics
tic

ns = [6];
vfs = {[13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");
thps_avg_group_sizes_6 = zeros(size(vfs{end}));
thps_avg_num_groups_6 = zeros(size(vfs{end}));
tps_group_sizes_6 = zeros(size(vfs{end}));
tps_num_groups_6 = ones(size(vfs{end}));

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

        sum_group_size = 0;

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

            group_size = length(micros_enc) / length(unique_3ps);
            sum_group_size = sum_group_size + group_size;

            % if length(unique_3ps) ~= length(micros_enc)
            %     disp("Three point statistics did not break the degeneracy!")
            % end
        end
        avg_group_size = sum_group_size / length(all_micros_enc);
        thps_avg_group_sizes_6(j) = avg_group_size;
        thps_avg_num_groups_6(j) = length(micros_enc) / avg_group_size;

        tps_group_sizes_6(j) = length(micros_enc);
    end
end

toc
% Analyze degeneracy breaking for lineal path function
tic

ns = [6];
vfs = {[13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");
lpf_avg_group_sizes_6 = zeros(size(vfs{end}));
lpf_avg_num_groups_6 = zeros(size(vfs{end}));

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

        sum_group_size = 0;

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

            group_size = length(micros_enc) / length(unique_lineal_paths);
            sum_group_size = sum_group_size + group_size;

            % if length(unique_lineal_paths) ~= length(micros_enc)
            %     fprintf("Lineal path function did not break the degeneracy!\n" + ...
            %         "%d micros resulted in %d lineal paths\n", length(micros_enc), length(unique_lineal_paths));
            % end
        end
        avg_group_size = sum_group_size / length(all_micros_enc);
        lpf_avg_group_sizes_6(j) = avg_group_size;
        lpf_avg_num_groups_6(j) = length(micros_enc) / avg_group_size;
    end
end

toc
% Analyze degeneracy breaking for cluster function
tic

ns = [6];
vfs = {[13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");
cf_avg_group_sizes_6 = zeros(size(vfs{end}));
cf_avg_num_groups_6 = zeros(size(vfs{end}));

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

        sum_group_size = 0;

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

            group_size = length(micros_enc) / length(unique_clusters);
            sum_group_size = sum_group_size + group_size;

            % if length(unique_clusters) ~= length(micros_enc)
            %     fprintf("Cluster function did not break the degeneracy!\n" + ...
            %         "%d micros resulted in %d cluster functions\n", length(micros_enc), length(unique_clusters));
            % end
        end
        avg_group_size = sum_group_size / length(all_micros_enc);
        cf_avg_group_sizes_6(j) = avg_group_size;
        cf_avg_num_groups_6(j) = length(micros_enc) / avg_group_size;
    end
end

toc
% Analyze degeneracy breaking for grain size distribution
tic

ns = [6];
vfs = {[13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");
gsd_avg_group_sizes_6 = zeros(size(vfs{end}));
gsd_avg_num_groups_6 = zeros(size(vfs{end}));

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

        sum_group_size = 0;

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

            group_size = length(micros_enc) / length(unique_dists);
            sum_group_size = sum_group_size + group_size;

            % if length(unique_dists) ~= length(micros_enc)
            %     fprintf("Grain size distribution did not break the degeneracy!\n" + ...
            %         "%d micros resulted in %d grain size distributions\n", length(micros_enc), length(unique_dists));
            % end
        end

        avg_group_size = sum_group_size / length(all_micros_enc);
        gsd_avg_group_sizes_6(j) = avg_group_size;
        gsd_avg_num_groups_6(j) = length(micros_enc) / avg_group_size;
    end
end

toc

curr_dir = pwd;

plot_data_group_sizes = [tps_group_sizes_6; thps_avg_group_sizes_6; lpf_avg_group_sizes_6; cf_avg_group_sizes_6; gsd_avg_group_sizes_6]';
plot_data_num_groups = [tps_num_groups_6; thps_avg_num_groups_6; lpf_avg_num_groups_6; cf_avg_num_groups_6; gsd_avg_num_groups_6]';

num_6 = length(vfs{end});
labels_6 = ["13/36", "14/36", "15/36", "16/36", "17/36", "18/36"];

RGB = orderedcolors("gem");
colors = [[0 0 0]; RGB(1,:); RGB(2,:); RGB(4,:); RGB(5,:)];

f=figure;
b = bar(plot_data_group_sizes, FaceColor="flat");
for k = 1:length(b)
    b(k).CData = colors(k,:);
end
ax = gca;
xticks(1:num_6);
xticklabels(ax, labels_6);
xlabel("Volume Fraction of 6x6 Microstructure", FontSize=14)
ylabel("Average Group Size", FontSize=14)
set(ax, 'YScale', 'log')
ylim([0.9, 3e2])
legend(["Two Point", "Three Point", "Lineal Path", "Cluster", "Grain Size"], Location="northwest", FontSize=12)
ax.FontSize = 12;
f.Position = [100 100 450 400];
savefig(f, fullfile(curr_dir, "Plots", "groupSizeDegeneracyBreak.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "groupSizeDegeneracyBreak.png"), Resolution=600);

f=figure;
b = bar(plot_data_num_groups, FaceColor="flat");
for k = 1:length(b)
    b(k).CData = colors(k,:);
end
ax = gca;
xticks(1:num_6);
xticklabels(ax, labels_6);
xlabel("Volume Fraction of 6x6 Microstructure", FontSize=14)
ylabel("Average Number of Groups", FontSize=14)
set(ax, 'YScale', 'log')
ylim([0.9, 3e2])
legend(["Two Point", "Three Point", "Lineal Path", "Cluster", "Grain Size"], Location="northwest", FontSize=12)
ax.FontSize = 12;
f.Position = [100 100 450 400];
savefig(f, fullfile(curr_dir, "Plots", "numGroupsDegeneracyBreak.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "numGroupsDegeneracyBreak.png"), Resolution=600);

%% Full Analysis

% Analyze degeneracy breaking for 3 point statistics
tic

ns = [4 5 6];
vfs = {[1 2 3 4 5 6 7 8] [1 2 3 4 5 6 7 8 9 10 11 12] [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");
thps_avg_group_sizes = cell(size(vfs));
thps_avg_num_groups = cell(size(vfs));
tps_group_sizes = cell(size(vfs));
tps_num_groups = cell(size(vfs));

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

        sum_group_size = 0;

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

            group_size = length(micros_enc) / length(unique_3ps);
            sum_group_size = sum_group_size + group_size;

            % if length(unique_3ps) ~= length(micros_enc)
            %     disp("Three point statistics did not break the degeneracy!")
            % end
        end
        avg_group_size = sum_group_size / length(all_micros_enc);
        thps_avg_group_sizes{i}(end+1) = avg_group_size;
        thps_avg_num_groups{i}(end+1) = length(micros_enc) / avg_group_size;

        tps_group_sizes{i}(end+1) = length(micros_enc);
        tps_num_groups{i}(end+1) = 1;
    end
end

toc
% Analyze degeneracy breaking for lineal path function
tic

ns = [4 5 6];
vfs = {[1 2 3 4 5 6 7 8] [1 2 3 4 5 6 7 8 9 10 11 12] [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");
lpf_avg_group_sizes = cell(size(vfs));
lpf_avg_num_groups = cell(size(vfs));

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

        sum_group_size = 0;

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

            group_size = length(micros_enc) / length(unique_lineal_paths);
            sum_group_size = sum_group_size + group_size;

            % if length(unique_lineal_paths) ~= length(micros_enc)
            %     fprintf("Lineal path function did not break the degeneracy!\n" + ...
            %         "%d micros resulted in %d lineal paths\n", length(micros_enc), length(unique_lineal_paths));
            % end
        end
        avg_group_size = sum_group_size / length(all_micros_enc);
        lpf_avg_group_sizes{i}(end+1) = avg_group_size;
        lpf_avg_num_groups{i}(end+1) = length(micros_enc) / avg_group_size;
    end
end

toc
% Analyze degeneracy breaking for cluster function
tic

ns = [4 5 6];
vfs = {[1 2 3 4 5 6 7 8] [1 2 3 4 5 6 7 8 9 10 11 12] [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");
cf_avg_group_sizes = cell(size(vfs));
cf_avg_num_groups = cell(size(vfs));

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

        sum_group_size = 0;

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

            group_size = length(micros_enc) / length(unique_clusters);
            sum_group_size = sum_group_size + group_size;

            % if length(unique_clusters) ~= length(micros_enc)
            %     fprintf("Cluster function did not break the degeneracy!\n" + ...
            %         "%d micros resulted in %d cluster functions\n", length(micros_enc), length(unique_clusters));
            % end
        end
        avg_group_size = sum_group_size / length(all_micros_enc);
        cf_avg_group_sizes{i}(end+1) = avg_group_size;
        cf_avg_num_groups{i}(end+1) = length(micros_enc) / avg_group_size;
    end
end

toc
% Analyze degeneracy breaking for grain size distribution
tic

ns = [4 5 6];
vfs = {[1 2 3 4 5 6 7 8] [1 2 3 4 5 6 7 8 9 10 11 12] [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");
gsd_avg_group_sizes = cell(size(vfs));
gsd_avg_num_groups = cell(size(vfs));

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

        sum_group_size = 0;

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

            group_size = length(micros_enc) / length(unique_dists);
            sum_group_size = sum_group_size + group_size;

            % if length(unique_dists) ~= length(micros_enc)
            %     fprintf("Grain size distribution did not break the degeneracy!\n" + ...
            %         "%d micros resulted in %d grain size distributions\n", length(micros_enc), length(unique_dists));
            % end
        end

        avg_group_size = sum_group_size / length(all_micros_enc);
        gsd_avg_group_sizes{i}(end+1) = avg_group_size;
        gsd_avg_num_groups{i}(end+1) = length(micros_enc) / avg_group_size;
    end
end

toc