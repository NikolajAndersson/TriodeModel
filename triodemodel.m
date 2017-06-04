% WDF Triode model
% WAVE DIGITAL SIMULATION OF A VACUUM-TUBE AMPLIFIER by Matti Karjalainen and Jyri Pakarinen
clear; clc; close all;
%V+ = 250 V, Rp = 100 k?, Ro = 1 M?, Co = 10 nF, Rk = 1 k?, Ck = 10 ?F
Fs = 44100;
N = 10000;

gain = 250; % input signal gain parameter
f0 = 1000; % excitation frequency (Hz)
t = 1:N; % time vector for the excitation
 %input = [zeros(1,500),gain.*sin(2*pi*f0/Fs.*t)]; % the excitation signal
input = [gain.*sin(2*pi*f0/Fs.*t)]; % the excitation signal

output = zeros(1,length(input));

R0 = Resistor(1e6)
C0 = Capacitor(10e-9, Fs)

A1 = Series(C0,R0)

V = TerminatedVs(250,100e3)

A2 = Parallel(V,A1)

Rk = Resistor(1e3)

Ck = Capacitor(10e-6,Fs)

A3 = Parallel(Ck,Rk)

A4 = Series(A2,A3)

Vk = 0;
Vg = -2;
Vpk = 250;

triodePortRes = A4.PortRes;

for n = 1:N % run each time sample until N
    V.E = input(n); % read the input signal for the voltage source
    a = WaveUp(A4);  % get the waves up to the root

    % Triode calculations
    % 1. get Vgk(n) = Vg(n) - Vk(n-1)
    Vg = 10;%input(n); % ?
    Vgk = Vg + (-Vk);
    
    [b, Vpk] = triodeNL(a, triodePortRes, Vgk, Vpk);
    %Vpk = newV
    pVpk(n) = Vpk; 
    % down going wave
    WaveDown(A4, b);        
   
    % update Vk, unit delay
    Vk = Voltage(Rk);
    
    output(n) = Voltage(R0); % the output is the voltage over the parallel adaptor A2
    output2(n) = Voltage(Rk);
end

plot(output);% hold on; plot(pVpk)
figure; plot(output2)

%% Test Triode

a = [-10:0.1:10];

Vgk = [-10:0.1:10];
Vpk = 0;
for i = 1:length(a)
[b, Vpk] = triodeNL(a(i), triodePortRes, Vgk(i), Vpk);
pVpk(i) = Vpk;
end
plot(pVpk)

%% 
Vpk = 0:0.1:250;
for i = 1:length(Vpk)
    B(i) = getIp(0,Vpk(i));
    B2(i) = getIp(-1,Vpk(i));
    B3(i) = getIp(-2,Vpk(i));
    B4(i) = getIp(-3,Vpk(i));

end
plot(B); hold on; plot(B2); plot(B3); plot(B4);