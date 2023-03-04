classdef uitimeline_background < TComponent
    properties (Constant)
        Type = "hggroup"
    end
    properties (SetAccess = immutable)
        ln
    end
    properties (Access = private)
        tx
    end

    methods
        function updateprop(obj)
            d = obj.Data.prop.duration;
            w = obj.Data.uiprvw_timeline.width;
            n = ceil(d/w);

            % Background line
            x = repmat([0 w NaN], 1, n);
            x(end - 1) = rem(obj.Data.prop.duration, w);

            y = repelem(1:n, 3);
            
            i = 1:3:(n * 3);
            i(end + 1) = (n * 3) - 1;

            set(obj.ln, ...
                'XData', x, ...
                'YData', y, ...
                'MarkerIndices', i)

            % Text labels
            delete(allchild(obj.tx))
            
            s = ((1:n) - 1)' * (w/60);
            s = strcat(cellstr(num2str(s)), ' min');

            text(obj.tx, ...
                zeros(1, n), 1:n, s, ...
                ... Text
                'Color', [0.5 0.5 0.5], ...
                ... Font
                'FontSize', 8, ...
                'FontName', 'default', ...
                'FontWeight', 'normal', ...
                ... Position
                'HorizontalAlignment', 'left', ...
                'VerticalAlignment', 'bottom')
        end
    end
    methods % CONSTRUCTOR
        function obj = uitimeline_background()
            set(obj.Handle, ...
                'PickableParts', 'none')

            obj.ln = line(obj.Handle, ...
                ... Line
                'Color', [204 204 204]/256, ...
                'LineWidth', 1, ...
                'AlignVertexCenters', 'on', ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Marker
                'Marker', 'o', ...
                'MarkerSize', 3, ...
                'MarkerFaceColor', [204 204 204]/256);
            obj.tx = hggroup(obj.Handle);
        end
    end     % CONSTRUCTOR
end
