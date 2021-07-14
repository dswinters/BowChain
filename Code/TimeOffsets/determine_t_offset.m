function offset=determine_t_offset(time1,signal1,time2,signal2,trange)
% Find the temporal offset, offset, between two signals, signal1 & signal2,
% based on the coherence of the filtered signals over a particular period
% of time, trange. Only works for signals with the same sampling frequency.
% Time, time1 & time2, is in days (datenum or yday acceptable).

% Filter the signals to beat down noise
signal1=medfilt1(signal1,10);
signal2=medfilt1(signal2,10);

% Shorten timeseries to the appropriate ranges
tinds1 = find(time1 >= trange(1) & time1 <= trange(2));
tinds2 = find(time2 >= trange(1) & time2 <= trange(2));
% Find the shorter timeseries
leni = min([length(tinds1) length(tinds2)]);
% Get sampling frequency, SIGNALS MUST HAVE THE SAME SAMPLING FREQUENCY
FS=1./(mean(diff(time1(tinds1)))*86400);    % [Hz]

% Estimate the coherence over the desired time period
p=fast_cohere(signal1(tinds1(1:leni)),signal2(tinds2(1:leni)),256,FS);
% Find the low frequencies for which the signals are coherent
ginds = find(p.coh > 0.5 & p.f < 0.2);
% disp('Coherent Low Frequencies')
% disp(p.f(ginds))
% Unwrap phase for total time offset at each frequency
temp=unwrap(p.pha);
% Fit a line to only the coherent offsets
b=regress(temp(ginds),p.f(ginds));
% Plot resutls
figure
subplot(311)
plot(time1(tinds1(1:leni)),signal1(tinds1(1:leni)),...
  time2(tinds2(1:leni)),signal2(tinds2(1:leni)))
legend('Singal 1','Singal 2')
subplot(312)
plot(p.f,p.coh)
title('Coherence')
subplot(313)
plot(p.f,p.pha,p.f(ginds),p.f(ginds)*b(1))
title(['b=' num2str(b(1)/2/pi)])
% Get offset back into days
offset=b(1)/2/pi/86400;
% fig
pause(.01)
