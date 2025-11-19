n_values = [6];
vf_values = {
    [18]
};

for i = 1:length(n_values)
    n = n_values(i);
    for j = 1:length(vf_values{i})
        vf = vf_values{i}(j);   % single numeric value each iteration
        Enumerate_Nondirectional_Statistics(n, vf);
        drawnow;
    end
end

