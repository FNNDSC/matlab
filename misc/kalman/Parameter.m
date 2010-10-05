function Parameter

% Extended Kalman filter for parameter estimation.
% Estimate the natural frequency of a second order system.

tf = 100; % simulation length
dt = 0.01; % simulation step size
wn = 2; % natural frequency
zeta = 0.1; % damping ratio
b = -2 * zeta * wn;
Q2 = .1; % artificial noise used for parameter estimation
Q = [1000 0; 0 Q2]; % covariance of process noise
R = [10 0; 0 10]; % covariance of measurement noise
H = [1 0 0; 0 1 0]; % measurement matrix
P = [0 0 0; 0 0 0; 0 0 20]; % covariance of estimation error

x = [0; 0; -wn*wn]; % initial state
xhat = 2 * x; % initial state estimate

% Initialize arrays for later plotting
xArray = x;
xhatArray = xhat;
P3Array = P(3,3);

dtPlot = tf / 100; % how often to plot output data
tPlot = 0;

for t = dt : dt : tf+dt
   % Simulate the system.
   w = sqrt(Q(1,1)) * randn;
   xdot = [x(2); x(3)*x(1) + b*x(2) - x(3)*w; 0];
   x = x + xdot * dt;
   z = H * x + sqrt(R) * [randn; randn];
   % Simulate the Kalman filter.
   F = [0 1 0; xhat(3) b xhat(1); 0 0 0];
   L = [0 0; -xhat(3) 0; 0 1];
   Pdot = F * P + P * F' + L * Q * L' - P * H' * inv(R) * H * P;
   P = P + Pdot * dt;
   K = P * H' * inv(R);
   xhatdot = [xhat(2); xhat(3)*xhat(1) + b*xhat(2); 0];
   xhatdot = xhatdot + K * (z - H * xhat);
   xhat = xhat + xhatdot * dt;
   if (t >= tPlot + dtPlot - 100*eps)
	   % Save data for plotting.
	   xArray = [xArray x];
	   xhatArray = [xhatArray xhat];
      P3Array = [P3Array P(3,3)];
      tPlot = t;
   end
end

% Plot results
close all
t = 0 : dtPlot : tf;
figure;
plot(t, xArray(3,:) - xhatArray(3,:));
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds'); ylabel('wn^2 Estimation Error');
figure;
plot(t, P3Array);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds'); ylabel('Variance of wn^2 Estimation Error');