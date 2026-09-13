function loss = atmosphericLoss(elevation_deg, p)
%ATMOSPHERICLOSS Calculate atmospheric attenuation for optical uplink/downlink.
%
% Inputs:
%   elevation_deg - Ground-station elevation angle in degrees.
%                   Can be a scalar or vector.
%   p             - Parameter structure from parameters.m containing:
%                   p.lambda
%                   p.groundStationAltitude_km
%                   p.troposphereHeight_km
%                   p.cloudConcentration_cm3
%                   p.liquidWaterContent_g_m3
%
% Output:
%   loss - Structure containing linear attenuation factors:
%          loss.geometric  : geometrical-scattering loss, Ig
%          loss.mie        : Mie-scattering loss, Im
%          loss.uplink     : uplink atmospheric loss, LA_up
%          loss.downlink   : downlink atmospheric loss, LA_down
%
% Implements Eqs. (10)-(22) from Liang et al. (2024).

validateattributes(elevation_deg, {'numeric'}, ...
    {'real', 'finite', '>', 0, '<=', 90});

requiredFields = { ...
    'lambda', ...
    'groundStationAltitude_km', ...
    'troposphereHeight_km', ...
    'cloudConcentration_cm3', ...
    'liquidWaterContent_g_m3' ...
};

for k = 1:numel(requiredFields)
    if ~isfield(p, requiredFields{k})
        error('Missing parameter: p.%s', requiredFields{k});
    end
end

% Convert wavelength for the equations used in the paper.
lambda_um = p.lambda * 1e6;
lambda_nm = p.lambda * 1e9;

% ---- Mie scattering: Eqs. (10)-(15) ----
a = -0.000545 * lambda_um^2 + 0.002 * lambda_um - 0.0038;
b =  0.00628  * lambda_um^2 - 0.0232 * lambda_um + 0.00439;
c = -0.028    * lambda_um^2 + 0.101  * lambda_um - 0.18;
d = -0.228    * lambda_um^3 + 0.922  * lambda_um^2 ...
    - 1.26 * lambda_um + 0.719;

hE_km = p.groundStationAltitude_km;
rho = a * hE_km^3 + b * hE_km^2 + c * hE_km + d;

mieLoss = exp(-rho ./ sind(elevation_deg));

% ---- Geometrical scattering: Eqs. (16)-(20) ----
N_cm3 = p.cloudConcentration_cm3;
LW_g_m3 = p.liquidWaterContent_g_m3;

visibility_km = 1.002 / (N_cm3 * LW_g_m3)^0.6473;

% Particle-size coefficient from Kim's visibility model.
phi = kimParticleSizeCoefficient(visibility_km);

attenuationCoefficient = (3.91 / visibility_km) ...
    * (lambda_nm / 550)^(-phi);

% Atmospheric path length through the troposphere.
atmosphericPath_km = (p.troposphereHeight_km - hE_km) ...
    ./ sind(elevation_deg);

geometricLoss = exp(-attenuationCoefficient .* atmosphericPath_km);

% The paper uses geometrical scattering for uplink and both
% Mie and geometrical scattering for downlink.
loss.geometric = geometricLoss;
loss.mie = mieLoss;
loss.uplink = geometricLoss;
loss.downlink = mieLoss .* geometricLoss;

% Helpful intermediate values for checking and plotting.
loss.visibility_km = visibility_km;
loss.atmosphericPath_km = atmosphericPath_km;
loss.extinctionRatio = rho;
loss.attenuationCoefficient = attenuationCoefficient;

end


function phi = kimParticleSizeCoefficient(visibility_km)
%KIMPARTICLESIZECOEFFICIENT Particle-size coefficient in Kim's model.

if visibility_km > 50
    phi = 1.6;
elseif visibility_km > 6
    phi = 1.3;
elseif visibility_km > 1
    phi = 0.16 * visibility_km + 0.34;
elseif visibility_km > 0.5
    phi = visibility_km - 0.5;
else
    phi = 0;
end

end