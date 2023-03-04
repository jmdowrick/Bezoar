classdef uimaps_panel < TComponent
    properties (Constant)
        Type = 'vbox'
    end
    properties (SetAccess = immutable)
        index
    end

    methods
        function updateuimaps(obj)
            if (obj.index <= obj.Data.uimaps.n)
                obj.Width = -1;     % Show panel
            else
                obj.Width = 0;      % Hide panel
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = uimaps_panel()
            set(obj.Handle, ...
                'Spacing', 20, ...
                'Padding', 20, ...
                'BackgroundColor', [248 248 248]/256)

            obj.index = obj.Index - 1;
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(~)
            uimaps_title();
            uimaps_propagation();
            uimaps_velocities();
        end
    end     % INITIALISE
end