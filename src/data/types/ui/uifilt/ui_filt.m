classdef ui_filt < TData
    properties (Constant)
        Name = 'uifilt'
    end
    properties (Constant)
        default_filter                      = FilterProperties()
    end
    properties (SetObservable, SetAccess = private)
        provisional         (1,:)   TFilter = TFilter.empty(1,0)
    end

    methods
        function reset(obj)
            obj.provisional = copy(obj.Data.filt.current);
            obj.update()
        end
        function refilter(obj)
            obj.Data.filt.filter(obj.provisional)
        end

        function changeFilter(obj, i, index)
            obj.provisional(i) = copy(obj.Data.filt.list(index));
            obj.update()
        end
        function changeFilterParameters(obj, i, values)
            p = obj.provisional(i);
            p.setParameters(values)
            obj.provisional(i) = p;
            obj.update()
        end

        function addFilter(obj, i)
            i = max(min(i, obj.n), 0);
            obj.provisional = [ ...
                obj.provisional(1:i), ...
                copy(obj.Data.filt.list(1)), ...
                obj.provisional((i + 1):end)];
            obj.update()
        end
        function removeFilter(obj, i)
            if (i < 1) || (i > obj.n); return; end
            obj.provisional = [ ...
                obj.provisional(1:(i - 1)), ...
                obj.provisional((i + 1):end)];
            obj.update()
        end
        function shiftFilterUp(obj, i)
            if (i < 2) || (i > obj.n); return; end
            obj.provisional = [ ...
                obj.provisional(1:(i - 2)), ...
                obj.provisional(i), ...
                obj.provisional(i - 1), ...
                obj.provisional((i + 1):end)];
            obj.update()
        end
        function shiftFilterDown(obj, i)
            if (i < 1) || (i > obj.n - 1); return; end
            obj.provisional = [ ...
                obj.provisional(1:(i - 1)), ...
                obj.provisional(i + 1), ...
                obj.provisional(i), ...
                obj.provisional((i + 2):end)];
            obj.update()
        end
    end
    methods (Access = protected)
        function updateFcn(obj)
            p = obj.default_filter;
            if obj.Data.file.isloaded
                p.frequency = obj.Data.prop.frequency;
                p.samples = obj.Data.prop.samples;
            end

            for f = obj.provisional
                p = f.validateProperties(p);
            end
        end
    end

    properties (Dependent)
        n
    end
    methods
        function n = get.n(obj)
            n = length(obj.provisional);
        end
    end
end