function loss = pointingLoss(p)
%POINTINGLOSS Calculate transmitter and receiver pointing-loss factors.
%
% Input:
%   p    - Parameter structure from parameters.m
%
% Output:
%   loss - Structure containing transmitter, receiver, and combined losses.
%
% Implements Eqs. (4)-(5) of Liang et al. (2024):
% LT = exp(-GT*thetaT^2), LR = exp(-GR*thetaR^2).

if p.thetaT < 0 || p.thetaR < 0
    error('Pointing errors cannot be negative.');
end

[GT, GR] = opticalGain(p);

loss.transmitter = exp(-GT * p.thetaT^2);
loss.receiver = exp(-GR * p.thetaR^2);
loss.combined = loss.transmitter * loss.receiver;

end
