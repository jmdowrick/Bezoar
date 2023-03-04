classdef uisignalmain_edit < TComponent
    properties (Constant)
        Type = 'hggroup'
    end
    properties (SetAccess = immutable)
        rc; ln_select; ln_cursor; tx
    end
    properties (Access = private)
        channel         (1,1)   double = NaN
    end

    methods
        function updateuisign_settings(obj)
            obj.channel = NaN;

            switch obj.Data.uisign_settings.mode
                case 'edit'
                    set(obj.Handle, ...
                        'Visible', 'on', ...
                        'HitTest', 'on', ...
                        'PickableParts', 'all')

                    if isequal(obj.Handle, hittest) || isequal(obj.Parent.Handle, hittest)
                        obj.traverseFcn()
                    end
                otherwise
                    set(obj.Handle, ...
                        'Visible', 'off', ...
                        'HitTest', 'off', ...
                        'PickableParts', 'none')
            end
        end
        function updateuisign(obj)
            obj.channel = NaN;
        end
    end
    methods (Access = protected)
        function mouseClick(obj)
            p = obj.CurrentPosition;

            ic = round(obj.Data.uisign.n - p(2)) + 1;
            ic = max(min(ic, obj.Data.uisign.n), 0);

            obj.channel = ic;
        end
        function mouseDrag(obj)
            p = obj.CurrentPosition;

            at = obj.Data.uiprvw.at;
            at(obj.Data.uisign.indices_grid(obj.channel)) = p(1);

            obj.Data.uiprvw.modifyWave(at)
        end
        function mouseRelease(obj)
            obj.channel = NaN;
        end
        
        function mouseClickRight(obj)
            p = obj.CurrentPosition;

            ic = round(obj.Data.uisign.n - p(2)) + 1;
            ic = max(min(ic, obj.Data.uisign.n), 0);

            at = obj.Data.uiprvw.at;
            at(obj.Data.uisign.indices_grid(ic)) = NaN;

            obj.Data.uiprvw.modifyWave(at)
        end

        function traverseFcn(obj)
            set(obj.Handle, 'Visible', 'on')

            p = obj.CurrentPosition;
            n = obj.Data.uisign.n;

            if isnan(obj.channel)
                ic = round(obj.Data.uisign.n - p(2)) + 1;
                ic = max(min(ic, obj.Data.uisign.n), 0);

                c = obj.Data.uisign.indices(ic);
                e = obj.Data.evnt.e(:, c);
                e(e == obj.Data.uiprvw.i) = 0;

                set(obj.ln_select, ...
                    'Color', [256 256 000]/256, ...
                    'LineWidth', 1, ...
                    'XData', obj.Data.uisign_signals.time, ...
                    'YData', obj.Data.uisign_signals.signals(:, ic), ...
                    'MarkerIndices', find(e), ...
                    'Visible', 'on')
            else
                ic = obj.channel;
            end

            x = p(1);
            y = n - ic + 1;

            set(obj.rc, ...
                'Position', [0 y - 0.5 86400 1], ...
                'FaceColor', [256 256 000 032]/256, ...
                'Visible', 'on')
            set(obj.ln_cursor, ...
                'XData', [x x], ...
                'YData', y + [-0.5 0.5], ...
                'MarkerIndices', [], ...
                'Visible', 'on')
        end
        function exitFcn(obj)
            if isnan(obj.channel)
                set(obj.Handle, 'Visible', 'off')
            end
        end
    end

    methods % CONSTRUCTOR
        function obj = uisignalmain_edit()
            set(obj.Handle, ...
                ... Interactivity
                'Visible', 'off', ...
                ... Callback Execution Control
                'HitTest', 'off')

            obj.rc = rectangle(obj.Handle, ...
                ... Color and Styling
                'FaceColor', [256 256 000 008]/256, ...
                'EdgeColor', 'none', ...
                ... Position
                'Position', [0 0.5 86400 1]);
            obj.ln_select = line(obj.Handle, ...
                ... Line
                'Color', [256 256 000]/256, ...
                ... Marker
                'Marker', 'o', ...
                'MarkerSize', 4, ...
                'MarkerFaceColor', [256 000 000]/256, ...
                'MarkerEdgeColor', [256 256 000]/256, ...
                'MarkerIndices', [], ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Callback Execution Control
                'PickableParts', 'none');
            obj.tx = text(obj.Handle, ...
                0, 0, '', ...
                ... Text
                'Color', [0.5 0.5 0.5], ...
                ... Font
                'FontName', 'fixedwidth', ...
                'FontSize', 8, ...
                'FontWeight', 'bold', ...
                ... Text Box
                'Margin', 1, ...
                'BackgroundColor', [1 1 1 0.9], ...
                ... Position
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'middle');
            obj.ln_cursor = line(obj.Handle, ...
                ... Line
                'Color', [240 240 240]/256, ...
                ... Markers
                'Marker', 'x', ...
                'MarkerIndices', [], ...
                ... Data
                'XData', [NaN 0 NaN], ...
                'YData', [NaN 0 NaN]);

            set(allchild(obj.Handle), ...
                ... Interactivity
                'Visible', 'off', ...
                ... Callback Execution Control
                'PickableParts', 'none')

            rectangle(obj.Handle, ...
                ... Position
                'Position', [0 0.5 86400 256], ...
                ... Interactivity
                'Visible', 'off', ...
                ... Callback Execution Control
                'PickableParts', 'all', ...
                'HitTest', 'off');
        end
    end     % CONSTRUCTOR
end