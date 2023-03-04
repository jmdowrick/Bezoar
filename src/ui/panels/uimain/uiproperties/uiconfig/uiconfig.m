classdef uiconfig < TComponent
    properties (Constant)
        Type = "panel"
    end
    
    methods % CONSTRUCTOR
        function obj = uiconfig()
            set(obj.Handle, ...
                ... Title
                'Title', 'Configuration', ...
                ... Color and Styling
                'BorderType', 'etchedin', ...
                'Padding', 10)
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.resocket(uipanel(obj.Handle, ...
                'BorderType', 'none'))

            uiconfig_axes_flat();
            uiconfig_axes_sphere();

            obj.Height = 360;
        end
    end     % INITIALISE
end