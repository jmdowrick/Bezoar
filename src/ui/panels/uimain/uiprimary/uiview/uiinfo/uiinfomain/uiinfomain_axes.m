classdef uiinfomain_axes < TComponent
    properties (Constant)
        Type = 'axes'
    end
    properties (SetAccess = immutable)
        rc
        cm
    end

    methods
        function updatecnfg(obj)
            sz = obj.Data.cnfg.size;
            if all(sz)
                set(obj.Handle, ...
                    'XLim', [0 sz(2) + 1], ...
                    'YLim', [0 sz(1) + 1])
            else
                set(obj.Handle, ...
                    'XLim', [0 1] + 0.5, ...
                    'YLim', [0 1] + 0.5)
            end
        end
    end
    methods (Access = protected)
        function initialise(~)
            uiinfomain_select();
            uiinfomain_trace();
            uiinfomain_vectors();
        end
        
        function traverseFcn(obj)
            cp = obj.CurrentPosition;
            sz = obj.Data.cnfg.size;

            if all(cp > 0.5 & cp < sz + 0.5)
                set(obj.rc, ...
                    'Position', [round(cp) - 0.5 1 1], ...
                    'Visible', 'on')
            else
                set(obj.rc, ...
                    'Visible', 'off')
            end
        end
        function exitFcn(obj)
            set(obj.rc, 'Visible', 'off')
        end
        
        function mouseScroll(obj)            
            sz = obj.Data.cnfg.size;
            cp = obj.CurrentPosition;

            if all(cp > 0.5 & cp < sz + 0.5)
                cp = round(cp);
                in = sub2ind(sz, cp(2), cp(1));

                at = obj.Data.uiprvw.at;
                
                if isfinite(at(in))
                    dt_small = 0.1;
                    dt_large = 0.2;

                    tf_small = ~obj.isAlt & ~obj.isCtrl & ~obj.isShift;
                    tf_large = ~obj.isAlt &  obj.isCtrl & ~obj.isShift;

                    if obj.ScrolledUnits == 0
                    elseif obj.ScrolledUnits > 0
                        if tf_small;   at(in) = at(in) + dt_small;   end
                        if tf_large;   at(in) = at(in) + dt_large;   end
                    elseif obj.ScrolledUnits < 0
                        if tf_small;   at(in) = at(in) - dt_small;   end
                        if tf_large;   at(in) = at(in) - dt_large;   end
                    end
                else
                    iw = interpolateWave(at);
                    at(in) = iw(in);
                end

                obj.Data.uiprvw.modifyWave(at)
            end
        end
    
        function mouseAxesClickRight(obj)
            set(obj.cm, ...
                'Visible', 'on', ...
                'Position', get(obj.Window, 'CurrentPoint'))
        end
        function mouseAxesClickMiddle(obj)
            sz = obj.Data.cnfg.size;
            cp = obj.CurrentPosition;

            if all(cp > 0.5 & cp < sz + 0.5)
                cp = round(cp);
                in = sub2ind(sz, cp(2), cp(1));

                at = obj.Data.uiprvw.at;
                at(in) = NaN;

                obj.Data.uiprvw.modifyWave(at)
            end
        end
    end
    methods (Access = private)
        function menuFcn(obj, e)
            switch e.Source.Text
                case 'Copy activation times...'
                    a = obj.Data.uiprvw.at;
                case 'Copy velocity speeds...'
                    a = obj.Data.uiinfo.velocities;
                case 'Copy velocity directions...'
                    a = obj.Data.uiinfo.directions;
                    a = wrapTo360(rad2deg(a));
            end

            % Convert to string
            a = string(a);

            % Replace invalid cells with empty strings
            a(ismissing(a)) = "";

            % Add tab character after each cell
            a(:, 1:end - 1) = strcat(a(:, 1:end - 1), {char(9)});

            % Add new line character after each row
            a(:, end) = strcat(a(:, end), {newline});

            % Convert string array to single char array
            a = reshape(a', 1, []);
            a = char(join(a));

            % Copy to clipboard
            clipboard("copy", a)
        end
    end
    methods
        function obj = uiinfomain_axes()
            set(obj.Handle, ...
                ... Ticks
                'XTick', [], ...
                'YTick', [], ...
                ... Rulers
                'XLim', [0.5 1.5], ...
                'YLim', [0.5 1.5], ...
                'YDir', 'reverse', ...
                ... Grids
                'YGrid', 'on', ...
                'GridColor', [0.15 0.15 0.15], ...
                ... Color and Transparency Maps
                'ALim', [0 1], ...
                ... Box Styling
                'Color', 'w', ...
                ... Position
                'DataAspectRatioMode', 'manual', ...
                'DataAspectRatio', [1 1 1])

            obj.rc = rectangle(obj.Handle, ...
                ... Color Styling
                'FaceColor', [128 128 128 032]/256, ...
                'EdgeColor', 'none', ...
                'LineWidth', 0.5, ...
                ... Position
                'Position', [0 0 1 1], ...
                ... Interactivity
                'Visible', 'off', ...
                ... Callback Execution Control
                'PickableParts', 'none');
            
            obj.cm = uicontextmenu(obj.Window);
            uimenu(obj.cm, ...
                'Text', 'Copy activation times...')
            uimenu(obj.cm, ...
                'Text', 'Copy velocity speeds...')
            uimenu(obj.cm, ...
                'Text', 'Copy velocity directions...')

            obj.addlistener(allchild(obj.cm), ...
                'Action', @(~, e)obj.menuFcn(e))
        end
    end
end

function w = interpolateWave(w)
tf = ~isnan(w);

[ir, ic] = find(tf);
F = scatteredInterpolant(ic, ir, w(tf), 'nearest', 'nearest');

[ir, ic] = find(~tf);
w(sub2ind(size(w), ir, ic)) = F([ic ir]);
end