function Pout = outageProbability(averageSNR_dB, thresholdSNR_dB, ...
    atmosphericLossFactor, weibull)
% OUTAGEPROBABILITY Calculate optical-link outage probability.
%
% Inputs:
%   averageSNR_dB          - Average electrical SNR in dB.
%                            Can be a scalar or vector.
%   thresholdSNR_dB        - Required SNR threshold in dB.
%   atmosphericLossFactor  - Linear atmospheric-loss factor, La.
%                            Use loss.uplink or loss.downlink from
%                            atmosphericLoss.m. Must be between 0 and 1.
%   weibull                - Structure returned by weibullParameters.m,
%                            containing alpha, beta, and eta.
%
% Output:
%   Pout                   - Outage probability, between 0 and 1.
%
% Implements Equation (39) from Liang et al. (2024).

validateattributes(averageSNR_dB, {'numeric'}, {'real', 'finite'});
validateattributes(thresholdSNR_dB, {'numeric'}, {'real', 'finite'});
validateattributes(atmosphericLossFactor, {'numeric'}, ...
    {'real', 'finite', '>', 0, '<=', 1});

requiredFields = {'alpha', 'beta', 'eta'};

for k = 1:numel(requiredFields)
    if ~isfield(weibull, requiredFields{k})
        error('Missing Weibull parameter: weibull.%s', requiredFields{k});
    end
end

if weibull.alpha <= 0 || weibull.beta <= 0 || weibull.eta <= 0
    error('Weibull alpha, beta, and eta must all be positive.');
end

% Convert SNR values from decibels to linear scale.
averageSNR_linear = 10.^(averageSNR_dB ./ 10);
thresholdSNR_linear = 10.^(thresholdSNR_dB ./ 10);

% Equation (39).
fadingArgument = (thresholdSNR_linear ./ ...
    ((weibull.eta .* atmosphericLossFactor).^2 .* averageSNR_linear)) ...
    .^ (weibull.beta ./ 2);

% -expm1(-x) calculates 1 - exp(-x) accurately, even for small x.
Pout = (-expm1(-fadingArgument)) .^ weibull.alpha;

% Prevent tiny numerical rounding errors outside the valid range.
Pout = min(max(Pout, 0), 1);

end