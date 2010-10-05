function Hinfinity(g, duration, dt, SteadyState)

% function Hinfinity(g, duration, dt, SteadyState)
%
% H-infinity filter simulation for a vehicle travelling along a road.
% This code also simulates the Kalman filter.
% INPUTS
%   g = gamma
%   if g is too large the program will terminate with an error message.
%   In my simulation I set g = 0.01.
%   duration = length of simulation (seconds). I used duration = 60.
%   dt = step size (seconds). I used dt = 0.1.
%   SteadyState = flag indicating use of steady state filter.
%                 1 = steady state, 0 = time-varying

if ~exist('g', 'var')
    g = 0.01;
end
if ~exist('duration', 'var') 
    duration = 20;
end
if ~exist('dt', 'var')
    dt = 0.1;
end
if ~exist('SteadyState', 'var')
    SteadyState = 0;
end

measnoise = 2; % nominal velocity measurement noise (feet/sec)
accelnoise = 0.2; % nominal acceleration noise (feet/sec^2)
a = [1 dt; 0 1]; % transition matrix
b = [dt^2/2; dt]; % input matrix
c = [0 1]; % measurement matrix
x = [0; 0]; % initial state vector
y = c * x; % initial measurement

% Initialize Kalman filter variables
xhat = x; % initial Kalman filter state estimate
Sz = measnoise^2; % measurement error covariance
Sw = accelnoise^2 * [dt^4/4 dt^3/2; dt^3/2 dt^2]; % process noise cov
P = Sw; % initial Kalman filter estimation covariance

% Initialize H-infinity filter variables
xhatinf = x; % initial H-infinity filter state estimate
Pinf = 0.01*eye(2);
W = [0.0003 0.0050; 0.0050 0.1000]/1000;
V = 0.01;
Q = [0.01 0; 0 0.01];

% Initialize arrays for later plotting.
pos = [x(1)]; % true position array
vel = [x(2)]; % true velocity array
poshat = [xhat(1)]; % estimated position array (Kalman filter)
velhat = [xhat(2)]; % estimated velocity array (Kalman filter)
poshatinf = [xhatinf(1)]; % estimated position array (H-infinity)
velhatinf = [xhatinf(2)]; % estimated velocity array (H-infinity)
HinfGains = [0; 0]; % H-infinity filter gains
KalmanGains = [0; 0]; % Kalman filter gains

for t = 0 : dt: duration-dt

   % Use a constant commanded acceleration of 1 foot/sec^2.
   u = 1;

   % Figure out the H-infinity estimate.
   if (SteadyState == 1)
      % Use steady-state H-infinity gains
      K = [0.11; 0.09];
   else
      L = inv(eye(2) - g * Q * Pinf + c' * inv(V) * c * Pinf);
      K = a * Pinf * L * c' * inv(V);
      Pinf = a * Pinf * L * a' + W;
      % Force Pinf to be symmetric.
      Pinf = (Pinf + Pinf') / 2;
      % Make sure the eigenvalues of Pinf are less than 1 in magnitude.
      lambda = eig(Pinf);
      if (abs(lambda(1)) >= 1) | (abs(lambda(2)) >= 1)
         disp('gamma is too large');
         return;
      end
   end
   xhatinf = a * xhatinf + b * u + K * (y - c * xhatinf);
   HinfGains = [HinfGains K];
   poshatinf = [poshatinf; xhatinf(1)];
   velhatinf = [velhatinf; xhatinf(2)];

   % Simulate the linear system and noisy measurement.
   % Note that randn is Matlab's Gaussian (normal) random number
   % generator; rand is Matlab's uniform random number generator.
   ProcessNoise = 2 * accelnoise * b .* [randn; randn];
   x = a * x + b * u + ProcessNoise;
   MeasNoise = measnoise * (rand - 0.5);
   y = c * x + MeasNoise;

   % Compute the Kalman filter estimate.
   % Extrapolate the most recent state estimate to the present time.
   xhat = a * xhat + b * u;
   poshat = [poshat; xhat(1)];
   velhat = [velhat; xhat(2)];
   % Form the Innovation vector.
   Inn = y - c * xhat;
   if (SteadyState == 1)
      K = [0.1; 0.01];
   else
      % Compute the covariance of the Innovation.
      s = c * P * c' + Sz;
      % Form the Kalman Gain matrix.
      K = a * P * c' * inv(s);
      % Compute the covariance of the estimation error.
      P = a * P * a' - a * P * c' * inv(s) * c * P * a' + Sw;
      % Force P to be symmetric.
      P = (P + P') / 2;
   end
   % Update the Kalman filter state estimate.
   xhat = xhat + K * Inn;

   % Save some parameters for plotting later.
   KalmanGains = [KalmanGains K];
   pos = [pos; x(1)];
   vel = [vel; x(2)];

end

% Plot the results
close all; % Close all open figures
t = 0 : dt : duration; % Create a time array

% Plot the position estimation error
% (Kalman filter = red line, H-infinity filter = green line)
figure;
plot(t,pos-poshat,'r', t,pos-poshatinf,'b--');
set(gca,'FontSize',12); set(gcf,'Color','White');
grid;
xlabel('Time (sec)');
ylabel('Position Error (feet)');
title('Position Estimation Error');
legend('Kalman filter', 'H_{\infty} filter');

% Plot the velocity estimation error
% (Kalman filter = red line, H-infinity filter = green line)
figure;
plot(t,vel-velhat,'r', t,vel-velhatinf,'b--');
set(gca,'FontSize',12); set(gcf,'Color','White');
grid;
xlabel('Time (sec)');
ylabel('Velocity Error (feet)');
title('Velocity Estimation Error');
legend('Kalman filter', 'H_{\infty} filter');

% Plot the Kalman filter gain matrix
figure;
plot(t,KalmanGains(1,:),'r', t,KalmanGains(2,:),'b--');
set(gca,'FontSize',12); set(gcf,'Color','White');
grid;
xlabel('Time (sec)');
title('Kalman Gains');

% Plot the H-infinity filter gain matrix
figure;
plot(t,HinfGains(1,:),'r', t,HinfGains(2,:),'b--');
set(gca,'FontSize',12); set(gcf,'Color','White');
grid;
xlabel('Time (sec)');
title('H-Infinity Gains');