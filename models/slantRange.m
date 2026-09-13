function distance_km = slantRange(elevation_deg, p)
%SLANTRANGE Calculate the ground-station-to-satellite slant distance.
%
% Inputs:
%   elevation_deg - Ground-station elevation angle in degrees.
%                   Can be a scalar or vector.
%   p             - Parameter structure from parameters.m containing:
%                   p.earthRadius_km
%                   p.groundStationAltitude_km
%                   p.satelliteAltitude_km
%
% Output:
%   distance_km   - Ground-station-to-satellite distance in km.
%
% Implements Equation (8) from Liang et al. (2024).

validateattributes(elevation_deg, {'numeric'}, ...
    {'real', 'finite', '>=', 0, '<=', 90});

requiredFields = { ...
    'earthRadius_km', ...
    'groundStationAltitude_km', ...
    'satelliteAltitude_km' ...
};

for k = 1:numel(requiredFields)
    if ~isfield(p, requiredFields{k})
        error('Missing parameter: p.%s', requiredFields{k});
    end
end

% R is the distance from Earth's centre to the ground station.
R_km = p.earthRadius_km + p.groundStationAltitude_km;

% H is the satellite altitude above the ground station.
H_km = p.satelliteAltitude_km - p.groundStationAltitude_km;

distance_km = R_km .* ( ...
    sqrt(((R_km + H_km) ./ R_km).^2 - cosd(elevation_deg).^2) ...
    - sind(elevation_deg));

end