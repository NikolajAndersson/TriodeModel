% Enhanced triode model
% Enhanced Wave Digital Triode Model for Real-Time Tube Amplifier Emulation
% by J. Pakarinen and M. Karjalainen
Fs = 44100;
N = 10000;

% Ci = 100nF, Ri = 1MOhm, Rg = 20kOhm, Rp = 100kOhm
% Rk = 1kOhm, Ck = 10muF, C0 = 10nF, V+ = 250 V 

Vi = VoltageSource(0,1);
Ci = Capacitor(100e-6,Fs)
Ri = Resistor(1e10);
Rg = Resistor(20e3)

% grid circuit
A1 = Series(Vi, Ci)
A2 = Parallel(A1,Ri)
A3 = Series(A2, Rg)

% Cathode circuit
Rk = Resistor(1e3)
Ck = Capacitor(10e-6, Fs)
A4 = Series(Rk,Ck)

% Plate
V = VoltageSource(250,100e3)
C0 = Capacitor(10e-9,Fs)
R0 = Resistor(8);
T = IdealTransformer(R0,100)

A4 = Series(C0, T)
A5 = Parallel(V,A4)

% Grid to Triode Need this part
A6 = Series(A3, diode)
% Cathode to triode
A7 = Parallel(A6, A4)
% Connect triode to plate
A8 = Series(A7, A5)

