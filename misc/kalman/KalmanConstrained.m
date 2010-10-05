function KalmanConstrained

% function KalmanConstrained
% This m-file simulates a vehicle tracking problem.
% The vehicle state is estimated with an extended Kalman filter.
% In addition, with the a priori knowledge that the vehicle is on
% a particular road, the vehicle state is estimated with a 
% constrained Kalman filter.
% The state consists of the north and east position, and the
% north and east velocity of the vehicle.
% The measurement consists of ranges to two transponders.
% For further details see the web site 
% http://academic.csuohio.edu/simond/kalmanconstrained.

tf = 300; % final time (seconds)
T = 3; % time step (seconds)

Q = diag([4, 4, 1, 1]); % Process noise covariance (m, m, m/sec, m/sec)
Qsqrt = sqrt(Q);

R = diag([900, 900]); % Measurement noise covariance (m, m)
Rsqrt = sqrt(R);

% Measurement noise covariance for perfect measurement formulation.
R1 = diag([900, 900, 0.000, 0.000]);
R1sqrt = sqrt(R1);

theta = pi / 3; % heading angle (measured CCW from east)
tantheta = tan(theta);
sintheta = sin(theta);
costheta = cos(theta);

% Define the initial state x, initial unconstrained filter estimate xhat,
% and initial constrained Kalman filter estimate xtilde.
x = [0; 0; tantheta; 1] * 100;
xhat = x; % Unconstrained Kalman filter
xhat1 = x; % Kalman filter with perfect measurements
xtilde = x; % Constrained Kalman filter (W=I)
xtildeP = x; % Constrained Kalman filter (W=inv(P))

% Initial estimation error covariance
P = diag([R(1,1), R(2,2), Q(1,1), Q(2,2)]);
% Initial estimation error covariance for perfect measurement formulation
P1 = P;

% AccelDecelFlag is used to simulate the vehicle alternately accelerating and
% decelerating, as if in traffic.
AccelDecelFlag = 1;

% Transponder locations.  The first transponder is located at rn1 meters north
% and re1 meters east.  The second transponder is located at rn2 meters north
% and re2 meters east.
rn1 = 0;
re1 = 0;
rn2 = 1e5 * tantheta;
re2 = 1e5;

% System matrix.
A = [1 0 T 0
   0 1 0 T
   0 0 1 0
   0 0 0 1];

% State constraint matrix.
D = [1 -tantheta 0 0; 
   0 0 1 -tantheta];

% Initialize arrays for saving data for plotting.
xarray = x;
xhatarray = [];
Constrarray = [];
xhat1array = [];
Constr1array = [];
ConstrTildearray = [];
ConstrTildeParray = [];
xtildearray = [];
xtildeParray = [];
randn('state', sum(100*clock));

% Begin the simulation.
for t = T : T : tf
   % Get the measurement.
   z(1, 1) = (x(1)-rn1)^2 + (x(2)-re1)^2;
   z(2, 1) = (x(1)-rn2)^2 + (x(2)-re2)^2;
   MeasErr = Rsqrt*randn(size(z));
   z = z + MeasErr;
   % Get the measurement for the perfect measurement formulation.
   z1(1, 1) = z(1, 1);
   z1(2, 1) = z(2, 1);
   z1(3, 1) = 0;
   z1(4, 1) = 0;
   % Set the known input.
   if AccelDecelFlag == 1
      if (x(3) > 30) | (x(4) > 30)
         AccelDecelFlag = -1;
      end
   else
      if (x(3) < 5) | (x(4) < 5)
         AccelDecelFlag = 1;
      end
   end
   u = 1 * AccelDecelFlag;
   % Estimate the heading on the basis of the state estimate.
   headinghat = atan2(xhat(3), xhat(4));  
   % Run the Kalman filter.
   H = [2*(xhat(1)-rn1) 2*(xhat(1)-rn2) %0
      2*(xhat(2)-re1) 2*(xhat(2)-re2) %0
      0 0 
      0 0]; 
   K = P * H * inv(H' * P * H + R);
   
   % Run the filter for the perfect measurement formulation.
   H1 = [2*(xhat1(1)-rn1) 2*(xhat1(1)-rn2) 1 0
      2*(xhat1(2)-re1) 2*(xhat1(2)-re2) -tantheta 0
      0 0 0 1
      0 0 0 -tantheta];
   if (cond(H1' * P1 * H1 + R1) > 1/eps)
      disp('ill conditioning problem');
      return;
   end
   K1 = P1 * H1 * inv(H1' * P1 * H1 + R1);
   
   h(1) = (xhat(1)-rn1)^2 + (xhat(2)-re1)^2;
   h(2) = (xhat(1)-rn2)^2 + (xhat(2)-re2)^2;
   xhat = xhat + K * (z - h');
   xhatarray = [xhatarray xhat];
   % Find the constrained Kalman filter estimates.
   xtilde = xhat - D' * inv(D*D') * D * xhat;
   xtildearray = [xtildearray xtilde];
   xtildeP = xhat - P * D' * inv(D*P*D') * D * xhat;
   xtildeParray = [xtildeParray xtildeP];
   
   h1(1) = (xhat1(1)-rn1)^2 + (xhat1(2)-re1)^2;
   h1(2) = (xhat1(1)-rn2)^2 + (xhat1(2)-re2)^2;
   h1(3) = xhat1(1) - tantheta * xhat1(2);
   h1(4) = xhat1(3) - tantheta * xhat1(4);
   xhat1 = xhat1 + K1 * (z1 - h1');
   xhat1array = [xhat1array xhat1];
   
	B = [0; 0; T*sin(headinghat); T*cos(headinghat)];
   xhat = A*xhat + B*u;
   ConstrErr = D * xhat;
   Constrarray = [Constrarray ConstrErr];
   
	B1 = [0; 0; T*sintheta; T*costheta];
   xhat1 = A*xhat1 + B1*u;
   Constr1Err = D * xhat1;
   Constr1array = [Constr1array Constr1Err];
   
   xtilde = A*xtilde + B*u;
   xtildeP = A*xtildeP + B*u;
   ConstrTilde = D * xtilde;
   ConstrTildearray = [ConstrTildearray ConstrTilde];
   ConstrTildeP = D * xtildeP;
   ConstrTildeParray = [ConstrTildeParray ConstrTildeP];
   % Update the state estimation error covariance.
	P = (eye(4) - K * H') * P;
   P = A * P * A' + Q;   
   
   P1 = (eye(4) - K1 * H1') * P1;
   P1 = A * P1 * A' + Q;
   
   % Simulate the system.
   B = [0; 0; T*sin(theta); T*cos(theta)];
   x = A*x + B*u + Qsqrt*randn(size(x));
   % Constrain the vehicle (i.e., the true state) to the straight road.
   if abs(x(1) - tantheta * x(2)) > 2
      x(2) = (x(2) + x(1) * tantheta) / (1 + tantheta^2);
      x(1) = x(2) * tantheta;
   end
   if abs(x(3) - tantheta * x(4)) > 0.2
      x(4) = (x(4) + x(3) * tantheta) / (1 + tantheta^2);
      x(3) = x(4) * tantheta;
   end
   xarray = [xarray x];
end

% Process one more measurement.
z(1, 1) = (x(1)-rn1)^2 + (x(2)-re1)^2;
z(2, 1) = (x(1)-rn2)^2 + (x(2)-re2)^2;
MeasErr = Rsqrt*randn(size(z));
z = z + MeasErr;

H = [2*(xhat(1)-rn1) 2*(xhat(1)-rn2)
   2*(xhat(2)-re1) 2*(xhat(2)-re2) 
   0 0 
   0 0 ];
K = P * H * inv(H' * P * H + R);
h(1) = (xhat(1)-rn1)^2 + (xhat(2)-re1)^2;
h(2) = (xhat(1)-rn2)^2 + (xhat(2)-re2)^2;
xhat = xhat + K * (z - h');
xhatarray = [xhatarray xhat];
xtilde = xhat - D' * inv(D*D') * D * xhat;
xtildearray = [xtildearray xtilde];
xtildeP = xhat - P * D' * inv(D*P*D') * D * xhat;
xtildeParray = [xtildeParray xtildeP];
headinghat = atan2(xhat(3), xhat(4));  

z1(1, 1) = z(1, 1);
z1(2, 1) = z(2, 1);
z1(3, 1) = 0;
z1(4, 1) = 0;
H1 = [2*(xhat1(1)-rn1) 2*(xhat1(1)-rn2) 1 0
   2*(xhat1(2)-re1) 2*(xhat1(2)-re2) -tantheta 0
   0 0 0 1
   0 0 0 -tantheta];
K1 = P1 * H1 * inv(H1' * P1 * H1 + R1);
h1(1) = (xhat1(1)-rn1)^2 + (xhat1(2)-re1)^2;
h1(2) = (xhat1(1)-rn2)^2 + (xhat1(2)-re2)^2;
h1(3) = xhat1(1) - tantheta * xhat1(2);
h1(4) = xhat1(3) - tantheta * xhat1(4);
xhat1 = xhat1 + K1 * (z1 - h1');
xhat1array = [xhat1array xhat1];

% Compute averages.
EstError = xarray - xhatarray;
EstError = sqrt(EstError(1,:).^2 + EstError(2,:).^2);
EstError = mean(EstError);
disp(['RMS Unconstrained Estimation Error = ', num2str(EstError)]);

EstError1 = xarray - xhat1array;
EstError1 = sqrt(EstError1(1,:).^2 + EstError1(2,:).^2);
EstError1 = mean(EstError1);
disp(['RMS Estimation Error (Perfect Meas) = ', num2str(EstError1)]);

EstErrorConstr = xarray - xtildearray;
EstErrorConstr = sqrt(EstErrorConstr(1,:).^2 + EstErrorConstr(2,:).^2);
EstErrorConstr = mean(EstErrorConstr);
disp(['RMS Constrained Estimation Error (W=I) = ', num2str(EstErrorConstr)]);

EstErrorConstrP = xarray - xtildeParray;
EstErrorConstrP = sqrt(EstErrorConstrP(1,:).^2 + EstErrorConstrP(2,:).^2);
EstErrorConstrP = mean(EstErrorConstrP);
disp(['RMS Constrained Estimation Error (W=inv(P)) = ', num2str(EstErrorConstrP)]);

disp(' ');

Constr = sqrt(Constrarray(1,:).^2 + Constrarray(2,:).^2);
Constr = mean(Constr);
disp(['Average Constraint Error (Unconstrained) = ', num2str(Constr)]);

Constr1 = sqrt(Constr1array(1,:).^2 + Constr1array(2,:).^2);
Constr1 = mean(Constr1);
disp(['Average Constraint Error (Perfect Meas) = ', num2str(Constr1)]);

ConstrTilde = sqrt(ConstrTildearray(1,:).^2 + ConstrTildearray(2,:).^2);
ConstrTilde = mean(ConstrTilde);
disp(['Average Constraint Error (W=I) = ', num2str(ConstrTilde)]);

ConstrTildeP = sqrt(ConstrTildeParray(1,:).^2 + ConstrTildeParray(2,:).^2);
ConstrTildeP = mean(ConstrTildeP);
disp(['Average Constraint Error (W=inv(P)) = ', num2str(ConstrTildeP)]);

% Plot data.
close all;
t = 0 : T : tf;
figure;
plot(t, xarray(1, :), t, xarray(2, :));
title('True Position', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('seconds'); ylabel('meters');
legend('North Position', 'East Position');

figure;
plot(t, xarray(1, :) - xhatarray(1, :), ...
   t, xarray(2, :) - xhatarray(2, :));
title('Position Estimation Error (Unconstrained)', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('seconds'); ylabel('meters');
legend('North Estimation Error', 'East Estimation Error');

figure;
plot(t, xarray(1, :) - xhat1array(1, :), ...
   t, xarray(2, :) - xhat1array(2, :));
title('Position Estimation Error (Perfect Measurements)', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('seconds'); ylabel('meters');
legend('North Estimation Error', 'East Estimation Error');

figure;
plot(t, xarray(1, :) - xtildearray(1, :), ...
   t, xarray(2, :) - xtildearray(2, :));
title('Position Estimation Error (Constrained, W=I)', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('seconds'); ylabel('meters');
legend('North Estimation Error', 'East Estimation Error');

figure;
plot(t, xarray(1, :) - xtildeParray(1, :), ...
   t, xarray(2, :) - xtildeParray(2, :));
title('Position Estimation Error (Constrained, W=inv(P))', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('seconds'); ylabel('meters');
legend('North Estimation Error', 'East Estimation Error');

