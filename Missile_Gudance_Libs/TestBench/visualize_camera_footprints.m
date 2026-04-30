function visualize_camera_footprints(data, img_width_px, img_height_px, focal_length_mm, sensor_width_mm, debug)
% VISUALIZE_CAMERA_FOOTPRINTS  Project airborne camera images onto ground (2D NED)
%
% CAMERA FRAME:
%   X = forward  (boresight)
%   Y = right    (image horizontal axis)
%   Z = down     (image vertical axis, top->bottom)
%
% NED FRAME:
%   X = North, Y = East, Z = Down
%   Camera at Z_ned < 0 (above ground), ground at Z_ned = 0
%
% INPUT:
%   data             - Nx8 [index, time, X, Y, Z, Psi, Theta, Phi]
%                      positions in meters, angles in RADIANS, Euler 321
%   img_width_px     - image width  in pixels        (default: 4000)
%   img_height_px    - image height in pixels        (default: 3000)
%   focal_length_mm  - lens focal length in mm       (default: 35)
%   sensor_width_mm  - physical sensor width in mm   (default: 35.9  Sony A7 full-frame)
%   debug            - true/false diagnostics        (default: false)
%
% USAGE:
%   visualize_camera_footprints(data)
%   visualize_camera_footprints(data, 4000, 3000, 35, 35.9, true)

    if nargin < 2, img_width_px    = 4000;  end
    if nargin < 3, img_height_px   = 3000;  end
    if nargin < 4, focal_length_mm = 35;    end
    if nargin < 5, sensor_width_mm = 35.9;  end
    if nargin < 6, debug           = false; end

    % --- Sensor geometry (physical units, mm) ---
    pixel_pitch_mm   = sensor_width_mm / img_width_px;
    sensor_height_mm = pixel_pitch_mm  * img_height_px;
    hw_mm            = sensor_width_mm  / 2;
    hh_mm            = sensor_height_mm / 2;

    % --- FOV angles ---
    fov_h_deg = 2 * rad2deg(atan(hw_mm / focal_length_mm));
    fov_v_deg = 2 * rad2deg(atan(hh_mm / focal_length_mm));

    % --- Corner rays in camera frame (mm, consistent units — cancel on normalize) ---
    % Camera: X=forward (boresight), Y=right, Z=down
    % Image plane at X=f, corners at Y=+-hw, Z=+-hh
    corners_cam = [ focal_length_mm,  hw_mm,  hh_mm;    % bottom-right
                    focal_length_mm, -hw_mm,  hh_mm;    % bottom-left
                    focal_length_mm, -hw_mm, -hh_mm;    % top-left
                    focal_length_mm,  hw_mm, -hh_mm ]'; % top-right  (3x4)
    corners_cam = corners_cam ./ vecnorm(corners_cam);  % unit rays

    % --- Global debug header ---
    if debug
        fprintf('\n========== SENSOR / OPTICS ==========\n');
        fprintf('  Image size       : %d x %d px\n',   img_width_px, img_height_px);
        fprintf('  Focal length     : %.2f mm\n',       focal_length_mm);
        fprintf('  Sensor width     : %.2f mm\n',       sensor_width_mm);
        fprintf('  Sensor height    : %.2f mm\n',       sensor_height_mm);
        fprintf('  Pixel pitch      : %.4f mm\n',       pixel_pitch_mm);
        fprintf('  FOV horizontal   : %.2f deg\n',      fov_h_deg);
        fprintf('  FOV vertical     : %.2f deg\n',      fov_v_deg);
        fprintf('  Footprint @100m  : %.1f x %.1f m\n', ...
                2*100*tan(deg2rad(fov_h_deg/2)), ...
                2*100*tan(deg2rad(fov_v_deg/2)));
        fprintf('  Footprint @500m  : %.1f x %.1f m\n', ...
                2*500*tan(deg2rad(fov_h_deg/2)), ...
                2*500*tan(deg2rad(fov_v_deg/2)));
        fprintf('  Corner rays (unit, cam frame):\n');
        corner_names = {'BR','BL','TL','TR'};
        for c = 1:4
            fprintf('    %s: [%6.4f, %6.4f, %6.4f]\n', ...
                    corner_names{c}, corners_cam(1,c), corners_cam(2,c), corners_cam(3,c));
        end
    end

    % --- Plot setup ---
    fig = figure('Name','Camera Footprints - Ground Frame','Color','w', 'Position',[0 0 1000 1000]);
    ax  = axes('Parent', fig);
    hold(ax, 'on');
    axis(ax, 'equal');
    grid(ax, 'on');
    xlabel(ax, 'Y – East (m)');
    ylabel(ax, 'X – North (m)');
    title(ax, 'Camera Image Footprints on Ground (NED 2D) — click legend to toggle');
    set(ax, 'YDir', 'normal');
    colors = lines(size(data, 1));

    % Storage for legend toggle
    frame_handles = cell(size(data, 1), 1);
    legend_entries = gobjects(size(data, 1), 1);

    for k = 1:size(data, 1)
        idx   = data(k,1);
        X_ned = data(k,3);
        Y_ned = data(k,4);
        Z_ned = data(k,5);
        psi   = data(k,6);
        theta = data(k,7);
        phi   = data(k,8);

        % --- Euler 321 rotation matrix: body -> NED ---
        cp = cos(psi);   sp = sin(psi);
        ct = cos(theta); st = sin(theta);
        cr = cos(phi);   sr = sin(phi);

        R = [cp*ct,  cp*st*sr - sp*cr,  cp*st*cr + sp*sr;
             sp*ct,  sp*st*sr + cp*cr,  sp*st*cr - cp*sr;
            -st,     ct*sr,             ct*cr           ];

        rays_ned      = R * corners_cam;
        boresight_ned = R * [1; 0; 0];

        % ---- DEBUG per frame ---------------------------------------------
        if debug
            fprintf('\n---------- Frame %d ----------\n', idx);
            fprintf('  Position NED : X=%.2f  Y=%.2f  Z=%.2f\n', X_ned, Y_ned, Z_ned);
            fprintf('  Altitude     : %.2f m\n', -Z_ned);
            fprintf('  Angles (rad) : psi=%.4f  theta=%.4f  phi=%.4f\n', psi, theta, phi);
            fprintf('  Angles (deg) : psi=%.2f  theta=%.2f  phi=%.2f\n', ...
                    rad2deg(psi), rad2deg(theta), rad2deg(phi));
            if abs(psi) > 2*pi || abs(theta) > 2*pi || abs(phi) > 2*pi
                fprintf('  *** WARNING: angles look like degrees, not radians!\n');
            end
            fprintf('  R (body->NED):\n');
            fprintf('    [%6.3f  %6.3f  %6.3f]\n', R(1,:));
            fprintf('    [%6.3f  %6.3f  %6.3f]\n', R(2,:));
            fprintf('    [%6.3f  %6.3f  %6.3f]\n', R(3,:));
            fprintf('  Boresight NED : [%.3f, %.3f, %.3f]', boresight_ned);
            if     boresight_ned(3) >  1e-6, fprintf('  => pointing DOWN (OK)\n');
            elseif boresight_ned(3) < -1e-6, fprintf('  => pointing UP (PROBLEM)\n');
            else,                             fprintf('  => horizontal (PROBLEM)\n');
            end
            fprintf('  Corner rays NED (rz must be > 0 to hit ground):\n');
            corner_names = {'BR','BL','TL','TR'};
            for c = 1:4
                rz   = rays_ned(3,c);
                flag = '';
                if rz <= 1e-6, flag = '  *** FAILS ground check'; end
                fprintf('    %s: [%6.3f, %6.3f, %6.3f]  rz=%6.3f%s\n', ...
                        corner_names{c}, rays_ned(1,c), rays_ned(2,c), rays_ned(3,c), rz, flag);
            end
            if boresight_ned(3) > 1e-6
                t_c = -Z_ned / boresight_ned(3);
                fprintf('  Boresight ground hit : North=%.1f  East=%.1f  range=%.1f m\n', ...
                        X_ned + t_c*boresight_ned(1), ...
                        Y_ned + t_c*boresight_ned(2), t_c);
            end
            % Expected footprint size at this altitude
            alt = -Z_ned;
            fprintf('  Expected footprint   : %.1f x %.1f m  (nadir, this altitude)\n', ...
                    2*alt*tan(deg2rad(fov_h_deg/2)), ...
                    2*alt*tan(deg2rad(fov_v_deg/2)));
        end
        % ---- END DEBUG ---------------------------------------------------

        % --- Validate position ---
        if Z_ned >= 0
            warning('Frame %d: Z >= 0 (at or below ground), skipping.', idx);
            frame_handles{k} = [];
            continue;
        end

        % --- Ground intersection ---
        ground_pts = zeros(2, 4);
        valid = true;
        for c = 1:4
            rz = rays_ned(3, c);
            if rz <= 1e-6
                warning('Frame %d, corner %d: ray does not reach ground.', idx, c);
                valid = false;
                break;
            end
            t = -Z_ned / rz;
            ground_pts(1, c) = X_ned + t * rays_ned(1, c);   % North
            ground_pts(2, c) = Y_ned + t * rays_ned(2, c);   % East
        end

        if ~valid
            frame_handles{k} = [];
            continue;
        end

        px = ground_pts(1, :);   % North
        py = ground_pts(2, :);   % East

        % --- Footprint polygon ---
        h_fill = fill(ax, [py, py(1)], [px, px(1)], colors(k,:), ...
                      'FaceAlpha',  0.15, ...
                      'EdgeColor',  colors(k,:), ...
                      'LineWidth',  1.5, ...
                      'DisplayName', sprintf('Frame %d', idx));

        % --- Nadir point ---
        h_marker = plot(ax, Y_ned, X_ned, '+', ...
                        'Color',      colors(k,:), ...
                        'MarkerSize', 8, ...
                        'LineWidth',  1.5, ...
                        'HandleVisibility', 'off');

        % --- Index label at footprint centroid ---
        h_label = text(ax, mean(py), mean(px), sprintf('%d', idx), ...
                       'HorizontalAlignment', 'center', ...
                       'VerticalAlignment',   'middle', ...
                       'FontSize',   9, ...
                       'FontWeight', 'bold', ...
                       'Color',      colors(k,:) * 0.6);

        frame_handles{k}  = [h_fill, h_marker, h_label];
        legend_entries(k) = h_fill;
    end

    % --- Legend with click-to-toggle ---
    valid_mask = ~cellfun(@isempty, frame_handles);
    lg = legend(ax, legend_entries(valid_mask), 'Location', 'bestoutside');
    lg.ItemHitFcn = @(src, evt) toggleFrame(evt, frame_handles, valid_mask);

    hold(ax, 'off');
end


function toggleFrame(evt, frame_handles, valid_mask)
% Toggle visibility of all elements belonging to the clicked frame.

    clicked      = evt.Peer;
    valid_indices = find(valid_mask);

    for i = 1:numel(valid_indices)
        k       = valid_indices(i);
        handles = frame_handles{k};
        if isempty(handles), continue; end

        if handles(1) == clicked
            if strcmp(handles(1).Visible, 'on')
                set(handles(1), 'Visible', 'off');
                set(handles(2), 'Visible', 'off');
                set(handles(3), 'Visible', 'off');
                evt.Peer.Color(4) = 0.2;    % dim legend icon
            else
                set(handles(1), 'Visible', 'on');
                set(handles(2), 'Visible', 'on');
                set(handles(3), 'Visible', 'on');
                evt.Peer.Color(4) = 1.0;    % restore legend icon
            end
            break;
        end
    end
end