classdef uimaps_panel_empty < TComponent
    properties (Constant)
        Type = "vbox"
    end

    methods
        function updateuimaps(obj)
            if obj.Data.uimaps.n == 0
                obj.Width = -1;
            else
                obj.Width = 0;
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = uimaps_panel_empty()
            uix.Empty('Parent', obj.Handle);
            uicontrol(obj.Handle, ...
                ... Type of Control
                'Style', 'text', ...
                ... Text and Styling
                'String', 'No group selected', ...
                'BackgroundColor', obj.Parent.Handle.BackgroundColor, ...
                ... FontName
                'FontName', 'fixedwidth', ...
                'FontWeight', 'bold', ...
                ... Position
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);
            uix.Empty('Parent', obj.Handle);

            set(obj.Handle, ...
                'BackgroundColor', obj.Parent.Handle.BackgroundColor, ...
                'Heights', [-1 20 -1])
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Width = -1;
        end
    end     % INITIALISE
end