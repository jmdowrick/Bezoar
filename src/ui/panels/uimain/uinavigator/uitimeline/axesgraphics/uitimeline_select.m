classdef uitimeline_select < TComponent
    properties (Constant)
        Type = "line"
    end

    methods
        function updatewave(obj)
            obj.updateSelection()
        end
        function updateuiprvw(obj)
            obj.updateSelection()
        end
        function updateuimaps(obj)
            obj.updateSelection()
        end
    end
    methods (Access = private)
        function updateSelection(obj)
            switch obj.Data.uiview.view
                case 'maps'
                    i = obj.Data.uimaps.selection;
                otherwise
                    i = obj.Data.uiprvw.i;
            end

            w = obj.Data.uiprvw_timeline.width;
            m = obj.Data.wave.medians;

            x = rem(m, w);
            y = ceil(m / w);

            if length(i) > 1 || i
                set(obj.Handle, ...                
                    'XData', x(i), ...
                    'YData', y(i))
            else
                set(obj.Handle, ...
                    'XData', [], ...
                    'YData', [])
            end
        end
    end     % PRIVATE
    methods % CONSTRUCTOR
        function obj = uitimeline_select()
            set(obj.Handle, ...
                ... Line
                'LineStyle', 'none', ...
                'LineWidth', 1.5, ...
                ... Markers
                'Marker', 'o', ...
                'MarkerSize', 10, ...
                'MarkerEdgeColor', [128 128 128]/256, ...
                'MarkerFaceColor', [128 128 128]/256, ...
                ... Callback Execution Controls
                'PickableParts', 'none')
        end
    end     % CONSTRUCTOR
end