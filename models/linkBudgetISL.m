function link = linkBudgetISL(distance_km, p)
%LINKBUDGETISL Calculate required power for an optical inter-satellite link.
%
% Inputs:
%   distance_km - Inter-satellite distance [km]; scalar or vector
%   p           - Parameter structure from parameters.m
%
% Output:
%   link        - Structure with required transmit power, losses, and margin.
%                 All fields follow the shape of distance_km.
%
% Implements Eqs. (1)-(6), (23), and (24) from Liang et al. (2024).
% The link margin sets the target received power, then this function finds
% the minimum transmitted power needed to meet that target.

validateattributes(distance_km, {'numeric'}, {'real', 'positive'});

requiredFields = {'etaT', 'etaR', 'PrSensitivity_dBm', 'ISLMargin_dB'};
for k = 1:numel(requiredFields)
    if ~isfield(p, requiredFields{k})
        error('Missing parameter: p.%s', requiredFields{k});
    end
end

[GT, GR] = opticalGain(p);
Lfs = freeSpaceLoss(distance_km, p);
pointing = pointingLoss(p);

requiredReceivedPower_dBm = p.PrSensitivity_dBm + p.ISLMargin_dB;
Pr_W = 1e-3 * 10.^(requiredReceivedPower_dBm / 10);
Pt_W = Pr_W ./ (GT .* GR .* pointing.combined .* Lfs .* p.etaT .* p.etaR);
Pt_dBm = 10 .* log10(Pt_W ./ 1e-3);

link.distance_km = distance_km;
link.transmitGain_dBi = 10 * log10(GT);
link.receiveGain_dBi = 10 * log10(GR);
link.freeSpaceLoss_dB = -10 * log10(Lfs);
link.transmitterPointingLoss_dB = -10 * log10(pointing.transmitter);
link.receiverPointingLoss_dB = -10 * log10(pointing.receiver);
link.requiredReceivedPower_W = Pr_W;
link.requiredReceivedPower_dBm = requiredReceivedPower_dBm;
link.requiredTransmitPower_W = Pt_W;
link.requiredTransmitPower_dBm = Pt_dBm;
link.requiredMargin_dB = p.ISLMargin_dB;

end
