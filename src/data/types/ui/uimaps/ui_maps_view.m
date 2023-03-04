classdef ui_maps_view < TData
    properties (Constant)
        Name = "uimaps_view"
    end
    properties (SetObservable, SetAccess = private)
        view                (1,2)   double = [60 30]
    end

    methods
        function setView(obj, v)
            v(2) = max(min(v(2), +45), -60);
            obj.view = v;

            obj.update()
        end
    end
end