classdef uimaps_cbars_title < TComponent
    properties (Constant)
        Type = 'uicontainer'
    end
    properties (SetAccess = immutable)
        index
    end
    properties (SetAccess = immutable)
        ui
    end

    methods % CONSTRUCTOR
        function obj = uimaps_cbars_title()
            set(obj.Handle, ...
                'BackgroundColor', obj.Parent.Handle.BackgroundColor)

            obj.ui = uicontrol(obj.Handle, ...
                ... Type of Control
                'Style', 'text', ...
                ... Text and Styling
                'String', 'Legend', ...
                'BackgroundColor', obj.Parent.Handle.BackgroundColor, ...
                ... FontName
                'FontName', 'fixedwidth', ...
                'FontWeight', 'bold', ...
                ... Position
                'Units', 'normalized', ...
                'Position', [0 0 1 1]);

            obj.index = obj.Parent.Index;
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            obj.Height = 15;
        end
    end     % INITIALISE
end