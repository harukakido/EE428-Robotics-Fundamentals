%Video Start
vid = VideoWriter('video name.avi');
vid.FrameRate = 1;
vid.Quality = 100;
open(vid)

path = [7.00    7.00;
        6.00    8.00;
        5.00    7.00;
        6.00    6.00;
        7.00    5.00;
        6.00    4.00;
        5.00    5.00;
        6.00    6.05;
        7.00    6.95];
robotInitialLocation = path(1,:);
robotGoal = path(end,:);
initialOrientation = 0;
robotCurrentPose = [robotInitialLocation initialOrientation]';
robot = differentialDriveKinematics("TrackWidth", 1, "VehicleInputs", "VehicleSpeedHeadingRate");
figure
plot(path(:,1), path(:,2),'k--d')
xlim([0 13])
ylim([0 13])
controller = controllerPurePursuit;
controller.Waypoints = path;
controller.DesiredLinearVelocity = 0.6;
controller.MaxAngularVelocity = 2;
controller.LookaheadDistance = 0.75;
goalRadius = 0.04;
distanceToGoal = norm(robotInitialLocation - robotGoal);
% Initialize the simulation loop
sampleTime = 0.1;
vizRate = rateControl(1/sampleTime);

% Initialize the figure
figure

% Determine vehicle frame size to most closely represent vehicle with plotTransforms
frameSize = robot.TrackWidth/0.8;

while( distanceToGoal > goalRadius )
    
    % Compute the controller outputs, i.e., the inputs to the robot
    [v, omega] = controller(robotCurrentPose);
    
    % Get the robot's velocity using controller inputs
    vel = derivative(robot, robotCurrentPose, [v omega]);
    
    % Update the current pose
    robotCurrentPose = robotCurrentPose + vel*sampleTime; 
    
    % Re-compute the distance to the goal
    distanceToGoal = norm(robotCurrentPose(1:2) - robotGoal(:));
    
    % Update the plot
    hold off
    
    % Plot path each instance so that it stays persistent while robot mesh
    % moves
    plot(path(:,1), path(:,2),"k--d")
    hold all
    
    % Plot the path of the robot as a set of transforms
    plotTrVec = [robotCurrentPose(1:2); 0];
    plotRot = axang2quat([0 0 1 robotCurrentPose(3)]);
    plotTransforms(plotTrVec', plotRot, "MeshFilePath", "groundvehicle.stl", "Parent", gca, "View","2D", "FrameSize", frameSize);
    light;
    xlim([0 13])
    ylim([0 13])
    
    waitfor(vizRate);
                   
frame = getframe(gcf);
writeVideo(vid,frame);
                   
end % animation ends here
                   
close(vid);
