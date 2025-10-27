n_values = 6;
vf_values = {8:18};  % Use cell array for different lengths

for i = 1:length(n_values)
    n = n_values(i);
    for vf = vf_values{i}
        Enumerate_Statistics(n, vf);
	drawnow;
    end
end
