function [ b, Vpk ] = triodeNL(a, R0, Vgk,Vpk)
% 12AX7 model with New-Raphson solver
% using Wave Digital Filters

maxIter = 10;   % maximun number of iterations
dx = 1e-6;      % delta x
err =  1e-6;    % error
epsilon = 1e-9; % a value close to 0 to stop the iteration if the equation is converging

iter = 1;        % reset iter to 1
% Newton-Raphson algorithm
while (abs(err) / abs(Vpk) > epsilon )
    pVpk(iter) = Vpk; 
    f = Vpk + R0 * getIp(Vgk,Vpk) - a; % (7)
    df = (Vpk + dx) + R0 * getIp(Vgk, (Vpk + dx)) - a;
    newVpk = Vpk - (dx*f)/(df - f); 
    Vpk = newVpk;
    iter = iter + 1;
    if (iter > maxIter)         % if iter is larger than the maximum nr of iterations
        break;                  % break out from the while loop
    end
end
%plot(pVpk);
b = Vpk - R0 * getIp(Vgk,Vpk);

end

