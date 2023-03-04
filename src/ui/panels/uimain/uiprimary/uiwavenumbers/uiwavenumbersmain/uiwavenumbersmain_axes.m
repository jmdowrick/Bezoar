classdef uiwavenumbersmain_axes < TComponent
    properties (Constant)
        Type = 'axes'
    end
    
    methods
        function updateprop(obj)
            set(obj.Handle, ...
                'XTick', 60:60:obj.Data.prop.duration)
        end
        function updateuiscbr(obj)
            set(obj.Handle, ...
                'XLim', [obj.Data.uiscbr.window])
        end
    end
    methods (Access = protected)
        function mouseScroll(obj)
            p = obj.CurrentPosition(1);
            if obj.ScrolledUnits > 0
                if obj.isCtrl
                    obj.Data.uiscbr.zoomOut(p)
                else
                    obj.Data.uiscbr.scrollForwards()
                end
            elseif obj.ScrolledUnits < 0
                if obj.isCtrl
                    obj.Data.uiscbr.zoomIn(p)
                else
                    obj.Data.uiscbr.scrollBackwards()
                end
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = uiwavenumbersmain_axes()
            set(obj.Handle, ...
                ... Ticks
                'XTick', 60:60:86400, ...
                'YTick', [], ...
                ... Rulers
                'XLim', [0 600], ...
                'YLim', [-1 1], ...
                'YDir', 'reverse', ...
                ... Grids
                'XGrid', 'on', ...
                'YGrid', 'on', ...
                'GridColor', [0.15 0.15 0.15], ...
                'XMinorGrid', 'on', ...
                'MinorGridColor', [0.15 0.15 0.15], ...
                ... Colour
                'Color', 'w')
            set(obj.Handle.XRuler, ...
                ... Ticks
                'MinorTickValues', 15:15:86400)
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(~)
            uiwavenumbersmain_text();
            uiwavenumbersmain_text_select();
            uiwavenumbersmain_text_select_multi();
        end
    end     % INITIALISE
end