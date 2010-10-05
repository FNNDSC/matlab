function ExtendedBody

% Extended Kalman filter example.
% Track a body falling through the atmosphere.

rho0 = 0.0034; % lb-sec^2/ft^4
g = 32.2; % ft/sec^2
k = 22000; % ft
R = 100; % measurement variance (ft^2)

x = [100000; -6000; 2000]; % initial state
xhat = [100010; -6100; 2500]; % initial state estimate
H = [1 0 0]; % measurement matrix

P = [500 0 0; 0 20000 0; 0 0 250000]; % initial estimation error covariance

tf = 16; % simulation length
dt = tf / 40000; % simulation step size
PlotStep = 200; % how often to plot data points
i = 0;
xArray = x;
xhatArray = xhat;
for t = dt : dt : tf
   % Simulate the system (rectangular integration).
   xdot(1,1) = x(2);
   xdot(2,1) = rho0 * exp(-x(1)/k) * x(2)^2 / 2 / x(3) - g;
   xdot(3,1) = 0;
   x = x + xdot * dt;
   % Simulate the measurement.
   z = H * x + sqrt(R) * randn;
   % Simulate the filter.
   temp = rho0 * exp(-xhat(1)/k) * xhat(2) / xhat(3);
   F = [0 1 0; -temp * xhat(2) / 2 / k temp ...
      -temp * xhat(2) / 2 / xhat(3); ...
         0 0 0];
   Pdot = F * P + P * F' - P * H' * inv(R) * H * P;
   P = P + Pdot * dt;
   K = P * H' * inv(R);
   xhatdot(1,1) = xhat(2);
   xhatdot(2,1) = temp * xhat(2) / 2 - g;
   xhatdot(3,1) = 0;
   xhatdot = xhatdot + K * (z - H * xhat);
   xhat = xhat + xhatdot * dt;
   % Save data for plotting.
   i = i + 1;
   if i == PlotStep
      xArray = [xArray x];
      xhatArray = [xhatArray xhat];
      i = 0;
   end
end

% Plot data.
close all;
t = 0 : PlotStep*dt : tf;

figure;
plot(t, xArray(1,:) - xhatArray(1,:));
title('Extended Kalman Filter', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds'); ylabel('Position Estimation Error');

figure;
plot(t, xArray(2,:) - xhatArray(2,:));
title('Extended Kalman Filter', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds'); ylabel('Velocity Estimation Error');

figure;
plot(t, xArray(3,:) - xhatArray(3,:));
title('Extended Kalman Filter', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds'); ylabel('Ballistic Coefficient Estimation Error');

figure;
plot(t, xArray(1,:));
title('Falling Body Simulation', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds'); ylabel('True Position');

figure;
plot(t, xArray(2,:));
title('Falling Body Simulation', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds'); ylabel('True Velocity');
