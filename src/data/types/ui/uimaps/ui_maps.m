classdef ui_maps < TData
    properties (Constant)
        Name = "uimaps"
    end
    properties (Constant)
        n_max = 5
    end
    properties (SetObservable, SetAccess = private)
        selection           (1,:)   double = []

        interval            (1,1)   double = 1
        max_speed           (1,1)   double = 10
    end
    properties (SetAccess = private)
        at                          double = []
        vel                         double = []
        dir                         double = []
    end

    methods
        function setSelection(obj, i)
            if i
                if any(i == obj.selection)
                    obj.selection(i == obj.selection) = [];
                elseif (obj.n == obj.n_max)
                    [~, j] = min(abs(i - obj.selection));
                    obj.selection(j) = i;
                else
                    obj.selection = sort([i obj.selection]);
                end

                obj.update()
            end
        end
    end
    methods (Access = ?DataContainer)
        function updateuiview(obj)
            switch obj.Data.uiview.viewname
                case "maps"
                    obj.markForUpdate()
            end
        end
    end
    methods (Access = protected)
        function updateFcn(obj)
            obj.at = obj.Data.wave.waves(:, :, obj.selection);
            
            obj.vel = NaN([obj.Data.al_velo.size obj.n]);
            obj.dir = NaN([obj.Data.al_velo.size obj.n]);
        
            for i = 1:obj.n
                [obj.vel(:,:,i), obj.dir(:,:,i)] = ...
                    obj.Data.al_velo.calculateVelocities(obj.at(:,:,i));
            end
        end
    end

    properties (Dependent)
        n
    end
    methods
        function n = get.n(obj)
            n = length(obj.selection);
        end
    end
end