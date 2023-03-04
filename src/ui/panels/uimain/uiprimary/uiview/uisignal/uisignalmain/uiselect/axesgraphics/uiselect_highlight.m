classdef uiselect_highlight < TComponent
    properties (Constant)
        Type        = 'hggroup'
    end
    properties
        ln_hover
        ln_selection
        ln_highlight
    end
    methods (Access = public)
        function updateuisign(obj)
            set(obj.ln_selection, ...
                'XData', obj.Data.cnfg.x(obj.Data.uisign.indices), ...
                'YData', obj.Data.cnfg.y(obj.Data.uisign.indices))
        end
        function updatecnfg(obj)
            set(obj.ln_hover, ...
                'XData', obj.Data.cnfg.x, ...
                'YData', obj.Data.cnfg.y)
        end
    end
    methods (Access = protected)
        function initialise(~)
            %uisignalmain_axes();
        end
        
        function mouseClick(obj)
            p = obj.CurrentPosition;
            x = obj.Data.cnfg.x;
            y = obj.Data.cnfg.y;
            
            diff = (x - p(1)).^2 + (y - p(2)).^2;
            [~, i] = min(diff);
            
            tf = false(obj.Data.cnfg.size);
            switch obj.Data.uisign.mode
                case 'i'
                    col = obj.Data.cnfg.i(i);
                    tf(:, col) = true;
                case 'j'
                    row = obj.Data.cnfg.j(i);
                    tf(row, :) = true;
                case 'free'
                    col = obj.Data.cnfg.i(i);
                    row = obj.Data.cnfg.j(i);
                    tf(row, col) = true;
            end
            obj.Data.uisign.setSelection(tf)
        end

        function traverseFcn(obj)
            p = obj.CurrentPosition;
            x = obj.Data.cnfg.x;
            y = obj.Data.cnfg.y;
            
            diff = (x - p(1)).^2 + (y - p(2)).^2;
            [~, i] = min(diff);
            
            switch obj.Data.uisign.mode
                case 'i'
                    col = obj.Data.cnfg.i(i);
                    i = find(obj.Data.cnfg.i == col);
                case 'j'
                    row = obj.Data.cnfg.j(i);
                    i = find(obj.Data.cnfg.j == row);
                case 'free'
            end

            set(obj.ln_highlight, ...
                'XData', x(i), ...
                'YData', y(i))
        end
        function exitFcn(obj)
            set(obj.ln_highlight, ...
                'XData', [], ...
                'YData', [])
        end
    end
    
    methods % CONSTRUCTOR
        function obj = uiselect_highlight()
            obj.ln_hover = line(obj.Handle, ...
                ... Line
                'LineStyle', 'none', ...
                'LineWidth', 1, ...
                ... Marker
                'Marker', 'o', ...
                'MarkerSize', 12, ...
                'MarkerFaceColor', 'none', ...
                'MarkerEdgeColor', [0.7 0.7 1.0], ...
                ... Data
                'XData', [], ...
                'YData', [], ...
                ... Callbacks
                'HitTest', 'off');
            obj.ln_selection = line(obj.Handle, ...
                ... Line
                'LineStyle', 'none', ...
                'LineWidth', 1, ...
                ... Marker
                'Marker', 'o', ...
                'MarkerSize', 12, ...
                'MarkerFaceColor', [0.7 0.7 1.0], ...
                'MarkerEdgeColor', 'none', ...
                ... Data
                'XData', [], ...
                'YData', [], ...
                ... Callbacks
                'PickableParts', 'none', ...
                'HitTest', 'off');
            obj.ln_highlight = line(obj.Handle, ...
                ... Line
                'LineStyle', 'none', ...
                'LineWidth', 1, ...
                ... Marker
                'Marker', 'o', ...
                'MarkerSize', 6, ...
                'MarkerFaceColor', [0.4 0.4 1.0], ...
                'MarkerEdgeColor', 'none', ...
                ... Data
                'XData', [], ...
                'YData', [], ...
                ... Callbacks
                'PickableParts', 'none', ...
                'HitTest', 'off');
        end
    end     % CONSTRUCTOR
end