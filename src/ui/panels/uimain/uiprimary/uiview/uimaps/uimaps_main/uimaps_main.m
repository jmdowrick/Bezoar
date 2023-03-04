classdef uimaps_main < TComponent
    properties (Constant)
        Type = 'hbox'
    end
    
    methods % CONSTRUCTOR
        function obj = uimaps_main()
            set(obj.Handle, ...
                'BackgroundColor', [248 248 248]/256)
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            uimaps_panel_empty();
            for i = 1:obj.Data.uimaps.n_max
                uimaps_panel();
            end
        end
    end     % INITIALISE
end