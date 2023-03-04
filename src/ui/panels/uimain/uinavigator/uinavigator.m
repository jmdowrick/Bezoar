classdef uinavigator < TComponent
    properties (Constant)
        Type = 'vbox'
    end
    methods
        function updateuiview(obj)
            if obj.Data.uiview.navigator
                obj.Width = 300;
                set(obj.Handle, 'Visible', 'on')
            else
                obj.Width = 0;
                set(obj.Handle, 'Visible', 'off')
            end
        end
    end
    methods (Access = protected)
        function initialise(obj)
            obj.Width = 300;

            uipreview();
            uipreviewinfo();
            uithumbs();
            uitimeline();
        end
    end
end