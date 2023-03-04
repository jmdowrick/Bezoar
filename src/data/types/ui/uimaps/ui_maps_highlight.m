classdef ui_maps_highlight < TData
    properties (Constant)
        Name = "uimaps_highlight"
    end
    properties (SetObservable, SetAccess = private)
        time                (1,1)   double = NaN
        speed               (1,1)   double = NaN
    end

    methods
        function setTime(obj, t)
            obj.time = t;
            obj.speed = NaN;

            obj.update()
        end
        function setSpeed(obj, v)
            obj.speed = v;
            obj.time = NaN;

            obj.update()
        end
    end
end