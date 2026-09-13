%% Power versus LISL Distance
% Required optical transmit power for the paper's Starlink LISL ranges.

% Make project functions available regardless of the current folder.
thisFile = mfilename('fullpath');
simulationsFolder = fileparts(thisFile);
projectFolder = fileparts(simulationsFolder);

addpath(projectFolder);
addpath(fullfile(projectFolder, 'models'));

% Load parameters and calculate the ISL link budget.
p = parameters();
distance_km = p.LISLRanges_km;

link = linkBudgetISL(distance_km, p);
requiredPower_mW = link.requiredTransmitPower_W * 1e3;

% Display numerical results.
resultsTable = table( ...
    distance_km(:), ...
    requiredPower_mW(:), ...
    link.requiredTransmitPower_dBm(:), ...
    'VariableNames', { ...
        'LISL_Range_km', ...
        'Required_Transmit_Power_mW', ...
        'Required_Transmit_Power_dBm' ...
    });

disp(resultsTable);

% Plot required transmit power against LISL range.
figure('Color', 'w');

plot(distance_km, requiredPower_mW, '-o', ...
    'LineWidth', 2, ...
    'MarkerSize', 7, ...
    'MarkerFaceColor', [0.20 0.45 0.75]);

grid on;
box on;

xlabel('Laser Inter-Satellite Link Range (km)');
ylabel('Required Transmit Power (mW)');
title('Required LISL Transmit Power versus Link Distance');

% Label each simulated point.
for k = 1:numel(distance_km)
    text(distance_km(k), requiredPower_mW(k), ...
        sprintf('  %.1f mW', requiredPower_mW(k)), ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 9);
end