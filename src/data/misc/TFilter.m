classdef TFilter < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable
    properties (Abstract, Constant)
        name                char
        type                char
        
        parameterNames      string
        parameterUnits      string
        parameterDefaults   double
    end
    properties (SetAccess = protected)
        parameterValues     double
        description         char
    end
    methods (Abstract)
        prop = validateProperties(obj, prop)
        data = filter(obj, data)
    end
    
    methods
        function setParameters(obj, values)
            for i = 1:min(length(values), length(obj.parameterNames))
                try
                    obj.parameterValues(i) = values(i);
                    obj.(strcat('validate', obj.parameterNames(i)))()
                catch
                end
            end
        end
        function obj = TFilter()
            obj.parameterValues = obj.parameterDefaults;
        end
    end
end