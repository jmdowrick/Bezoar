classdef uithumbs_images < TComponent
    properties (Constant)
        Type = "hggroup"
    end
    properties (Constant, Access = private)
        px = 3
        gd = 8
    end
    properties  (SetAccess = immutable)
        tx_wave; tx
        ln
        im          (1,:)   = gobjects(0)
    end

    methods
        function updateuiprvw_timeline(obj)
            p = getpixelposition(obj.Handle.Parent);
            w = obj.px * obj.gd;
            x = [(obj.px + w/2 + ((-1:2)*(w + obj.px))) ...
                p(3)/2 ...
                p(3) - (obj.px + w/2 + ((2:-1:-1)*(w + obj.px)))];
            d = mean(diff(x(3:5))) - (w + obj.px * 2);

            md = obj.Data.wave.medians;
            if isempty(md)
                return
            end

            n = obj.Data.wave.n;
            if isfinite(obj.Data.uiprvw_timeline.i)
                i = obj.Data.uiprvw_timeline.i;
                t = md(i);
            elseif isfinite(obj.Data.uiprvw_timeline.t)
                i = find(obj.Data.uiprvw_timeline.t <= [md Inf], 1, 'first');
                i = max(i - 1, 1);
                t = obj.Data.uiprvw_timeline.t;
                t = min(max(t, md(1)), md(end));
            elseif obj.Data.uiprvw.i == 0
                set(obj.Handle, 'Visible', 'off')
                return
            elseif isfinite(obj.Data.uiprvw.i)
                i = obj.Data.uiprvw.i;
                t = md(i);
            else
                i = 0;
                t = NaN;
            end
            set(obj.Handle, 'Visible', 'on')

            is = i + (-3:4);
            is(is < 1 | is > n) = NaN;
            ts = NaN(1, 9);
            ts(isfinite(is)) = md(is(isfinite(is)));

            d0 = diff(ts(3:4));
            d1 = diff(ts(4:5));
            d2 = diff(ts(5:6));

            x0 = x;
            if isnan(d0) || isnan(d1)
            elseif d0 > d1
                x0(6) = x(6) - min(round(d * d1/d0), d - 20);
            else
                x0(4) = x(4) + min(round(d * d0/d1), d - 20);
            end

            x1 = x;
            if isnan(d2) || isnan(d1)
            elseif d2 > d1
                x1(6) = x(6) - min(round(d * d2/d1), d - 20);
            else
                x1(4) = x(4) + min(round(d * d1/d2), d - 20);
            end

            if isnan(d1)
                x = x0(2:end);
            else
                x = x0(2:end) + (x1(1:end - 1) - x0(2:end))*((t - ts(4))/d1);
            end
            x(isnan(is)) = NaN;

            l = [1 obj.px*8] + [1 -1]*((obj.px + 1)/2 - 1);
            for i = 1:8
                if isfinite(is(i)) && isfinite(x(i))
                    at = obj.Data.wave.waves(:,:,is(i));
                    at = imresize(at, obj.gd * [1 1], 'bilinear', ...
                        'Antialiasing', false);
                    at = at - min(at, [], [1 2]);
                    at = at./range(at, 'all');

                    set(obj.im(i), ...
                        'CData', at, ...
                        'CDataMapping', 'scaled', ...
                        'AlphaData', isfinite(at), ...
                        'XData', l + x(i) - (w/2), ...
                        'YData', l + 20, ...
                        'Visible', 'on')
                    set(obj.tx_wave(i), ...
                        'Position', [x(i) 20], ...
                        'String', num2str(is(i)), ...
                        'Visible', 'on')
                else
                    set(obj.im(i), 'Visible', 'off')
                    set(obj.tx_wave(i), ...
                        'Visible', 'off')
                end
            end

            if t == ts(4)
                set(obj.ln, ...
                    'XData', [x(3) x(4) NaN x(4) x(5)] + d * [1 -1 0 1 -1], ...
                    'YData', 32 * ones(1, 5), ...
                    'Color', 'w')

                if isfinite(mean(x(3:4)))
                    set(obj.tx(1), ...
                        'Position', [mean(x(3:4)) 32], ...
                        'String', num2str(round(diff(md(is(3:4))), 1)) + " s")
                else
                    set(obj.tx(1), 'String', '')
                end
                if isfinite(mean(x(4:5)))
                    set(obj.tx(2), ...
                        'Position', [mean(x(4:5)) 32], ...
                        'String', num2str(round(diff(md(is(4:5))), 1)) + " s")
                else
                    set(obj.tx(2), 'String', '')
                end
            else
                set(obj.ln, ...
                    'XData', [x(4) x(5)] + d * [1 -1], ...
                    'YData', 32 * ones(1, 2), ...
                    'Color', 'w')
                set(obj.tx(1), ...
                    'String', '')
                set(obj.tx(2), ...
                    'Position', [mean(x(4:5)) 32], ...
                    'String', num2str(round(diff(md(is(4:5))), 1)) + " s")
            end
        end
    end
    methods
        function obj = uithumbs_images()
            obj.im = gobjects(1, 8);
            for i = 1:8
                obj.im(i) = image(obj.Handle, ...
                    'CData', []);
            end
            obj.ln = line(obj.Handle, ...
                0, 0, ...
                'Color', 'w');
            obj.tx = [ ...
                text(obj.Handle, ...
                0, 0, '', ...
                'Color', 'w', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'top', ...
                'FontSize', 8) ...
                ...
                text(obj.Handle, ...
                0, 0, '', ...
                'Color', 'w', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'top', ...
                'FontSize', 8) ...
                ];
            obj.tx_wave = text(obj.Handle, ...
                zeros(1, 8), zeros(1, 8), '', ...
                'Color', 0.75*ones(1,3), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'top', ...
                'FontSize', 8, ...
                'FontName', 'fixedwidth', ...
                'FontWeight', 'bold');
        end
    end
end