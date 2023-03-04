classdef uitimeline_axes < TComponent
    properties (Constant)
        Type = "axes"
    end

    methods
        function updateprop(obj)
            w = obj.Data.uiprvw_timeline.width;
            n = ceil(obj.Data.prop.duration/w);

            if n
                set(obj.Handle, ...
                    'YLim', [0 n] + 0.5, ...
                    'XLim', [-0.05 1.05] * w)
            else
                set(obj.Handle, ...
                    'YLim', [0 1] + 0.5, ...
                    'XLim', [-0.05 1.05] * w)
            end

            obj.Height = n * 50;
        end
    end
    methods (Access = protected)
        function traverseFcn(obj)
            w = obj.Data.uiprvw_timeline.width;
            p = obj.CurrentPosition;
            
            i = NaN;
            if (p(1) >= 0) && (p(1) <= w)
                i = p(1) + round(p(2) - 1) * w;
            end

            if isnan(i) || (i < 0) || i >= obj.Data.prop.duration
                obj.Data.uiprvw_timeline.setTime(NaN)
            else
                obj.Data.uiprvw_timeline.setTime(i)
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = uitimeline_axes()
            set(obj.Handle, ...
                'YDir', 'reverse', ...
                'Color', [248 248 248]/256)
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Height = 400;

            uitimeline_background();
            uitimeline_markers();
            uitimeline_text();
            uitimeline_select();
            uitimeline_highlight();
        end
    end     % INITIALISE
end