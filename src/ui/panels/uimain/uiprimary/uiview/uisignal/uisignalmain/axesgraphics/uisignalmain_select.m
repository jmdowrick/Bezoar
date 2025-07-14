classdef uisignalmain_select < TComponent
    properties (Constant)
        Type = "hggroup"
    end
    properties (SetAccess = immutable)
        pa; ln; rc
    end

    methods
        function updateuisign_settings(obj)
            switch obj.Data.uisign_settings.mode
                case 'edit'
                    set(obj.ln, ...
                        'Color', [192 192 000]/256, ...
                        'MarkerEdgeColor', [256 256 000]/256, ...
                        'MarkerFaceColor', [256 000 000]/256)
                    set(obj.rc, ...
                        'EdgeColor', [256 256 000 064]/256, ...
                        'FaceColor', [256 256 000 016]/256)
                otherwise
                    set(obj.ln, ...
                        'Color', [032 032 256]/256, ...
                        'MarkerEdgeColor', [000 000 256]/256, ...
                        'MarkerFaceColor', [128 128 256]/256)
                    set(obj.rc, ...
                        'EdgeColor', [128 128 256 064]/256, ...
                        'FaceColor', [128 128 256 016]/256)
            end
        end
        function updateuiprvw(obj)
            obj.updateSelection()
        end
        function updateuiprvw_contours(obj)
            w = obj.Data.uiprvw_contours.window;
            if all(isfinite(w))
                set(obj.rc, ...
                    'Position', [w(1) -256 range(w) 512], ...
                    'Visible', 'on')
            else
                set(obj.rc, ...
                    'Visible', 'off')
            end
        end
        function updateuisign_signals(obj)
            obj.updateSelection()
        end
    end
    methods (Access = private)
        function updateSelection(obj)
            if any(obj.Data.uiprvw.at, "all")

                c = obj.Data.uisign.indices;

                tf = (c > 0) & (c <= obj.Data.prop.channels);

                it = obj.Data.uiprvw.at(obj.Data.uisign.indices_grid);
                it = round(it * obj.Data.filt.frequency) + 1;

                is = sub2ind([obj.Data.filt.samples, obj.Data.uisign.n], it, find(tf));

                it = it(isfinite(is));
                is = is(isfinite(is));

                x = obj.Data.uisign_signals.time(it);
                y = obj.Data.uisign_signals.signals(is);

                set(obj.ln, ...
                    'XData', x(:), ...
                    'YData', y(:))

                set(obj.Handle, ...
                    'Visible', 'on')
            else
                set(obj.Handle, ...
                    'Visible', 'off')
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = uisignalmain_select()
            set(obj.Handle, ...
                ... Interactivity
                'Visible', 'off', ...
                ... Callback Execution Control
                'PickableParts', 'none')

            %obj.pa = patch(obj.Handle);
            obj.ln = line(obj.Handle, ...
                ... Line
                'Color', [032 032 256]/256, ...
                'LineWidth', 2, ...
                ... Markers
                'Marker', 'o', ...
                'MarkerSize', 5, ...
                'MarkerEdgeColor', [000 000 256]/256, ...
                'MarkerFaceColor', [128 128 256]/256, ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0));
            obj.rc = rectangle(obj.Handle, ...
                ... Color and Styling
                'EdgeColor', [128 128 256 064]/256, ...
                'FaceColor', [128 128 256 016]/256, ...
                'LineWidth', 2, ...
                ... Position
                'Position', [0 0 1 1]);
        end
    end     % CONSTRUCTOR
end

function i = sub2ind(sz, r, c)
% Efficient version of sub2ind which forgoes no input validation or error
% generation.
i = r + sz(1).*(c - 1);
end