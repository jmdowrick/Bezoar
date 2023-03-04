classdef ui_prvw_timeline < TData
    properties (Constant)
        Name = "uiprvw_timeline"
    end
    properties (SetAccess = private)
        width               (1,1)   double  = 120
        height              (1,1)   double  = 50

        i                   (1,1)   double
        t                   (1,1)   double
    end

    methods (Access = public)
        function setTime(obj, t)
            obj.t = t;
            obj.i = NaN;

            if isnan(t) || ~t
                obj.i = NaN;
                obj.t = NaN;
            end

            obj.update()
        end
        function setWave(obj, i)
            obj.i = i;
            obj.t = NaN;

            if isnan(i) || ~i
                obj.i = NaN;
                obj.t = NaN;
            end

            obj.update()
        end
    end
end