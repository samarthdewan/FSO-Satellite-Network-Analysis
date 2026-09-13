%% Outage Probability versus Average SNR
% Replicates the paper's uplink/downlink outage comparison under
% thin-cirrus, cirrus, and cumulus cloud conditions.

% Make project functions available regardless of the current folder.
thisFile = mfilename('fullpath');
simulationsFolder = fileparts(thisFile);
projectFolder = fileparts(simulationsFolder);

addpath(projectFolder);
addpath(fullfile(projectFolder, 'models'));

% Load common simulation parameters.
p = parameters();

% Parameters specified in the paper for outage analysis.
elevation_deg = 30;
thresholdSNR_dB = 7;
averageSNR_dB = 0:1:60; % average SNR sweep

% The paper mentions 30 dB as its stated average-SNR reference.
referenceSNR_dB = 30;
referenceIndex = find(averageSNR_dB == referenceSNR_dB, 1);

% Three cloud conditions from the paper.
cloudConditions = struct( ...
    'name', { ...
        'Thin cirrus', ...
        'Cirrus', ...
        'Cumulus' ...
    }, ...
    'concentration_cm3', { ...
        0.5, ...
        0.025, ...
        250 ...
    }, ...
    'liquidWater_g_m3', { ...
        3.128e-4, ...
        0.06405, ...
        1.0 ...
    } ...
);

numberOfConditions = numel(cloudConditions);

% Turbulence is determined by elevation, wavelength, altitude,
% wind speed, and ground-level Cn^2 in the current model.
% It is therefore calculated once and used for every cloud condition.
[sigmaI, sigmaR2] = scintillationIndex(elevation_deg, p);
weibull = weibullParameters(sigmaI);


uplinkOutage = zeros(numberOfConditions, numel(averageSNR_dB));
downlinkOutage = zeros(numberOfConditions, numel(averageSNR_dB));

for k = 1:numberOfConditions

    % Apply this cloud condition to a copy of the parameter structure.
    pCondition = p;
    pCondition.cloudConcentration_cm3 = ...
        cloudConditions(k).concentration_cm3;
    pCondition.liquidWaterContent_g_m3 = ...
        cloudConditions(k).liquidWater_g_m3;

    % Calculate uplink and downlink atmospheric-loss factors.
    loss = atmosphericLoss(elevation_deg, pCondition);

    % Complete attenuation means the optical link is unavailable.
    if loss.uplink <= realmin
        uplinkOutage(k, :) = 1;
    else
        uplinkOutage(k, :) = outageProbability( ...
            averageSNR_dB, thresholdSNR_dB, loss.uplink, weibull);
    end

    if loss.downlink <= realmin
        downlinkOutage(k, :) = 1;
    else
        downlinkOutage(k, :) = outageProbability( ...
            averageSNR_dB, thresholdSNR_dB, loss.downlink, weibull);
    end

end

% Display the outage probability at the paper's 30 dB reference point.
resultsAt30dB = table( ...
    string({cloudConditions.name})', ...
    uplinkOutage(:, referenceIndex), ...
    downlinkOutage(:, referenceIndex), ...
    'VariableNames', { ...
        'Cloud_Condition', ...
        'Uplink_Outage_at_30_dB', ...
        'Downlink_Outage_at_30_dB' ...
    });

disp(resultsAt30dB);

% Use a common colour for each cloud condition in both plots.
colours = lines(numberOfConditions);

% Values smaller than this are displayed at the lower plotting limit.
% Original values remain unchanged in uplinkOutage and downlinkOutage.
plottingFloor = 1e-16;

figure('Color', 'w');
tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

% ---- Uplink outage probability ----
nexttile;
hold on;

for k = 1:numberOfConditions
    semilogy(averageSNR_dB, ...
        max(uplinkOutage(k, :), plottingFloor), ...
        'LineWidth', 2, ...
        'Color', colours(k, :));
end

ax = gca;
ax.YScale = 'log';
ax.YLim = [1e-16, 1];
ax.YTick = 10.^(-16:0);

grid on;
box on;
ylim([plottingFloor, 1]);

xlabel('Average SNR (dB)');
ylabel('Outage Probability');
title('Optical Uplink');
legend({cloudConditions.name}, 'Location', 'southwest');

% ---- Downlink outage probability ----
nexttile;
hold on;

for k = 1:numberOfConditions
    semilogy(averageSNR_dB, ...
        max(downlinkOutage(k, :), plottingFloor), ...
        'LineWidth', 2, ...
        'Color', colours(k, :));
end

ax = gca;
ax.YScale = 'log';
ax.YLim = [1e-16, 1];
ax.YTick = 10.^(-16:0);

grid on;
box on;
ylim([plottingFloor, 1]);

xlabel('Average SNR (dB)');
ylabel('Outage Probability');
title('Optical Downlink');
legend({cloudConditions.name}, 'Location', 'southwest');

sgtitle(sprintf([ ...
    'FSO Outage Probability at %g° Elevation and %g dB SNR Threshold'], ...
    elevation_deg, thresholdSNR_dB));

% Save the figure in the project figures folder.
figuresFolder = fullfile(projectFolder, 'figures');

if ~isfolder(figuresFolder)
    mkdir(figuresFolder);
end

exportgraphics(gcf, ...
    fullfile(figuresFolder, 'outage_vs_snr.png'), ...
    'Resolution', 300);