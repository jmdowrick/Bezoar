classdef uiproperties < TComponent
    properties (Constant)
        Type = "vboxscroll"
    end
    methods
        function updateuiview(obj)
            if obj.Data.uiview.property
                obj.Width = 370;
                set(obj.Handle, ...
                    'Visible', 'on')
            else
                obj.Width = 0;
                set(obj.Handle, ...
                    'Visible', 'off')
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = uiproperties()
            set(obj.Handle, ...
                'Padding', 3, ...
                'Spacing', 3)
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            uiconfig();
            uifilters();

            obj.Width = 370; 
        end
    end     % INITIALISE
end