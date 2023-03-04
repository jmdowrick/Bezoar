classdef ui_prvw_contours < TData
    properties (Constant)
        Name = "uiprvw_contours"
    end
    properties (SetObservable, SetAccess = private)
        interval        (1,1)   double = 2
    end
    properties (SetAccess = private)
        levels          (1,:)   double = []
        window          (1,2)   double = [NaN NaN]
        colourmap       (:,3)   double = []

        padding         (1,1)   double = 1
    end

    methods
        function setInterval(obj, t)
            obj.interval = t;

            obj.update()
        end
    end
    methods
        function updateuiprvw(obj)
            obj.markForUpdate()
        end
    end
    methods (Access = protected)
        function updateFcn(obj)
            at = obj.Data.uiprvw.at;
            if any(at, "all")
                tmin = min(at, [], "all");
                tmax = max(at, [], "all");

                obj.levels = floor(tmin/obj.interval):ceil(tmax/obj.interval);
                obj.levels = obj.levels * obj.interval;
                obj.window = [tmin tmax] + [-1 1] * obj.padding;
                obj.colourmap = flipud(autumn(numel(obj.levels) - 1));
            else
                obj.levels = [];
                obj.window = [NaN NaN];
                obj.colourmap = autumn(0);
            end
        end
    end
end