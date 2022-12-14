clear all; clc; close all;

%% Simulation Parameters
dt = 0.1; %time step size
ts = 300; %simulation time
t = 0:dt:ts; % time span

%% Vehicle (Mobile Robot) Physical Parameters
a = 0.2; % radius of the wheel (meter, fixed)
d = 0.5; % distance between wheel frame to vehicle frame (along y-axis) (unsure of meaning JV)

%% Initial Conditions
xO = 0.5;
yO = 0.5;
psiO = pi/4; %starting frame of object 45 degree angle 

etaO = [xO;yO;psiO];

eta(:,1) = etaO;

%% loop starts here
for i = 1:length(t)
    psi = eta(3,i); %current orientation in radians
% Jacobian matrix
J_psi = [cos(psi),-sin(psi), 0;
         sin(psi), cos(psi), 0;
          0,           0,    1]; % Rotation around z-axis (JV)

%% inputs
omega_1 = 0.5; %left wheel angular velocity (rad/sec)
omega_2 = 0.2; %right wheel angular velocity (rad/sec), rotation
omega = [omega_1;omega_2]; %omega is vector of 2 omegas

%% Wheel configuration matrix
W = [a/2, a/2;
    0, 0;
    -a/(2*d), a/(2*d)]

    % Velocity Input Commands
    zeta(:,i) = W*omega;

% Time derivative of generalized coordinates
eta_dot(:,i) = J_psi*zeta(:,i);

%% Position propagation using Euler method
eta(:,i+1) = eta(:,i)+ dt * eta_dot(:,i); %state update
% generalized coordinates
end
figure
plot (t, eta(1,1:i),'r-');
hold on
plot (t,eta(2,1:i),'b--');
plot(t, eta(3,1:i),'m-.');
legend('x,[m]', 'y,[m]','\psi,[rad]');
set(gca, 'fontsize',24);
xlabel('t,[s]');
ylabel('\eta,[units]');

%% Animation (mobile robot motion animation)
l = 0.4; % length of the mobile robot
w = 2*d; % width of the mobile robot

%Mobile robot coordinates
mr_co = [-1/2, 1/2, 1/2, -1/2, -1/2;
         -w/2, -w/2, w/2, w/2, -w/2];
figure
for i = 5:length(t) % animation starts here
    psi = eta(3,i);
    R_psi = [cos(psi), -sin(psi);
              sin(psi), cos(psi);]; %rotation matrix
v_pos = R_psi*mr_co;
fill(v_pos(1,:)+eta(1,i),v_pos(2,:)+eta(2,i),'g')
hold on, grid on
axis([-5 5 -5 5]), axis square
plot(eta(1,1:i),eta(2,1:i), 'b-');
legend('Robot','Path');
set(gca,'fontsize',24);
xlabel('x,[m]'); ylabel('y,[m]');
pause(0.01);
hold off
end % animation ends here
