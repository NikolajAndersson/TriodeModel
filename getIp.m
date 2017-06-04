function [ Ip ] = getIp(Vgk, Vpk)
mu = 100;
kx = 1.4;
kg1 = 1060;
kp = 600;
kvb = 300;

E1 = (Vpk/kp) * log10(1 + exp(kp * ((1/mu) + Vgk/sqrt(kvb + Vpk^2)))); % (2)
Ip = ((E1^kx)/kg1)*(1 + sign(E1)); % (3)


end

