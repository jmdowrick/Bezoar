classdef TData < TDataHeader
    properties (Hidden, SetAccess = immutable)
        Listeners       (1,:)   event.listener = event.listener.empty(0,1)
    end
    properties (Hidden, SetAccess = private)
        Dirty           (1,1)   logical = false
    end

    methods (Access = public)
        function update(obj)
            if obj.Data.Active
                obj.updateFcn()
                obj.Dirty = false;

                notify(obj, 'PropertiesChanged')
            else
                % Force update
                obj.markAsDirty()
                
                obj.Data.update(obj.Name) 
            end
        end
        function markAsDirty(obj)
            obj.Dirty = true;
        end
    end
    methods (Access = protected)
        function updateFcn(~)
            % Implement in subclass
        end
        function markForUpdate(obj)
            obj.Dirty = true;
        end
    end

    methods % CONSTRUCTOR
        function obj = TData()
            mc = metaclass(obj);

            % Generate property list
            pl = mc.PropertyList;
            for i = find([pl.SetObservable])
                obj.Listeners(end + 1) = addlistener(obj, pl(i).Name, ...
                    'PostSet', @(~,~) obj.markForUpdate());
            end
        end
    end
end