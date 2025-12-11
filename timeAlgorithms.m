side_lengths = 4:10;
twops_times = zeros(size(side_lengths));
threeps_times = zeros(size(side_lengths));
linpath_times = zeros(size(side_lengths));
cluster_times = zeros(size(side_lengths));
grainsize_times = zeros(size(side_lengths));


for i = 1:length(side_lengths)
    side_length = side_lengths(i);
    fprintf("Side length %d\n", side_length)
    micro = logical(round(rand(side_length) - 0.25));
    
    % Numsber of times to run each algorithm
    num_trials = 1e4;
    
    tic
    for j = 1:num_trials
        Calculate_Two_Point_Statistics_Fourier(micro);
    end
    time = toc;
    twops_times(i) = time;
    fprintf("Two point statistics: %.4f seconds\n", time)

    % tic
    % for i = 1:num_trials
    %     Calculate_Two_Point_Statistics(micro);
    % end
    % time = toc;
    % twops_times(side_length) = time;
    % fprintf("Two point statistics: %.4f seconds\n\n", time)

    tic
    for j = 1:num_trials
        Calculate_Three_Point_Statistics(micro);
    end
    time = toc;
    threeps_times(i) = time;
    fprintf("Three point statistics: %.4f seconds\n", time)

    tic
    for j = 1:num_trials
        Calculate_Lineal_Path_Function(micro);
    end
    time = toc;
    linpath_times(i) = time;
    fprintf("Lineal path function: %.4f seconds\n", time)

    tic
    for j = 1:num_trials
        Calculate_Cluster_Function(micro);
    end
    time = toc;
    cluster_times(i) = time;
    fprintf("Cluster function: %.4f seconds\n", time)
    
    tic
    for j = 1:num_trials
        Calculate_Grain_Size_Distribution(micro);
    end
    time = toc;
    grainsize_times(i) = time;
    fprintf("Grain size distribution: %.4f seconds\n\n", time)
end

RGB = orderedcolors("gem");

f=figure;
hold on
plot(side_lengths, twops_times, Color="k", LineWidth=1)
plot(side_lengths, threeps_times, Color=RGB(1,:), LineWidth=1)
plot(side_lengths, linpath_times, Color=RGB(2,:), LineWidth=1)
plot(side_lengths, cluster_times, Color=RGB(4,:), LineWidth=1)
plot(side_lengths, grainsize_times, Color=RGB(5,:), LineWidth=1)
xlim([4 10])
legend(["Two Point", "Three Point", "Lineal Path", "Cluster", "Grain Size"], Location="northwest")
xlabel("Side Length (pixels)");
ylabel("Calculation Time (s)");
curr_dir = pwd;
set(gca, 'YScale', 'log')
f.Position = [100 100 400 400];
savefig(f, fullfile(curr_dir, "Plots", "algorithmTimes.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "algorithmTimes.png"), Resolution=600);