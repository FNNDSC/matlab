function Multiple

% Multiple model Kalman filtering.
% Second order system.

zeta = 0.1; % damping ratio
wn = [sqrt(4); sqrt(4.4); sqrt(4.8)]; % possible wn values
N = size(wn, 1); % number of parameter sets
pr = [0.1; 0.6; 0.3]; % a priori probabilities
% Compute the initial estimate of wn
wnhat = 0;
for i = 1 : N
   wnhat = wnhat + wn(i) * pr(i);
end
T = 0.1; % sample period
Q = 1000; % discrete time process noise variance
R = diag([10 10]); % discrete time measurement noise covariance
H = eye(2); % measurement matrix
q = size(H, 1); % number of measurements
x = [0; 0]; % initial state

% Compute the alternative Lambda and phi matrices.
for i = 1 : N
   Fi = [0 1; -wn(i)^2 -2*zeta*wn(i)];
   Li = [0; wn(i)^2];
   phii = expm(Fi*T);
   phi(:,:,i) = phii;
   Lambda(:,:,i) = (phii - eye(size(phii))) * inv(Fi) * Li;
   Pplus(:,:,i) = zeros(size(phii));
   xhat(:,i) = x;
end

tf = 60; % Length of simulation
% Create arrays for later plotting
wnhatArray = [wnhat];
prArray = [pr];
for t = T : T : tf
   % Simulate the system.
   % The first parameter set is the true parameter set.
   w = sqrt(Q) * randn;
   x = phi(:,:,1) * x + Lambda(:,:,1) * w;
   z = H * x + sqrt(R) * [randn; randn];
   % Run a separate Kalman filter for each parameter set.
   for i = 1 : N
      Pminus(:,:,i) = phi(:,:,i) * Pplus(:,:,i) * phi(:,:,i)';
      Pminus(:,:,i) = Pminus(:,:,i) + Lambda(:,:,i) * Q * Lambda(:,:,i)';
      K = Pminus(:,:,i) * H' * inv(H * Pminus(:,:,i) * H' + R);
      xhat(:,i) = phi(:,:,i) * xhat(:,i);
      r = z - H * xhat(:,i); % measurment residual
      S = H * Pminus(:,:,i) * H' + R; % covariance of measurement residual
      pdf(i) = exp(-r'*inv(S)*r/2) / ((2*pi)^(q/2)) / sqrt(det(S));
      xhat(:,i) = xhat(:,i) + K * (z - H * xhat(:,i));
      Pplus(:,:,i) = (eye(2) - K * H) * Pminus(:,:,i) * (eye(2) - K * H)' + K * R * K';
   end
   % Compute the sum that appears in the denominator of the probability expression.
   Prsum = 0;
   for i = 1 : N
      Prsum = Prsum + pdf(i) * pr(i);
   end
   % Update the probability of each parameter set.
   for i = 1 : N
      pr(i) = pdf(i) * pr(i) / Prsum;
   end
   % Compute the best state estimate and the best parameter estimate.
   xhatbest = 0;
   wnhat = 0;
   for i = 1 : N
      xhatbest = xhatbest + pr(i) * xhat(:,i);
      wnhat = wnhat + pr(i) * wn(i);
   end
   % Save data for plotting.
   wnhatArray = [wnhatArray wnhat];
   prArray = [prArray pr];
end

close all;
t = 0 : T : tf;
figure;
plot(t, wnhatArray.^2);
title('Estimate of square of natural frequency', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds');
figure;
plot(t, prArray(1,:), '-', t, prArray(2,:), '--', t, prArray(3,:), ':');
title('Probabilities of square of natural frequency', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds');
legend('Probability of 4', 'Probability of 4.4', 'Probability of 4.8');
