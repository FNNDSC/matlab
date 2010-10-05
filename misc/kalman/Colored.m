function Colored(flag, corr)

% Kalman filter simulation with colored (time correlated) measurement noise.
% INPUTS:
%    flag = 0 means ignore the time correlation of the measurement noise
%           1 means augment the system state
%           2 means use the Bryson/Henrikson approach
%    corr = magnitude of measurement noise correlation <= 1

kf = 500; % Number of time steps in simulation
phi = [0.7 -0.15; 0.03 0.79];
H = [1 0; 0 1];
psi = [corr 0; 0 corr];
L = [0.15; 0.21];
Q = L * [1] * L';
Qv = [0.05 0; 0 0.05];

phi1 = [phi zeros(2,2); zeros(2,2) psi];
Q1 = [Q zeros(2,2); zeros(2,2) Qv];
R1 = zeros(2,2);
H1 = [H eye(2,2)];

if (flag == 0)
   n = 2; % number of states
   R = Qv;
   sTitle = 'Correlation Ignored';
elseif (flag == 1)
   n = 4; % number of states
   sTitle = 'Augmented State';
elseif (flag == 2)
   n = 2; % number of states
   R = H * Q * H' + Qv;
   M = Q * H';
   D = H * phi - psi * H;
   sTitle = 'Bryson and Henrikson';
else
   disp('illegal input argument');
end

% Assume xhat(0) = x(0) = 0.
x = zeros(4,1); xhatplus = zeros(n,1); xhatminus = zeros(n,1);
z = zeros(2,1);
% Assume P(0) = 0.
Pplus = zeros(n,n); Pminus = zeros(n,n);

xArray = []; xhatArray = []; KArray = []; PArray = []; zArray = [];

randn('state', 0);
for k = 1 : kf
   % Simulate the system
   StateNoise = randn;
   n(1,1) = L(1,1) * StateNoise;
   n(2,1) = L(2,1) * StateNoise;
   n(3,1) = sqrt(Qv(1,1)) * randn;
   n(4,1) = sqrt(Qv(2,2)) * randn;
   x = phi1 * x + n;
   zold = z;
   z = H1 * x;
   % Run the Kalman filter
   if (flag == 0)
       % Ignore the time correlation
      Pminus = phi * Pplus * phi' + Q;
      K = inv(H * Pminus * H' + R);
      K = (Pminus * H') * K;
      xhatminus = phi * xhatplus;
      xhatplus = xhatminus + K * (z - H * xhatminus);
      Pplus = Pminus - K * H * Pminus;
   elseif (flag == 1)
       % Use the augmented state approach
      Pminus = phi1 * Pplus * phi1' + Q1;
      K = inv(H1 * Pminus * H1' + R1);
      K = (Pminus * H1') * K;
      xhatminus = phi1 * xhatplus;
      xhatplus = xhatminus + K * (z - H1 * xhatminus);
      Pplus = Pminus - K * H1 * Pminus;
   elseif (flag == 2)
       % Use the Bryson/Henrikson approach
      zeta = z - psi * zold;
      C = M * inv(D * Pminus * D' + R);
      K = Pminus * D' * inv(D * Pminus * D' + R);
      xhatplus = xhatminus + K * (zeta - D * xhatminus);
      xhatminus = phi * xhatplus + C * (zeta - D * xhatplus);
      Pplus = (eye(2) - K * D) * Pminus * (eye(2) - K * D)' + K * R * K';
      Pminus = phi * Pplus * phi' + Q - C * M' - phi * K * M - M' * K' * phi';
      xhatplus = xhatminus;
   end
   % Save data for plotting.
   xArray = [xArray x];
   xhatArray = [xhatArray xhatplus];
   KArray = [KArray K];
   PArray = [PArray Pplus];
   zArray = [zArray z];
end

% Plot.
k = 1 : kf;
close all;
figure;
plot(k, zArray(1,:) - xArray(1,:), '-', k, xArray(1,:) - xhatArray(1,:), ':');
title([sTitle,' - x1 - Solid = Measurement Error, Dotted = Estimation Error']);
xlabel('time');

figure;
plot(k, zArray(2,:) - xArray(2,:), '-', k, xArray(2,:) - xhatArray(2,:), ':');
title([sTitle,' - x2 - Solid = Measurement Error, Dotted = Estimation Error']);
xlabel('time');

% Compute estimation error statistics.
err1 = xArray(1,:) - xhatArray(1,:);
err1 = sqrt(norm(err1)^2 / kf);
meas = xArray(1,:) - zArray(1,:);
meas = sqrt(norm(meas)^2 / kf);
disp(['x1 RMS Meas / Est Error Variance = ',num2str(meas),' / ',num2str(err1)]);
err2 = xArray(2,:) - xhatArray(2,:);
err2 = sqrt(norm(err2)^2 / kf);
meas = xArray(1,:) - zArray(1,:);
meas = sqrt(norm(meas)^2 / kf);
disp(['x2 RMS Meas / Est Error Variance = ',num2str(meas),' / ',num2str(err2)]);
disp(['RMS Est Error Variance Sum = ',num2str(err1+err2)]);