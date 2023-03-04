classdef uiinfomain < TComponent
    properties (Constant)
        Type = "panel"
    end
    
    
    
    methods
        function obj = uiinfomain()
            set(obj.Handle, ...
                'BackgroundColor', [172 172 172]/256, ...
                'Padding', 10)
        end
    end
    methods (Access = protected)
        function initialise(~)
            uiinfomain_axes();
        end
    end     % INITIALISE
end