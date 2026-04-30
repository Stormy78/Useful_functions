prism_A_coords.x  = P_A_front(1) + [-delta delta t_prism t_prism];
prism_A_coords.y = [-d_prism/2 d_prism/2 d_prism/2 -d_prism/2];

prism_B_coords.x = P_B_front(1) + [0 0 t_prism + delta t_prism-delta];
prism_B_coords.y = prism_A_coords.y;

figure('Position',[0 0 1200 500])

ax1 = subplot(1,5,1:3);

patch(prism_A_coords.x, prism_A_coords.y, 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'none'), hold on
quiver(P_A_front(1), P_A_front(2), n_A_i(1), n_A_i(2),'LineWidth',3, AutoScale='on', AutoScaleFactor=d_prism/3, LineStyle='-', Color='b' )
patch(prism_B_coords.x, prism_B_coords.y, 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'none')
quiver(P_B_back(1), P_B_back(2), n_B_i(1), n_B_i(2),'LineWidth',3, AutoScale='on', AutoScaleFactor=d_prism/3, LineStyle='-', Color='b' )

plot(trace_points(:,1), trace_points(:,2), 'o', 'MarkerFaceColor','red', MarkerSize=8)

for i = 1:length(trace_points)-1
    pi = trace_points(i,:);
    po = trace_points(i+1,:);
    quiver(pi(1), pi(2), po(1)-pi(1), po(2)-pi(2),'LineWidth',1, LineStyle='-', Color='r', AutoScale='on', AutoScaleFactor=1.0, ShowArrowHead='on')
end

yline(0, 'b--')
xline(P_screen(1), 'b-', LineWidth=3)
xlabel('\rightarrow x_{axis}', 'Color','r', FontSize=15)
ylabel('\rightarrow y_{axis}', 'Color','r', FontSize=15)
axis equal
grid minor
xlim([Q_i(1) P_screen(1)])
ylim([-15 15])

ax2 = subplot(1,5,4:5);
plot(trace_points(end,3), trace_points(end,2), 'ro', 'MarkerFaceColor','red', MarkerSize=10), hold on;
plot([-1 1; 0 0]', [0 0; -1 1]', 'r-', LineWidth=2)
xlabel('\rightarrow z_{axis}', 'Color','r', FontSize=15)
axis equal
grid minor
box on
xlim([-15 15])
linkaxes([ax1 ax2],'y')

drawnow