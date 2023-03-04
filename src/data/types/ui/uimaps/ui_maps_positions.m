classdef ui_maps_positions < TData
    properties (Constant)
        Name = "uimaps_positions"
    end
    properties (SetObservable, SetAccess = private)
        xlim                (1,2)   double = [0 1]
        ylim                (1,2)   double = [0 1]
    end

    methods
        function updatecnfg(obj)
            if all(obj.Data.cnfg.size)
                x = obj.Data.cnfg.x;   xr = range(x);
                y = obj.Data.cnfg.y;   yr = range(y);

                if xr && yr
                    obj.xlim = xr * [-0.05 0.05] + [min(x) max(x)];
                    obj.ylim = yr * [-0.05 0.05] + [min(y) max(y)];
                else
                    obj.xlim = [0 1];
                    obj.ylim = [0 1];
                end
            else
                obj.xlim = [0 1];
                obj.ylim = [0 1];
            end
        end
    end
end