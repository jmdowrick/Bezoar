classdef uimoviemain < TComponent
    properties (Constant)
        Type        = 'Panel'
    end
    
    methods (Access = protected)
        function initialise(~)
            uimoviemain_axes();
        end
    end
    
    methods
        function obj = uimoviemain()
            set(obj.Handle, ...
                'BackgroundColor', [172 172 172]/256, ...
                'Padding', 50)
        end
    end
end