classdef uieventviewermain_cursor < TComponent
    properties (Constant)
        Type = 'hggroup'
    end
    properties
        rc; ln
    end

    methods
        function updateuiflmv(obj)
            c = obj.Data.uiflmv.cursor;
            if isfinite(c)
                if obj.Data.uiprvw.i
                    w = obj.Data.uiprvw_contours.window;
                    p = [w(1) -100 (c - w(1)) 200];
                else
                    p = [0 -100 c 200];
                end

                set(obj.rc, ...
                    'Position', p)
                set(obj.ln, ...
                    'XData', [c c], ...
                    'YData', [-100 100])
            end
        end
        function updateuiview(obj)
            switch obj.Data.uiview.viewname
                case 'flmv'
                    set(obj.Handle, ...
                        'Visible', 'on')
                otherwise
                    set(obj.Handle, ...
                        'Visible', 'off')
            end
        end
    end
    methods (Access = protected)
        function mouseAxesDrag(obj)
            switch obj.Data.uiview.viewname
                case 'flmv'
                    if obj.Data.uiprvw.i
                        p = obj.CurrentPosition(1);
                        t = obj.Data.uiprvw.at;

                        t_min = min(t, [], "all") - 1;
                        t_max = max(t, [], "all") + 1;

                        if (p < t_min) || (p > t_max)
                            obj.Data.uiprvw.setWave(0)
                        end
                    end
                    obj.Data.uiflmv.jumpTo(obj.CurrentPosition(1));
                otherwise
                    set(obj.Handle, ...
                        'Visible', 'off')
            end

            if (obj.Data.uiview.view == 2)
                obj.Data.uiflmv.jumpTo(obj.CurrentPosition(1))
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = uieventviewermain_cursor()
            set(obj.Handle, ...
                ... Interactivity
                'Visible', 'off', ...
                ... Callbacks
                'PickableParts', 'none')
            obj.rc = rectangle(obj.Handle, ...
                ... Color and Styling
                'FaceColor', [0.2 0.2 1.0 0.2], ...
                'EdgeColor', 'none', ...
                ... Position
                'Position', [0 0 0 2], ...
                ... Callbacks
                'PickableParts', 'none');
            obj.ln = line(obj.Handle, [0 0], [-100 100], ...
                ... Color and Styling
                'Color', [0.2 0.2 1.0], ...
                ... Callbacks
                'PickableParts', 'none');

        end
    end     % CONSTRUCTOR
end