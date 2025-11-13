
%%
% Get all .mat files from folders
current_dir = pwd;
fileList = dir(fullfile(current_dir, '**', '*_2ps.mat'));

totalSums = struct();

for k = 1:numel(fileList)
    filePath = fullfile(fileList(k).folder, fileList(k).name);
    fprintf('Processing: %s\n', filePath);

    % Get n from filename
    tokens = regexp(fileList(k).name, '(\d+)x\d+_vf\d+_2ps\.mat', 'tokens');
    if isempty(tokens)
        warning('Could not parse n from filename: %s', fileList(k).name);
        continue;
    end
    n = str2double(tokens{1}{1});

    % Load the .mat file
    data = load(filePath);

    % Ensure map variable exists
    if isfield(data, 'two_point_map')
        mvals = values(data.two_point_map);
    else
        warning('Missing two_point_map in %s', fileList(k).name);
        continue;
    end

    % Compute totalSum
    totalSum = 0;
    for i = 1:numel(mvals)
        len = numel(mvals{i});
        if len > 1
            totalSum = totalSum + len * 2 * n^2;
        end
    end

    varName = erase(fileList(k).name, '_2ps.mat');
    varName = ['n' varName];  % add prefix to make it valid
    varName = matlab.lang.makeValidName(varName); % extra safety

    totalSums.(varName) = totalSum;
end

%% Plot results
names = fieldnames(totalSums);
values = zeros(numel(names), 1);
for k = 1:numel(names)
    values(k) = totalSums.(names{k});
end

% Sort and plot
[values, sortIdx] = sort(values, 'descend');
names = names(sortIdx);

figure;
bar(values);
set(gca, 'XTick', 1:numel(names), 'XTickLabel', names, 'XTickLabelRotation', 45);
ylabel('Total Sum of 2n^2 terms');
title('Total Sum per .mat file');
grid on;


%% Percentage of degeneracy plot

total_n_4 = 2^16;
total_n_5 = 2^25;
total_n_6 = 2^36;

% Add up deceneracy for each size

pattern = 'n4x4';  % prefix to match
sum_n4x4 = 0;      % accumulator

names = fieldnames(totalSums);

for k = 1:numel(names)
    if startsWith(names{k}, pattern)
        sum_n4x4 = sum_n4x4 + totalSums.(names{k});
    end
end

pattern = 'n5x5';  % prefix to match
sum_n5x5 = 0;      % accumulator

names = fieldnames(totalSums);

for k = 1:numel(names)
    if startsWith(names{k}, pattern)
        sum_n5x5 = sum_n5x5 + totalSums.(names{k});
    end
end

pattern = 'n6x6';  % prefix to match
sum_n6x6 = 0;      % accumulator

names = fieldnames(totalSums);

for k = 1:numel(names)
    if startsWith(names{k}, pattern)
        sum_n6x6 = sum_n6x6 + totalSums.(names{k});
    end
end

Percentage_4x4 = sum_n4x4/total_n_4;
Percentage_5x5 = sum_n5x5/total_n_5;
Percentage_6x6 = sum_n6x6/total_n_6;

Percentages = [Percentage_4x4, Percentage_5x5, Percentage_6x6];
x_label = ["4x4", "5x5", "6x6"];

figure;
bar(x_label,Percentages);
title('Percentage of Dengeneracy');
grid off;