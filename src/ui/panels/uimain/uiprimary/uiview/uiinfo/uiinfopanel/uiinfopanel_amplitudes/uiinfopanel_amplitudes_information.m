classdef uiinfopanel_amplitudes_information < TComponent
    properties (Constant)
        Type = "panel"
    end
    properties (SetAccess = immutable)
        uitx
    end

    methods 
        function updateuiinfo_amplitudes(obj)
            a = obj.Data.uiinfo_amplitudes.amplitudes;
            s = obj.Data.uiinfo_selection.selection;

            s32 = median(a, 'all', 'omitnan');
            s42 = mean(a, 'all', 'omitnan');
            s52 = std(a, 0, 'all', 'omitnan');
            s62 = sum(isfinite(a), 'all');

            if isnan(s32);  s32 = [];   end
            if isnan(s42);  s42 = [];   end
            if isnan(s52);  s52 = [];   end

            set(obj.uitx(3, 2), 'String', num2str(s32, '%.2f'))
            set(obj.uitx(4, 2), 'String', num2str(s42, '%.2f'))
            set(obj.uitx(5, 2), 'String', num2str(s52, '%.2f'))
            set(obj.uitx(6, 2), 'String', num2str(s62))

            s33 = median(a(s), 'all', 'omitnan');
            s43 = mean(a(s), 'all', 'omitnan');
            s53 = std(a(s), 0, 'all', 'omitnan');
            s63 = sum(isfinite(a(s)), 'all');

            if isnan(s33);  s33 = [];   end
            if isnan(s43);  s43 = [];   end
            if isnan(s53);  s53 = [];   end

            set(obj.uitx(3, 3), 'String', num2str(s33, '%.2f'))
            set(obj.uitx(4, 3), 'String', num2str(s43, '%.2f'))
            set(obj.uitx(5, 3), 'String', num2str(s53, '%.2f'))
            set(obj.uitx(6, 3), 'String', num2str(s63))
        end
    end
    methods % CONSTRUCTOR
        function obj = uiinfopanel_amplitudes_information()
            set(obj.Handle, ...
                'BackgroundColor', [128 128 128]/256)

            g = uix.Grid(...
                'Parent', obj.Handle, ...
                'BackgroundColor', [128 128 128]/256, ...
                'Padding', 3, ...
                'Spacing', 3);

            r = 7;
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
            set(obj.uitx(3:6, 1), ...
                ... Text and Styling
                {'String'}, {'Median'; 'Mean'; 'SD'; 'Samples'});
            
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
                'Heights', [10 18 13 13 13 13 -1], ...
                'Widths', [45 -1 -1])
        end
    end     % CONSTRUCTOR
end