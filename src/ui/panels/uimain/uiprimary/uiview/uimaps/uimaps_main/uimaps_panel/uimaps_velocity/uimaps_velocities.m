classdef uimaps_velocities < TComponent
    properties (Constant)
        Type = "uicontainer"
    end
    properties (SetAccess = immutable)
        index
    end

    methods % CONSTRUCTOR
        function obj = uimaps_velocities()
            set(obj.Handle, ...
                'BackgroundColor', obj.Parent.Handle.BackgroundColor)
            
            obj.index = obj.Parent.index;
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(~)
            uimaps_velocities_axes();
            % uimaps_velocities_axes_sphere();
        end
    end     % INITIALISE
end