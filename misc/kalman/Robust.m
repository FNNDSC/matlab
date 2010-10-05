function Robust()
% Simulate a robust Kalman filter.

K_optimal = [0.02; 0.002]; % optimal Kalman gain for this problem
duration = 100; % simulation length
dt = 0.1; % step size
a = [1 dt;0 1]; % system matrix
b = [dt^2;dt]; % input matrix
B_w = eye(2); % noise input matrix
c = [1 0]; % measurement matrix

rho1 = 0.5; % relative weight on nominal Kalman filter performance
rho2 = 0.5; % relative weight on robustness
randn('state',sum(100*clock));
measnoise = 10; % std dev of measurement noise
accelnoise = 0.2; % std dev of process noise
R = measnoise^2; %measurement noise covariance
Q = accelnoise^2*[dt^4/4 dt^3/2;dt^3/2 dt^2]; %process noise covariance
x = [0; 0]; % initial state
xhat = x; % initial state estimate
xhat_new = x; % initial robust state estimate

x1hatnew=0; x2hatnew=0;
x1=0;x2=0;
x1hat=0;x2hat=0;
epsilon = 0.01;
zero_temp = eps*eye(2,2);
JArray = [];
K = K_optimal;

J = inf;
% Minimize the robust Kalman filter cost function
while (1 == 1)   
    X_1 = DARE ( (a-K*c*a)', zeros(2,2), (B_w-K*c*B_w)*Q*(B_w-K*c*B_w)', zero_temp, zeros(2,2), eye(2) );
    X_2 = DARE ( (a-K*c*a)', zeros(2,2), (K*R*K'), zero_temp, zeros(2,2), eye(2) );
    J_old = J;
    J = (rho1*(trace(X_1)+trace(X_2))) + (rho2*(trace(X_1)^2+trace(X_2)^2));
    disp(['J = ',num2str(J)]);
    JArray = [JArray J];
    if (J > 0.999*J_old ) 
        break; % convergence
    end;
    % Partial of J with respect to X1 and X2
    par_J_X1 = rho1*eye(2)+2*rho2*trace(X_1)*eye(2);
    par_J_X2 = rho1*eye(2)+2*rho2*trace(X_2)*eye(2);
    % Change K so that the partial of X1 and X2 w/r to K can be computed
    % numerically.
    D_K_1 = [K(1,1)*(1 + epsilon);K(2,1)];
    D_K_2 = [K(1,1);K(2,1)*(1 + epsilon)];
    % PARTIAL OF X_1 w/r to K
    X_1_new_K1 = DARE ( (a-D_K_1*c*a)', zeros(2,2), (B_w-D_K_1*c*B_w)*Q*(B_w-D_K_1*c*B_w)', zero_temp, zeros(2,2), eye(2) );
    X_1_delta_K1 = X_1 -X_1_new_K1;
    deltaX_1_K1 = [X_1_delta_K1(1,1) X_1_delta_K1(1,2) X_1_delta_K1(2,1) X_1_delta_K1(2,2)];
    X_1_new_K2 = DARE ( (a-D_K_2*c*a)', zeros(2,2), (B_w-D_K_2*c*B_w)*Q*(B_w-D_K_2*c*B_w)', zero_temp, zeros(2,2), eye(2) );
    X_1_delta_K2 = X_1 -X_1_new_K2;
    deltaX_1_K2 = [X_1_delta_K2(1,1) X_1_delta_K2(1,2) X_1_delta_K2(2,1) X_1_delta_K2(2,2)];
    DeltaX_1_K = [deltaX_1_K1;deltaX_1_K2];
    % Partial of X_2 w/r to K
    X_2_new_K1 = DARE ( (a-D_K_1*c*a)', zeros(2,2), (D_K_1*R*D_K_1'), zero_temp, zeros(2,2), eye(2) );  
    X_2_delta_K1 = X_2 -X_2_new_K1;
    deltaX_2_K1 = [X_2_delta_K1(1,1) X_2_delta_K1(1,2) X_2_delta_K1(2,1) X_2_delta_K1(2,2)];
    X_2_new_K2 = DARE ( (a-D_K_2*c*a)', zeros(2,2), (D_K_2*R*D_K_2'), zero_temp, zeros(2,2), eye(2) );
    X_2_delta_K2 = X_2 -X_2_new_K2;
    deltaX_2_K2 = [X_2_delta_K2(1,1) X_2_delta_K2(1,2) X_2_delta_K2(2,1) X_2_delta_K2(2,2)];
    DeltaX_2_K = [deltaX_2_K1;deltaX_2_K2];
    % Partial of J w/r to K 
    temp1 = par_J_X1(1,1)*DeltaX_1_K(1,1)+par_J_X1(1,2)*DeltaX_1_K(1,2)+par_J_X1(2,1)*DeltaX_1_K(1,3)+...
        par_J_X1(2,2)*DeltaX_1_K(1,4);
    temp2 = par_J_X1(1,1)*DeltaX_1_K(2,1)+par_J_X1(1,2)*DeltaX_1_K(2,2)+par_J_X1(2,1)*DeltaX_1_K(2,3)+...
        par_J_X1(2,2)*DeltaX_1_K(2,4);
    temp3 = par_J_X2(1,1)*DeltaX_2_K(1,1)+par_J_X2(1,2)*DeltaX_2_K(1,2)+par_J_X2(2,1)*DeltaX_2_K(1,3)+...
        par_J_X2(2,2)*DeltaX_2_K(1,4);
    temp4 = par_J_X2(1,1)*DeltaX_2_K(2,1)+par_J_X2(1,2)*DeltaX_2_K(2,2)+par_J_X2(2,1)*DeltaX_2_K(2,3)+...
        par_J_X2(2,2)*DeltaX_2_K(2,4);
    Delta_J_K = [temp1;temp2]+[temp3;temp4];
    % Use gradient descent to compute a new K
    K_new = K + epsilon*Delta_J_K;
    K = K_new;
end
beta1 = 3; % Variation in Q from nominal value
beta1 = 0;
beta2 = -0.8; % Variation in R from nominal value
beta2 = 0;
for t = 0:dt:duration
    u = 1; % control input
    ProcessNoise = (1+beta2)*accelnoise*[(dt^2/2)*randn;dt*randn];
    x = a*x+b*u+ProcessNoise;
    x1 = [x1 x(1)];
    x2 = [x2 x(2)];
    MeasNoise = (1+beta1)*measnoise*randn;
    y = c*x+MeasNoise;
    xhat = a*xhat+b*u;
    xhat_new = a*xhat_new+b*u;
    Inn1 = y-c*xhat;
    Inn2 = y-c*xhat_new;
    % Standard Kalman filter estimate
    xhat = xhat+K_optimal*Inn1;
    x1hat = [x1hat xhat(1)];
    x2hat = [x2hat xhat(2)];
    % Robust Kalman filter estimate
    xhat_new = xhat_new+K_new*Inn2;
    x1hatnew = [x1hatnew xhat_new(1)];
    x2hatnew = [x2hatnew xhat_new(2)];
end

x1_sqr = (x1-x1hatnew).^2;
x1_rms_robu = (mean(x1_sqr))^0.5;
x1_sqr_op = (x1-x1hat).^2;
x1_rms_opt = (mean(x1_sqr_op))^0.5;
disp(['RMS x1 error = ',num2str(x1_rms_robu),' (robust), ',num2str(x1_rms_opt),' (optimal)']);

x2_sqr = (x2-x2hatnew).^2;
x2_rms_robu = (mean(x2_sqr))^0.5;
x2_sqr_op = (x2-x2hat).^2;
x2_rms_opt = (mean(x2_sqr_op))^0.5;
disp(['RMS x2 error = ',num2str(x2_rms_robu),' (robust), ',num2str(x2_rms_opt),' (optimal)']);

