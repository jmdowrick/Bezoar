classdef uimaps_cbars < TComponent
    properties (Constant)
        Type = "vbox"
    end
    
    methods % CONSTRUCTOR
        function obj = uimaps_cbars()
            set(obj.Handle, ...
                'Padding', 20, ...
                'Spacing', 20)
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Width = 100;

            uimaps_cbars_title();
            uimaps_cbars_propagation();
            uimaps_cbars_velocity();
        end
    end     % INITIALISE
end