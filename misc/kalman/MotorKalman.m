function MotorKalman

% Kalman filter simulation for two-phase step motor.
% Estimate the stator currents, and the rotor position and velocity, on the
% basis of noisy measurements of the stator currents.

Ra = 1.9; % Winding resistance
L = 0.003; % Winding inductance
lambda = 0.1; % Motor constant
J = 0.00018; % Moment of inertia
B = 0.001; % Coefficient of viscous friction

ControlNoise = 0.01; % std dev of uncertainty in control inputs
AccelNoise = 0.5; % std dev of shaft acceleration noise

MeasNoise = 0.1; % standard deviation of measurement noise
R = [MeasNoise^2 0; 0 MeasNoise^2]; % Measurement noise covariance
xdotNoise = [ControlNoise/L ControlNoise/L 0.5 0];
Q = [xdotNoise(1)^2 0 0 0; 0 xdotNoise(2)^2 0 0; 0 0 xdotNoise(3)^2 0; 0 0 0 xdotNoise(4)^2]; % Process noise covariance
P = 1*eye(4); % Initial state estimation covariance

dt = 0.0005; % Integration step size
tf = 2; % Simulation length

x = [0; 0; 0; 0]; % Initial state
xlin = x; % Linearized approximation of state
xhat = x; % State estimate
w = 2 * pi; % Control input frequency

dtPlot = 0.005; % How often to plot results
tPlot = -inf;

% Initialize arrays for plotting at the end of the program
xArray = [];
xlinArray = [];
xhatArray = [];
trPArray = [];
tArray = [];

dx = x - xlin; % Difference between true state and linearized state

% Begin simulation loop
for t = 0 : dt : tf
    if t >= tPlot + dtPlot
        % Save data for plotting
        tPlot = t + dtPlot - eps;
        xArray = [xArray x];
        xlinArray = [xlinArray xlin];
        xhatArray = [xhatArray xhat];
        trPArray = [trPArray trace(P)];
        tArray = [tArray t];
    end
    % Nonlinear simulation
    ua0 = sin(w*t);
    ub0 = cos(w*t);
    xdot = [-Ra/L*x(1) + x(3)*lambda/L*sin(x(4)) + ua0/L;
        -Ra/L*x(2) - x(3)*lambda/L*cos(x(4)) + ub0/L;
        -3/2*lambda/J*x(1)*sin(x(4)) + 3/2*lambda/J*x(2)*cos(x(4)) - B/J*x(3);
        x(3)];
    xdot = xdot + [xdotNoise(1)*randn; xdotNoise(2)*randn; xdotNoise(3)*randn; xdotNoise(4)*randn];
    x = x + xdot * dt;
    x(4) = mod(x(4), 2*pi);
    % Linear simulation
    w0 = -6.2832; % nominal rotor speed
    theta0 = -6.2835 * t + 2.3679; % nominal rotor position
    ia0 = 0.3708 * cos(2*pi*(t-1.36)); % nominal winding a current
    ib0 = -0.3708 * sin(2*pi*(t-1.36)); % nominal winding b current
    ua = sin(w*t); % winding a control input
    ub = cos(w*t); % winding b control input
    du = [ua - ua0; ub - ub0];
    F = [-Ra/L 0 lambda/L*sin(theta0) w0*lambda/L*cos(theta0);
        0 -Ra/L -lambda/L*cos(theta0) w0*lambda/L*sin(theta0);
        -3/2*lambda/J*sin(theta0) 3/2*lambda/J*cos(theta0) -B/J -3/2*lambda/J*(ia0*cos(theta0)+ib0*sin(theta0));
        0 0 1 0];
    G = [1/L 0; 0 1/L; 0 0; 0 0];
    dxdot = F * dx + G * du;
    dx = dx + dxdot * dt;
    xlin = [ia0; ib0; w0; theta0] + dx;
    xlin(4) = mod(xlin(4), 2*pi);
    % Kalman filter
    H = [1 0 0 0; 0 1 0 0];
    z = H * x + [MeasNoise*randn; MeasNoise*randn];
    xhatdot = [-Ra/L*xhat(1) + xhat(3)*lambda/L*sin(xhat(4)) + ua0/L;
        -Ra/L*xhat(2) - xhat(3)*lambda/L*cos(xhat(4)) + ub0/L;
        -3/2*lambda/J*xhat(1)*sin(xhat(4)) + 3/2*lambda/J*xhat(2)*cos(xhat(4)) - B/J*xhat(3);
        xhat(3)];
    xhat = xhat + xhatdot * dt;
    Pdot = F * P + P * F' + Q - P * H' * inv(R) * H * P;
    P = P + Pdot * dt;
    K = P * H' * inv(H * P * H' + R);
    xhat = xhat + K * (z - H * xhat);
    xhat(4) = mod(xhat(4), 2*pi);
    P = (eye(4) - K * H) * P * (eye(4) - K * H)' + K * R * K';
end

if 1 == 0
% Compare linear and nonlinear simulation.
% This verifies that the linearization is valid.
close all;
figure;
plot(tArray, xArray(1,:), tArray,xlinArray(1,:),'--'); title('ia');
figure;
plot(tArray, xArray(2,:), tArray,xlinArray(2,:),'--'); title('ib');
figure;
plot(tArray, xArray(3,:), tArray,xlinArray(3,:),'--'); title('speed');
figure;
plot(tArray, xArray(4,:), tArray,xlinArray(4,:),'--'); title('position');
return;
end

% Plot data.
close all;
figure;
plot(tArray, xArray(1,:), tArray,xhatArray(1,:),'r:'); title('Winding A Current', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds'); ylabel('Amps');
legend('True', 'Estimated');

figure;
plot(tArray, xArray(2,:), tArray,xhatArray(2,:),'r:'); title('Winding B Current', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds'); ylabel('Amps');
legend('True', 'Estimated');

figure;
plot(tArray, xArray(3,:), tArray,xhatArray(3,:),'r:'); title('Rotor Speed', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds'); ylabel('Radians / Sec');
legend('True', 'Estimated');

figure;
plot(tArray, xArray(4,:), tArray,xhatArray(4,:),'r:'); title('Rotor Position', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds'); ylabel('Radians');
legend('True', 'Estimated');

figure;
plot(tArray, trPArray); title('Trace(P)', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Seconds');

% Compute the std dev of the estimation errors
N = size(xArray, 2);
N2 = round(N / 2);
xArray = xArray(:,N2:N);
xhatArray = xhatArray(:,N2:N);
iaEstErr = sqrt(norm(xArray(1,:)-xhatArray(1,:))^2 / size(xArray,2));
ibEstErr = sqrt(norm(xArray(2,:)-xhatArray(2,:))^2 / size(xArray,2));
wEstErr = sqrt(norm(xArray(3,:)-xhatArray(3,:))^2 / size(xArray,2));
thetaEstErr = sqrt(norm(xArray(4,:)-xhatArray(4,:))^2 / size(xArray,2));
disp(['Std Dev of Estimation Errors = ',num2str(iaEstErr),', ',num2str(ibEstErr),', ',num2str(wEstErr),', ',num2str(thetaEstErr)]);

% Display the P version of the estimation error standard deviations
disp(['Sqrt(P) = ',num2str(sqrt(P(1,1))),', ',num2str(sqrt(P(2,2))),', ',num2str(sqrt(P(3,3))),', ',num2str(sqrt(P(4,4)))]);

