function [] = plot_kriging_2inputs(model,x,y,x_range,num_points)

% ========================================================================
% Purpose: Create a kriging plot of the upper and lower bounds based on the
% predected variance. Also, plot the mean prediction of the krigng model.
% inputs: model - model structure created by krigms function
%         x - input samples
%         y - outputs of the true function as a function of x
%         x_range - first column lower bounds and second column upper
%                   bounds
%         num_points - number of points used in the meshgrid
% outputs: none, except a plot
% date created: April 6, 2010
% ========================================================================

% create the meshgrid for the two inputs
[x1,x2] = meshgrid(x_range(1,1):(x_range(1,2)-x_range(1,1))/(num_points-1):x_range(1,2),x_range(2,1):(x_range(2,2)-x_range(2,1))/(num_points-1):x_range(2,2));
[m,n] = size(x1);

% Create the prediction
mean = zeros(m,n); var = zeros(m,n);
for i = 1:m
    for j = 1:n
        [mean(i,j) var(i,j)] = krigpred(model,[x1(i,j) x2(i,j)]);
    end
end

% Create the upper and lower bounds of the plot
ub = mean + 1.96*sqrt(var);
lb = mean - 1.96*sqrt(var);

% create the plots of the prediction
figure('Color',[1 1 1])
surf(x1,x2,ub,'FaceColor',[0.75 0.75 0.75],'EdgeColor','none','FaceAlpha',0.5)
hold on
surf(x1,x2,mean,'FaceColor','y','FaceAlpha',0.5,'EdgeColor','none')
% plot the sample points
for i = 1:length(x(:,1))
    plot3(x(i,1),x(i,2),y(i),'ok','MarkerFaceColor','k');
    plot3([x(i,1);x(i,1)],[x(i,2);x(i,2)],[0;y(i)],'-k','LineWidth',2);
end
surf(x1,x2,lb,'FaceColor',[0.75 0.75 0.75],'EdgeColor','none','FaceAlpha',0.5)
grid on
xlabel('x_1');ylabel('x_2');zlabel('Y');
legend('95% CI','Prediction','samples','location','NorthEast')