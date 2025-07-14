classdef ui_maps_settings < TData
    properties (Constant)
        Name = "uimaps_settings"
    end
    properties (SetObservable, SetAccess = private)
        interval        (1,1)   double = 2
        max_speed       (1,1)   double = 10
    end
    properties
        cmap_at         (:,3)   double = double.empty(0,3) 
        cmap_speed      (:,3)   double = double.empty(0,3) 
    end

    methods
        function setInterval(obj, t)
            obj.interval = t;
            
            obj.update()
        end
        function setMaxSpeed(obj, v)
            obj.max_speed = v;
            
            obj.update()
        end
        function updateuimaps(obj)
            obj.markForUpdate()
        end
    end
    methods (Access = protected)
        function updateFcn(obj)
            r_at = range(obj.Data.uimaps.at, [1 2]);
            if isempty(r_at)
                obj.cmap_at = autumn();
            else
                obj.cmap_at = flipud(autumn(ceil(max(r_at)/obj.interval)));
            end
            obj.cmap_speed = cool();
        end
    end
end