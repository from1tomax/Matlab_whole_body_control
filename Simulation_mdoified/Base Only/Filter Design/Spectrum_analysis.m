load("NoFeed3.mat")

fs = 333; %Hz

%Define series for simulink
qv_dot_cmd_series = data{1}.Values;
qv_dot_series = data{2}.Values;

%Load values for signal analysis
qv_dot_cmd = data{1}.Values.Data;
qv_dot = data{2}.Values.Data;
time = data{1}.Values.Time;

figure 
plot(time,qv_dot)
hold on;
plot(time,qv_dot_cmd)

%% ODOM spectrum
spectrum = fft(qv_dot);
n = length(qv_dot);
f_range = (0:n-1)*(fs/n); 
power = abs(spectrum).^2/n;

figure
plot(f_range(1:end),power(1:end))
xlabel('Frequency')
ylabel('Power')


%% CMD spectrum
spectrum_cmd = fft(qv_dot_cmd);
n = length(qv_dot_cmd);
f_range_cmd = (0:n-1)*(fs/n); 
power_cmd = abs(spectrum_cmd).^2/n;
figure
plot(f_range_cmd(1:end),power_cmd(1:end))
xlabel('Frequency')
ylabel('Power')
