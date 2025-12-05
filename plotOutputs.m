ns = [4 5 6];
vfs = {[1 2 3 4 5 6 7 8] [1 2 3 4 5 6 7 8 9 10 11 12] [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18]};
curr_dir = pwd;
outputs_path = fullfile(curr_dir, "Outputs/");

num_outputs = length(vfs{1}) + length(vfs{2}) + length(vfs{3});

fracs_deg_dir = zeros(size(ns));
fracs_deg_nondir = zeros(size(ns));

vf_fracs_deg_dir = zeros(1, num_outputs);
vf_fracs_deg_nondir = zeros(1, num_outputs);

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
        vf_fracs_deg_nondir(count) = curr_frac_nondir;
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

        if n == 6 && vf > 6 && vf < 11
            f=figure;
            group_sizes = cell2mat(keys(map_dir));
            group_counts = cell2mat(values(map_dir));
            stem(group_sizes, group_counts, 'filled')
            % set(gca, 'XScale', 'log')
            set(gca, 'YScale', 'log')
            xlabel("Number of Microstructures in Degenerate Group")
            ylabel("Number of Groups")
            savefig(f, fullfile(curr_dir, "Plots", sprintf("dirDegGroupBreakdown_n%dvf%d.fig", n, vf)))
            exportgraphics(f, fullfile(curr_dir, "Plots", sprintf("dirDegGroupBreakdown_n%dvf%d.png", n, vf)), Resolution=600);
        
            f=figure;
            group_sizes = cell2mat(keys(map_nondir));
            group_counts = cell2mat(values(map_nondir));
            stem(group_sizes, group_counts, 'filled');
            % set(gca, 'XScale', 'log')
            set(gca, 'YScale', 'log')
            xlabel("Number of Microstructures in Degenerate Group")
            ylabel("Number of Groups")
            savefig(f, fullfile(curr_dir, "Plots", sprintf("nondirDegGroupBreakdown_n%dvf%d.fig", n, vf)))
            exportgraphics(f, fullfile(curr_dir, "Plots", sprintf("nondirDegGroupBreakdown_n%dvf%d.png", n, vf)), Resolution=600);
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

f=figure;
bar(fracs_deg_dir)
xlabel("Microstructure Side Length")
ylabel("Fraction of Degeneracy")
ylim([0 1])
labels = {"4", "5", "6"};
xticks(1:length(labels));
xticklabels(labels);
% title("Directional S_2 Degeneracy")
savefig(f, fullfile(curr_dir, "Plots", "dirDegeneracy.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "dirDegeneracy.png"), Resolution=600);

f=figure;
bar(fracs_deg_nondir)
xlabel("Microstructure Side Length")
ylabel("Fraction of Degeneracy")
ylim([0 1])
labels = {"4", "5", "6"};
xticks(1:length(labels));
xticklabels(labels);
% title("Nondirectional S_2 Degeneracy")
savefig(f, fullfile(curr_dir, "Plots", "nondirDegeneracy.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "nondirDegeneracy.png"), Resolution=600);

% Plot the degeneracy broken up by volume fraction (directional)
vf_fracs_4 = vf_fracs_deg_dir(1:8);
vf_fracs_5 = vf_fracs_deg_dir(9:20);
vf_fracs_6 = vf_fracs_deg_dir(21:end);

num_4 = length(vf_fracs_4);
num_5 = length(vf_fracs_5);
num_6 = length(vf_fracs_6);

labels_4 = linspace(0.5/num_4, 0.5, num_4);
labels_5 = linspace(0.5/num_5, 0.5, num_5);
labels_6 = linspace(0.5/num_6, 0.5, num_6);

f = figure;
t = tiledlayout(1, 3);
t.TileSpacing = 'compact';
t.Padding = 'compact';

ax1 = nexttile;
bar(vf_fracs_4);
xticks(1:num_4);
xticklabels(ax1, string(round(labels_4, 3)));
ax1.FontSize = 12;
xtickangle(ax1, 90);

ax2 = nexttile;
bar(vf_fracs_5);
xticks(1:num_5);
xticklabels(ax2, string(round(labels_5, 3)));
ax2.FontSize = 12;
xtickangle(ax2, 90);

ax3 = nexttile;
bar(vf_fracs_6);
xticks(1:num_6);
xticklabels(ax3, string(round(labels_6, 3)));
ax3.FontSize = 12;
xtickangle(ax3, 90);

linkaxes([ax1, ax2, ax3], 'y')
   
ax2.YTickLabel = [];        
ax2.YTick = [];   
ax1.YAxisLocation = 'left';
ax3.YAxisLocation = 'right';
ylim([0 1])

xlabel(t, "Volume Fraction", FontSize=16)
ylabel(t, "Fraction of Degeneracy", FontSize=16)
title(ax1, "n = 4", FontSize=16)
title(ax2, "n = 5", FontSize=16)
title(ax3, "n = 6", FontSize=16)

f.Position = [100, 100, 900, 500];
savefig(f, fullfile(curr_dir, "Plots", "dirDegeneracyByVF.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "dirDegeneracyByVF.png"), Resolution=600);

% Plot the degeneracy broken up by volume fraction (nondirectional)
vf_fracs_4 = vf_fracs_deg_nondir(1:8);
vf_fracs_5 = vf_fracs_deg_nondir(9:20);
vf_fracs_6 = vf_fracs_deg_nondir(21:end);

num_4 = length(vf_fracs_4);
num_5 = length(vf_fracs_5);
num_6 = length(vf_fracs_6);

labels_4 = linspace(0.5/num_4, 0.5, num_4);
labels_5 = linspace(0.5/num_5, 0.5, num_5);
labels_6 = linspace(0.5/num_6, 0.5, num_6);

f = figure;
t = tiledlayout(1, 3);
t.TileSpacing = 'compact';
t.Padding = 'compact';

ax1 = nexttile;
bar(vf_fracs_4);
xticks(1:num_4);
xticklabels(ax1, string(round(labels_4, 3)));
ax1.FontSize = 12;
xtickangle(ax1, 90);

ax2 = nexttile;
bar(vf_fracs_5);
xticks(1:num_5);
xticklabels(ax2, string(round(labels_5, 3)));
ax2.FontSize = 12;
xtickangle(ax2, 90);

ax3 = nexttile;
bar(vf_fracs_6);
xticks(1:num_6);
xticklabels(ax3, string(round(labels_6, 3)));
ax3.FontSize = 12;
xtickangle(ax3, 90);

linkaxes([ax1, ax2, ax3], 'y')
   
ax2.YTickLabel = [];        
ax2.YTick = [];   
ax1.YAxisLocation = 'left';
ax3.YAxisLocation = 'right';
ylim([0 1])

xlabel(t, "Volume Fraction", FontSize=16)
ylabel(t, "Fraction of Degeneracy", FontSize=16)
title(ax1, "n = 4", FontSize=16)
title(ax2, "n = 5", FontSize=16)
title(ax3, "n = 6", FontSize=16)

f.Position = [100, 100, 900, 500];
savefig(f, fullfile(curr_dir, "Plots", "nondirDegeneracyByVF.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "nondirDegeneracyByVF.png"), Resolution=600);