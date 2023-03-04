classdef uiprimary < TComponent
    properties (Constant)
        Type        = 'VBox'
    end
    
    methods (Access = protected)
        function initialise(obj)
            uiview();
            uiwavenumbers();
            uieventviewer();

            obj.Width = -1;
        end
    end
    methods
        function obj = uiprimary()
            set(obj.Handle, ...
                'Spacing', 1, ...
                'BackgroundColor', [172 172 172]/256)
        end
    end
end