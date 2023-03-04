classdef uitimeline < TComponent
    properties (Constant)
        Type            = 'VBoxScroll'
    end
    methods (Access = protected)
        function initialise(~)
            uitimeline_axes();
        end
    end
    methods
        function obj = uitimeline()
            set(obj.Handle, ...
                'BackgroundColor', [248 248 248]/256)
        end
    end
end