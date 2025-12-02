function cluster = Calculate_Cluster_Function(microstructure)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    n = size(microstructure, 1);
    grain_microstructure = zeros(n);
    curr_grain = 0;

        % Directions for 4-connectivity
    dirs = [ -1  0;   % up
              1  0;   % down
              0 -1;   % left
              0  1 ]; % right

    for i = 1:n
        for j = 1:n
            % Only start BFS/DFS on unlabeled grain pixels
            if microstructure(i,j) == 1 && grain_microstructure(i,j) == 0
                curr_grain = curr_grain + 1;

                % BFS queue
                queue = [i, j];
                grain_microstructure(i,j) = curr_grain;

                while ~isempty(queue)
                    [ci, cj] = deal(queue(1,1), queue(1,2));
                    queue(1,:) = [];   % pop

                    % Explore neighbors
                    for d = 1:4
                        ni = ci + dirs(d,1);
                        nj = cj + dirs(d,2);

                        % Apply periodic wrapping
                        if ni < 1, ni = n; end
                        if ni > n, ni = 1; end
                        if nj < 1, nj = n; end
                        if nj > n, nj = 1; end

                        % If same grain and not labeled, label it
                        if microstructure(ni,nj) == 1 && grain_microstructure(ni,nj) == 0
                            grain_microstructure(ni,nj) = curr_grain;
                            queue(end+1,:) = [ni, nj]; %#ok<AGROW>
                        end
                    end
                end
            end
        end
    end

    cluster = zeros(n);

    for i = 1:n
        for j = 1:n
            shifted = circshift(grain_microstructure, [i-1, j-1]);

            cluster(i, j) = sum(sum((grain_microstructure == shifted) & (grain_microstructure > 0) & (shifted > 0)));
        end
    end
end