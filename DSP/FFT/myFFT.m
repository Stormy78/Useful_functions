function [f,P1] = myFFT(Values,Fs)
L = numel(Values);
L = L + mod(L,2); % Replace L with the nearest even integer
Y = fft(Values);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
end