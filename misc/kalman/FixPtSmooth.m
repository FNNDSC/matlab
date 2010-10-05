function FixPtSmooth(duration, dt, measnoise)

% function FixPtSmooth(duration, dt)
%
% Fixed point smoother simulation for a vehicle travelling along a road.
% INPUTS
%   duration = length of simulation (seconds)
%   dt = step size (seconds)
%   measnoise = standard deviation of position measurement noise

if ~exist('duration', 'var')
    duration = 5;
end
if ~exist('dt', 'var')
    dt = 0.1;
end
if ~exist('measnoise', 'var')
    measnoise = 1; 
end

accelnoise = 0.2; % acceleration noise (feet/sec^2)

a = [1 dt; 0 1]; % transition matrix
b = [dt^2/2; dt]; % input matrix
c = [1 0]; % measurement matrix
x = [0; 0]; % initial state vector
xhat = x; % initial state estimate

Sw = accelnoise^2 * [dt^4/4 dt^3/2; dt^3/2 dt^2]; % process noise covariance
P = [1 0; 0 1]; % initial estimation covariance
Sz = measnoise^2; % measurement error covariance

% Initialize arrays for later plotting.
pos = []; % true position array
poshat = []; % estimated position array
posmeas = []; % measured position array
vel = []; % true velocity array
velhat = []; % estimated velocity array
TrPArray = []; % Trace of standard estimation covariance
TrPiArray = []; % Trace of smoothed estimation covariance

FirstPass = 1;
randn('state',sum(100*clock));
K = zeros(size(c'));

% Simulate the noisy measurement
MeasNoise = measnoise * randn;
y = c * x + MeasNoise;

for t = 0 : dt: duration,
    % Use a constant commanded acceleration of 1 foot/sec^2.
    u = 1;
    % Simulate the linear system.
    ProcessNoise = accelnoise * [(dt^2/2)*randn; dt*randn];
    x = a * x + b * u + ProcessNoise;
    % Form the Innovation vector.
    Inn = y - c * xhat;
    % Compute the covariance of the Innovation.
    s = c * P * c' + Sz;
    % Form the Kalman Gain matrix.
    K = a * P * c' * inv(s);
    % Update the state estimate.
    xhat = a * xhat + K * Inn + b * u;
    % Compute the covariance of the estimation error.
    POld = P;
    P = a * P * a' - a * P * c' * inv(s) * c * P * a' + Sw;
    
    if (FirstPass == 1)
        % Initialize the covariance arrays for the fixed point smoother
        Sigma = P;
        Pi = P;
        FirstPass = 0;
    else
        Lambda = Sigma * c' * inv(c * POld * c' + Sz); % smoother gain
        Pi = Pi - Sigma * c' * Lambda'; % covariance of smoothed estimate
        Sigma = Sigma * (a - K * c)'; % cross variance of standard and smoothed estimates
    end
    
    % Simulate the noisy measurement
    MeasNoise = measnoise * randn;
    y = c * x + MeasNoise;
    
    % Save some parameters for plotting later.
    pos = [pos; x(1)];
    posmeas = [posmeas; y];
    poshat = [poshat; xhat(1)];
    vel = [vel; x(2)];
    velhat = [velhat; xhat(2)];
    TrPArray = [TrPArray trace(P)];
    TrPiArray = [TrPiArray trace(Pi)];
    
end

Improve = 100 * (TrPArray(1) - trace(Pi)) / TrPArray(1);
disp(['Smoothing Improvement = ',num2str(Improve),' %']);

% Plot the results
close all;
t = 0 : dt : duration;

figure;
plot(t,TrPArray,'r', t,TrPiArray,'b');
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Time (sec)');
ylabel('Estimation Covariance', 'FontSize', 12);
legend('Standard Filter', 'Smoothed Filter'); 
grid;

figure;
plot(t,pos, t,posmeas, t,poshat);
grid;
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Time (sec)');
ylabel('Position (feet)');
legend('True Vehicle Position', 'Measured Vehicle Position', 'Estimated Vehicle Position');

figure;
plot(t,pos-posmeas, t,pos-poshat);
grid;
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Time (sec)');
ylabel('Position Error (feet)');
legend('Position Measurement Error', 'Position Estimation Error');

figure;
plot(t,vel, t,velhat);
grid;
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Time (sec)');
ylabel('Velocity (feet/sec)');
legend('True Vehicle Velocity', 'Estimated Vehicle Velocity');

figure;
plot(t,vel-velhat);
grid;
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Time (sec)');
ylabel('Velocity Error (feet/sec)');
title('Velocity Estimation Error', 'FontSize', 12);