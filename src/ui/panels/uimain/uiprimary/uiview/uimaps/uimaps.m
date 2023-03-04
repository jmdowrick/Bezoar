classdef uimaps < TComponent
    properties (Constant)
        Type = 'hbox'
    end
    
    methods % CONSTRUCTOR
        function obj = uimaps()
            set(obj.Handle, ...
                'Spacing', 1, ...
                'BackgroundColor', [172 172 172]/256)
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(~)
            uimaps_labels();
            uimaps_main();
            uimaps_cbars();
        end
    end     % INITIALISE
end