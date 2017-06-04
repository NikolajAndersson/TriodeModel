% WDF Triode model
% WAVE DIGITAL SIMULATION OF A VACUUM-TUBE AMPLIFIER by Matti Karjalainen and Jyri Pakarinen
clear; clc; close all;
%V+ = 250 V, Rp = 100 k?, Ro = 1 M?, Co = 10 nF, Rk = 1 k?, Ck = 10 ?F
Fs = 44100;
N = 10000;

gain = 1; % input signal gain parameter
f0 = 80; % excitation frequency (Hz)
t = 1:N-1; % time vector for the excitation
input = [zeros(1,500),gain.*sin(2*pi*f0/Fs.*t)]; % the excitation signal

output = zeros(1,length(input));

R0 = Resistor(1e6)
C0 = Capacitor(10e-9, Fs)

A1 = Series(C0,R0)

V = VoltageSource(250,100e3)

A2 = Parallel(A1,V)

Rk = Resistor(1e3)

Ck = Capacitor(10e-6,Fs)

A3 = Parallel(Ck,Rk);

A4 = Series(A2,A3)

Vk = 0;
Vg = -2;
Vpk = 0;
triodePortRes = A4.KidLeft.PortRes + A4.KidRight.PortRes;

for n = 1:N % run each time sample until N
    %V.E = input(n); % read the input signal for the voltage source
    a = WaveUp(A4);  % get the waves up to the root
   
    % Triode calculations
    % 1. get Vgk(n) = Vg(n) - Vk(n-1)
    Vg = input(n); % ?
    Vgk = Vg - Vk;
    
    [b, Vpk] = triodeNL(a, triodePortRes, Vgk, Vpk);
    pVpk(n) = Vpk; 
    % down going wave
    WaveDown(A4, b);            % evaluate the wave leaving the diode (root element)
    
    
    % update Vk, unit delay
    Vk = Voltage(Rk);
    
    
    output(n) = Voltage(R0); % the output is the voltage over the parallel adaptor A2
end

plot(output)


%% Test Triode

a = 2;
Vpk = 10;

[b, Vpk] = triodeNL(a, triodePortRes, Vgk, Vpk);