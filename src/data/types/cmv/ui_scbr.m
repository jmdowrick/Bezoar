classdef ui_scbr < TData
    properties (Constant)
        Name = "uiscbr"
    end
    properties (SetAccess = private)
        window          (1,2)   double  = [0 600]
    end
    properties (Constant, Access = private)
        window_default = [0 600]
        window_min = 15

        window_zoom = 1.2
        window_scroll = 0.1
    end

    methods
        function setWindow(obj, w)
            if (obj.Data.prop.duration == 0)
                d = range(obj.window_default);
            else
                d = obj.Data.prop.duration;
            end

            r = range(w);
            r = max(r, obj.window_min);
            r = min(r, d);

            if w(1) < 0
                obj.window = [0 r]; 
            elseif w(2) > d
                obj.window = d - [r 0];
            elseif range(w) < r
                obj.window = max(mean(w) - r/2, 0) + [0 r];
            else
                obj.window = w;
            end

            obj.update()
        end
        function resetWindow(obj)
            obj.setWindow([0 Inf])
        end

        function scrollTo(obj, target)
            w = obj.window + (target - mean(obj.window));
            obj.setWindow(w)
        end
        function scrollBackwards(obj)
            w = obj.window - range(obj.window)*obj.window_scroll;
            obj.setWindow(w)
        end
        function scrollForwards(obj)
            w = obj.window + range(obj.window)*obj.window_scroll;
            obj.setWindow(w)
        end
        
        function zoomIn(obj, target)
            if isempty(target)
                target = mean(obj.window);
            end
            
            if ~isequal(abs(diff(obj.window)), obj.window_min)
                w = (obj.window - target)/obj.window_zoom + target;
                obj.setWindow(w)
            end
        end
        function zoomOut(obj, target)
            if isempty(target)
                target = mean(obj.window);
            end
            w = (obj.window - target)*obj.window_zoom + target;
            obj.setWindow(w)
        end
    end
    methods (Access = ?DataContainer)
        function updateprop(obj)
            obj.resetWindow()
        end
    end
end