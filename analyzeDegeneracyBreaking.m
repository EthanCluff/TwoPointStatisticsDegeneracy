%% Analyze degeneracy breaking for 3 point statistics

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

                autocorr = Calculate_Three_Point_Statistics(micro);

                if isempty(unique_3ps)
                    unique_3ps{end+1} = autocorr;
                else
                    seen = false;
                    for m = 1:length(unique_3ps)
                        comp_autocorr = unique_3ps{m};
                        if isequal(autocorr, comp_autocorr)
                            seen = true;
                            break;
                        end
                    end

                    if ~seen
                        unique_3ps{end+1} = autocorr;
                    end
                end
            end

            if length(unique_3ps) ~= length(micros_enc)
                disp("Three point statistics did not break the degeneracy!")
            end
        end
    end
end

%% Analyze degeneracy breaking for 3 point statistics

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

                autocorr = Calculate_Three_Point_Statistics(micro);

                if isempty(unique_3ps)
                    unique_3ps{end+1} = autocorr;
                else
                    seen = false;
                    for m = 1:length(unique_3ps)
                        comp_autocorr = unique_3ps{m};
                        if isequal(autocorr, comp_autocorr)
                            seen = true;
                            break;
                        end
                    end

                    if ~seen
                        unique_3ps{end+1} = autocorr;
                    end
                end
            end

            if length(unique_3ps) ~= length(micros_enc)
                disp("Three point statistics did not break the degeneracy!")
            end
        end
    end
end