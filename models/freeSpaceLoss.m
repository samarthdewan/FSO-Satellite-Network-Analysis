function Lps = freeSpaceLoss(distance_km, p)
%FREESPaceLOSS Calculate free-space path-loss factor.
%
% Inputs:
%   distance_km - Satellite-to-satellite distance [km]
%   p           - Parameter structure
%
% Output:
%   Lps         - Free-space path-loss factor (linear)

distance_m = distance_km * 1e3;

Lps = (p.lambda ./ (4*pi*distance_m)).^2;

end