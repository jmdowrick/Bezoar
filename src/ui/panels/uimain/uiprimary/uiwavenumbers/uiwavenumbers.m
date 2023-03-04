classdef uiwavenumbers < TComponent
    properties (Constant)
        Type = 'hbox'
    end

    methods % CONSTRUCTOR
        function obj = uiwavenumbers()
            set(obj.Handle, ...
                'Spacing', 1, ...
                'BackgroundColor', [160 160 160]/256)
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Height = 12;

            uiwavenumberslabels();
            uiwavenumbersmain();
        end
    end     % INITIALISE
end