classdef uieventviewermain_select_single < TComponent
    properties (Constant)
        Type = 'hggroup'
    end
    properties (SetAccess = immutable)
        rc; ln_p; ln_n; ln_e
    end

    methods
        function updateuiview(obj)
            switch obj.Data.uiview.viewname
                case 'maps'
                    set(obj.Handle, ...
                        'Visible', 'off')
                otherwise
                    set(obj.Handle, ...
                        'Visible', 'on')
            end
        end
        function updateuiprvw(obj)
            at = obj.Data.uiprvw.at;

            if any(at, "all")
                obj.updateSelected(at)
            else
                obj.updateClear()
            end
        end
    end
    methods (Access = private)
        function updateSelected(obj, at)
            [nr, nc] = size(at);

            v = reshape(permute(at, [1 2]), nr, []);
            h = reshape(permute(at, [2 1]), nc, []);

            dv = diff(v);
            dh = diff(h);

            [pv, npv] = findsegments(v, dv > 0);
            [ph, nph] = findsegments(h, dh > 0);
            [nv, nnv] = findsegments(v, dv < 0);
            [nh, nnh] = findsegments(h, dh < 0);
            [ev, nev] = findsegments(v, dv == 0);
            [eh, neh] = findsegments(h, dh == 0);

            yt = [-nr:-1 NaN];
            yb = [1:nc NaN];

            xp = [pv ph];
            xn = [nv nh];
            xe = [ev eh];

            yp = [repmat(yt, 1, npv) repmat(yb, 1, nph)];
            yn = [repmat(yt, 1, nnv) repmat(yb, 1, nnh)];
            ye = [repmat(yt, 1, nev) repmat(yb, 1, neh)];

            p = 1;
            x = min(at, [], "all") - p;
            w = range(at, "all") + 2 * p;

            set(obj.rc, ...
                'Position', [x -256 w 512], ...
                'FaceColor', [252 252 252 160]/256, ...
                'LineStyle', '-')
            set(obj.ln_p, ...
                'XData', xp, ...
                'YData', yp)
            set(obj.ln_n, ...
                'XData', xn, ...
                'YData', yn)
            set(obj.ln_e, ...
                'XData', xe, ...
                'YData', ye)
        end
        function updateClear(obj)
            set(obj.rc, ...
                'FaceColor', 'none', ...
                'LineStyle', 'none')
            set(obj.ln_p, ...
                'XData', [], ...
                'YData', [])
            set(obj.ln_n, ...
                'XData', [], ...
                'YData', [])
            set(obj.ln_e, ...
                'XData', [], ...
                'YData', [])
        end
    end
    methods % CONSTRUCTOR
        function obj = uieventviewermain_select_single()
            obj.rc = rectangle(obj.Handle, ...
                ... Color and Styling
                'FaceColor', [252 252 252 160]/256, ...
                'EdgeColor', [208 208 208 256]/256, ...
                'LineWidth', 2, ...
                'AlignVertexCenters', 'on', ...
                ... Position
                'Position', [-2 -2 1 4], ...
                ... Callback Execution Control
                'PickableParts', 'none');
            obj.ln_p = line(obj.Handle, ...
                ... Color
                'Color', [000 000 256]/256, ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Callback Execution Control
                'PickableParts', 'none');
            obj.ln_n = line(obj.Handle, ...
                ... Color
                'Color', [256 000 000]/256, ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Callback Execution Control
                'PickableParts', 'none');
            obj.ln_e = line(obj.Handle, ...
                ... Color
                'Color', [256 000 256]/256, ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Callbacks Execution Control
                'PickableParts', 'none');
        end
    end     % CONSTRUCTOR
end

function [p, n] = findsegments(v, tf)
d = diff(padarray(tf, [1 0], false, 'both'));

[is, t] = find(d == +1);
[ie, ~] = find(d == -1);

p = NaN(size(v, 1), length(t));

for i = 1:length(t)
    p(is(i):ie(i), i) = v(is(i):ie(i), t(i));
end

n = size(p, 2);
p = padarray(p, [1 0], NaN, 'post');
p = reshape(p, 1, []);
end