classdef uisignalmain_axes < TComponent
    properties (Constant)
        Type = "axes"
    end

    methods
        function updateuisign_settings(obj)
            switch obj.Data.uisign_settings.mode
                case "edit"
                    set(obj.Handle, ...
                        'Color', [048 048 048]/256, ...
                        'GridColor', [192 192 192]/256)
                otherwise
                    set(obj.Handle, ...
                        'Color', [256 256 256]/256, ...
                        'GridColor', [032 032 032]/256)
            end
        end
        function updateuisign(obj)
            set(obj.Handle, ...
                'YLim', [0 obj.Data.uisign.n] + 0.5)
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

        function keyPress(obj)
            if (obj.Data.uiview.view == 1)
                switch obj.LastKey
                    case 'add'
                        obj.Data.uisign_signals.scaleZoomIn()
                    case 'subtract'
                        obj.Data.uisign_signals.scaleZoomOut()
                    case 'r'
                        obj.Data.uisign_signals.scaleZoomReset()
                    case 'equal'
                        obj.Data.uisign_signals.scaleToggleNormalise()
                end
            end
        end
    end     % PROTECTOR
    methods % CONSTRUCTOR
        function obj = uisignalmain_axes()
            set(obj.Handle, ...
                ... Ticks
                'XTick', 60:60:86400, ...
                'YTick', 1:256, ...
                ... Rulers
                'XLim', [obj.Data.uiscbr.window], ...
                'YLim', [0 1] + 0.5, ...
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
            uisignalmain_traces();

            uisignalmain_query();
            uisignalmain_edit();

            uisignalmain_select();
        end
    end     % INITIALISE
end