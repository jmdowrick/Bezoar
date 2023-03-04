classdef uimaps_title < TComponent
    properties (Constant)
        Type = 'uicontainer'
    end
    properties (SetAccess = immutable)
        index
    end
    properties (SetAccess = immutable)
        ui
    end

    methods
        function updateuimaps(obj)
            if (obj.index <= obj.Data.uimaps.n)
                g = obj.Data.uimaps.selection(obj.index);
                set(obj.ui, ...
                    'String', "Wave " + num2str(g), ...
                    'FontSize', 10)
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = uimaps_title()
            set(obj.Handle, ...
                'BackgroundColor', obj.Parent.Handle.BackgroundColor)

            obj.ui = uicontrol(obj.Handle, ...
                ... Type of Control
                'Style', 'text', ...
                ... Text and Styling
                'String', '', ...
                'BackgroundColor', obj.Parent.Handle.BackgroundColor, ...
                ... FontName
                'FontName', 'fixedwidth', ...
                'FontWeight', 'bold', ...
                ... Position
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);

            obj.index = obj.Parent.index;
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Height = 15;
        end
    end     % INITIALISE
end