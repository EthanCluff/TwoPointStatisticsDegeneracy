ns = [4 5 6];
vfs = {[1 2 3 4 5 6 7 8] [1 2 3 4 5 6 7 8 9 10 11 12] [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");

num_outputs = length(vfs{1}) + length(vfs{2}) + length(vfs{3});

fracs_deg_dir = zeros(size(ns));
fracs_deg_nondir = zeros(size(ns));

vf_fracs_deg_dir = zeros(1, num_outputs);
vf_fracs_deg_nondir = zeros(1, num_outputs);
vf_total_micros_dir = zeros(1, num_outputs);
vf_total_micros_nondir = zeros(1, num_outputs);

count = 1;

ovr_map_dir = containers.Map(KeyType='uint64', ValueType='double');
ovr_map_nondir = containers.Map(KeyType='uint64', ValueType='double');

for i = 1:length(ns)
    % Extract the side length and the volume fractions for this side length
    n = ns(i);
    n_vfs = vfs{i};

    deg_dir = 0;
    micros_dir = 0;
    deg_nondir = 0;
    micros_nondir = 0;

    % Iterate through all of the volume fractions
    for j = 1:length(n_vfs)
        map_dir = containers.Map(KeyType='uint64', ValueType='double');
        map_nondir = containers.Map(KeyType='uint64', ValueType='double');

        % Extract the volume fraction
        vf = n_vfs(j);

        % Create a struct to store the plotting data in
        data_path = fullfile(outputs_path, sprintf("n%d", n), sprintf("vf%d", vf), sprintf("plotting_data_%dx%d_vf%d.mat", n, n, vf));
        plotting_data = load(data_path).plotting_data;

        curr_micros_dir = plotting_data.total_micros_est_dir;
        micros_dir = micros_dir + curr_micros_dir;
        curr_deg_dir = plotting_data.total_deg_est_dir;
        deg_dir = deg_dir + curr_deg_dir;
        curr_frac_dir = double(curr_deg_dir) / double(curr_micros_dir);

        curr_micros_nondir = plotting_data.total_micros_est_nondir;
        micros_nondir = micros_nondir + curr_micros_nondir;
        curr_deg_nondir = plotting_data.total_deg_est_nondir;
        deg_nondir = deg_nondir + curr_deg_nondir;
        curr_frac_nondir = double(curr_deg_nondir) / double(curr_micros_nondir);

        vf_fracs_deg_dir(count) = curr_frac_dir;
        vf_total_micros_dir(count) = curr_micros_dir;

        vf_fracs_deg_nondir(count) = curr_frac_nondir;
        vf_total_micros_nondir(count) = curr_micros_nondir;

        count = count + 1;

        dir_nontriv_deg_map = plotting_data.dir_nontriv_deg_map;
        map_keys = keys(dir_nontriv_deg_map);
        for k = 1:length(map_keys)
            curr_key = map_keys{k};
            if isKey(map_dir, curr_key)
                map_dir(curr_key) = map_dir(curr_key) + dir_nontriv_deg_map(curr_key);
                ovr_map_dir(curr_key) = ovr_map_dir(curr_key) + dir_nontriv_deg_map(curr_key);
            else
                map_dir(curr_key) = dir_nontriv_deg_map(curr_key);
                ovr_map_dir(curr_key) = dir_nontriv_deg_map(curr_key);
            end
        end

        nondir_nontriv_deg_map = plotting_data.nondir_nontriv_deg_map;
        map_keys = keys(nondir_nontriv_deg_map);
        for k = 1:length(map_keys)
            curr_key = map_keys{k};
            if isKey(map_nondir, curr_key)
                map_nondir(curr_key) = map_nondir(curr_key) + nondir_nontriv_deg_map(curr_key);
                ovr_map_nondir(curr_key) = ovr_map_nondir(curr_key) + nondir_nontriv_deg_map(curr_key);
            else
                map_nondir(curr_key) = nondir_nontriv_deg_map(curr_key);
                ovr_map_nondir(curr_key) = nondir_nontriv_deg_map(curr_key);
            end
        end

        if n == 6 && vf == 9
            keys_dir = keys(map_dir);

            dir_group_sizes = zeros(size(keys_dir));
            dir_prob_dist = zeros(size(keys_dir));

            for k = 1:length(keys_dir)
                key = double(keys_dir{k});
                val = map_dir(key);

                micro_count = key * val;
                dir_group_sizes(k) = key;
                dir_prob_dist(k) = micro_count;
            end
            
            dir_prob_dist = dir_prob_dist / sum(dir_prob_dist);

            keys_nondir = keys(map_nondir);

            nondir_group_sizes = zeros(size(keys_nondir));
            nondir_prob_dist = zeros(size(keys_nondir));

            for k = 1:length(keys_nondir)
                key = double(keys_nondir{k});
                val = map_nondir(key);

                micro_count = key * val;
                nondir_group_sizes(k) = key;
                nondir_prob_dist(k) = micro_count;
            end
            
            nondir_prob_dist = nondir_prob_dist / sum(nondir_prob_dist);

            xlims = [0 175];
            ylims = [2e-5 1];
            
            % --- build full x grid and fill probabilities (zeros where missing) ---
            x_full = xlims(1):xlims(2);              % full integer grid
            dir_full = zeros(size(x_full));
            nondir_full = zeros(size(x_full));
            
            % assume dir_group_sizes and nondir_group_sizes are integer vectors within xlims
            [~, idxD] = ismember(dir_group_sizes, x_full);
            dir_full(idxD(idxD>0)) = dir_prob_dist;
            
            [~, idxN] = ismember(nondir_group_sizes, x_full);
            nondir_full(idxN(idxN>0)) = nondir_prob_dist;
            
            % Combine into one figure with two tiles
            f = figure;
            tl = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding','compact');
            
            % Shared axis labels
            xlabel(tl, "Degenerate Group Size", FontSize=14);
            ylabel(tl, "Fraction of Microstructures", FontSize=14);
            
            % --- Directional ---
            ax1 = nexttile;
            b1 = bar(ax1, x_full, dir_full, 1, 'EdgeColor','none');   % width 1 -> bars touch
            b1.FaceColor = 'flat';
            
            % optional: color a particular bar (e.g. last nonzero) red
            lastObs = find(dir_full>0, 1, 'last');
            if ~isempty(lastObs)
                defaultColor = repmat([0 0.4470 0.7410], numel(x_full), 1); % default col
                b1.CData = defaultColor;
                b1.CData(lastObs, :) = [1 0 0];
            end
            
            xlim(ax1, xlims);
            ylim(ax1, ylims);
            title(ax1, "Directional", FontSize=14);
            
            % --- Nondirectional ---
            ax2 = nexttile;
            b2 = bar(ax2, x_full, nondir_full, 1, 'EdgeColor','none');
            
            xlim(ax2, xlims);
            ylim(ax2, ylims);
            title(ax2, "Nondirectional", FontSize=14);
            ax2.YAxisLocation = 'right';
            
            % set shared xticks (every 20)
            set([ax1 ax2], 'XTick', 0:20:160);

            set(ax1, 'YScale', 'log');
            set(ax2, 'YScale', 'log');
            
            % link y-axes if you want y linked
            linkaxes([ax1 ax2], 'y');
            h = title(tl, '6x6 Microstructure at Volume Fraction 9/36', FontSize=14);
            h.FontWeight = "bold";

            ax1.FontSize = 12;
            ax2.FontSize = 12;

            % xlims = [0 175];
            % ylims = [0 1];
            % 
            % % Combine into one figure with two tiles
            % f = figure;
            % tl = tiledlayout(1, 2, 'TileSpacing', 'compact');
            % tl.TileSpacing = 'compact';
            % tl.Padding = 'compact';
            % 
            % % Shared axis labels
            % xlabel(tl, "Degenerate Group Size");
            % ylabel(tl, "Fraction of Microstructures");
            % 
            % % --- Directional ---
            % ax1 = nexttile;
            % b = bar(dir_group_sizes, dir_prob_dist, 1);
            % RGB = orderedcolors("gem");
            % b.FaceColor = 'flat';
            % b.CData(end,:) = [1 0 0];
            % % set(gca, 'YScale', 'log');
            % xlim(xlims);
            % ylim(ylims);
            % title("Directional");
            % 
            % 
            % % --- Nondirectional ---
            % ax2 = nexttile;
            % bar(nondir_group_sizes, nondir_prob_dist, 1);
            % % set(gca, 'YScale', 'log');
            % xlim(xlims);
            % ylim(ylims);
            % title("Nondirectional");
            % 
            % ax2.YAxisLocation = 'right';
            % 
            % % Link y-axes
            % linkaxes([ax1 ax2], 'y');
            % 
            % Save combined figure
            f.Position = [100 100 700 400];
            savefig(f, fullfile(curr_dir, "Plots", sprintf("degGroupBreakdown_n%dvf%d.fig", n, vf)));
            exportgraphics(f, fullfile(curr_dir, "Plots", sprintf("degGroupBreakdown_n%dvf%d.png", n, vf)), Resolution=600);
        end
    end

    fracs_deg_dir(i) = double(deg_dir) / double(micros_dir);
    fracs_deg_nondir(i) = double(deg_nondir) / double(micros_nondir);
end

% f=figure;
% key_list = keys(ovr_map_dir);
% plot_vals = cell2mat(values(ovr_map_dir));
% bar(plot_vals);
% xticks(1:numel(key_list));
% xticklabels(key_list);
% xlabel("Number of Microstructures in Degenerate Group")
% ylabel("Number of Groups")
% title("Degenerate Group Sizes, Directional S_2")
% savefig(f, fullfile(curr_dir, "Plots", "dirDegGroupBreakdown.fig"))
% exportgraphics(f, fullfile(curr_dir, "Plots", "dirDegGroupBreakdown.png"), Resolution=600);
% 
% f=figure;
% key_list = keys(ovr_map_nondir);
% plot_vals = cell2mat(values(ovr_map_nondir));
% bar(plot_vals);
% xticks(1:numel(key_list));
% xticklabels(key_list);
% plot_vals = cell2mat(values(ovr_map_nondir));
% histogram(plot_vals);
% xlabel("Number of Microstructures in Degenerate Group")
% ylabel("Number of Groups")
% title("Degenerate Group Sizes, Nondirectional S_2")
% savefig(f, fullfile(curr_dir, "Plots", "nondirDegGroupBreakdown.fig"))
% exportgraphics(f, fullfile(curr_dir, "Plots", "nondirDegGroupBreakdown.png"), Resolution=600);

abs_deg_dir = vf_fracs_deg_dir .* vf_total_micros_dir;
abs_deg_dir_log = log10(abs_deg_dir);
abs_deg_nondir = vf_fracs_deg_nondir .* vf_total_micros_nondir;
abs_deg_nondir_log = log10(abs_deg_nondir);

f=figure;
bar(fracs_deg_dir)
xlabel("Microstructure Side Length", FontSize = 14)
ylabel("Fraction of Degeneracy", FontSize = 14)
ylim([0 1])
labels = {"4", "5", "6"};
xticks(1:length(labels));
xticklabels(labels);
% title("Directional S_2 Degeneracy")

ax = gca;
ax.FontSize = 12;

f.Position = [100 100 400 400];
savefig(f, fullfile(curr_dir, "Plots", "dirDegeneracy.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "dirDegeneracy.png"), Resolution=600);

f=figure;
bar(fracs_deg_nondir)
xlabel("Microstructure Side Length", FontSize = 12)
ylabel("Fraction of Degeneracy")
ylim([0 1])
labels = {"4", "5", "6"};
xticks(1:length(labels));
xticklabels(labels);
% title("Nondirectional S_2 Degeneracy")

ax = gca;
ax.FontSize = 12;

f.Position = [100 100 400 400];
savefig(f, fullfile(curr_dir, "Plots", "nondirDegeneracy.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "nondirDegeneracy.png"), Resolution=600);

% Plot the degeneracy broken up by volume fraction (directional)
vf_fracs_4 = vf_fracs_deg_dir(1:8);
vf_fracs_5 = vf_fracs_deg_dir(9:20);
vf_fracs_6 = vf_fracs_deg_dir(21:end);

num_4 = length(vf_fracs_4);
num_5 = length(vf_fracs_5);
num_6 = length(vf_fracs_6);

labels_4 = ["1/16", "2/16", "3/16", "4/16", "5/16", "6/16", "7/16", "8/16"];
labels_5 = ["1/25", "2/25", "3/25", "4/25", "5/25", "6/25", "7/25", "8/25", "9/25", "10/25", "11/25", "12/25"];
labels_6 = ["1/36", "2/36", "3/36", "4/36", "5/36", "6/36", "7/36", "8/36", "9/36", "10/36", "11/36", "12/36", "13/36", "14/36", "15/36", "16/36", "17/36", "18/36"];

f = figure;
t = tiledlayout(1, 40);
t.TileSpacing = 'compact';
t.Padding = 'compact';

ax1 = nexttile(1, [1 8]);
b = bar(vf_fracs_4);
b.FaceColor = 'flat';
b.CData = abs_deg_dir_log(1:8).';
clim(ax1, [min(abs_deg_dir_log) max(abs_deg_dir_log)]);
even_idx = 2:2:num_4;
xticks(ax1, even_idx);
xticklabels(ax1, labels_4(even_idx));
xtickangle(ax1, 45);

ax2 = nexttile(10, [1 12]);
b = bar(vf_fracs_5);
b.FaceColor = 'flat';
b.CData = abs_deg_dir_log(9:20).';
clim(ax2, [min(abs_deg_dir_log) max(abs_deg_dir_log)]);
even_idx = 2:2:num_5;
xticks(ax2, even_idx);
xticklabels(ax2, labels_5(even_idx));
xtickangle(ax2, 45);

ax3 = nexttile(23, [1 18]);
b = bar(vf_fracs_6);
b.FaceColor = 'flat';
b.CData = abs_deg_dir_log(21:end).';
clim(ax1, [min(abs_deg_dir_log) max(abs_deg_dir_log)]);
even_idx = 2:2:num_6;
xticks(ax3, even_idx);
xticklabels(ax3, labels_6(even_idx));
xtickangle(ax3, 45);

linkaxes([ax1, ax2, ax3], 'y')

colormap("parula")
cb = colorbar;
cb.Label.String = 'log_{10}(Number of Microstructures)';
cb.FontSize = 12;
cb.Label.FontSize = 14;
   
ax2.YTickLabel = [];        
ax2.YTick = [];   
ax1.YAxisLocation = 'left';
ax3.YAxisLocation = 'right';
ylim([0 1])

xlabel(t, "Volume Fraction", FontSize=14)
ylabel(t, "Fraction of Degeneracy", FontSize=14)
title(ax1, "4x4", FontSize=14)
title(ax2, "5x5", FontSize=14)
title(ax3, "6x6", FontSize=14)

ax1.FontSize = 12;
ax2.FontSize = 12;
ax3.FontSize = 12;

f.Position = [100, 100, 700, 400];
savefig(f, fullfile(curr_dir, "Plots", "dirDegeneracyByVF.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "dirDegeneracyByVF.png"), Resolution=600);

% Plot the degeneracy broken up by volume fraction (nondirectional)
vf_fracs_4 = vf_fracs_deg_nondir(1:8);
vf_fracs_5 = vf_fracs_deg_nondir(9:20);
vf_fracs_6 = vf_fracs_deg_nondir(21:end);

num_4 = length(vf_fracs_4);
num_5 = length(vf_fracs_5);
num_6 = length(vf_fracs_6);

labels_4 = ["1/16", "2/16", "3/16", "4/16", "5/16", "6/16", "7/16", "8/16"];
labels_5 = ["1/25", "2/25", "3/25", "4/25", "5/25", "6/25", "7/25", "8/25", "9/25", "10/25", "11/25", "12/25"];
labels_6 = ["1/36", "2/36", "3/36", "4/36", "5/36", "6/36", "7/36", "8/36", "9/36", "10/36", "11/36", "12/36", "13/36", "14/36", "15/36", "16/36", "17/36", "18/36"];

f = figure;
t = tiledlayout(1, 40);
t.TileSpacing = 'compact';
t.Padding = 'compact';

ax1 = nexttile(1, [1 8]);
b = bar(vf_fracs_4);
b.FaceColor = 'flat';
b.CData = abs_deg_nondir_log(1:8).';
clim(ax1, [min(abs_deg_nondir_log) max(abs_deg_nondir_log)]);
even_idx = 2:2:num_4;
xticks(ax1, even_idx);
xticklabels(ax1, labels_4(even_idx));
xtickangle(ax1, 45);

ax2 = nexttile(10, [1 12]);
b = bar(vf_fracs_5);
b.FaceColor = 'flat';
b.CData = abs_deg_nondir_log(9:20).';
clim(ax2, [min(abs_deg_nondir_log) max(abs_deg_nondir_log)]);
even_idx = 2:2:num_5;
xticks(ax2, even_idx);
xticklabels(ax2, labels_5(even_idx));
xtickangle(ax2, 45);

ax3 = nexttile(23, [1 18]);
b = bar(vf_fracs_6);
b.FaceColor = 'flat';
b.CData = abs_deg_nondir_log(21:end).';
clim(ax1, [min(abs_deg_nondir_log) max(abs_deg_nondir_log)]);
even_idx = 2:2:num_6;
xticks(ax3, even_idx);
xticklabels(ax3, labels_6(even_idx));
xtickangle(ax3, 45);

linkaxes([ax1, ax2, ax3], 'y')

colormap("parula")
cb = colorbar;
cb.Label.String = 'log_{10}(Number of Microstructures)';
cb.FontSize = 12;
cb.Label.FontSize = 14;
   
ax2.YTickLabel = [];        
ax2.YTick = [];   
ax1.YAxisLocation = 'left';
ax3.YAxisLocation = 'right';
ylim([0 1])

xlabel(t, "Volume Fraction", FontSize=14)
ylabel(t, "Fraction of Degeneracy", FontSize=14)
title(ax1, "4x4", FontSize=14)
title(ax2, "5x5", FontSize=14)
title(ax3, "6x6", FontSize=14)

ax1.FontSize = 12;
ax2.FontSize = 12;
ax3.FontSize = 12;

f.Position = [100, 100, 700, 400];
savefig(f, fullfile(curr_dir, "Plots", "nondirDegeneracyByVF.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "nondirDegeneracyByVF.png"), Resolution=600);