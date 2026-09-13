function p = parameters()
%PARAMETERS Central values used by the FSO satellite-network models.

% Physical constants
p.c = 299792458;                % Speed of light [m/s]

% Optical-terminal parameters (Table 6 of Liang et al., 2024)
p.lambda = 1550e-9;             % Wavelength [m]
p.etaT = 0.8;                   % Transmitter optical efficiency
p.etaR = 0.8;                   % Receiver optical efficiency
p.Dr = 80e-3;                   % Receiver telescope diameter [m]
p.divergence = 15e-6;           % Full transmitter divergence angle [rad]
p.thetaT = 1e-6;                % Transmitter pointing error [rad]
p.thetaR = 1e-6;                % Receiver pointing error [rad]

% Receiver and ISL design target
p.PrSensitivity_dBm = -35.5;    % OOK, 10 Gbps, BER 10^-12 sensitivity [dBm]
p.ISLMargin_dB = 3;             % ISL link margin [dB]

% LISL ranges: Starlink Phase 1 Version 3, from the paper [km]
p.LISLRanges_km = [1575 1731 2000 3000 4000 5016];

% Earth-space geometry for uplink/downlink models
p.earthRadius_km = 6378;          % Earth radius [km]
p.groundStationAltitude_km = 0.1; % Ground-station altitude [km]
p.satelliteAltitude_km = 550;     % Starlink Phase 1 Version 3 altitude [km]

% Atmospheric parameters for uplink/downlink outage analysis
p.troposphereHeight_km = 20;           % Troposphere height [km]
p.cloudConcentration_cm3 = 0.5;        % Thin-cirrus cloud concentration [cm^-3]
p.liquidWaterContent_g_m3 = 3.128e-4;  % Thin-cirrus liquid water content [g/m^3]


% Atmospheric-turbulence parameters [assumed from common Hufnagel-Valley
% turbulence model]
p.rmsWindSpeed_mps = 21;       % RMS ground wind speed [m/s]
p.Cn2Ground_m_2_3 = 1.7e-14;   % Ground refractive-index parameter C0 [m^(-2/3)]

end
