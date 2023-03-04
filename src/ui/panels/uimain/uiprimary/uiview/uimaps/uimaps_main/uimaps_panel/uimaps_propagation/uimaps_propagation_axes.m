classdef uimaps_propagation_axes < TComponent
    properties (Constant)
        Type = 'axes'
    end
    properties (SetAccess = immutable)
        index
    end
    properties (SetAccess = immutable)
        pa; rc; ln
    end

    methods
        function updateuimaps(obj)
            if strcmp('flat', obj.Data.cnfg.mode) && ...
                    (obj.index <= obj.Data.uimaps.n)
                
                in = obj.Data.uimaps_settings.interval;

                at = obj.Data.uimaps.at(:, :, obj.index);
                at = at - min(at(:));

                lv = (0:ceil(max(at(:))/in)) * in;

                [vx, vy, cd] = obj.Data.al_cont.createContours(at, lv);

                set(obj.pa, ...
                    'XData', vx, ...
                    'YData', vy, ...
                    'CData', cd)
            end
        end
        function updateuimaps_settings(obj)
            if strcmp('flat', obj.Data.cnfg.mode) && ...
                    (obj.index <= obj.Data.uimaps.n)
                
                in = obj.Data.uimaps_settings.interval;

                at = obj.Data.uimaps.at(:, :, obj.index);
                at = at - min(at(:));

                lv = (0:ceil(max(at(:))/in)) * in;

                [vx, vy, cd] = obj.Data.al_cont.createContours(at, lv);

                set(obj.pa, ...
                    'XData', vx, ...
                    'YData', vy, ...
                    'CData', cd)
            end
            set(obj.Handle, ...
                'Colormap', obj.Data.uimaps_settings.cmap_at)
        end
        function updateuimaps_positions(obj)
            switch obj.Data.cnfg.mode
                case 'flat'
                    set(obj.Handle, ...
                        'XLim', obj.Data.uimaps_positions.xlim, ...
                        'YLim', obj.Data.uimaps_positions.ylim)
                case 'sphere'
                    set(obj.Handle, ...
                        'XLim', [0 1], ...
                        'YLim', [0 1])
            end
        end
    end
    methods (Access = protected)
        function traverseFcn(obj)
            p = obj.CurrentPosition;

            x = obj.Data.cnfg.xgrid;
            y = obj.Data.cnfg.ygrid;

            dx = x - p(1);
            dy = y - p(2);

            d = (dx.^2 + dy.^2);
            [~, i] = min(d, [], "all");
            
            t = obj.Data.uimaps.at(:, :, obj.index);
            if isfinite(t(i))
                set(obj.ln, ...
                    "XData", x(i), ...
                    "YData", y(i))
                obj.Data.uimaps_highlight.setTime(t(i) - min(t(:)))
            else
                set(obj.ln, ...
                    "XData", [], ...
                    "YData", [])
                obj.Data.uimaps_highlight.setTime(NaN)
            end
        end
        function exitFcn(obj)
            set(obj.ln, ...
                "XData", [], ...
                "YData", [])
            obj.Data.uimaps_highlight.setTime(NaN)
        end
    end
    methods % CONSTRUCTOR
        function obj = uimaps_propagation_axes()
            set(obj.Handle, ...
                ... Rulers
                'XColor', [192 192 192]/256, ...
                'YColor', [192 192 192]/256, ...
                'YDir', 'reverse', ...
                ... Box Styling
                'Color', 'w', ...
                'Box', 'on', ...
                ... Position
                'Units', 'normalized', ...
                'InnerPosition', [0.01 0.01 0.98 0.98], ...
                'DataAspectRatio', [1 1 1])

            obj.pa = patch(obj.Handle, ...
                ... Color
                'FaceColor', 'flat', ...
                'EdgeColor', 'none', ...
                'CData', [], ...
                'CDataMapping', 'direct', ...
                ... Data
                'XData', [], ...
                'YData', [], ...
                'ZData', [], ...
                ... Callback Execution Control
                'PickableParts', 'none');
            obj.ln = line(obj.Handle, ...
                ... Line
                "LineWidth", 1, ...
                ... Markers
                "Marker", "o", ...
                "MarkerSize", 5, ...
                "MarkerEdgeColor", [064 064 064]/256, ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Callback Execution Control
                "PickableParts", "none");

            obj.index = obj.Parent.index;
        end
    end     % CONSTRUCTOR
end