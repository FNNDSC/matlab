function Schmidt

% Reduced order Kalman filter using consider states.

phix = 1; phiy = 1;
phi = [phix 0; 0 phiy];
Qx = 1; Qy = 0;
Q = [Qx 0; 0 Qy];
Hx = 1; Hy = 1;
H = [Hx Hy];
R = 1;
Pxminus = 1.6; Pxyminus = 0; Pyxminus = Pxyminus'; Pyminus = 1;
Pminus = [Pxminus Pxyminus; Pyxminus Pyminus];

x = [0; 0];
xhatminus = [0; 0];
xhatminusSchmidt = [0];

xhatErr = [];
xhatErrSchmidt = [];

for t = 0 : 1000
    % Simulate the measurement
    z = H * x + sqrt(R) * randn;
    % Simulate the full order filter
    K = Pminus * H' * inv(H * Pminus * H' + R);
    xhatplus = xhatminus + K * (z - H * xhatminus);
    Pplus = (eye(2) - K * H) * Pminus * (eye(2) - K * H)' + K * R * K';
    xhatminus = phi * xhatplus;
    Pminus = phi * Pplus * phi' + Q;
    % Simulate the Kalman-Schmidt filter
    alpha = Hx * Pxminus * Hx' + Hx * Pxyminus * Hy' + Hy * Pxyminus * Hx' + Hy * Pyminus * Hy' + R;
    Kx = (Pxminus * Hx' + Pxyminus * Hy') * inv(alpha);
    xhatplusSchmidt = xhatminusSchmidt + Kx * (z - Hx * xhatminusSchmidt);
    Pxplus = (eye(1) - Kx * Hx) * Pxminus - Kx * Hy * Pyxminus;
    Pxyplus = (eye(1) - Kx * Hx) * Pxyminus - Kx * Hy * Pyminus;
    Pyxplus = Pxyplus';
    Pyplus = Pyminus;
    xhatminusSchmidt = phix * xhatplusSchmidt;
    Pxminus = phix * Pxplus * phix' + Qx;
    Pxyminus = phix * Pxyplus * phiy';
    Pyxminus = Pxyminus';
    Pyminus = phiy * Pyplus * phiy' + Qy;    
    % Save data for later
    xhatErr = [xhatErr; x(1) - xhatplus(1)];
    xhatErrSchmidt = [xhatErrSchmidt; x(1) - xhatplusSchmidt];
    % Simulate the state dynamics
    x = phi * x + [Qx * randn; Qy * randn];
end

t = 0 : 20;
close all;
plot(t, xhatErr(1:21), 'r-', t, xhatErrSchmidt(1:21), 'b--'); grid;
set(gca,'FontSize',12); set(gcf,'Color','White');
legend('full order filter', 'reduced order filter');
xlabel('time'); ylabel('estimation error');

xhatErr = std(xhatErr);
xhatErrSchmidt = std(xhatErrSchmidt);
disp(['RMS Error = ', num2str(xhatErr), ' (full order filter), ', num2str(xhatErrSchmidt), ' (Schmidt filter)']);