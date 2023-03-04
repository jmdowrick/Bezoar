classdef uieventviewermain_axes < TComponent
    properties (Constant)
        Type = 'axes'
    end
    
    methods
        function updatecnfg(obj)
            nr = obj.Data.cnfg.size(1);
            nc = obj.Data.cnfg.size(2);

            set(obj.Handle, ...
                'YLim', [-nr nc] + [-1 1])
        end
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
        function obj = uieventviewermain_axes()
            set(obj.Handle, ...
                ... Ticks
                'XTick', 60:60:86400, ...
                'YTick', 0, ...
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
            uieventviewermain_traces();
            uieventviewermain_select_single();
            uieventviewermain_select_multi();
            uieventviewermain_cursor();
        end
    end     % INITIALISE
end