classdef uimaps_propagation < TComponent
    properties (Constant)
        Type = "uicontainer"
    end
    properties (SetAccess = immutable)
        index
    end

    methods % CONSTRUCTOR
        function obj = uimaps_propagation()
            set(obj.Handle, ...
                'BackgroundColor', obj.Parent.Handle.BackgroundColor)
            
            obj.index = obj.Parent.index;
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(~)
            uimaps_propagation_axes();
            % uimaps_propagation_axes_sphere();
        end
    end     % INITIALISE
end