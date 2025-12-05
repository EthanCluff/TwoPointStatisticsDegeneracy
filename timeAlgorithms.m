side_lengths = 1:10;
twops_times = zeros(size(side_lengths));
threeps_times = zeros(size(side_lengths));
linpath_times = zeros(size(side_lengths));
cluster_times = zeros(size(side_lengths));
grainsize_times = zeros(size(side_lengths));


for side_length = side_lengths
    fprintf("Side length %d\n\n", side_length)
    micro = logical(round(rand(side_length) - 0.25));
    
    % Number of times to run each algorithm
    num_trials = 1e4;
    
    tic
    for i = 1:num_trials
        Calculate_Two_Point_Statistics_Fourier(micro);
    end
    time = toc;
    twops_times(side_length) = time;
    fprintf("Two point statistics: %.4f seconds\n\n", time)

    % tic
    % for i = 1:num_trials
    %     Calculate_Two_Point_Statistics(micro);
    % end
    % time = toc;
    % twops_times(side_length) = time;
    % fprintf("Two point statistics: %.4f seconds\n\n", time)

    tic
    for i = 1:num_trials
        Calculate_Three_Point_Statistics(micro);
    end
    time = toc;
    threeps_times(side_length) = time;
    fprintf("Three point statistics: %.4f seconds\n\n", time)

    tic
    for i = 1:num_trials
        Calculate_Lineal_Path_Function(micro);
    end
    time = toc;
    linpath_times(side_length) = time;
    fprintf("Lineal path function: %.4f seconds\n\n", time)

    tic
    for i = 1:num_trials
        Calculate_Cluster_Function(micro);
    end
    time = toc;
    cluster_times(side_length) = time;
    fprintf("Cluster function: %.4f seconds\n\n", time)
    
    tic
    for i = 1:num_trials
        Calculate_Grain_Size_Distribution(micro);
    end
    time = toc;
    grainsize_times(side_length) = time;
    fprintf("Grain size distribution: %.4f seconds\n\n", time)
end

f=figure;
hold on
plot(side_lengths, twops_times)
plot(side_lengths, threeps_times)
plot(side_lengths, linpath_times)
plot(side_lengths, cluster_times)
plot(side_lengths, grainsize_times)
xlim([1 10])
legend(["Two Point", "Three Point", "Lineal Path", "Cluster", "Grain Size"], Location="northwest")
xlabel("Side Length (pixels)", FontSize=16);
ylabel("Calculation Time (s)", FontSize=16);
curr_dir = pwd;
set(gca, 'YScale', 'log')
savefig(f, fullfile(curr_dir, "Plots", "algorithmTimes.fig"))
exportgraphics(f, fullfile(curr_dir, "Plots", "algorithmTimes.png"), Resolution=600);