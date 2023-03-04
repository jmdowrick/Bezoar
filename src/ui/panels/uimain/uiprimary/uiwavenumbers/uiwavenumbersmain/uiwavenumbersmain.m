classdef uiwavenumbersmain < TComponent
    properties (Constant)
        Type = 'panel'
    end
    
    methods (Access = protected)
        function initialise(~)
            uiwavenumbersmain_axes();
        end
    end     % INITIALISE
end