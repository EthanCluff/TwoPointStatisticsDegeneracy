function size_dist = Calculate_Grain_Size_Distribution(microstructure)
    n = size(microstructure, 1);
    counted = false(n);
    size_dist = zeros(n^2, 1);

    num_grains = 0;
    for i = 1:n
        for j = 1:n
            if microstructure(i, j) && ~counted(i, j)
                num_grains = num_grains + 1;
                curr_size = 0;
                
                [curr_size, counted] = Get_Grain_Size(microstructure, counted, i, j, curr_size, n);

                size_dist(num_grains) = curr_size;
            end
        end
    end

    size_dist = sort(size_dist, 'descend');
end

function [curr_size, counted] = Get_Grain_Size(microstructure, counted, i, j, curr_size, n)
    if microstructure(i, j) && ~counted(i, j)
        counted(i, j) = true;
        curr_size = curr_size + 1;

        i_pos = i+1;
        j_pos = j+1;
        i_neg = i-1;
        j_neg = j-1;

        if i_pos > n
            i_pos = 1;
        end
        if j_pos > n
            j_pos = 1;
        end
        if i_neg < 1
            i_neg = n;
        end
        if j_neg < 1
            j_neg = n;
        end

        [curr_size, counted] = Get_Grain_Size(microstructure, counted, i_pos, j, curr_size, n);
        [curr_size, counted] = Get_Grain_Size(microstructure, counted, i_neg, j, curr_size, n);
        [curr_size, counted] = Get_Grain_Size(microstructure, counted, i, j_pos, curr_size, n);
        [curr_size, counted] = Get_Grain_Size(microstructure, counted, i, j_neg, curr_size, n);
    end
end