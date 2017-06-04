% WDF Triode model
%V+ = 250 V Rp = 100 k? Ro = 1 M? Co = 10 nF Rk = 1 k? Ck = 10 ?F
Fs = 44100;
N = 1000;


R0 = Resistor(1e9)
C0 = Capacitor(1/(2*10e-10*Fs))

A1 = Series(C0,R0)

V = TerminatedVs(0,100e3)

A2 = Parallel(A1,V)

Rk = Resistor(1e3)
Ck = Capacitor(1/(2*10e-7*Fs))

A3 = Parallel(Ck,Rk);

A4 = Series(A2,A3)
for i = 1:N
end