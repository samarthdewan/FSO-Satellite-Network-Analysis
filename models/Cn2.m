function cn2_m_2_3 = Cn2(altitude_m, p)
%CN2 Calculate the altitude-dependent refractive-index structure parameter.
%
% Inputs:
%   altitude_m  - Altitude above Earth's surface in metres.
%                 Can be a scalar or vector.
%   p           - Parameter structure from parameters.m containing:
%                 p.rmsWindSpeed_mps
%                 p.Cn2Ground_m_2_3
%
% Output:
%   cn2_m_2_3  - Refractive-index structure parameter Cn^2 [m^(-2/3)].
%
% Implements Equation (32) from Liang et al. (2024).

validateattributes(altitude_m, {'numeric'}, ...
    {'real', 'finite', 'nonnegative'});

requiredFields = {'rmsWindSpeed_mps', 'Cn2Ground_m_2_3'};

for k = 1:numel(requiredFields)
    if ~isfield(p, requiredFields{k})
        error('Missing parameter: p.%s', requiredFields{k});
    end
end

h_m = altitude_m;
vr_mps = p.rmsWindSpeed_mps;
C0 = p.Cn2Ground_m_2_3;

% Hufnagel-Valley atmospheric-turbulence model.
highAltitudeTerm = 8.148e-56 .* vr_mps^2 .* h_m.^10 ...
    .* exp(-h_m ./ 1000);

midAltitudeTerm = 2.7e-16 .* exp(-h_m ./ 1500);

groundTerm = C0 .* exp(-h_m ./ 100);

cn2_m_2_3 = highAltitudeTerm + midAltitudeTerm + groundTerm;

end