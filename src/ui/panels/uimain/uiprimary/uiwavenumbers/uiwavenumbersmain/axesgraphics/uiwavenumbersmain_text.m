classdef uiwavenumbersmain_text < TComponent
    properties (Constant)
        Type = 'hggroup'
    end
    properties (SetAccess = immutable)
        hg; tx_h
    end
    properties (Access = private)
        tx
    end
    methods (Access = public)
        function update(obj)
            n = obj.Data.wave.n;
            c = length(obj.tx);
            if c < n
                obj.tx = [obj.tx; ...
                    text(obj.hg, ...
                    zeros(n - c, 1), zeros(n - c, 1), ...
                    cellstr(string(num2cell(c + 1:n)))', ...
                    ... Text
                    'Color', [128 128 128]/256, ...
                    ... Font
                    'FontSize', 8, ...
                    'FontName', 'FixedWidth', ...
                    'FontWeight', 'bold', ...
                    ... Text Box
                    'BackgroundColor', [232 232 232 128]/256, ...
                    ... Position
                    'HorizontalAlignment', 'center', ...
                    ... Callbacks
                    'HitTest', 'off')];
            end

            m = obj.Data.wave.medians;
            set(obj.tx(1:n), ...
                ... Position
                {'Position'}, num2cell([m' zeros(n, 1)], 2), ...
                'Visible', 'on')
            set(obj.tx(n + 1:end), ...
                'Visible', 'off')
        end
        function updatewave(obj)
            obj.update()
        end
    end
    methods (Access = protected)
        function mouseClick(obj)
            p = obj.CurrentPosition(1);
            m = obj.Data.wave.medians;
            [~, i] = min(abs(m - p));
            
            switch obj.Data.uiview.viewname
                case 'maps'
                    obj.Data.uimaps.setSelection(i)
                otherwise
                    if (i == obj.Data.uiprvw.i)
                        obj.Data.uiprvw.setWave(0)
                    else
                        obj.Data.uiprvw.setWave(i)
                    end
            end
        end

        function traverseFcn(obj)
            p = obj.CurrentPosition(1);
            m = obj.Data.wave.medians;
            [~, i] = min(abs(m - p));
            
            set(obj.tx_h, ...
                'String', num2str(i), ...
                'Position', [m(i) 0], ...
                'Visible', 'on')
        end
        function exitFcn(obj)
            set(obj.tx_h, ...
                'BackgroundColor', [128 128 128]/256, ...
                'Visible', 'off')
        end
    end
    methods % CONSTRUCTOR
        function obj = uiwavenumbersmain_text()
            obj.hg = hggroup(obj.Handle, ...
                'HitTest', 'off');
            obj.tx = gobjects(0);
            obj.tx_h = text(obj.Handle, ...
                    0, 0, '', ...
                    ... Text
                    'Color', [232 232 232]/256, ...
                    ... Font
                    'FontSize', 8, ...
                    'FontName', 'FixedWidth', ...
                    'FontWeight', 'bold', ...
                    ... Text Box
                    'BackgroundColor', [064 064 064]/256, ...
                    ... Position
                    'HorizontalAlignment', 'center', ...
                    ... Callbacks
                    'HitTest', 'off');
        end
    end
end