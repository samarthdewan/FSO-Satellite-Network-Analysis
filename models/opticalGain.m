function [GT, GR] = opticalGain(p)
%OPTICALGAIN Calculate transmitter and receiver optical gains.
%
% Inputs:
%   p  - parameter structure
%
% Outputs:
%   GT - transmitter gain (linear)
%   GR - receiver gain (linear)

GT = 16 / p.divergence^2;

GR = (pi * p.Dr / p.lambda)^2;

end