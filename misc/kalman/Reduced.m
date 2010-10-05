function Reduced

% Reduced order Kalman filter simulation.
% Estimate the first state of a two-state system.

F = [.9 .1; .2 .7]; % System matrix
%F = [1.1 -.1; .2 .7]; % System matrix
Lambda1 = 1;
Lambda2 = 0;
Q = 0.1; % Process noise covariance
H1 = 0;
H2 = 1;
R = 1; % Measurement noise covariance

Lambda = [Lambda1; Lambda2]; % Noise input matrix
H = [H1 H2]; % Measurement matrix

Ktol = 0.00001; % tolerance for convergence of gain to steady state
NumSteps = 50; % number of simulation steps

close all; % close all figures

% Iteratively compute the steady state reduced filter Kalman gain
P = 0;
PIt = 0;
PItOld = 0;
PItt = 0;
PIttOld = 0;
Ptt = 0;
Pt = 0;
Sigma = 0;
K = 0;

x = [0; 0]; % Initial state vector
xhat = [0; 0]; % Initial state estimate
xhatReduced = 0; % Initial reduced order state estimate
Pplus = [0 0; 0 0]; % Initial Kalman filter estimation error covariance
I = eye(2); % Identity matrix
ErrArray = [x - xhat]; % Array of Kalman filter estimation errors
ErrReducedArray = [x(1) - xhatReduced]; % Array of reduced order filter estimation errors
x1Array = [x(1)];
xhatReducedArray = [x(1)];
KArray = [];
PttArray = [];
PtArray = [];
PArray = [];
SigmaArray = [];

randn('state', sum(100*clock)); % initialize the random number generator

% Try to find a steady state reduced order gain.
temp1 = H1 * F(1,2) + H2 * F(2,2);
temp2 = H1 * Lambda1 + H2 * Lambda2;
for k = 1 : 200
   A = H1 * F(1,1) * P * F(1,1)' * H1';
   A = A + H1 * F(1,1) * Sigma * temp1';
   A = A + temp1 * Sigma' * F(1,1) * H1';
   A = A - H1 * F(1,1) * PItt * temp1';
   A = A - temp1 * PItt' * F(1,1) * H1';
   A = A + H1 * F(1,1) * Pt * F(2,1) * H2';
   A = A + H2 * F(2,1) * Pt * F(1,1) * H1';
   A = A - H1 * F(1,1) * PIt * F(2,1) * H2';
   A = A - H2 * F(2,1) * PIt * F(1,1) * H1';   
   A = A + temp1 * Ptt * temp1';
   A = A + temp1 * Sigma' * F(2,1) * H2';
   A = A + H2 * F(2,1) * Sigma * temp1';
   A = A + H2 * F(2,1) * Pt * F(2,1) * H2';
   A = A + R;
   A = A + temp2 * Q * temp2';
      
   B = F(1,1) * P * F(1,1) * H1';
   B = B + F(1,2) * Sigma' * F(1,1) * H1';
   B = B + F(1,1) * Sigma * temp1';
   B = B - F(1,2) * PItt' * F(1,1) * H1';
   B = B - F(1,1) * PItt * temp1';   
   B = B + F(1,1) * Pt * F(2,1) * H2';
   B = B - F(1,1) * PIt * F(2,1) * H2';
   B = B + F(1,2) * Ptt * temp1';
   B = B + F(1,2) * Sigma' * F(2,1) * H2';
   B = B + Lambda1 * Q * temp2';

   KOld = K;
   K = B * inv(A);
   
   KArray = [KArray K];
   if (k > 3) & (abs((K - KOld) / K) < Ktol)
      break;
   end
      
   PIttOld = PItt;
   PItt = (1 - K * H1) * F(1,1) * (PIt * F(2,1) + PItt * F(2,2));
   PItt = PItt + K * (H1 * F(1,1) + H2 * F(2,1)) * (Pt * F(2,1) + Sigma * F(2,2));
   PItt = PItt + K * temp1 * (Sigma' * F(2,1) + Ptt * F(2,2));
   PItt = PItt + K * temp2 * Q * Lambda2';
   
   PItOld = PIt;
   PIt = (1 - K * H1) * F(1,1) * (PIt * F(1,1) + PIttOld * F(1,2));
   PIt = PIt + K * (H1 * F(1,1) + H2 * F(2,1)) * (Pt * F(1,1) + Sigma * F(1,2));
   PIt = PIt + K * temp1 * (Sigma' * F(1,1) + Ptt * F(1,2));
   PIt = PIt + K * temp2 * Q * Lambda1';
   
   temp3 = F(1,2) - K * H1 * F(1,2) - K * H2 * F(2,2);
   P = (1 - K * H1)^2 * F(1,1)^2 * P;
   P = P + 2 * (1 - K * H1) * F(1,1) * Sigma * temp3;
   P = P - 2 * (1 - K * H1) * F(1,1) * PIttOld * temp3;
   P = P - 2 * (1 - K * H1) * F(1,1) * Pt * F(2,1) * H2' * K';
   P = P + 2 * (1 - K * H1) * F(1,1) * PItOld * F(2,1) * H2' * K';   
   P = P + temp3^2 * Ptt;
   P = P - 2 * temp3 * Sigma' * F(2,1) * H2' * K;
   P = P + K^2 * H2^2 * F(2,1)^2 * Pt;
   P = P + K^2 * R;
   P = P + (Lambda1 - K * H1 * Lambda1 - K * H2 * Lambda2)^2 * Q;
   
   PttOld = Ptt;
   PtOld = Pt;
   SigmaOld = Sigma;
   
   Ptt = F(2,1)^2 * Pt + 2 * F(2,1) * Sigma * F(2,2) + F(2,2)^2 * Ptt + Lambda2^2 * Q;
   Pt = F(1,1)^2 * Pt + 2 * F(1,1) * Sigma * F(1,2) + F(1,2)^2 * PttOld + Lambda1^2 * Q;
   Sigma = F(1,1) * PtOld * F(2,1) + F(1,1) * SigmaOld * F(2,2);
   Sigma = Sigma + F(1,2) * SigmaOld * F(2,1) + F(1,2) * PttOld * F(2,2);
   Sigma = Sigma + Lambda1 * Q * Lambda2;
   
   PttArray = [PttArray Ptt];
   PtArray = [PtArray Pt];
   PArray = [PArray P];
   SigmaArray = [SigmaArray Sigma];
   
end

figure; plot(KArray); title('Reduced order gain', 'FontSize', 12); 
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Iteration Number');

if abs((K - KOld) / K) > Ktol
   disp('Reduced order Kalman gain did not converge to a steady state value');
   return;
end

for k = 1 : NumSteps
   % System simultion
   x = F * x + Lambda * sqrt(Q) * randn;
   z = H * x + sqrt(R) * randn;
   % Full order Kalman filter simulation (time varying)
   Pminus = F * Pplus * F' + Lambda * Q * Lambda';
   KStd = Pminus * H' * inv(H * Pminus * H' + R);
   xhat = F * xhat;
   xhat = xhat + KStd  * (z - H * xhat);
   Pplus = (I - KStd  * H) * Pminus * (I - KStd  * H)' + KStd  * R * KStd';
   % Reduced order Kalman filter simulation (steady state)
   xhatReduced = F(1,1) * xhatReduced + K * (z - H1 * F(1,1) * xhatReduced);
   % Save data for plotting
   x1Array = [x1Array x(1)];
   xhatReducedArray = [xhatReducedArray xhatReduced ];
   ErrArray = [ErrArray x-xhat];
   ErrReducedArray = [ErrReducedArray x(1)-xhatReduced];
end

% Compute estimation errors
Err = sqrt(norm(ErrArray(1,:))^2 / size(ErrArray,2));
disp(['Full order estimation std dev (analytical and experimental) = ',num2str(sqrt(Pplus(1,1))),', ',num2str(Err)]);
ErrReduced = sqrt(norm(ErrReducedArray(1,:))^2 / size(ErrReducedArray,2));
disp(['Reduced order estimation std dev (analytical and experimental) = ',num2str(sqrt(P)),', ',num2str(ErrReduced)]);

% Plot results
k = 0 : NumSteps;
figure; plot(PttArray); title('Ptt', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Iteration Number');
figure; plot(PtArray); title('Pt', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Iteration Number');
figure; plot(PArray); title('P', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Iteration Number');
figure; plot(SigmaArray); title('Sigma', 'FontSize', 12);
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Iteration Number');
figure; plot(k,ErrArray(1,:),'r:');
hold on;
plot(k,ErrReducedArray, 'b');
set(gca,'FontSize',12); set(gcf,'Color','White');
xlabel('Time Step');
legend('Std Kalman filter error', 'Reduced filter error');
