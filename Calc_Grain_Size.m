function [grainStats, equivStats] = Calc_Grain_Size(decodedResults)
% CALC_GRAIN_SIZE Compute grain size statistics and identify non-unique microstructures
%
%   [grainStats, equivStats] = calc_grain_size(decodedResults)
%
%   Inputs:
%       decodedResults - Struct with fields named like 'n_6x6_vf18', each
%                        containing a cell array of microstructure matrices
%
%   Outputs:
%       grainStats - Struct containing grain size distributions for each
%                    microstructure
%       equivStats - Struct containing uniqueness analysis for each field

    grainStats = struct();   % Output container

    fields = fieldnames(decodedResults);

    for f = 1:numel(fields)
        fieldName = fields{f};
        micros = decodedResults.(fieldName);   % this is a cell array
        numMicros = numel(micros);
        
        grainStats.(fieldName) = cell(1, numMicros);

        for i = 1:numMicros
            ms = micros{i};   % decoded microstructure matrix

            % --- Ensure grain labels (convert binary to region labels) ---
            if islogical(ms) || numel(unique(ms)) == 2
                ms = bwlabel_periodic(ms);
            end

            % --- Compute grain properties ---
            props = regionprops(ms, "Area");
            grainSizes = [props.Area];

            % --- Store results ---
            grainStats.(fieldName){i}.grainSizes = grainSizes;
            grainStats.(fieldName){i}.numGrains = numel(grainSizes);

            % Also store histogram bins (optional)
            [counts, edges] = histcounts(grainSizes, "BinMethod", "fd");
            grainStats.(fieldName){i}.histCounts = counts;
            grainStats.(fieldName){i}.histEdges = edges;
        end
    end

    fprintf("Grain size distributions computed for all microstructures.\n");

    % ==========================================================
    % Compare grain size statistics between microstructures
    % ==========================================================
    fields = fieldnames(grainStats);
    equivStats = struct();

    for f = 1:numel(fields)
        fieldName = fields{f};

        msStats = grainStats.(fieldName);   % cell array for this n/vf
        numMicros = numel(msStats);

        % Create canonical string representation of grain sizes
        canonStrings = strings(numMicros,1);

        for i = 1:numMicros
            gs = msStats{i}.grainSizes;

            % Sort for canonical representation
            gs_sorted = sort(gs);

            % Convert to compact string key
            canonStrings(i) = join(string(gs_sorted), "_");
        end

        % Find unique grain size distributions and groups
        [uniqueKeys, ~, idxGroups] = unique(canonStrings);

        numUnique = numel(uniqueKeys);
        groupCounts = accumarray(idxGroups, 1);

        % Store results
        equivStats.(fieldName).uniqueStats = uniqueKeys;
        equivStats.(fieldName).counts = groupCounts;
        equivStats.(fieldName).groups = idxGroups;
        equivStats.(fieldName).numUnique = numUnique;
        equivStats.(fieldName).numMicros = numMicros;

        fprintf("\n%s:\n", fieldName);
        fprintf("  Microstructures: %d\n", numMicros);
        fprintf("  Unique grain-size distributions: %d\n", numUnique);

        % Optional: print groups
        for g = 1:numUnique
            fprintf("    Group %d: %d microstructures\n", g, groupCounts(g));
        end
    end

    % ==========================================================
    % Plot number of non-unique microstructures for each (n, vf)
    % ==========================================================
    fields = fieldnames(equivStats);

    sizes = zeros(numel(fields),1);
    vfs   = zeros(numel(fields),1);
    nonUniqueCounts = zeros(numel(fields),1);

    for f = 1:numel(fields)
        fieldName = fields{f};

        % Extract n and vf from fieldName pattern: n_6x6_vf18
        tokens = regexp(fieldName, 'n_plotting_data_(\d+)x\d+_vf(\d+)', 'tokens');
        if isempty(tokens)
            warning("Could not parse field name: %s", fieldName);
            continue;
        end

        n  = str2double(tokens{1}{1});
        vf = str2double(tokens{1}{2});

        sizes(f) = n;
        vfs(f)   = vf;

        totalMicros = equivStats.(fieldName).numMicros;
        numUnique   = equivStats.(fieldName).numUnique;

        nonUniqueCounts(f) = totalMicros - numUnique;
    end

    % Sort bars by size then vf
    [~, sortIdx] = sortrows([sizes vfs]);
    sizes = sizes(sortIdx);
    vfs = vfs(sortIdx);
    nonUniqueCounts = nonUniqueCounts(sortIdx);
    labels = strings(numel(sizes),1);

    for i = 1:numel(sizes)
        labels(i) = sprintf('n=%d, vf=%d', sizes(i), vfs(i));
    end

    %% -------- Plot --------
    figure;
    bar(nonUniqueCounts, 'FaceColor',[0.2 0.4 0.8]);

    set(gca, 'XTick', 1:numel(labels), 'XTickLabel', labels, 'XTickLabelRotation', 45);
    ylabel('Number of Non-Unique Microstructures');
    title('Grain Size Distribution: Number of Degenerate Microstructures Remaining');
    grid on;

    % ==========================================================
    % Nested function: bwlabel_periodic
    % ==========================================================
    function L = bwlabel_periodic(BW)
    % BWLABEL_PERIODIC  Connected-component labeling with periodic boundaries.

        BW = logical(BW);
        [ny, nx] = size(BW);

        % ----------------------------------------------------------
        % 1. Tile 3×3 grid to allow wrap-around connectivity
        % ----------------------------------------------------------
        big = repmat(BW, 3, 3);   % size (3*ny, 3*nx)

        % ----------------------------------------------------------
        % 2. Label the large tiled image normally
        % ----------------------------------------------------------
        Lbig = bwlabel(big, 8);

        % Center tile
        Lcenter = Lbig(ny+1:2*ny, nx+1:2*nx);

        % ----------------------------------------------------------
        % 3. Extract all 9 tile blocks for wrap resolution
        % ----------------------------------------------------------
        tiles = cell(3,3);
        for i = 1:3
            for j = 1:3
                tiles{i,j} = Lbig((i-1)*ny+1:i*ny, (j-1)*nx+1:j*nx);
            end
        end

        % ----------------------------------------------------------
        % 4. Union-Find Setup
        % ----------------------------------------------------------
        maxLabel = max(Lbig(:));
        parent = 1:maxLabel;

        function r = find_root(x)
            while parent(x) ~= x
                x = parent(x);
            end
            r = x;
        end

        function union_labels(a,b)
            ra = find_root(a);
            rb = find_root(b);
            if ra ~= rb
                parent(rb) = ra;   % merge
            end
        end

        % ----------------------------------------------------------
        % 5. Merge wrapped labels across periodic boundaries
        % ----------------------------------------------------------
        for i = 1:ny
            for j = 1:nx
                % label in the center block
                lbl = Lcenter(i,j);

                % labels in all 9 tiles at the same logical position
                labels = [
                    tiles{1,1}(i,j), tiles{1,2}(i,j), tiles{1,3}(i,j);
                    tiles{2,1}(i,j), lbl,             tiles{2,3}(i,j);
                    tiles{3,1}(i,j), tiles{3,2}(i,j), tiles{3,3}(i,j)
                ];

                labels = unique(labels(labels > 0));  % remove zeros

                % union all of them under one representative
                for k = 2:length(labels)
                    union_labels(labels(1), labels(k));
                end
            end
        end

        % ----------------------------------------------------------
        % 6. Apply label compression
        % ----------------------------------------------------------
        for k = 1:maxLabel
            parent(k) = find_root(k);
        end
        
        % Map center tile labels to final periodic labels
        L = Lcenter;                % preserve zeros
        mask = Lcenter > 0;         % only remap valid labels
        L(mask) = parent(Lcenter(mask));

    end

end
