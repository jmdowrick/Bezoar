classdef uitimeline_text < TComponent
    properties (Constant)
        Type = "hggroup"
    end
    properties
        hg
        tx
    end
    methods
        function updatewave(obj)
            n = obj.Data.wave.n;
            c = length(obj.tx);
            if c < n
                obj.tx = [obj.tx; ...
                    text(obj.hg, ...
                    zeros(n - c, 1), zeros(n - c, 1), ...
                    cellstr(string(num2cell(c + 1:n)))', ...
                    ... Text
                    'Color', [096 096 096]/256, ...
                    ... Font
                    'FontSize', 8, ...
                    'FontName', 'FixedWidth', ...
                    'FontWeight', 'bold', ...
                    ... Position
                    'HorizontalAlignment', 'center')];
            end

            w = obj.Data.uiprvw_timeline.width;
            m = obj.Data.wave.medians';
            
            set(obj.tx(1:n), ...
                {'Position'}, num2cell([rem(m, w) ceil(m/w) + 0.3], 2), ...
                'Visible', 'on')
            set(obj.tx(n + 1:end), ...
                'Visible', 'off')
        end
    end
    methods % CONSTRUCTOR
        function obj = uitimeline_text()
            obj.hg = hggroup(obj.Handle, ...
                'HitTest', 'off', ...
                'PickableParts', 'none');
            obj.tx = gobjects(0);
        end
    end     % CONSTRUCTOR
end