function HinfTF

%  Time-varying H-infinity radar tracking.

%  Define the bounds on the disturbance input and the measurement error.
Wbound = 4; Vbound = 20;
%  Define the plant model (with normalized inputs).
A = [0 1; 0 0]; B = [0 0; Wbound 0]; D = [0 1];
Cm = [1/Vbound 0]; Cy = eye(2);
%  Initialize the state and the estimator state.
x(:,1) = [10000; -50]; xh(:,1) = [9500; 0];
%  Initialize the Riccati solution.
Q = zeros(2);
%  Define the time step and simulation length. 
dt = 0.05;
tf = 25;
%  Define the disturbance input and the measurement error.
%  Define the performance bound.
gamma = 22.5;
gm2 = 1 / gamma / gamma;

%  Simulation loop for plant, Riccati equation, and estimator.
i = 1;
for t = dt : dt : tf
  % Noisy plant and measurement simulation.
  vn = 2 * Vbound * rand - Vbound;
  wn = 2 * Wbound * rand - Wbound;
  m = [1 0] * x(:,i) + vn;
  x(:,i+1) = x(:,i) + dt * (A * x(:,i) + B(:,1) * wn);
  % Riccati solution.
  Q = Q + dt*(Q*A' + A*Q + B*B' - Q*(Cm'*Cm-gm2*Cy'*Cy)*Q);
  %  Gain computation.
  G = Q * Cm' / Vbound;
  % Save the estimator gains for plotting.
  Gs(:,i) = G;
  % Estimator simulation.
  xh(:,i+1) = xh(:,i) + dt*(A*xh(:,i) + G*(m - [1 0]*xh(:,i)));
  i = i + 1;  
end
% Fill out the gain arrays for plotting.
Gs(:,i) = G;

%  Define the time vector for plotting.
t = 0 : dt : tf;
%  Plot the results.
close all;
figure;
plot(t, x(1,:), 'r-', t, xh(1,:), 'b--')
set(gca,'FontSize',12); set(gcf,'Color','White');
%axis([0 tf 8000 10000])
ylabel('Range'); xlabel('seconds')
grid
legend('true', 'estimated');

figure;
plot(t, x(2,:), 'r-', t, xh(2,:), 'b--')
set(gca,'FontSize',12); set(gcf,'Color','White');
%axis([0 tf -100 100])
ylabel('Range rate'); xlabel('seconds')
grid
legend('true', 'estimated');
