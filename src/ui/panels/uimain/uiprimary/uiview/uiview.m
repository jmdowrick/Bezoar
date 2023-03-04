classdef uiview < TComponent
    properties (Constant)
        Type = "cardpanel"
    end

    methods
        function updateuiview(obj)
            set(obj.Handle, ...
                'Selection', obj.Data.uiview.view)
        end
    end
    methods % CONSTURCTOR
        function obj = uiview()
            set(obj.Handle, ...
                'BackgroundColor', [192 192 192]/256)
        end
    end     % CONSTURCTOR
    methods (Access = protected)
        function initialise(obj)
            uisignal();
            uimovie();
            uiinfo();
            uimaps();
            set(obj.Handle, ...
                'Selection', 1)
        end
    end     % INITIALISE
end