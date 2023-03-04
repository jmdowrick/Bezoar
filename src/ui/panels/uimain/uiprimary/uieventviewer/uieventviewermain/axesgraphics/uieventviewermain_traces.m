classdef uieventviewermain_traces < TComponent
    properties (Constant)
        Type = 'hggroup'
    end
    properties (SetAccess = immutable)
        ln_p; ln_n; ln_e
    end

    methods
        function updatewave(obj)
            if obj.Data.wave.n
                waves = obj.Data.wave.waves;

                [nr, nc, ~] = size(waves);

                v = reshape(permute(waves, [1 2 3]), nr, []);
                h = reshape(permute(waves, [2 1 3]), nc, []);

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

                xp = [pv ph];   yp = [repmat(yt, 1, npv) repmat(yb, 1, nph)];
                xn = [nv nh];   yn = [repmat(yt, 1, nnv) repmat(yb, 1, nnh)];
                xe = [ev eh];   ye = [repmat(yt, 1, nev) repmat(yb, 1, neh)];
            else
                xp = [];   yp = [];
                xn = [];   yn = [];
                xe = [];   ye = [];
            end

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
        function updateuiview(obj)
            obj.updateTraceColours()
        end
        function updateuiprvw(obj)
            obj.updateTraceColours()
        end
    end
    methods (Access = private)
        function updateTraceColours(obj)
            switch obj.Data.uiview.viewname
                case 'maps'
                    set(obj.ln_p, ...
                        'Color', [224 224 256]/256)
                    set(obj.ln_n, ...
                        'Color', [256 224 224]/256)
                    set(obj.ln_e, ...
                        'Color', [256 224 256]/256)
                otherwise
                    if obj.Data.uiprvw.i
                        set(obj.ln_p, ...
                            'Color', [192 192 256]/256)
                        set(obj.ln_n, ...
                            'Color', [256 192 192]/256)
                        set(obj.ln_e, ...
                            'Color', [256 192 256]/256)
                    else
                        set(obj.ln_p, ...
                            'Color', [000 000 256]/256)
                        set(obj.ln_n, ...
                            'Color', [256 000 000]/256)
                        set(obj.ln_e, ...
                            'Color', [256 000 256]/256)
                    end
            end
        end
    end
    methods % CONSTRUCTOR
        function obj = uieventviewermain_traces()
            obj.ln_p = line(obj.Handle, ...
                ... Color
                'Color', [000 000 256]/256, ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Callback
                'PickableParts', 'none');
            obj.ln_n = line(obj.Handle, ...
                ... Color
                'Color', [256 000 000]/256, ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Callback
                'PickableParts', 'none');
            obj.ln_e = line(obj.Handle, ...
                ... Color
                'Color', [256 000 256]/256, ...
                ... Data
                'XData', double.empty(1,0), ...
                'YData', double.empty(1,0), ...
                ... Callbacks
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