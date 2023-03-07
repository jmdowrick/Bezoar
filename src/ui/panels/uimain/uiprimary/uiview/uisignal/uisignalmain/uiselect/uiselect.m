classdef uiselect < TComponent
    properties (Constant)
        Type = 'axes'
    end
    properties (Constant, Access = private)
        pixels = 20
        offset = [20 20]
    end
    properties (SetAccess = private)
        sz              (1,2)   double  = [100 100]
    end

    methods
        function updateuisign_settings(obj)
            obj.resize()
        end
        function updatecnfg(obj)
            x = obj.Data.cnfg.x;
            y = obj.Data.cnfg.y;

            sz_g = obj.Data.cnfg.size([2 1]);
            sz_a = [range(x) range(y)];

            base = min(sz_a./(sz_g - 1));

            sz = (sz_a/base) * obj.pixels;
            sz = sz + (base * 2);

            obj.sz = sz;

            set(obj.Handle, ...
                'XLim', [min(x) - base max(x) + base], ...
                'YLim', [min(y) - base max(y) + base])
            
            obj.resize()
        end
    end
    methods (Access = protected)
        function resizeFcn(obj)
            if all(obj.sz)
                p = getpixelposition(obj.Parent.Handle);
                p = p(3:4);
                p = [p - obj.sz - obj.offset, obj.sz];
                p(1) = p(1) - 75 * obj.Data.uisign_settings.showOverlay;

                set(obj.Handle, ...
                    'Position', p)
            end
        end

        function keyPress(obj)
            if (obj.Data.uiview.view == 1) && ...
                    ~obj.isAlt && ~obj.isCtrl && ~obj.isShift
                switch obj.LastKey
                    case 's'
                        if obj.Handle.Visible
                            set(obj.Handle, 'Visible', 'off')
                            set(allchild(obj.Handle), 'Visible', 'off')
                        else
                            set(obj.Handle, 'Visible', 'on')
                            set(allchild(obj.Handle), 'Visible', 'on')
                        end
                    case 'm'
                        obj.Data.uisign.cycleSelectionMode()
                end
            end
        end
    end     % PROTECTED
    methods % CONSTRUCTOR
        function obj = uiselect()
            set(obj.Handle, ...
                ... Ruler
                'XColor', [208 208 208]/256, ...
                'YColor', [208 208 208]/256, ...
                'YDir', 'reverse', ...
                ... Box Styling
                'Color', [248 248 248 232]/256, ...
                'Box', 'on', ...
                ... Position
                'Units', 'pixels', ...
                'Position', [50 50 200 200])
        end
    end     % CONSTRUCTOR
    methods (Access = protected)
        function initialise(obj)
            uiselect_line();
            uiselect_highlight();
            uiselect_text();

            obj.resize()
        end
    end     % INITIALISE
end