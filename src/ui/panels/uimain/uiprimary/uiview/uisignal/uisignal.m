classdef uisignal < TComponent
    properties (Constant)
        Type = "hbox"
    end
    
    methods % CONSTRUCTOR
        function obj = uisignal()
            set(obj.Handle, ...
                'Spacing', 1, ...
                'BackgroundColor', [172 172 172]/256)
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(~)
            uisignallabels();
            uisignalmain();
        end
    end     % INITIALISE
end