function [timeSignal, FitErrProc] = psd2time(PSDinput, timeSignalDurationSec, maxFitErrorProc, debugFlag)
%[timeSignal, FitErrProc] = psd2time(PSDinput, timeSignalDurationSec, maxFitErrorProc, debugFlag)

% timeSignal - timeseries form of converted signal
% PSDinput - struct with two fiels 'freq' and 'ASD'
% timeSignalDurationSec - required duration [sec] of time signal


switch nargin

    case [1,0]
        error('Not Enough Input Variables')
    case 2
        debugFlag = 0;
        maxFitErrorProc = 2;
    case 3
        debugFlag = 0;
end

%% Input profile

% Define Input Profile
% PSDinput.freq = [10 50 1200 2000];
% PSDinput.ASD = [0.000125 0.00125 0.00125 0.000125];


F0 = min(PSDinput.freq); %initial frequency
Fmax = max(PSDinput.freq); % final frequency


%% Interpolate Input Profile

Fr = 1/timeSignalDurationSec; % frequency resolution
Fs = 2*Fmax; %sampling frequency

% PSDinput Inrepolation
f = 0:Fr:Fs/2;
PSD = exp(interp1(log(PSDinput.freq), log(PSDinput.ASD), log(f), 'linear'));
PSD(f<F0) = 0;
PSD(f>Fmax) = 0;

inputGrms = sqrt(trapz(PSD)*Fr);

% plot Input Profile

%% Time SIgnal Reconstruction

t = 0:1/Fs:timeSignalDurationSec;
t = t(1:end-1);
% PSD -> One Sided Amplitude

X1 = zeros(size(PSD));

X1(1) = sqrt(Fr*PSD(1));
X1(2:end) = sqrt(2*Fr*PSD(2:end));
% Phase Randomization

Xphase = randn(size(X1))*(2*pi);
% One Sided Amplitude/Phase to Double-Sided Real/Imag

X1(2:end-1) = X1(2:end-1)/2;
Xreal = X1.*cos(Xphase);
Ximag = X1.*sin(Xphase);

X2 = [Xreal + 1i*Ximag conj(flip(Xreal(2:end-1) + 1i*Ximag(2:end-1)))];

DFT = numel(X2) * X2;
% Frequency Domain -> Time Domain

s = real(ifft(DFT));

outputGrms = rms(s);

FitErrProc = abs((inputGrms-outputGrms)/inputGrms) *100;

if FitErrProc > maxFitErrorProc
    error('Convertion was Inaccurate, Fit = %d [[%]]', FitErrProc)
end

timeSignal = timeseries(s, t);

%% Plot Results


if debugFlag

    figure('Position',[0 0 1000 500])

    subplot(211)

    loglog(PSDinput.freq, PSDinput.ASD, '-*','LineWidth',2, 'DisplayName',  'Input', 'MarkerSize', 20);
    hold on
    loglog(f, PSD, 'r*','LineWidth',3, 'DisplayName','Sampled', 'MarkerSize', 5);
    grid minor
    xlim([0.5*min(PSDinput.freq) 2*max(PSDinput.freq)])
    ylim([0.5*min(PSDinput.ASD) 2*max(PSDinput.ASD)])
    ylabel('$ASD \left[\frac{g^2}{Hz}\right]$', 'Interpreter','latex')
    xlabel('Frequency [Hz]')
    title(sprintf('PSD Profile, Total %.2f [Grms]', inputGrms))
    legend('show', 'Location','best')

    set(gca, 'fontsize', 15)

    subplot(212)

    plot(t, s, 'LineWidth',2);
    grid minor
    ylabel('Signal [g]')
    xlabel('Time [S]')
    title(sprintf('Time Profile, Total %.2f [Grms]', outputGrms))

    set(gca, 'fontsize', 15)
end

end