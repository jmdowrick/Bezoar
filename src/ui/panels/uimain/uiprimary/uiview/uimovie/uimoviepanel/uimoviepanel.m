classdef uimoviepanel < TComponent
    properties (Constant)
        Type        = 'VBoxScroll'
    end
    
    methods (Access = protected)
        function initialise(~)
            uimoviepanel_buttons();
            uimoviepanel_time();
            uimoviepanel_speed();
        end
    end
    
    methods
        function obj = uimoviepanel()
            obj.Width = 180;
            set(obj.Handle, ...
                'Spacing', 3)
        end
    end
end