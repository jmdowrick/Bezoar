classdef uimain < TComponent
    properties (Constant)
        Type = "hbox"
    end
    methods (Access = protected)
        function initialise(~)
             uiprimary();
             uinavigator_hide();
             uinavigator();
             uiproperties_hide();
             uiproperties();
        end
    end
end