classdef uitimeline_markers < TComponent
    properties (Constant)
        Type = "line"
    end

    methods
        function updatewave(obj)
            w = obj.Data.uiprvw_timeline.width;
            m = obj.Data.wave.medians;

            x = rem(m, w);
            y = ceil(m/w);

            set(obj.Handle, ...
                'XData', x, ...
                'YData', y)
        end
    end
    methods (Access = protected)
        function mouseClick(obj)
            w = obj.Data.uiprvw_timeline.width;
            p = obj.CurrentPosition;

            i = NaN;
            if (p(1) >= 0) && (p(1) <= w)
                i = p(1) + round(p(2) - 1) * w;
            end

            [~, g] = min(abs(obj.Data.wave.medians - i));
            if (obj.Data.uiprvw.i == g)
                obj.Data.uiprvw.setWave(0)
            else
                obj.Data.uiprvw.setWave(g)
            end
        end

        function enterFcn(obj)
            w = obj.Data.uiprvw_timeline.width;
            p = obj.CurrentPosition;

            i = NaN;
            if (p(1) >= 0) && (p(1) <= w)
                i = p(1) + round(p(2) - 1) * w;
            end
            [~, g] = min(abs(obj.Data.wave.medians - i));

            obj.Data.uiprvw_timeline.setWave(g)
        end
    end     % PROTECTED
    methods % CONSTRUCTOR
        function obj = uitimeline_markers()
            set(obj.Handle, ...
                ... Line
                'LineStyle', 'none', ...
                'LineWidth', 1.5, ...
                ... Markers
                'Marker', 'o', ...
                'MarkerSize', 10, ...
                'MarkerEdgeColor', [128 128 128]/256, ...
                'MarkerFaceColor', [204 204 204]/256)
        end
    end     % CONSTRUCTOR
end