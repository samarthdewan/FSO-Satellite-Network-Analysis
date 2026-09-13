function weibull = weibullParameters(sigmaI)
%WEIBULLPARAMETERS Calculate exponentiated-Weibull fading parameters.
%
% Input:
%   sigmaI  - Scintillation index from scintillationIndex.m.
%             Can be a scalar or vector. Must be positive.
%
% Output:
%   weibull - Structure containing:
%             weibull.alpha : first shape parameter
%             weibull.beta  : second shape parameter
%             weibull.eta   : scale parameter
%             weibull.g     : normalisation factor
%
% Implements Eqs. (27)-(29) from Liang et al. (2024).

validateattributes(sigmaI, {'numeric'}, ...
    {'real', 'finite', 'positive'});

% Preallocate outputs so sigmaI may be a vector.
weibull.alpha = zeros(size(sigmaI));
weibull.beta = zeros(size(sigmaI));
weibull.eta = zeros(size(sigmaI));
weibull.g = zeros(size(sigmaI));

for index = 1:numel(sigmaI)

    % Equation (27): first shape parameter.
    alpha = (7.220 * sigmaI(index)^(2/3)) ...
        / gamma(2.487 * sigmaI(index)^(1/3) - 0.104);

    % Equation (28): second shape parameter.
    beta = 1.012 * (alpha * sigmaI(index)^2)^(-0.52) + 0.142;

    % Calculate the mean irradiance for an exponentiated-Weibull
    % random variable with unit scale parameter (eta = 1).
    unitScaleMean = integral( ...
        @(I) 1 - (1 - exp(-I.^beta)).^alpha, ...
        0, Inf, ...
        'RelTol', 1e-8, ...
        'AbsTol', 1e-12);

    % Equation (29) uses g(alpha, beta). Calculate it from the
    % unit-scale mean so that the final fading irradiance has E[I] = 1.
    g = unitScaleMean / (alpha * gamma(1 + 1 / beta));

    % Scale parameter that normalises mean irradiance to one.
    eta = 1 / unitScaleMean;

    weibull.alpha(index) = alpha;
    weibull.beta(index) = beta;
    weibull.eta(index) = eta;
    weibull.g(index) = g;

end

end