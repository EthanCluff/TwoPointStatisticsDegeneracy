n_values = [4 5 6];
vf_values = {
    [1 2 3 4 5 6 7 8], ...
    [1 2 3 4 5 6 7 8 9 10 11 12], ...
    [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17]
};

for i = 1:length(n_values)
    n = n_values(i);
    for j = 1:length(vf_values{i})
        vf = vf_values{i}(j);   % single numeric value each iteration
        Enumerate_Nondirectional_Statistics(n, vf);
        drawnow;
    end
end

