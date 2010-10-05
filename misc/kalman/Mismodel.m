function Mismodel(Q)

% Simulate a continuous time Kalman filter with a mismodel condition.
% We design the filter aunder the assumption that we are trying to estimate
% a constant bias state. In reality the state is a ramp.
% Performance can be improved by progressively increasing Q from 0 to 10.
% This illustrates the effectiveness of adding fictitious process noise 
% to the assumed model. Fictitious process noise can compensate for modeling errors.

tf = 100; % final time
dt = 0.05; % integration step size

F = 0; % Assumed state matrix
H = 1; % Assumed measurement matrix
L = 1; % Assumed process noisematrix

x = [0; 10]; % initial true state
xhat = 0; % initial state estimate
P = 1; % initial estimation error covariance
R = 1; % covariance of measurement noise

x1Array = [];
xhatArray = [];
KArray = [];

for t = 0 : dt : tf
   % Simulate the system
   x1dot = x(2);
   x(1) = x(1) + x1dot * dt;
   z = x(1) + sqrt(R) * randn;
   % Kalman filter
   K = P * H(1)' * inv(R);
   xhatdot = F * xhat + K * (z - xhat);
   xhat = xhat + xhatdot * dt;
   Pdot = -P * H' * inv(R) * H * P + F * P + P * F' + L * Q * L';
   P = P + Pdot * dt;
   % Save data for later
   x1Array = [x1Array; x(1)];
   xhatArray = [xhatArray; xhat];
   KArray = [KArray; K];
end

% Plot results
close all;
t = 0 : dt : tf;
plot(t, x1Array, 'r-', t, xhatArray, 'b--');
title(['Q = ',num2str(Q)], 'FontSize', 14);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('time');
legend('true state', 'estimated state');

plot(t, KArray);
title(['Kalman Gain; Q = ', num2str(Q)], 'FontSize', 14);
set(gca,'FontSize',12); set(gcf,'Color','White');
axis([0 tf/2 0 3.5]);
xlabel('time');

