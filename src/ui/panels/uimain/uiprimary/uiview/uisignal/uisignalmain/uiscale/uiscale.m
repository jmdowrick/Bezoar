classdef uiscale < TComponent
    properties (Constant)
        Type = "axes"
    end
    methods
        function updateuisign(obj)
            set(obj.Handle, ...
                'YLim', [0 max(obj.Data.uisign.n, 1)] + 0.5)
        end
        function updateuisign_settings(obj)
            set(obj.Handle, ...
                'Visible', obj.Data.uisign_settings.showOverlay)
            set(allchild(obj.Handle), ...
                'Visible', obj.Data.uisign_settings.showOverlay)
        end
    end
    methods (Access = protected)
        function resizeFcn(obj)
            p = getpixelposition(obj.Parent.Handle);
            p = p(3:4);
            w = 75;

            set(obj.Handle, ...
                'Position', [p(1) - w + 1 1 w p(2)])
        end

        function keyPress(obj)
            switch obj.Data.uiview.viewname
                case 'sign'
                    switch obj.LastKey
                        case 'o'
                            obj.Data.uisign_settings.toggleOverlay()
                    end
            end
        end
    end     % PROTECTED
    methods % CONSTRUCTOR
        function obj = uiscale()
            set(obj.Handle, ...
                ... Ruler
                'XLim', [0 5], ...
                'YDir', 'reverse', ...
                ... Box Styling
                'Color', [248 248 248 232]/256, ...
                ... Position
                'Units', 'pixels')
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            uiscale_line();
            uiscale_text();

            obj.resize()
        end
    end     % INITIALISE
end