side_length = 6;
micro = logical(round(rand(side_length) - 0.25));

f = @() Calculate_Two_Point_Statistics_Barebones(micro);

t = timeit(f);

fprintf("Average time for unoptimized: %s\n", t);