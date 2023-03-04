classdef uiinfopanel_velocities_information < TComponent
    properties (Constant)
        Type = 'panel'
    end
    properties (SetAccess = immutable)
        uitx
    end

    methods
        function updateuiinfo_velocities(obj)
            v = obj.Data.uiinfo_velocities.velocities;
            b = obj.Data.uiinfo_velocities.directions;
            s = obj.Data.uiinfo_selection.staggered;

            sb = sin(b);
            cb = cos(b);
            
            sba = mean(sb, 'all', 'omitnan');
            cba = mean(cb, 'all', 'omitnan');
            
            s32 = median(v, 'all', 'omitnan');
            s42 = mad(v, 1, 'all');
            s52 = atan(sba/cba);
            s62 = sqrt(1 - (sba^2 + cba^2));
            s72 = sum(isfinite(v), 'all');

            s52 = wrapTo360(rad2deg(s52));
            s62 = wrapTo360(rad2deg(s62));
            
            if isnan(s32);  s32 = [];   end
            if isnan(s42);  s42 = [];   end
            if isnan(s52);  s52 = [];   end
            if isnan(s62);  s52 = [];   end
            
            set(obj.uitx(3, 2), 'String', num2str(s32, '%.2f'))
            set(obj.uitx(4, 2), 'String', num2str(s42, '%.2f'))
            set(obj.uitx(5, 2), 'String', num2str(s52, '%.2f') + "°")
            set(obj.uitx(6, 2), 'String', num2str(s62, '%.2f') + "°")
            set(obj.uitx(7, 2), 'String', num2str(s72))
            
            sbs = mean(sb(s), 'all', 'omitnan');
            cbs = mean(cb(s), 'all', 'omitnan');
            
            s33 = median(v(s), 'all', 'omitnan');
            s43 = mad(v(s), 1, 'all');
            s53 = real(atan(sbs/cbs));
            s63 = real(sqrt(1 - (sbs^2 + cbs^2)));
            s73 = sum(isfinite(v(s)), 'all');

            if isnan(s33);  s33 = [];   end
            if isnan(s43);  s43 = [];   end
            if isnan(s53);  s53 = [];   end
            if isnan(s63);  s63 = [];   end
            
            s53 = wrapTo360(rad2deg(s53));
            s63 = wrapTo360(rad2deg(s63));

            set(obj.uitx(3, 3), 'String', num2str(s33, '%.2f'))
            set(obj.uitx(4, 3), 'String', num2str(s43, '%.2f'))
            set(obj.uitx(5, 3), 'String', num2str(s53, '%.2f') + "°")
            set(obj.uitx(6, 3), 'String', num2str(s63, '%.2f') + "°")
            set(obj.uitx(7, 3), 'String', num2str(s73))
        end
    end
    methods % CONSTRUCTOR
        function obj = uiinfopanel_velocities_information()
            set(obj.Handle, ...
                'BackgroundColor', [128 128 128]/256)

            g = uix.Grid(...
                'Parent', obj.Handle, ...
                'BackgroundColor', [128 128 128]/256, ...
                'Padding', 3, ...
                'Spacing', 3);

            r = 8;
            c = 3;
            
            obj.uitx = gobjects(r, c);

            % Create grid of text uicontrols
            % Rows then columns as per uix.Grid
            for j = 1:c
                for i = 1:r
                    obj.uitx(i, j) = uicontrol(g, ...
                        ... Type
                        'Style', 'Text', ...
                        ... Text and Styling
                        'String', '', ...
                        'ForegroundColor', 'w', ...
                        'BackgroundColor', g.BackgroundColor);
                end
            end

            % Set default text
            set(obj.uitx(:, 1), ...
                ... Position
                'HorizontalAlignment', 'right')
            set(obj.uitx(3:7, 1), ...
                ... Text and Styling
                {'String'}, {'Speed'; 'MAD'; 'Bearing'; 'SD'; 'Samples'});
            
            set(obj.uitx(:, 2:end), ...
                ... Position
                'HorizontalAlignment', 'center')

            set(obj.uitx(2, 2), ...
                ... Text and Styling
                'String', 'All');
            set(obj.uitx(2, 3), ...
                ... Text and Styling
                'String', 'Selection');
            
            % Set grid arrangement
            set(g, ...
                'Heights', [0 13 13 18 13 18 13 -1], ...
                'Widths', [45 -1 -1])
        end
    end     % CONSTRUCTOR
end