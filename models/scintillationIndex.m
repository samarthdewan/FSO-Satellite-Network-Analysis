function [sigmaI, sigmaR2] = scintillationIndex(elevation_deg, p)
%SCINTILLATIONINDEX Calculate turbulence-induced optical intensity fluctuation.
%
% Inputs:
%   elevation_deg - Ground-station elevation angle in degrees.
%                   Can be a scalar or vector.
%   p             - Parameter structure from parameters.m containing:
%                   p.lambda
%                   p.groundStationAltitude_km
%                   p.satelliteAltitude_km
%                   p.rmsWindSpeed_mps
%                   p.Cn2Ground_m_2_3
%
% Outputs:
%   sigmaI  - Scintillation index.
%   sigmaR2 - Rytov variance.
%
% Implements Eqs. (30)-(32) from Liang et al. (2024).

validateattributes(elevation_deg, {'numeric'}, ...
    {'real', 'finite', '>', 0, '<=', 90});

requiredFields = { ...
    'lambda', ...
    'groundStationAltitude_km', ...
    'satelliteAltitude_km', ...
    'rmsWindSpeed_mps', ...
    'Cn2Ground_m_2_3' ...
};

for k = 1:numel(requiredFields)
    if ~isfield(p, requiredFields{k})
        error('Missing parameter: p.%s', requiredFields{k});
    end
end

% Convert geometry from kilometres to metres.
hE_m = p.groundStationAltitude_km * 1e3;
hS_m = p.satelliteAltitude_km * 1e3;

if hS_m <= hE_m
    error('Satellite altitude must be greater than ground-station altitude.');
end

% Optical wave number: k = 2*pi/lambda.
waveNumber_rad_m = 2 * pi / p.lambda;

% Preallocate outputs so elevation_deg may be a vector.
sigmaI = zeros(size(elevation_deg));
sigmaR2 = zeros(size(elevation_deg));

for index = 1:numel(elevation_deg)

    % Zenith angle = 90 degrees - elevation angle.
    zenith_deg = 90 - elevation_deg(index);

    % Equation (31): numerical integration of Cn^2 through the path.
    turbulenceIntegral = integral( ...
        @(h_m) Cn2(h_m, p) .* (h_m - hE_m).^(5/6), ...
        hE_m, hS_m, ...
        'RelTol', 1e-7, ...
        'AbsTol', 1e-20);

    sigmaR2(index) = 2.25 ...
        * waveNumber_rad_m^(7/6) ...
        * secd(zenith_deg)^(11/6) ...
        * turbulenceIntegral;

    % Equation (30): scintillation index from Rytov variance.
    rytovPower = sigmaR2(index)^(12/5);

    firstTerm = 0.49 * sigmaR2(index) ...
        / (1 + 1.11 * rytovPower)^(7/6);

    secondTerm = 0.51 * sigmaR2(index) ...
        / (1 + 0.69 * rytovPower)^(5/6);

    sigmaI(index) = exp(firstTerm + secondTerm) - 1;

end

end