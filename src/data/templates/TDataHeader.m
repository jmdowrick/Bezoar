classdef TDataHeader < ...
        matlab.mixin.SetGet & ...
        matlab.mixin.Heterogeneous & ...
        dynamicprops

    properties (Hidden, Constant, Abstract)
        Name            (1,:)   char
    end
    properties (SetAccess = immutable)
        Data                    DataContainer
    end
        
    methods
        function obj = TDataHeader()
            obj.Data = DataContainer.instance();
        end
    end

    events (NotifyAccess = public)
        PropertiesChanged
    end
end