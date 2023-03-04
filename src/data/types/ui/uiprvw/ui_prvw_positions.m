classdef ui_prvw_positions < TData
    properties (Constant)
        Name = "uiprvw_positions"
    end
    properties (Constant)
        width = 300
        width_max = 240

        height_max = 360

        height_title = 40
        height_scale = 30
        height_cbar = 40
    end
    properties (SetObservable, SetAccess = private)
        xlim                (1,2)   double  = [0 1]
        ylim                (1,2)   double  = [0 1]
    end
    
    properties (Dependent)
        height
        height_sphere

        position_axes
        position_sphere
        position_scale
        position_colorbar
    end
    methods
        function h = get.height(obj)
            h = ...
                obj.height_title + ...
                obj.position_axes(4) + ...
                obj.position_scale(4) + ...
                obj.position_colorbar(4);
        end
        function h = get.height_sphere(obj)
            h = ...
                obj.height_title + ...
                obj.position_sphere(4) + ...
                obj.position_scale(4) + ...
                obj.position_colorbar(4);
        end
        function p = get.position_axes(obj)
            r_reference = obj.width_max/obj.height_max;
            r = range(obj.xlim)/range(obj.ylim);
            
            if r > r_reference
                sz = [1 1/r] * obj.width_max;
            else
                sz = [r 1] * obj.height_max;
            end

            p = [ ...
                1 + round(obj.width - sz(1))/2, ...
                1 + obj.height_scale + obj.height_cbar, ...
                sz(1), ...
                sz(2)];
        end
        function p = get.position_sphere(obj)
            r_reference = obj.width_max/obj.height_max;            
            if 1 > r_reference
                sz = [1 1] * obj.width_max;
            else
                sz = [1 1] * obj.height_max;
            end

            p = [ ...
                1 + round(obj.width - sz(1))/2, ...
                1 + obj.height_scale + obj.height_cbar, ...
                sz(1), ...
                sz(2)];
        end
        function p = get.position_scale(obj)
            p = [ ...
                obj.position_axes(1), ...
                1 + obj.height_cbar, ...
                obj.position_axes(3), ...
                obj.height_scale];
        end
        function p = get.position_colorbar(obj)
            p = [ ...
                1 + (obj.width - obj.width_max)/2, ...
                1, ...
                obj.width_max, ...
                obj.height_cbar];
        end
    end
    methods (Access = ?DataContainer)
        function updatecnfg(obj)
            x = obj.Data.cnfg.x;
            y = obj.Data.cnfg.y;

            if (range(x) > 0) && (range(y) > 0)
                obj.xlim = [min(x) max(x)];
                obj.ylim = [min(y) max(y)];
            else
                obj.xlim = [0 1];
                obj.ylim = [0 1];
            end
            obj.markForUpdate()
        end
    end
end