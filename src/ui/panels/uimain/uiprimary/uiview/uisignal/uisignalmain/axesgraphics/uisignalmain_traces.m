classdef uisignalmain_traces < TComponent
    properties (Constant)
        Type = "line"
    end
    
    methods
        function updateevnt(obj)
            obj.updateTraces()
        end
        function updateuisign_signals(obj)
            obj.updateTraces()
        end
        function updateuisign_settings(obj)
            switch obj.Data.uisign_settings.mode
                case 'default'
                    set(obj.Handle, ...
                        'Color', [000 000 256]/256, ...
                        'MarkerSize', 4, ...
                        'MarkerEdgeColor', [000 000 256]/256, ...
                        'MarkerFaceColor', [256 000 000]/256)
                case 'query'
                    set(obj.Handle, ...
                        'Color', [192 192 256]/256, ...
                        'MarkerSize', 4, ...
                        'MarkerEdgeColor', 'none', ...
                        'MarkerFaceColor', [256 192 192]/256)
                case 'edit'
                    set(obj.Handle, ...
                        'Color', [172 172 000]/256, ...
                        'MarkerSize', 4, ...
                        'MarkerEdgeColor', 'none', ...
                        'MarkerFaceColor', [172 080 000]/256)
            end
        end
    end
    methods (Access = private)
        function updateTraces(obj)
            nc = obj.Data.uisign.n;
            ns = obj.Data.filt.samples;

            i = obj.Data.uisign.indices;
            t = obj.Data.uisign_signals.time;
            s = obj.Data.uisign_signals.signals;

            x = [repmat(t, 1, nc); NaN(1, nc)];
            y = [s; NaN(1, nc)];

            v = find((i > 0) & (i <= obj.Data.prop.channels));
            e = obj.Data.evnt.e(:, i(v)) > 0;

            [t, c] = find(e);

            set(obj.Handle, ...
                'XData', x(:), ...
                'YData', y(:), ...
                'MarkerIndices', sub2ind([ns + 1, nc], t, v(c)'))
        end
    end
    methods % CONSTRUCTOR
        function obj = uisignalmain_traces()
            set(obj.Handle, ...
                ... Line
                'Color', [000 000 256]/256, ...
                ... Marker
                'Marker', 'o', ...
                'MarkerIndices', [], ...
                'MarkerSize', 4, ...
                'MarkerFaceColor', 'r', ...
                'MarkerEdgeColor', 'b', ...
                ... Callbacks
                'PickableParts', 'none')
        end
    end     % CONSTRUCTOR
end

function i = sub2ind(sz, r, c)
% Efficient version of sub2ind which forgoes no input validation or error
% generation.
i = r + sz(1).*(c - 1);
end