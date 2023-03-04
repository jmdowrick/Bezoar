classdef uiinfo < TComponent
    properties (Constant)
        Type = 'hbox'
    end
    methods (Access = protected)
        function initialise(~)
            uiinfolabels();
            uiinfomain();
            uiinfopanel();
        end
    end
    methods
        function obj = uiinfo()
            set(obj.Handle, ...
                'Spacing', 1, ...
                'BackgroundColor', [172 172 172]/256)
        end
    end
end